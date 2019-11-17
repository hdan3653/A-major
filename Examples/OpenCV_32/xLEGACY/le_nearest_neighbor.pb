IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, *keypoints1.CvSeq, *descriptors1.CvSeq, *keypoints2.CvSeq, *descriptors2.CvSeq, xmlTypeID.s, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Detects keypoints and computes SURF (Speeded-Up Robust Features) descriptors, " +
                  "finding the two nearest neighbors, but only returning the nearest if it is " +
                  "distinctly the better one." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Show/Hide keypoints."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          FileName.s = SaveFile()

          If FileName
            params.SAVE_INFO

            Select LCase(GetExtensionPart(FileName))
              Case "jpeg", "jpg", "jpe"
                params\paramId = #CV_IMWRITE_JPEG_QUALITY
                params\paramValue = 95
              Case "png"
                params\paramId = #CV_IMWRITE_PNG_COMPRESSION
                params\paramValue = 3
              Case "ppm", "pgm", "pbm"
                params\paramId = #CV_IMWRITE_PXM_BINARY
                params\paramValue = 1
              Default
                Select SelectedFilePattern()
                  Case 0
                    FileName + ".jpg"
                    params\paramId = #CV_IMWRITE_JPEG_QUALITY
                    params\paramValue = 95
                  Case 1
                    FileName + ".png"
                    params\paramId = #CV_IMWRITE_PNG_COMPRESSION
                    params\paramValue = 3
                  Case 2
                    FileName + ".ppm"
                    params\paramId = #CV_IMWRITE_PXM_BINARY
                    params\paramValue = 1
                EndSelect
            EndSelect
            cvSaveImage(FileName, *save, @params)
            cvSave("objects/box1_keypoints.xml", *keypoints1, xmlTypeID, #NULL$, #Null, #Null)
            cvSave("objects/box1_descriptors.xml", *descriptors1, xmlTypeID, #NULL$, #Null, #Null)
            cvSave("objects/box2_keypoints.xml", *keypoints2, xmlTypeID, #NULL$, #Null, #Null)
            cvSave("objects/box2_descriptors.xml", *descriptors2, xmlTypeID, #NULL$, #Null, #Null)
          EndIf
        Case 10
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
      EndSelect
    Case #WM_DESTROY
      exitCV = #True
  EndSelect
  ProcedureReturn CallWindowProc_(lpPrevWndFunc, hWnd, Msg, wParam, lParam)
EndProcedure

ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)
  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
  EndSelect
EndProcedure

ProcedureC.d CompareSURFDescriptors(*d1.FLOAT, *d2.FLOAT, best.d, length)
  If length % 4 = 0
    For i = 0 To length - 1 Step 12
      t0.d = PeekF(@*d1\f + i) - PeekF(@*d2\f + i)
      t1.d = PeekF(@*d1\f + i + 4) - PeekF(@*d2\f + i + 4)
      t2.d = PeekF(@*d1\f + i + 8) - PeekF(@*d2\f + i + 8)
      t3.d = PeekF(@*d1\f + i + 12) - PeekF(@*d2\f + i + 12)
      total_cost.d + t0 * t0 + t1 * t1 + t2 * t2 + t3 * t3

      If total_cost > best : Break : EndIf

    Next
  EndIf
  ProcedureReturn total_cost
EndProcedure

ProcedureC NaiveNearestNeighbor(*vec.FLOAT, laplacian, *model_keypoints.CvSeq, *model_descriptors.CvSeq)
  kreader.CvSeqReader
  reader.CvSeqReader
  cvStartReadSeq(*model_keypoints, @kreader, 0)
  cvStartReadSeq(*model_descriptors, @reader, 0)
  *kp.CvSURFPoint
  length = *model_descriptors\elem_size / SizeOf(FLOAT)
  dist1.d = 1000000
  dist2.d = 1000000
  neighbor = -1

  For i = 0 To *model_descriptors\total - 1
    *kp = kreader\ptr
    *mvec.FLOAT = reader\ptr
    CV_NEXT_SEQ_ELEM(kreader\seq\elem_size, kreader)
    CV_NEXT_SEQ_ELEM(reader\seq\elem_size, reader)

    If laplacian <> *kp\laplacian : Continue : EndIf

    d.d = CompareSURFDescriptors(*vec, *mvec, dist2, length)

    If d < dist1
      dist2 = dist1
      dist1 = d
      neighbor = i
    ElseIf d < dist2
      dist2 = d
    EndIf
  Next

  If dist1 < 0.365 * dist2 : ProcedureReturn neighbor : Else : ProcedureReturn -1 : EndIf

EndProcedure

ProcedureC FindPairs(*objectKeypoints.CvSeq, *objectDescriptors.CvSeq, *imageKeypoints.CvSeq, *imageDescriptors.CvSeq, Array ptpairs(1))
  kreader.CvSeqReader
  reader.CvSeqReader
  cvStartReadSeq(*objectKeypoints, @kreader, 0)
  cvStartReadSeq(*objectDescriptors, @reader, 0)
  *kp.CvSURFPoint

  For i = 0 To *objectDescriptors\total - 1
    *kp = kreader\ptr
    *descriptor.FLOAT = reader\ptr
    CV_NEXT_SEQ_ELEM(kreader\seq\elem_size, kreader)
    CV_NEXT_SEQ_ELEM(reader\seq\elem_size, reader)
    nearest_neighbor = NaiveNearestNeighbor(*descriptor, *kp\laplacian, *imageKeypoints, *imageDescriptors)

    If nearest_neighbor >= 0
      ReDim ptpairs(ArraySize(ptpairs()) + 2)
      ptpairs(ArraySize(ptpairs()) - 2) = i
      ptpairs(ArraySize(ptpairs()) - 1) = nearest_neighbor
    EndIf
  Next
EndProcedure

ProcedureC LocatePlanarObject(*objectKeypoints.CvSeq, *objectDescriptors.CvSeq, *imageKeypoints.CvSeq, *imageDescriptors.CvSeq, Array src_corners.CvPoint(1), Array dst_corners.CvPoint(1))
  Dim ptpairs(0)
  FindPairs(*objectKeypoints, *objectDescriptors, *imageKeypoints, *imageDescriptors, ptpairs())
  n = ArraySize(ptpairs()) / 2

  If n < 4 : ProcedureReturn 0 : EndIf

  *element1.CvSURFPoint
  *element2.CvSURFPoint
  Dim pt1.CvPoint2D32f(n)
  Dim pt2.CvPoint2D32f(n)

  For i = 0 To n - 1
    *element1 = cvGetSeqElem(*objectKeypoints, ptpairs(i * 2))
    *element2 = cvGetSeqElem(*imageKeypoints, ptpairs(i * 2 + 1))
    pt1(i)\x = *element1\pt\x
    pt1(i)\y = *element1\pt\y
    pt2(i)\x = *element2\pt\x
    pt2(i)\y = *element2\pt\y
  Next

  Dim h.d(9)
  *_h.CvMat = cvMat(3, 3, #CV_64F, h())
  *_pt1.CvMat = cvMat(1, n, CV_MAKETYPE(#CV_32F, 2), pt1())
  *_pt2.CvMat = cvMat(1, n, CV_MAKETYPE(#CV_32F, 2), pt2())

  If Not cvFindHomography(*_pt1, *_pt2, *_h, #CV_RANSAC, 5, 0) : ProcedureReturn 0 : EndIf

  For i = 0 To 4 - 1
    x_temp.d = src_corners(i)\x
    y_temp.d = src_corners(i)\y
    z.d = 1 / (h(6) * x_temp + h(7) * y_temp + h(8))
    x.d = (h(0) * x_temp + h(1) * y_temp + h(2)) * z
    y.d = (h(3) * x_temp + h(4) * y_temp + h(5)) * z
    dst_corners(i)\x = Round(x, #PB_Round_Nearest)
    dst_corners(i)\y = Round(y, #PB_Round_Nearest)
  Next
  ProcedureReturn 1
EndProcedure

ProcedureC OpenCV(ImageFile.s)
  If FileSize(ImageFile) > 0
    cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
    window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
    *window_name = cvGetWindowName(window_handle)
    lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(1, "Save")
      MenuBar()
      MenuItem(10, "Exit")
    EndIf
    hWnd = GetParent_(window_handle)
    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
    SendMessage_(hWnd, #WM_SETICON, 0, opencv)
    wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)
    SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))
    *image1.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_GRAYSCALE)
    *image2.IplImage = cvLoadImage("images/box2.png", #CV_LOAD_IMAGE_GRAYSCALE)
    cvResizeWindow(#CV_WINDOW_NAME, *image2\width, *image1\height + *image2\height)
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)
    *keypoints1.CvSeq
    *descriptors1.CvSeq
    *keypoints2.CvSeq
    *descriptors2.CvSeq
    *storage.CvMemStorage = cvCreateMemStorage(0)
    cvClearMemStorage(*storage)
    xmlTypeID.s = "JHPJHP"

    If FileSize("objects/box1_keypoints.xml") > 0 And FileSize("objects/box1_descriptors.xml") > 0
      *keypoints1 = cvLoad("objects/box1_keypoints.xml", *storage, @xmlTypeID, #Null)
      *descriptors1 = cvLoad("objects/box1_descriptors.xml", *storage, @xmlTypeID, #Null)
    Else
      cvExtractSURF(*image1, #Null, @*keypoints1, @*descriptors1, *storage, 0, 0, 500, 4, 6, #False)
    EndIf

    If FileSize("objects/box2_keypoints.xml") > 0 And FileSize("objects/box2_descriptors.xml") > 0
      *keypoints2 = cvLoad("objects/box2_keypoints.xml", *storage, @xmlTypeID, #Null)
      *descriptors2 = cvLoad("objects/box2_descriptors.xml", *storage, @xmlTypeID, #Null)
    Else
      cvExtractSURF(*image2, #Null, @*keypoints2, @*descriptors2, *storage, 0, 0, 500, 4, 6, #False)
    EndIf

    Dim src_corners.CvPoint(4)
    src_corners(0)\x = 0
    src_corners(0)\y = 0
    src_corners(1)\x = *image1\width
    src_corners(1)\y = 0
    src_corners(2)\x = *image1\width
    src_corners(2)\y = *image1\height
    src_corners(3)\x = 0
    src_corners(3)\y = *image1\height
    Dim dst_corners.CvPoint(4)
    *gray.IplImage = cvCreateImage(*image2\width, *image1\height + *image2\height, #IPL_DEPTH_8U, 1)
    cvSetZero(*gray)
    cvSetImageROI(*gray, 0, 0, *image1\width, *image1\height)
    cvCopy(*image1, *gray, #Null)
    cvSetImageROI(*gray, 0, *image1\height, *gray\width, *gray\height)
    cvCopy(*image2, *gray, #Null)
    cvResetImageROI(*gray)
    *color1.IplImage = cvCreateImage(*image2\width, *image1\height + *image2\height, #IPL_DEPTH_8U, 3)
    cvCvtColor(*gray, *color1, #CV_GRAY2BGR, 1)

    If LocatePlanarObject(*keypoints1, *descriptors1, *keypoints2, *descriptors2, src_corners(), dst_corners())
      r1.CvPoint
      r2.CvPoint

      For i = 0 To 4 - 1
        r1\x = dst_corners(i % 4)\x
        r1\y = dst_corners(i % 4)\y
        r2\x = dst_corners((i + 1) % 4)\x
        r2\y = dst_corners((i + 1) % 4)\y
        cvLine(*color1, r1\x, r1\y + *image1\height, r2\x, r2\y + *image1\height, 255, 0, 0, 0, 4, #CV_AA, #Null)
      Next
    EndIf

    Dim ptpairs(0)
    FindPairs(*keypoints1, *descriptors1, *keypoints2, *descriptors2, ptpairs())
    *r1.CvSURFPoint
    *r2.CvSURFPoint

    For i = 0 To ArraySize(ptpairs()) - 1 Step 2
      *r1 = cvGetSeqElem(*keypoints1, ptpairs(i))
      *r2 = cvGetSeqElem(*keypoints2, ptpairs(i + 1))
      x1 = Round(*r1\pt\x, #PB_Round_Nearest)
      y1 = Round(*r1\pt\y, #PB_Round_Nearest)
      x2 = Round(*r2\pt\x, #PB_Round_Nearest)
      y2 = Round(*r2\pt\y, #PB_Round_Nearest)

      If x2 < dst_corners(2 % 4)\x And y2 > dst_corners(1 % 4)\y
        cvLine(*color1, x1, y1, x2, y2 + *image1\height, 0, 255, 0, 0, 1, #CV_AA, #Null)
      EndIf
    Next
    *color2.IplImage = cvCloneImage(*color1)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *color1
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If *color1
        cvShowImage(#CV_WINDOW_NAME, *color1)
        keyPressed = cvWaitKey(0)

        If keyPressed =  32
          SURF ! #True

          If SURF
            *r.CvSURFPoint

            For i = 0 To *keypoints1\total
              *r = cvGetSeqElem(*keypoints1, i)
              size = *r\size
              
              If size < 25
                x = Round(*r\pt\x, #PB_Round_Nearest)
                y = Round(*r\pt\y, #PB_Round_Nearest)
                radius = Round(size * 1.2 / 9 * 2, #PB_Round_Nearest)
                cvCircle(*color1, x, y, radius, 0, 0, 255, 0, 1, #CV_AA, #Null)
              EndIf
            Next
          Else
            *color1 = cvCloneImage(*color2)
          EndIf
        EndIf
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseMemStorage(@*storage)    
    cvReleaseImage(@*color2)
    cvReleaseImage(@*color1)
    cvReleaseImage(@*gray)
    cvReleaseImage(@*image2)
    cvReleaseImage(@*image1)
    cvDestroyAllWindows()
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/box1.png")
; IDE Options = PureBasic 5.22 LTS (Windows - x86)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
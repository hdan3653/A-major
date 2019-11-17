IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Stitch together 2, 3, 4, and 5 images; based on the SIFT (Scale Invariant Feature Transform) algorithm." +
                  Chr(10) + Chr(10) + "- ENTER: Next set of images."

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

ProcedureC FindNearestPoints(*pA.FLOAT, laplacian, *model_keypoints.CvSeq, *model_descriptors.CvSeq, nSize)
  *pB.FLOAT
  *surf.CvSURFPoint
	nMatch = -1
	min1.d = 1000000
	min2.d = 1000000

	For rtnCount = 0 To *model_descriptors\total - 1
	  *pB = cvGetSeqElem(*model_descriptors, rtnCount)
	  *surf = cvGetSeqElem(*model_keypoints, rtnCount)

	  If laplacian <> *surf\laplacian : Continue : EndIf

	  sum.d = 0

	  For rtnNext = 0 To nSize - 1
	    sum + (PeekF(@*pA\f + rtnNext * 4) - PeekF(@*pB\f + rtnNext * 4)) * (PeekF(@*pA\f + rtnNext * 4) - PeekF(@*pB\f + rtnNext * 4))
	  Next

	  If sum < min1
			min2 = min1
			min1 = sum
			nMatch = rtnCount
		ElseIf sum < min2
		  min2 = sum
		EndIf
	Next

	If min1 < 0.2 * min2 : ProcedureReturn nMatch : Else : ProcedureReturn -1 : EndIf

EndProcedure

Structure MATCH_PAIR
  A.l
  B.l
EndStructure

ProcedureC FindMatchingPoints(*objectKeypoints.CvSeq, *objectDescriptors.CvSeq, *imageKeypoints.CvSeq, *imageDescriptors.CvSeq, nSize, Array MatchPair.MATCH_PAIR(1))
  *p.FLOAT
  *surf.CvSURFPoint

  For rtnCount = 0 To *objectDescriptors\total - 1
    *p = cvGetSeqElem(*objectDescriptors, rtnCount)
    *surf = cvGetSeqElem(*objectKeypoints, rtnCount)
    nMatch = FindNearestPoints(*p, *surf\laplacian, *imageKeypoints, *imageDescriptors, nSize)

    If nMatch > 0
      MatchPair(nCount)\A = rtnCount
			MatchPair(nCount)\B = nMatch
      nCount + 1
    EndIf
  Next
  ProcedureReturn nCount
EndProcedure

ProcedureC StitchImages(MatchCount, Array pt1.CvPoint2D32f(1), Array pt2.CvPoint2D32f(1), *image1.IplImage, *image2.IplImage)
  Dim H.d(9)
  *mxH.CvMat = cvMat(3, 3, #CV_64F, H())
  *M1.CvMat = cvMat(1, MatchCount, CV_MAKETYPE(#CV_32F, 2), pt1())
  *M2.CvMat = cvMat(1, MatchCount, CV_MAKETYPE(#CV_32F, 2), pt2())
  cvFindHomography(*M1, *M2, *mxH, #CV_RANSAC, 5, 0)
  *warp.IplImage = cvCreateImage(*image1\width + *image2\width * 2, *image1\height + *image2\height * 1.5, *image1\depth, *image1\nChannels)
  cvWarpPerspective(*image1, *warp, *mxH, #CV_INTER_LANCZOS4 | #CV_WARP_FILL_OUTLIERS, 0, 0, 0, 0)
  cvSetImageROI(*warp, 0, 0, *image2\width, *image2\height)
  cvCopy(*image2, *warp, #Null)
  cvResetImageROI(*warp)
  ProcedureReturn *warp
EndProcedure

ProcedureC FrameImage(*warp.IplImage)
  If *warp\nChannels = 1
    *gray.IplImage = cvCloneImage(*warp)
  Else
    *gray.IplImage = cvCreateImage(*warp\width, *warp\height, #IPL_DEPTH_8U, 1)
    cvCvtColor(*warp, *gray, #CV_BGR2GRAY, 1)
  EndIf
  cvThreshold(*gray, *gray, 1, 255, #CV_THRESH_BINARY)
  *storage.CvMemStorage = cvCreateMemStorage(0)
  cvClearMemStorage(*storage)
  *contours.CvSeq
  nContours = cvFindContours(*gray, *storage, @*contours, SizeOf(CvContour), #CV_RETR_EXTERNAL, #CV_CHAIN_APPROX_NONE, 0, 0)

  If nContours
    *poly.CvContour
    moments.CvMoments
    *element.CvPoint
    Dim pts.CvPoint(4)
    npts = ArraySize(pts())

    For rtnCount = 0 To nContours - 1
      area.d = cvContourArea(*contours, 0, #CV_WHOLE_SEQ_END_INDEX, 0)

      If area > 10000
        *poly = cvApproxPoly(*contours, SizeOf(CvContour), *storage, #CV_POLY_APPROX_DP, 100, 1)
        cvMoments(*contours, @moments, 0)
        cx.d = moments\m10 / area
        cy.d = moments\m01 / area
        pts(0)\x = cx
        pts(0)\y = cy
        pts(1)\x = cx
        pts(1)\y = cy
        pts(2)\x = cx
        pts(2)\y = cy
        pts(3)\x = cx
        pts(3)\y = cy

        For rtnPoint = 0 To *poly\total - 1
          *element = cvGetSeqElem(*poly, rtnPoint)

          If *element\x > pts(0)\x : pts(0)\x = *element\x : EndIf
          If *element\y > pts(0)\y : pts(0)\y = *element\y : EndIf
          If *element\x < pts(1)\x : pts(1)\x = *element\x : EndIf

          pts(1)\y = pts(0)\y
          pts(2)\x = pts(1)\x

          If *element\y < pts(2)\y : pts(2)\y = *element\y : EndIf
          If *element\x > pts(3)\x : pts(3)\x = *element\x : EndIf

          pts(3)\y = pts(2)\y
        Next
      EndIf
      *contours = *contours\h_next
    Next
    *frame.IplImage = cvCreateImage(pts(0)\x - pts(2)\x + 1, pts(0)\y - pts(2)\y + 1, #IPL_DEPTH_8U, *warp\nChannels)
    cvSetImageROI(*warp, pts(2)\x, pts(2)\y, pts(0)\x, pts(0)\y)
    cvCopy(*warp, *frame, #Null)
    cvResetImageROI(*warp)
    ProcedureReturn *frame
  EndIf
EndProcedure

ProcedureC EqualizeIntensity(*image.IplImage)
  Dim *channel.IplImage(3)
  *ycrcb.IplImage = cvCreateImage(*image\width, *image\height, #IPL_DEPTH_8U, *image\nChannels)
  *channel(0) = cvCreateImage(*image\width, *image\height, #IPL_DEPTH_8U, 1)
  *channel(1) = cvCreateImage(*image\width, *image\height, #IPL_DEPTH_8U, 1)
  *channel(2) = cvCreateImage(*image\width, *image\height, #IPL_DEPTH_8U, 1)
  *result.IplImage = cvCreateImage(*image\width, *image\height, #IPL_DEPTH_8U, *image\nChannels)
  cvCvtColor(*image, *ycrcb, #CV_BGR2YCrCb, 1)
  cvSplit(*ycrcb, *channel(0), *channel(1), *channel(2), #Null)
  cvEqualizeHist(*channel(0), *channel(0))
  cvMerge(*channel(0), *channel(1), *channel(2), #Null, *ycrcb)
  cvCvtColor(*ycrcb, *result, #CV_YCrCb2BGR, 1)
  cvReleaseImage(@*channel(2))
  cvReleaseImage(@*channel(1))
  cvReleaseImage(@*channel(0))
  cvReleaseImage(@*ycrcb)
  ProcedureReturn *result
EndProcedure

ProcedureC OpenCV(stitch)
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
  cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
  ToolTip(window_handle, #CV_DESCRIPTION)

  Select stitch + 2
    Case 2
      Dim *stitch.IplImage(2)
      *stitch(0) = cvLoadImage("images/stitch_2a_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(1) = cvLoadImage("images/stitch_2b_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    Case 3
      Dim *stitch.IplImage(3)
      *stitch(0) = cvLoadImage("images/stitch_3a_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(1) = cvLoadImage("images/stitch_3b_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(2) = cvLoadImage("images/stitch_3c_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    Case 4
      Dim *stitch.IplImage(4)
      *stitch(0) = cvLoadImage("images/stitch_4a_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(1) = cvLoadImage("images/stitch_4b_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(2) = cvLoadImage("images/stitch_4c_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(3) = cvLoadImage("images/stitch_4d_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    Case 5
      Dim *stitch.IplImage(5)
      *stitch(0) = cvLoadImage("images/stitch_5a_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(1) = cvLoadImage("images/stitch_5b_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(2) = cvLoadImage("images/stitch_5c_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(3) = cvLoadImage("images/stitch_5d_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *stitch(4) = cvLoadImage("images/stitch_5e_images.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
  EndSelect
  *keypoints1.CvSeq
  *descriptors1.CvSeq
  *keypoints2.CvSeq
  *descriptors2.CvSeq
  *storage.CvMemStorage = cvCreateMemStorage(0)
  cvClearMemStorage(*storage)
  #PARAMS_EXTENDED = 0
  #PARAMS_THRESHOLD = 500

  If #PARAMS_EXTENDED : nSize = 128 : Else : nSize = 64 : EndIf

  *surf1.CvSURFPoint
  *surf2.CvSURFPoint
  *warp.IplImage

  For rtnCount = 0 To ArraySize(*stitch()) - 2
    BringToTop(hWnd)
    cvShowImage(#CV_WINDOW_NAME, *stitch(rtnCount))
    keyPressed = cvWaitKey(100)

    If keyPressed <> 13 And keyPressed <> 27 And exitCV = #False
      If rtnCount = 0 : *warp = *stitch(rtnCount) : EndIf

      cvExtractSURF(*warp, #Null, @*keypoints1, @*descriptors1, *storage, #PARAMS_EXTENDED, 0, #PARAMS_THRESHOLD, 4, 2, #False)
      cvExtractSURF(*stitch(rtnCount + 1), #Null, @*keypoints2, @*descriptors2, *storage, #PARAMS_EXTENDED, 0, #PARAMS_THRESHOLD, 4, 2, #False)
      Dim MatchPair.MATCH_PAIR(*keypoints1\total)
      MatchCount = FindMatchingPoints(*keypoints1, *descriptors1, *keypoints2, *descriptors2, nSize, MatchPair())

      If MatchCount < 4 : Break : EndIf

      If rtnCount = ArraySize(*stitch()) - 2
        BringToTop(hWnd)
        cvShowImage(#CV_WINDOW_NAME, *stitch(rtnCount + 1))
        keyPressed = cvWaitKey(1000)
      EndIf

      Dim pt1.CvPoint2D32f(MatchCount)
      Dim pt2.CvPoint2D32f(MatchCount)

      For rtnPoint = 0 To MatchCount - 1
        *surf1 = cvGetSeqElem(*keypoints1, MatchPair(rtnPoint)\A)
        *surf2 = cvGetSeqElem(*keypoints2, MatchPair(rtnPoint)\B)
      	pt1(rtnPoint) = *surf1\pt
      	pt2(rtnPoint) = *surf2\pt
      Next
      *warp = StitchImages(MatchCount, pt1(), pt2(), *warp, *stitch(rtnCount + 1))
    Else
      Break
    EndIf
  Next

  If keyPressed <> 13 And keyPressed <> 27 And exitCV = #False
    If MatchCount >= 4
      *frame.IplImage = FrameImage(*warp)
      dtWidth = DesktopWidth(0)
      dtHeight = DesktopHeight(0)

      If *frame\width >= dtWidth - 100 Or *frame\height >= dtHeight - 100
        iWidth = dtWidth - 100
        iRatio1.d = iWidth / *frame\width
        iHeight = dtHeight - 100
        iRatio2.d = iHeight / *frame\height

        If iRatio1 < iRatio2
          iWidth = *frame\width * iRatio1
          iHeight = *frame\height * iRatio1
        Else
          iWidth = *frame\width * iRatio2
          iHeight = *frame\height * iRatio2
        EndIf
        cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight)
        *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *frame\nChannels)
        cvResize(*frame, *resize, #CV_INTER_AREA)
      Else
        cvResizeWindow(#CV_WINDOW_NAME, *frame\width, *frame\height)
        *resize.IplImage = cvCloneImage(*frame)
      EndIf
      font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)

      Select stitch + 2
        Case 2
          cvPutText(*resize, "Stitched 2 Images.", 10, 40, @font, 0, 0, 255, 0)
        Case 3
          cvPutText(*resize, "Stitched 3 Images.", 10, 40, @font, 0, 0, 255, 0)
        Case 4
          cvPutText(*resize, "Stitched 4 Images.", 10, 40, @font, 0, 0, 255, 0)
        Case 5
          cvPutText(*resize, "Stitched 5 Images.", 10, 40, @font, 0, 0, 255, 0)
      EndSelect
      BringToTop(hWnd)
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *frame
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *resize
          cvShowImage(#CV_WINDOW_NAME, *resize)
          keyPressed = cvWaitKey(0)
        EndIf
      Until keyPressed = 13 Or keyPressed = 27 Or exitCV
      FreeMemory(*param)
    Else
      MessageBox_(0, "There were not enough matching points returned to stitch the " + Str(stitch + 2) + " images together.", #CV_WINDOW_NAME, #MB_ICONERROR)
    EndIf
  EndIf
  cvReleaseMemStorage(@*storage)
  cvReleaseImage(@*resize)
  cvReleaseImage(@*frame)
  cvReleaseImage(@*warp)

  For rtnCount = 0 To ArraySize(*stitch()) - 1
    cvReleaseImage(@*stitch(rtnCount))
  Next
  cvDestroyAllWindows()

  If keyPressed = 13
    exitCV = #False
    stitch = (stitch + 1) % 4
    OpenCV(stitch)
  EndIf
EndProcedure
nonfree2411 = OpenLibrary(#PB_Any, "opencv_nonfree2411.dll")
ExamineDesktops()
OpenCV(0)
CloseLibrary(nonfree2411)
; IDE Options = PureBasic 5.40 LTS (Windows - x64)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
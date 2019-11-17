IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc, hWnd_stitch

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Stitch together 2 images in stages; based on the SIFT (Scale Invariant Feature Transform) algorithm." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Start next stage." +
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
      SendMessage_(hWnd_stitch, #WM_CLOSE, 0, 0)
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

ProcedureC MergeImages(*stitch1.IplImage, *stitch2.IplImage, *merge.IplImage)
  cvSet(*merge, 255, 255, 255, 0, #Null)
  cvSetImageROI(*merge, 0, 0, *stitch1\width, *stitch1\height)
  cvSetImageCOI(*merge, 1)
  cvCopy(*stitch1, *merge, #Null)
  cvSetImageCOI(*merge, 2)
  cvCopy(*stitch1, *merge, #Null)
  cvSetImageCOI(*merge, 3)
  cvCopy(*stitch1, *merge, #Null)
  cvSetImageROI(*merge, *stitch1\width, 0, *stitch2\width, *stitch2\height)
  cvSetImageCOI(*merge, 1)
  cvCopy(*stitch2, *merge, #Null)
  cvSetImageCOI(*merge, 2)
  cvCopy(*stitch2, *merge, #Null)
  cvSetImageCOI(*merge, 3)
  cvCopy(*stitch2, *merge, #Null)
  cvResetImageROI(*merge)
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

ProcedureC OpenCV(ImageFile.s, stitch)
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
    dtWidth = DesktopWidth(0)
    dtHeight = DesktopHeight(0)

    If *image1\width * 2 >= dtWidth - 100 Or *image1\height >= dtHeight - 100
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / (*image1\width * 2)
      iHeight = dtHeight - 100
      iRatio2.d = iHeight / *image1\height

      If iRatio1 < iRatio2
        iWidth = *image1\width * iRatio1
        iHeight = *image1\height * iRatio1
      Else
        iWidth = *image1\width * iRatio2
        iHeight = *image1\height * iRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight)
      *resize1.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image1\nChannels)
      cvResize(*image1, *resize1, #CV_INTER_AREA)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, *image1\width, *image1\height)
      *resize1.IplImage = cvCloneImage(*image1)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)
    cvNamedWindow(#CV_WINDOW_NAME + " - Stitching", #CV_WINDOW_AUTOSIZE)
    hWnd_stitch = GetParent_(cvGetWindowHandle(#CV_WINDOW_NAME + " - Stitching"))
    SendMessage_(hWnd_stitch, #WM_SETICON, 0, opencv)
    wStyle = GetWindowLongPtr_(hWnd_stitch, #GWL_STYLE)
    SetWindowLongPtr_(hWnd_stitch, #GWL_STYLE, wStyle & ~(#WS_SYSMENU | #WS_MAXIMIZEBOX | #WS_SIZEBOX))
    cvResizeWindow(#CV_WINDOW_NAME + " - Stitching", *resize1\width, *resize1\height)
    cvMoveWindow(#CV_WINDOW_NAME + " - Stitching", *resize1\width + 50, 20)
    *stitch1.IplImage = cvCreateImage(*resize1\width, *resize1\height, #IPL_DEPTH_8U, 3)
    cvCvtColor(*resize1, *stitch1, #CV_GRAY2BGR, 1)
    *image2.IplImage = cvLoadImage("images/stitch" + Str(stitch + 1) + "b.jpg", #CV_LOAD_IMAGE_GRAYSCALE)
    *resize2.IplImage = cvCreateImage(*resize1\width, *resize1\height, #IPL_DEPTH_8U, *resize1\nChannels)
    cvResize(*image2, *resize2, #CV_INTER_AREA)
    *stitch2.IplImage = cvCreateImage(*resize1\width, *resize1\height, #IPL_DEPTH_8U, 3)
    cvCvtColor(*resize2, *stitch2, #CV_GRAY2BGR, 1)
    BringToTop(hWnd)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *resize1
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      cvShowImage(#CV_WINDOW_NAME, *resize1)
      cvShowImage(#CV_WINDOW_NAME + " - Stitching", *resize2)
      keypressed = cvWaitKey(0)
    Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 32 Or exitCV

    If keyPressed = 32
      *keypoints1.CvSeq
      *descriptors1.CvSeq
      *keypoints2.CvSeq
      *descriptors2.CvSeq
      *storage.CvMemStorage = cvCreateMemStorage(0)
      cvClearMemStorage(*storage)
      cvExtractSURF(*resize1, #Null, @*keypoints1, @*descriptors1, *storage, 0, 0, 300, 4, 2, #False)
      *surf1.CvSURFPoint

      For rtnCount = 0 To *keypoints1\total - 1
        *surf1 = cvGetSeqElem(*keypoints1, rtnCount)
        size = *surf1\size

        If size < 15
          radius = size / 2
          cvCircle(*stitch1, *surf1\pt\x, *surf1\pt\y, radius, 0, 255, 0, 0, 1, #CV_AA, #Null)
    		  cvLine(*stitch1, *surf1\pt\x + radius, *surf1\pt\y + radius, *surf1\pt\x - radius, *surf1\pt\y - radius, 0, 0, 255, 0, 1, #CV_AA, #Null)
          cvLine(*stitch1, *surf1\pt\x - radius, *surf1\pt\y + radius, *surf1\pt\x + radius, *surf1\pt\y - radius, 0, 0, 255, 0, 1, #CV_AA, #Null)
        EndIf
      Next
      cvExtractSURF(*resize2, #Null, @*keypoints2, @*descriptors2, *storage, 0, 0, 300, 4, 2, #False)
      *surf2.CvSURFPoint

      For rtnCount = 0 To *keypoints2\total - 1
        *surf2 = cvGetSeqElem(*keypoints2, rtnCount)
        size = *surf2\size

        If size < 15
          radius = size / 2
          radius = *surf2\size / 2
          cvCircle(*stitch2, *surf2\pt\x, *surf2\pt\y, radius, 0, 255, 0, 0, 1, #CV_AA, #Null)
    		  cvLine(*stitch2, *surf2\pt\x + radius, *surf2\pt\y + radius, *surf2\pt\x - radius, *surf2\pt\y - radius, 255, 0, 0, 0, 1, #CV_AA, #Null)
          cvLine(*stitch2, *surf2\pt\x - radius, *surf2\pt\y + radius, *surf2\pt\x + radius, *surf2\pt\y - radius, 255, 0, 0, 0, 1, #CV_AA, #Null)
        EndIf
      Next
      BringToTop(hWnd)
      *param\uPointer1 = *stitch1

      Repeat
        cvShowImage(#CV_WINDOW_NAME, *stitch1)
        cvShowImage(#CV_WINDOW_NAME + " - Stitching", *stitch2)
        keypressed = cvWaitKey(0)
      Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 32 Or exitCV
      cvDestroyWindow(#CV_WINDOW_NAME + " - Stitching")

      If keyPressed = 32
        *merge.IplImage = cvCreateImage(*resize1\width + *resize2\width, *resize1\height, #IPL_DEPTH_8U, 3)
        MergeImages(*resize1, *resize2, *merge)
        cvResizeWindow(#CV_WINDOW_NAME, *merge\width, *merge\height)
        BringToTop(hWnd)
        *param\uPointer1 = *merge

        Repeat
          cvShowImage(#CV_WINDOW_NAME, *merge)
          keypressed = cvWaitKey(0)
        Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 32 Or exitCV

        If keyPressed = 32
          BringToTop(hWnd)
          font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
          cvPutText(*merge, "Working...", 20, 40, @font, 0, 0, 255, 0)
          cvShowImage(#CV_WINDOW_NAME, *merge)
          cvWaitKey(10)
          Dim MatchPair.MATCH_PAIR(*keypoints1\total)
          MatchCount = FindMatchingPoints(*keypoints1, *descriptors1, *keypoints2, *descriptors2, 64, MatchPair())
          Dim pt1.CvPoint2D32f(MatchCount)
          Dim pt2.CvPoint2D32f(MatchCount)

          For rtnCount = 0 To MatchCount - 1
            *surf1 = cvGetSeqElem(*keypoints1, MatchPair(rtnCount)\A)
            x1 = Round(*surf1\pt\x, #PB_Round_Nearest)
            y1 = Round(*surf1\pt\y, #PB_Round_Nearest)
            *surf2 = cvGetSeqElem(*keypoints2, MatchPair(rtnCount)\B)
        		x2 = Round(*surf2\pt\x, #PB_Round_Nearest) + *resize1\width
        		y2 = Round(*surf2\pt\y, #PB_Round_Nearest)

            If *surf1\size < 50 And *surf2\size < 50
              cvLine(*merge, x1, y1, x2, y2, Random(255), Random(255), Random(255), 0, 1, #CV_AA, #Null)
            EndIf
        		pt1(rtnCount) = *surf1\pt
        		pt2(rtnCount) = *surf2\pt
        	Next
        	BringToTop(hWnd)

        	If MatchCount >= 4
        	  cvPutText(*merge, "Ready.", 200, 40, @font, 0, 0, 255, 0)

        	  Repeat
          	  cvShowImage(#CV_WINDOW_NAME, *merge)
          	  keypressed = cvWaitKey(0)
          	Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 32 Or exitCV
        	Else
        	  cvPutText(*merge, "Not enough matching points.", 200, 40, @font, 0, 0, 255, 0)

        	  Repeat
          	  cvShowImage(#CV_WINDOW_NAME, *merge)
          	  keypressed = cvWaitKey(0)
          	Until keyPressed = 13 Or keyPressed = 27 Or exitCV
        	EndIf

      		If keyPressed = 32
            Dim H.d(9)
            *mxH.CvMat = cvMat(3, 3, #CV_64F, H())
          	*M1.CvMat = cvMat(1, MatchCount, CV_MAKETYPE(#CV_32F, 2), pt1())
          	*M2.CvMat = cvMat(1, MatchCount, CV_MAKETYPE(#CV_32F, 2), pt2())

          	If cvFindHomography(*M1, *M2, *mxH, #CV_RANSAC, 5, 0)
          	  *temp1.IplImage = cvLoadImage("images/stitch" + Str(stitch + 1) + "a.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
          	  *temp2.IplImage = cvLoadImage("images/stitch" + Str(stitch + 1) + "b.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
          	  *color1.IplImage = cvCreateImage(*resize1\width, *resize1\height, #IPL_DEPTH_8U, 3)
          	  *color2.IplImage = cvCreateImage(*resize2\width, *resize2\height, #IPL_DEPTH_8U, 3)
          	  cvResize(*temp1, *color1, #CV_INTER_AREA)
          	  cvResize(*temp2, *color2, #CV_INTER_AREA)
          	  *warp.IplImage = cvCreateImage(*color1\width + *color2\width, *color1\height + *color2\height, #IPL_DEPTH_8U, *color1\nChannels)
          	  cvWarpPerspective(*color1, *warp, *mxH, #CV_INTER_LANCZOS4 | #CV_WARP_FILL_OUTLIERS, 0, 0, 0, 0)
          	  cvSetImageROI(*warp, 0, 0, *color2\width, *color2\height)
        	    cvCopy(*color2, *warp, #Null)
        	    cvResetImageROI(*warp)
        	    *frame.IplImage = FrameImage(*warp)
        	    BringToTop(hWnd)
        	    *param\uPointer1 = *frame

              Repeat
                If *frame
                  cvShowImage(#CV_WINDOW_NAME, *frame)
                  keyPressed = cvWaitKey(0)
                EndIf
              Until keyPressed = 13 Or keyPressed = 27 Or exitCV
              FreeMemory(*param)
              cvReleaseImage(@*frame)
              cvReleaseImage(@*color2)
              cvReleaseImage(@*color1)
              cvReleaseImage(@*temp2)
              cvReleaseImage(@*temp1)
            EndIf
            cvReleaseImage(@*warp)
          EndIf
        EndIf
        cvReleaseImage(@*merge)
      EndIf
      cvReleaseMemStorage(@*storage)
    EndIf
    cvReleaseImage(@*stitch2)
    cvReleaseImage(@*resize2)
    cvReleaseImage(@*image2)
    cvReleaseImage(@*stitch1)
    cvReleaseImage(@*resize1)
    cvReleaseImage(@*image1)
    cvDestroyAllWindows()

    If keyPressed = 13
      exitCV = #False
      stitch = (stitch + 1) % 2
      OpenCV("images/stitch" + Str(stitch + 1) + "a.jpg", stitch)
    EndIf
  EndIf
EndProcedure

nonfree2411 = OpenLibrary(#PB_Any, "opencv_nonfree2411.dll")
ExamineDesktops()
OpenCV("images/stitch1a.jpg", 0)
CloseLibrary(nonfree2411)
; IDE Options = PureBasic 5.40 LTS (Windows - x64)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
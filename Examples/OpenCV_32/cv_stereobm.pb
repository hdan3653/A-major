IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc, hWnd_stereo

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Computes disparity using the BM (Block Matching) algorithm for a rectified stereo pair of images." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Adjust threshold to filter out objects based on depth."

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
      SendMessage_(hWnd_stereo, #WM_CLOSE, 0, 0)
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
    cvNamedWindow(#CV_WINDOW_NAME + " - StereoBM", #CV_WINDOW_AUTOSIZE)
    hWnd_stereo = GetParent_(cvGetWindowHandle(#CV_WINDOW_NAME + " - StereoBM"))
    SendMessage_(hWnd_stereo, #WM_SETICON, 0, opencv)
    wStyle = GetWindowLongPtr_(hWnd_stereo, #GWL_STYLE)
    SetWindowLongPtr_(hWnd_stereo, #GWL_STYLE, wStyle & ~(#WS_SYSMENU | #WS_MAXIMIZEBOX | #WS_SIZEBOX))
    cvResizeWindow(#CV_WINDOW_NAME + " - StereoBM", *resize1\width, *resize1\height)
    cvMoveWindow(#CV_WINDOW_NAME + " - StereoBM", *resize1\width + 50, 20)
    *image2.IplImage = cvLoadImage("images/scene_right.png", #CV_LOAD_IMAGE_GRAYSCALE)
    *resize2.IplImage = cvCreateImage(*resize1\width, *resize1\height, #IPL_DEPTH_8U, *resize1\nChannels)
    cvResize(*image2, *resize2, #CV_INTER_AREA)
    *disparity.CvMat = cvCreateMat(*resize1\height, *resize1\width, CV_MAKETYPE(#CV_16S, 1))
    *visual.CvMat = cvCreateMat(*resize1\height, *resize1\width, CV_MAKETYPE(#CV_8U, 1))
    *stereo.CvMat = cvCreateMat(*resize1\height, *resize1\width, CV_MAKETYPE(#CV_8U, 1))
    *state.CvStereoBMState = cvCreateStereoBMState(#CV_STEREO_BM_BASIC, 16)
    cvFindStereoCorrespondenceBM(*resize1, *resize2, *disparity, *state)
    cvConvertScale(*disparity, *visual, 1, 0)
    scalar.CvScalar
    threshold = 70
    *stereo = cvCloneImage(*resize1)
    BringToTop(hWnd)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *stereo
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If *resize1
        If keypressed = 32 And threshold > 70
          For y = 0 To *resize1\height - 1
            For x = 0 To *resize1\width - 1
              If cvGetReal2D(*visual, y, x) > threshold
                cvGet2D(@scalar, *resize1, y, x)
                cvSet2D(*stereo, y, x, scalar\val[0], scalar\val[1], scalar\val[2], 0)
              Else
                cvSet2D(*stereo, y, x, 128, 128, 128, 0)
              EndIf
            Next
          Next
        EndIf
        cvShowImage(#CV_WINDOW_NAME, *resize2)
        cvShowImage(#CV_WINDOW_NAME + " - StereoBM", *stereo)
        keypressed = cvWaitKey(0)

        If keypressed = 32
          If threshold >= 190
            threshold = 70
            cvReleaseImage(@*stereo)
            *stereo = cvCloneImage(*resize1)
          Else
            If threshold >= 110 : threshold + 40 : Else : threshold + 20 : EndIf
          EndIf
        EndIf
      EndIf
    Until keyPressed = 27 Or exitCV
    cvReleaseStereoBMState(@*state)
    cvReleaseMat(@*visual)
    cvReleaseMat(@*disparity)
    cvReleaseImage(@*resize2)
    cvReleaseImage(@*image2)
    cvReleaseImage(@*resize1)
    cvReleaseImage(@*image1)
    cvDestroyAllWindows()
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/scene_left.png")
; IDE Options = PureBasic 5.31 Beta 4 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
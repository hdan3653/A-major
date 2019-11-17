IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Alpha blend multiple images to simulate face morphing."

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
    *image.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    dtWidth = DesktopWidth(0)
    dtHeight = DesktopHeight(0)

    If *image\width >= dtWidth - 100 Or *image\height >= dtHeight - 100
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / *image\width
      iHeight = dtHeight - 100
      iRatio2.d = iHeight / *image\height

      If iRatio1 < iRatio2
        iWidth = *image\width * iRatio1
        iHeight = *image\height * iRatio1
      Else
        iWidth = *image\width * iRatio2
        iHeight = *image\height * iRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight)
      *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image\nChannels)
      cvResize(*image, *resize, #CV_INTER_AREA)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
      *resize.IplImage = cvCloneImage(*image)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)
    *overlay1.IplImage = cvLoadImage("images/weight2.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    *overlay2.IplImage = cvLoadImage("images/weight3.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    *overlay3.IplImage = cvLoadImage("images/weight4.jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    *blend.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 3)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *blend
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If *blend        
        For rtnCount = 0 To 100 - 1
          alpha.d = rtnCount / 100
          beta.d = 1 - alpha
          cvAddWeighted(*overlay1, alpha, *resize, beta, 0, *blend)
          cvShowImage(#CV_WINDOW_NAME, *blend)
          keyPressed = cvWaitKey(50)

          If keyPressed = 27 Or exitCV : Break 2 : EndIf

        Next

        For rtnCount = 0 To 100 - 1
          alpha.d = rtnCount / 100
          beta.d = 1 - alpha
          cvAddWeighted(*overlay2, alpha, *overlay1, beta, 0, *blend)
          cvShowImage(#CV_WINDOW_NAME, *blend)
          keyPressed = cvWaitKey(50)

          If keyPressed = 27 Or exitCV : Break 2 : EndIf

        Next

        For rtnCount = 0 To 100 - 1
          alpha.d = rtnCount / 100
          beta.d = 1 - alpha
          cvAddWeighted(*overlay3, alpha, *overlay2, beta, 0, *blend)
          cvShowImage(#CV_WINDOW_NAME, *blend)
          keyPressed = cvWaitKey(50)

          If keyPressed = 27 Or exitCV : Break 2 : EndIf

        Next

        For rtnCount = 0 To 100 - 1
          alpha.d = rtnCount / 100
          beta.d = 1 - alpha
          cvAddWeighted(*overlay2, alpha, *overlay3, beta, 0, *blend)
          cvShowImage(#CV_WINDOW_NAME, *blend)
          keyPressed = cvWaitKey(50)

          If keyPressed = 27 Or exitCV : Break 2 : EndIf

        Next

        For rtnCount = 0 To 100 - 1
          alpha.d = rtnCount / 100
          beta.d = 1 - alpha
          cvAddWeighted(*overlay1, alpha, *overlay2, beta, 0, *blend)
          cvShowImage(#CV_WINDOW_NAME, *blend)
          keyPressed = cvWaitKey(50)

          If keyPressed = 27 Or exitCV : Break 2 : EndIf

        Next

        For rtnCount = 0 To 100 - 1
          alpha.d = rtnCount / 100
          beta.d = 1 - alpha
          cvAddWeighted(*resize, alpha, *overlay1, beta, 0, *blend)
          cvShowImage(#CV_WINDOW_NAME, *blend)
          keyPressed = cvWaitKey(50)

          If keyPressed = 27 Or exitCV : Break 2 : EndIf

        Next
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseImage(@*blend)
    cvReleaseImage(@*overlay3)
    cvReleaseImage(@*overlay2)
    cvReleaseImage(@*overlay1)
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/weight1.jpg")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
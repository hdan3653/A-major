IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, hWnd_floodfill, nFlags, nLoDiff, nUpDiff

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Demonstration of the FloodFill function, filling a connected component with a given color." + Chr(10) + Chr(10) +
                  "- TRACKBAR 1: Maximal lower color / brightness difference between pixels." + Chr(10) + Chr(10) +
                  "- TRACKBAR 2: Maximal upper color / brightness difference between pixels." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Toggle connectivity." + Chr(10) + Chr(10) +
                  "- ENTER: Reset images." + Chr(10) + Chr(10) +
                  "- [ F ] KEY: Toggle Fixed / Floating."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          getCV = #True
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
        Case 2
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
      SendMessage_(hWnd_floodfill, #WM_CLOSE, 0, 0)
      exitCV = #True
  EndSelect
  ProcedureReturn CallWindowProc_(lpPrevWndFunc, hWnd, Msg, wParam, lParam)
EndProcedure

ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)
  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      cvThreshold(*param\uPointer2, *param\uPointer2, 1, 128, #CV_THRESH_BINARY)
      comp.CvConnectedComp
      cvFloodFill(*param\uPointer1, x, y, Random(255), Random(255), Random(255), 0, nLoDiff, nLoDiff, nLoDiff, 0, nUpDiff, nUpDiff, nUpDiff, 0, @comp, nFlags, *param\uPointer2)
      cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
      cvShowImage(#CV_WINDOW_NAME + " - Floodfill", *param\uPointer2)
  EndSelect
EndProcedure

ProcedureC CvTrackbarCallback1(pos)
  nLoDiff = pos
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  nUpDiff = pos
EndProcedure

ProcedureC OpenCV(ImageFile.s)
  If FileSize(ImageFile) > 0
    cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
    window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
    *window_name = cvGetWindowName(window_handle)
    lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(1, "Open")
      MenuBar()
      MenuItem(2, "Save")
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

    If *image\width * 2 >= dtWidth - 100 Or *image\height >= dtHeight - (100 + 48 + 42)
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / (*image\width * 2)
      iHeight = dtHeight - (100 + 48 + 42)
      iRatio2.d = iHeight / *image\height

      If iRatio1 < iRatio2
        iWidth = *image\width * iRatio1
        iHeight = *image\height * iRatio1
      Else
        iWidth = *image\width * iRatio2
        iHeight = *image\height * iRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight + 48 + 42)
      *resize1.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image\nChannels)
      cvResize(*image, *resize1, #CV_INTER_AREA)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height + 48 + 42)
      *resize1.IplImage = cvCloneImage(*image)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)

    If *resize1\width > 200 And *resize1\height > 200
      nLoDiff = 20
      nUpDiff = 20
      cvCreateTrackbar("loDiff", #CV_WINDOW_NAME, @nLoDiff, 255, @CvTrackbarCallback1())
      cvCreateTrackbar("upDiff", #CV_WINDOW_NAME, @nUpDiff, 255, @CvTrackbarCallback2())
      nFlags = 4 + (255 << 8) + #CV_FLOODFILL_FIXED_RANGE
      *reset.IplImage = cvCloneImage(*resize1)
      cvNamedWindow(#CV_WINDOW_NAME + " - Floodfill", #CV_WINDOW_AUTOSIZE)
      hWnd_floodfill = GetParent_(cvGetWindowHandle(#CV_WINDOW_NAME + " - Floodfill"))
      SendMessage_(hWnd_floodfill, #WM_SETICON, 0, opencv)
      wStyle = GetWindowLongPtr_(hWnd_floodfill, #GWL_STYLE)
      SetWindowLongPtr_(hWnd_floodfill, #GWL_STYLE, wStyle & ~(#WS_SYSMENU | #WS_MAXIMIZEBOX | #WS_SIZEBOX))
      cvResizeWindow(#CV_WINDOW_NAME + " - Floodfill", *resize1\width, *resize1\height)
      *resize2.IplImage = cvCreateImage(*resize1\width + 2, *resize1\height + 2, #IPL_DEPTH_8U, 1)
      cvSetZero(*resize2)
      cvMoveWindow(#CV_WINDOW_NAME + " - Floodfill", *resize1\width + 50, 20)
      BringToTop(hWnd)
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *resize1
      *param\uPointer2 = *resize2
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *resize1
          cvShowImage(#CV_WINDOW_NAME, *resize1)
          cvShowImage(#CV_WINDOW_NAME + " - Floodfill", *resize2)
          keypressed = cvWaitKey(0)

          Select keypressed
            Case 13
              cvCopy(*reset, *resize1, #Null)
              cvSetZero(*resize2)
            Case 32
              nConnect ! 1

              If nConnect
                nFlags + 4
              Else
                nFlags - 4
              EndIf
            Case 70, 102
              nFill ! 1

              If nFill
                nFlags - #CV_FLOODFILL_FIXED_RANGE
              Else
                nFlags + #CV_FLOODFILL_FIXED_RANGE
              EndIf
          EndSelect
        EndIf
      Until keyPressed = 27 Or exitCV
      cvReleaseImage(@*resize2)
      cvReleaseImage(@*reset)
      cvReleaseImage(@*resize1)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If getCV
        getCV = #False
        exitCV = #False
        OpenCV(GetImage())
      EndIf
    Else
      MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the size requirements, please try a larger image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      cvReleaseImage(@*resize1)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/fruits.jpg")
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
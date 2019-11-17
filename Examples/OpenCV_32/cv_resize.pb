IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Resizes an image to a specified percent." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Increase size by 10%."

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

ProcedureC OpenCV(ImageFile.s, nRatio.d)
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
    nWidth = *image\width * nRatio
    nHeight = *image\height * nRatio
    dtWidth = DesktopWidth(0)
    dtHeight = DesktopHeight(0)

    If nWidth >= dtWidth - 100 Or nHeight >= dtHeight - 100
      iWidth = dtWidth - 100
      nRatio1.d = iWidth / nWidth
      iHeight = dtHeight - 100
      nRatio2.d = iHeight / nHeight

      If nRatio1 < nRatio2
        iWidth = nWidth * nRatio1
        iHeight = nHeight * nRatio1
      Else
        iWidth = nWidth * nRatio2
        iHeight = nHeight * nRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, nWidth, nHeight)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)
    *resize.IplImage = cvCreateImage(*image\width * nRatio, *image\height * nRatio, #IPL_DEPTH_8U, *image\nChannels)
    cvResize(*image, *resize, #CV_INTER_AREA)
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_DUPLEX, 1, 1, #Null, 1, #CV_AA)
    BringToTop(hWnd)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *resize
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If *resize
        cvPutText(*resize, Str(nRatio * 100) + "%", 2, 27, @font, 0, 0, 0, 0)
        cvPutText(*resize, Str(nRatio * 100) + "%", 0, 25, @font, 255, 255, 255, 0)
        cvShowImage(#CV_WINDOW_NAME, *resize)
        keyPressed = cvWaitKey(0)

        If keyPressed = 32
          If nRatio > 0.9 : nRatio = 0.1 : Else : nRatio + 0.1 : EndIf

          cvReleaseImage(@*resize)
          cvReleaseImage(@*image)
          cvDestroyAllWindows()
          OpenCV(ImageFile, nRatio)
        EndIf
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()

    If getCV
      getCV = #False
      exitCV = #False
      OpenCV(GetImage(), 0.5)
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/starrynight.jpg", 0.5)
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
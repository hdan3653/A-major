IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Implementation of the Floyd-Steinberg dithering algorithm applied to a gray-scale image." +
                  Chr(10) + Chr(10) + "- [ V ] KEY: Change PIP view."

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
    *image.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_GRAYSCALE)
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

    If *resize\width > 200 And *resize\height > 200
      *reset.IplImage = cvCloneImage(*resize)
      cvSmooth(*resize, *resize, #CV_BLUR, 3, 0, 0, 0)
      *dither.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)

      For y = 0 To *resize\height - 2
        For x = 1 To *resize\width - 2
          oldPixel.a = PeekA(@*resize\imageData\b + (y * *resize\widthStep) + x)

          If oldPixel < 128 : newPixel = 0 : Else : newPixel = 255 : EndIf

          PokeA(@*dither\imageData\b + (y * *dither\widthStep) + x, newPixel)
          quantError = oldPixel - newPixel
          var1.f = PeekA(@*resize\imageData\b + (y * *resize\widthStep) + (x + 1)) + quantError * 7 / 20
          var2.f = PeekA(@*resize\imageData\b + ((y + 1) * *resize\widthStep) + (x - 1)) + quantError * 3 / 20
          var3.f = PeekA(@*resize\imageData\b + ((y + 1) * *resize\widthStep) + x) + quantError * 5 / 20
          var4.f = PeekA(@*resize\imageData\b + ((y + 1) * *resize\widthStep) + (x + 1)) + quantError * 1 / 20
          PokeA(@*resize\imageData\b + (y * *resize\widthStep) + (x + 1), var1)
          PokeA(@*resize\imageData\b + ((y + 1) * *resize\widthStep) + (x - 1), var2)
          PokeA(@*resize\imageData\b + ((y + 1) * *resize\widthStep) + x, var3)
          PokeA(@*resize\imageData\b + ((y + 1) * *resize\widthStep) + (x + 1), var4)
        Next
      Next
      iRatio.d = 150 / *resize\width
      iWidth = *resize\width * iRatio
      iHeight = *resize\height * iRatio
      *PIP.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 1)
      cvResize(*reset, *PIP, #CV_INTER_AREA)
      *reset.IplImage = cvCloneImage(*dither)
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *dither
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *dither
          Select PIP
            Case 0
              cvSetImageROI(*dither, 20, 20, iWidth, iHeight)
              cvAndS(*dither, 0, 0, 0, 0, *dither, #Null)
              cvAdd(*dither, *PIP, *dither, #Null)
              cvResetImageROI(*dither)
              cvRectangleR(*dither, 19, 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
            Case 1
              cvSetImageROI(*dither, *dither\width - (150 + 20), 20, iWidth, iHeight)
              cvAndS(*dither, 0, 0, 0, 0, *dither, #Null)
              cvAdd(*dither, *PIP, *dither, #Null)
              cvResetImageROI(*dither)
              cvRectangleR(*dither, *dither\width - (150 + 21), 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
          EndSelect
          cvShowImage(#CV_WINDOW_NAME, *dither)
          keyPressed = cvWaitKey(0)

          If keyPressed = 86 Or keyPressed = 118
            PIP = (PIP + 1) % 3
            cvReleaseImage(@*dither)
            *dither = cvCloneImage(*reset)
            *param\uPointer1 = *dither
          EndIf
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
      cvReleaseImage(@*PIP)
      cvReleaseImage(@*dither)
      cvReleaseImage(@*reset)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If getCV
        getCV = #False
        exitCV = #False
        OpenCV(GetImage())
      EndIf
    Else
      MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the size requirements, please try a larger image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/lena.jpg")
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
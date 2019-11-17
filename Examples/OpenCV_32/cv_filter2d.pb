IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Convolves an image with the kernel using various filters." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Change the filter." + Chr(10) + Chr(10) +
                  "- [ V ] KEY: Change PIP view."

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

    If *resize\width > 200 And *resize\height > 200 And *resize\nChannels = 3
      *reset.IplImage  = cvCloneImage(*resize)
      iRatio.d = 150 / *resize\width
      iWidth = *resize\width * iRatio
      iHeight = *resize\height * iRatio
      *PIP.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 3)
      cvResize(*resize, *PIP, #CV_INTER_AREA)
      Dim kernel.f(9)
      kernel(0) = 1 : kernel(1) = 1 : kernel(2) = 1
      kernel(3) = 0 : kernel(4) = 0 : kernel(5) = 0
      kernel(6) = -1 : kernel(7) = -1 : kernel(8) = -1
      *kernel.CvMat = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
      cvFilter2D(*resize, *resize, *kernel, -1, -1)
      font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
      filter.s = "HORIZONTAL PREWITT"
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *resize
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *resize
          Select PIP
            Case 0
              cvSetImageROI(*resize, 20, 20, iWidth, iHeight)
              cvAndS(*resize, 0, 0, 0, 0, *resize, #Null)
              cvAdd(*resize, *PIP, *resize, #Null)
              cvResetImageROI(*resize)
              cvRectangleR(*resize, 19, 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
            Case 1
              cvSetImageROI(*resize, *resize\width - (150 + 20), 20, iWidth, iHeight)
              cvAndS(*resize, 0, 0, 0, 0, *resize, #Null)
              cvAdd(*resize, *PIP, *resize, #Null)
              cvResetImageROI(*resize)
              cvRectangleR(*resize, *resize\width - (150 + 21), 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
          EndSelect
          cvPutText(*resize, filter, 22, *resize\height - 18, @font, 0, 0, 0, 0)
          cvPutText(*resize, filter, 20, *resize\height - 20, @font, 255, 255, 255, 0)
          cvShowImage(#CV_WINDOW_NAME, *resize)
          keyPressed = cvWaitKey(0)

          Select keyPressed
            Case 32
              nfilter = (nfilter + 1) % 19

              Select nfilter
                Case 0
                  filter = "HORIZONTAL PREWITT"
                  Dim kernel.f(9)
                  kernel(0) = 1 : kernel(1) = 1 : kernel(2) = 1
                  kernel(3) = 0 : kernel(4) = 0 : kernel(5) = 0
                  kernel(6) = -1 : kernel(7) = -1 : kernel(8) = -1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 1
                  filter = "VERTICAL PREWITT"
                  Dim kernel.f(9)
                  kernel(0) = -1 : kernel(1) = 0 : kernel(2) = 1
                  kernel(3) = -1 : kernel(4) = 0 : kernel(5) = 1
                  kernel(6) = -1 : kernel(7) = 0 : kernel(8) = 1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 2
                  filter = "GAUSSIAN 1"
                  Dim kernel.f(9)
                  kernel(0) = 1 : kernel(1) = 2 : kernel(2) = 1
                  kernel(3) = 2 : kernel(4) = 4 : kernel(5) = 2
                  kernel(6) = 1 : kernel(7) = 2 : kernel(8) = 1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 3
                  filter = "GAUSSIAN 2"
                  Dim kernel.f(25)
                  kernel(0) = 2 : kernel(1) = 7 : kernel(2) = 12 : kernel(3) = 7 : kernel(4) = 2
                  kernel(5) = 7 : kernel(6) = 31 : kernel(7) = 52 : kernel(8) = 31 : kernel(9) = 7
                  kernel(10) = 12 : kernel(11) = 52 : kernel(12) = 127 : kernel(13) = 52 : kernel(14) = 12
                  kernel(15) = 7 : kernel(16) = 31 : kernel(17) = 52 : kernel(18) = 31 : kernel(19) = 7
                  kernel(20) = 2 : kernel(21) = 7 : kernel(22) = 12 : kernel(23) = 7 : kernel(24) = 2
                  *kernel = cvMat(5, 5, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 4
                  filter = "GAUSSIAN 3"
                  Dim kernel.f(49)
                  kernel(0) = 1 : kernel(1) = 1 : kernel(2) = 2 : kernel(3) = 2 : kernel(4) = 2 : kernel(5) = 1 : kernel(6) = 1
                  kernel(7) = 1 : kernel(8) = 3 : kernel(9) = 4 : kernel(10) = 5 : kernel(11) = 4 : kernel(12) = 3 : kernel(13) = 1
                  kernel(14) = 2 : kernel(15) = 4 : kernel(16) = 7 : kernel(17) = 8 : kernel(18) = 7 : kernel(19) = 4 : kernel(20) = 2
                  kernel(21) = 2 : kernel(22) = 5 : kernel(23) = 8 : kernel(24) = 10 : kernel(25) = 8 : kernel(26) = 5 : kernel(27) = 2
                  kernel(28) = 2 : kernel(29) = 4 : kernel(30) = 7 : kernel(31) = 8 : kernel(32) = 7 : kernel(33) = 4 : kernel(34) = 2
                  kernel(35) = 1 : kernel(36) = 3 : kernel(37) = 4 : kernel(38) = 5 : kernel(39) = 4 : kernel(40) = 3 : kernel(41) = 1
                  kernel(42) = 1 : kernel(43) = 1 : kernel(44) = 2 : kernel(45) = 2 : kernel(46) = 2 : kernel(47) = 1 : kernel(48) = 1
                  *kernel = cvMat(7, 7, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 5
                  filter = "AVERAGE 1"
                  Dim kernel.f(9)
                  kernel(0) = 1 : kernel(1) = 1 : kernel(2) = 1
                  kernel(3) = 1 : kernel(4) = 1 : kernel(5) = 1
                  kernel(6) = 1 : kernel(7) = 1 : kernel(8) = 1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 6
                  filter = "AVERAGE 2"
                  Dim kernel.f(25)
                  kernel(0) = 1 : kernel(1) = 1 : kernel(2) = 1 : kernel(3) = 1 : kernel(4) = 1
                  kernel(5) = 1 : kernel(6) = 1 : kernel(7) = 1 : kernel(8) = 1 : kernel(9) = 1
                  kernel(10) = 1 : kernel(11) = 1 : kernel(12) = 1 : kernel(13) = 1 : kernel(14) = 1
                  kernel(15) = 1 : kernel(16) = 1 : kernel(17) = 1 : kernel(18) = 1 : kernel(19) = 1
                  kernel(20) = 1 : kernel(21) = 1 : kernel(22) = 1 : kernel(23) = 1 : kernel(24) = 1
                  *kernel = cvMat(5, 5, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 7
                  filter = "AVERAGE 3"
                  Dim kernel.f(49)
                  kernel(0) = 1 : kernel(1) = 1 : kernel(2) = 1 : kernel(3) = 1 : kernel(4) = 1 : kernel(5) = 1 : kernel(6) = 1
                  kernel(7) = 1 : kernel(8) = 1 : kernel(9) = 1 : kernel(10) = 1 : kernel(11) = 1 : kernel(12) = 1 : kernel(13) = 1
                  kernel(14) = 1 : kernel(15) = 1 : kernel(16) = 1 : kernel(17) = 1 : kernel(18) = 1 : kernel(19) = 1 : kernel(20) = 1
                  kernel(21) = 1 : kernel(22) = 1 : kernel(23) = 1 : kernel(24) = 1 : kernel(25) = 1 : kernel(26) = 1 : kernel(27) = 1
                  kernel(28) = 1 : kernel(29) = 1 : kernel(30) = 1 : kernel(31) = 1 : kernel(32) = 1 : kernel(33) = 1 : kernel(34) = 1
                  kernel(35) = 1 : kernel(36) = 1 : kernel(37) = 1 : kernel(38) = 1 : kernel(39) = 1 : kernel(40) = 1 : kernel(41) = 1
                  kernel(42) = 1 : kernel(43) = 1 : kernel(44) = 1 : kernel(45) = 1 : kernel(46) = 1 : kernel(47) = 1 : kernel(48) = 1
                  *kernel = cvMat(7, 7, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 8
                  filter = "HIGH PASS 1"
                  Dim kernel.f(9)
                  kernel(0) = -1 : kernel(1) = -1 : kernel(2) = -1
                  kernel(3) = -1 : kernel(4) = 8 : kernel(5) = -1
                  kernel(6) = -1 : kernel(7) = -1 : kernel(8) = -1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 9
                  filter = "HIGH PASS 2"
                  Dim kernel.f(25)
                  kernel(0) = -1 : kernel(1) = -1 : kernel(2) = -1 : kernel(3) = -1 : kernel(4) = -1
                  kernel(5) = -1 : kernel(6) = -1 : kernel(7) = -1 : kernel(8) = -1 : kernel(9) = -1
                  kernel(10) = -1 : kernel(11) = -1 : kernel(12) = 24 : kernel(13) = -1 : kernel(14) = -1
                  kernel(15) = -1 : kernel(16) = -1 : kernel(17) = -1 : kernel(18) = -1 : kernel(19) = -1
                  kernel(20) = -1 : kernel(21) = -1 : kernel(22) = -1 : kernel(23) = -1 : kernel(24) = -1
                  *kernel = cvMat(5, 5, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 10
                  filter = "HIGH PASS 3"
                  Dim kernel.f(49)
                  kernel(0) = -1 : kernel(1) = -1 : kernel(2) = -1 : kernel(3) = -1 : kernel(4) = -1 : kernel(5) = 1 : kernel(6) = -1
                  kernel(7) = -1 : kernel(8) = -1 : kernel(9) = -1 : kernel(10) = -1 : kernel(11) = -1 : kernel(12) = 1 : kernel(13) = -1
                  kernel(14) = -1 : kernel(15) = -1 : kernel(16) = -1 : kernel(17) = -1 : kernel(18) = -1 : kernel(19) = 1 : kernel(20) = -1
                  kernel(21) = -1 : kernel(22) = -1 : kernel(23) = -1 : kernel(24) = 48 : kernel(25) = -1 : kernel(26) = 1 : kernel(27) = -1
                  kernel(28) = -1 : kernel(29) = -1 : kernel(30) = -1 : kernel(31) = -1 : kernel(32) = -1 : kernel(33) = 1 : kernel(34) = -1
                  kernel(35) = -1 : kernel(36) = -1 : kernel(37) = -1 : kernel(38) = -1 : kernel(39) = -1 : kernel(40) = 1 : kernel(41) = -1
                  kernel(42) = -1 : kernel(43) = -1 : kernel(44) = -1 : kernel(45) = -1 : kernel(46) = -1 : kernel(47) = 1 : kernel(48) = -1
                  *kernel = cvMat(7, 7, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 11
                  filter = "HORIZONTAL SOBEL"
                  Dim kernel.f(9)
                  kernel(0) = 1 : kernel(1) = 2 : kernel(2) = 1
                  kernel(3) = 0 : kernel(4) = 0 : kernel(5) = 0
                  kernel(6) = -1 : kernel(7) = -2 : kernel(8) = -1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())                
                Case 12
                  filter = "VERTICAL SOBEL"
                  Dim kernel.f(9)
                  kernel(0) = -1 : kernel(1) = 0 : kernel(2) = 1
                  kernel(3) = -2 : kernel(4) = 0 : kernel(5) = 2
                  kernel(6) = -1 : kernel(7) = 0 : kernel(8) = 1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 13
                  filter = "SHARPEN 1"
                  Dim kernel.f(9)
                  kernel(0) = -1 : kernel(1) = -1 : kernel(2) = -1
                  kernel(3) = -1 : kernel(4) = 9 : kernel(5) = -1
                  kernel(6) = -1 : kernel(7) = -1 : kernel(8) = -1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 14
                  filter = "SHARPEN 2"
                  Dim kernel.f(25)
                  kernel(0) = -1 : kernel(1) = -1 : kernel(2) = -1 : kernel(3) = -1 : kernel(4) = -1
                  kernel(5) = -1 : kernel(6) = -1 : kernel(7) = -1 : kernel(8) = -1 : kernel(9) = -1
                  kernel(10) = -1 : kernel(11) = -1 : kernel(12) = 25 : kernel(13) = -1 : kernel(14) = -1
                  kernel(15) = -1 : kernel(16) = -1 : kernel(17) = -1 : kernel(18) = -1 : kernel(19) = -1
                  kernel(20) = -1 : kernel(21) = -1 : kernel(22) = -1 : kernel(23) = -1 : kernel(24) = -1
                  *kernel = cvMat(5, 5, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 15
                  filter = "SHARPEN 3"
                  Dim kernel.f(49)
                  kernel(0) = -1 : kernel(1) = -1 : kernel(2) = -1 : kernel(3) = -1 : kernel(4) = -1 : kernel(5) = 1 : kernel(6) = -1
                  kernel(7) = -1 : kernel(8) = -1 : kernel(9) = -1 : kernel(10) = -1 : kernel(11) = -1 : kernel(12) = 1 : kernel(13) = -1
                  kernel(14) = -1 : kernel(15) = -1 : kernel(16) = -1 : kernel(17) = -1 : kernel(18) = -1 : kernel(19) = 1 : kernel(20) = -1
                  kernel(21) = -1 : kernel(22) = -1 : kernel(23) = -1 : kernel(24) = 49 : kernel(25) = -1 : kernel(26) = 1 : kernel(27) = -1
                  kernel(28) = -1 : kernel(29) = -1 : kernel(30) = -1 : kernel(31) = -1 : kernel(32) = -1 : kernel(33) = 1 : kernel(34) = -1
                  kernel(35) = -1 : kernel(36) = -1 : kernel(37) = -1 : kernel(38) = -1 : kernel(39) = -1 : kernel(40) = 1 : kernel(41) = -1
                  kernel(42) = -1 : kernel(43) = -1 : kernel(44) = -1 : kernel(45) = -1 : kernel(46) = -1 : kernel(47) = 1 : kernel(48) = -1
                  *kernel = cvMat(7, 7, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 16
                  filter = "SHARPEN LOW 1"
                  Dim kernel.f(9)
                  kernel(0) = -1 : kernel(1) = -1 : kernel(2) = -1
                  kernel(3) = -1 : kernel(4) = 16 : kernel(5) = -1
                  kernel(6) = -1 : kernel(7) = -1 : kernel(8) = -1
                  *kernel = cvMat(3, 3, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 17
                  filter = "SHARPEN LOW 2"
                  Dim kernel.f(25)
                  kernel(0) = -1 : kernel(1) = -3 : kernel(2) = -4 : kernel(3) = -3 : kernel(4) = -1
                  kernel(5) = -3 : kernel(6) = 0 : kernel(7) = 6 : kernel(8) = 0 : kernel(9) = -3
                  kernel(10) = -4 : kernel(11) = 6 : kernel(12) = 40 : kernel(13) = 6 : kernel(14) = -4
                  kernel(15) = -3 : kernel(16) = 0 : kernel(17) = 6 : kernel(18) = 0 : kernel(19) = -3
                  kernel(20) = -1 : kernel(21) = -3 : kernel(22) = -4 : kernel(23) = -3 : kernel(24) = -1
                  *kernel = cvMat(5, 5, CV_MAKETYPE(#CV_32F, 1), kernel())
                Case 18
                  filter = "SHARPEN LOW 3"
                  Dim kernel.f(49)
                  kernel(0) = -2 : kernel(1) = -3 : kernel(2) = -4 : kernel(3) = -6 : kernel(4) = -4 : kernel(5) = -3 : kernel(6) = -2
                  kernel(7) = -3 : kernel(8) = -5 : kernel(9) = -4 : kernel(10) = -3 : kernel(11) = -4 : kernel(12) = -5 : kernel(13) = -3
                  kernel(14) = -4 : kernel(15) = -4 : kernel(16) = 9 : kernel(17) = 20 : kernel(18) = 9 : kernel(19) = -4 : kernel(20) = -4
                  kernel(21) = -6 : kernel(22) = -3 : kernel(23) = 20 : kernel(24) = 72 : kernel(25) = 20 : kernel(26) = -3 : kernel(27) = -6
                  kernel(28) = -4 : kernel(29) = -4 : kernel(30) = 9 : kernel(31) = 20 : kernel(32) = 9 : kernel(33) = -4 : kernel(34) = -4
                  kernel(35) = -3 : kernel(36) = -5 : kernel(37) = -4 : kernel(38) = -3 : kernel(39) = -4 : kernel(40) = -5 : kernel(41) = -3
                  kernel(42) = -2 : kernel(43) = -3 : kernel(44) = -4 : kernel(45) = -6 : kernel(46) = -4 : kernel(47) = -3 : kernel(48) = -2
                  *kernel = cvMat(7, 7, CV_MAKETYPE(#CV_32F, 1), kernel())
              EndSelect
              cvFilter2D(*reset, *resize, *kernel, -1, -1)
            Case 86, 118
              PIP = (PIP + 1) % 3
              cvFilter2D(*reset, *resize, *kernel, -1, -1)
          EndSelect
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
      cvReleaseImage(@*PIP)
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
      If *resize\nChannels = 3
        MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the size requirements, please try a larger image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      Else
        MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the channel requirements, please try a color image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      EndIf
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/nebula2.jpg")
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
IncludeFile "includes/cv_functions.pbi"

Global getCV.b, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Adds a logo with border to a webcam stream by utilizing the Region Of Interest functions."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          getCV = #True
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
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
      DisplayPopupMenu(0, *param\uValue)
  EndSelect
EndProcedure

ProcedureC OpenCV(ImageFile.s, *capture.CvCapture)
  If FileSize(ImageFile) > 0
    cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
    window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
    *window_name = cvGetWindowName(window_handle)
    lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(1, "Open")
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
    *logo.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)

    If *logo\nChannels = 1
      *temp.IplImage = cvCloneImage(*logo)
      *logo.IplImage = cvCreateImage(*temp\width, *temp\height, #IPL_DEPTH_8U, 3)
      cvCvtColor(*temp, *logo, #CV_GRAY2BGR, 1)
      cvReleaseImage(@*temp)
    EndIf

    If *logo\width > 100
      iRatio.d = 100 / *logo\width
      iWidth = *logo\width * iRatio
      iHeight = *logo\height * iRatio
      *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *logo\nChannels)
      cvResize(*logo, *resize, #CV_INTER_AREA)
    Else
      *resize = cvCloneImage(*logo)
    EndIf
    offset = 5
    *border.IplImage = cvCreateImage(*resize\width + offset - 1, *resize\height + offset - 1, #IPL_DEPTH_8U, *resize\nChannels)
    cvCopyMakeBorder(*resize, *border, (offset - 1) / 2, (offset - 1) / 2, #IPL_BORDER_CONSTANT, 0, 255, 255, 0)
    *image.IplImage
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      *image = cvQueryFrame(*capture)

      If *image
        cvFlip(*image, #Null, 1)
        cvSetImageROI(*image, 20, 20, *border\width, *border\height)
        cvAndS(*image, 0, 0, 0, 0, *image, #Null)
        cvAdd(*image, *border, *image, #Null)
        cvResetImageROI(*image)
        cvShowImage(#CV_WINDOW_NAME, *image)
        keyPressed = cvWaitKey(100)
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseImage(@*border)
    cvReleaseImage(@*resize)
    cvReleaseImage(@*logo)
    cvDestroyAllWindows()

    If getCV
      getCV = #False
      exitCV = #False
      OpenCV(GetImage(), *capture)
    EndIf
    cvReleaseCapture(@*capture)
  EndIf
EndProcedure

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
Until nCreate = 5 Or *capture

If *capture
  OpenCV("images/thinning2.jpg", *capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Using a Gaussian mixture-based background/foreground detection algorithm, foreground objects " +
                  "are highlighted by comparing the current frame with a static frame." + Chr(10) + Chr(10) +
                  "- SPACEBAR: New static frame." + Chr(10) + Chr(10) +
                  "- [ V ] KEY: Change PIP view."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared exitCV.b

  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 10
          exitCV = #True
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

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateFileCapture("movies/walking.avi")
Until nCreate = 5 Or *capture

If *capture
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
  window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
  *window_name = cvGetWindowName(window_handle)
  lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

  If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
    MenuItem(10, "Exit")
  EndIf
  hWnd = GetParent_(window_handle)
  opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
  SendMessage_(hWnd, #WM_SETICON, 0, opencv)
  wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)
  SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))
  cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
  ToolTip(window_handle, #CV_DESCRIPTION)
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  iRatio.d = 150 / FrameWidth
  iWidth = FrameWidth * iRatio
  iHeight = FrameHeight * iRatio
  *PIP.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 3)
  *color.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *image.IplImage = cvQueryFrame(*capture)
  *bg_model.CvBGStatModel = cvCreateGaussianBGModel(*image, #Null)
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvUpdateBGStatModel(*image, *bg_model, 0)
      cvResize(*image, *PIP, #CV_INTER_AREA)
      cvCvtColor(*bg_model\foreground, *color, #CV_GRAY2BGR, 1)

      Select PIP
        Case 0
          cvSetImageROI(*color, 20, 20, iWidth, iHeight)
          cvAndS(*color, 0, 0, 0, 0, *color, #Null)
          cvAdd(*color, *PIP, *color, #Null)
          cvResetImageROI(*color)
          cvRectangleR(*color, 19, 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
        Case 1
          cvSetImageROI(*color, *color\width - (150 + 20), 20, iWidth, iHeight)
          cvAndS(*color, 0, 0, 0, 0, *color, #Null)
          cvAdd(*color, *PIP, *color, #Null)
          cvResetImageROI(*color)
          cvRectangleR(*color, *color\width - (150 + 21), 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
      EndSelect
      cvShowImage(#CV_WINDOW_NAME, *color)
      keyPressed = cvWaitKey(100)

      Select keyPressed
        Case 32
          *bg_model = cvCreateGaussianBGModel(*image, #Null)
        Case 86, 118
          PIP = (PIP + 1) % 3
      EndSelect
    Else
      Break
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*color)
  cvReleaseImage(@*PIP)
  cvReleaseBGStatModel(@*bg_model)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
EndIf
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
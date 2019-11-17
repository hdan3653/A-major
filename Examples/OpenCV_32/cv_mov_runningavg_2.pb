IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Calculates the weighted sum of the input image and the accumulator so that the " +
                  "new image becomes a running average of a frame sequence." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Toggle between foreground/background view." + Chr(10) + Chr(10) +
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
  *pBkImg.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *pFrImg.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *pBkMat.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_32F, 1))
  *pFrMat.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_32F, 1))
  *pFrameMat.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_32F, 1))
  *image.IplImage = cvQueryFrame(*capture)
  cvCvtColor(*image, *pBkImg, #CV_BGR2GRAY, 1)
  cvCvtColor(*image, *pFrImg, #CV_BGR2GRAY, 1)
  cvConvert(*pFrImg, *pFrameMat)
  cvConvert(*pFrImg, *pFrMat)
  cvConvert(*pFrImg, *pBkMat)
  iRatio.d = 150 / FrameWidth
  iWidth = FrameWidth * iRatio
  iHeight = FrameHeight * iRatio
  *PIP.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 3)
  *color.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *kernel.IplConvKernel = cvCreateStructuringElementEx(3, 3, 1, 1, #CV_SHAPE_RECT, #Null)
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvCvtColor(*image, *pFrImg, #CV_BGR2GRAY, 1)
      cvConvert(*pFrImg, *pFrameMat)
      cvSmooth(*pFrameMat, *pFrameMat, #CV_GAUSSIAN, 3, 0, 0, 0)
      cvAbsDiff(*pFrameMat, *pBkMat, *pFrMat)
      cvThreshold(*pFrMat, *pFrImg, 60, 255.0, #CV_THRESH_BINARY)
      cvErode(*pFrImg, *pFrImg, *kernel, 1)
      cvDilate(*pFrImg, *pFrImg, *kernel, 1)
      cvRunningAvg(*pFrameMat, *pBkMat, 0.003, #Null)
      cvConvert(*pBkMat, *pBkImg)
      cvResize(*image, *PIP, #CV_INTER_AREA)

      If foreground : cvCvtColor(*pFrImg, *color, #CV_GRAY2BGR, 1) : Else : cvCvtColor(*pBkImg, *color, #CV_GRAY2BGR, 1) : EndIf

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
      keyPressed = cvWaitKey(10)

      Select keyPressed
        Case 32
          foreground ! 1
        Case 86, 118
          PIP = (PIP + 1) % 3
      EndSelect
    Else
      Break
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseStructuringElement(@*kernel)
  cvReleaseImage(@*color)
  cvReleaseImage(@*PIP)
  cvReleaseMat(@*pFrameMat)
  cvReleaseMat(@*pFrMat)
  cvReleaseMat(@*pBkMat)
  cvReleaseImage(@*pFrImg)
  cvReleaseImage(@*pBkImg)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
EndIf
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
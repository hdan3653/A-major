IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, *imgTracking.IplImage, lastX, lastY, nCursor

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Tracks red objects demonstrated by drawing a line that traces its location." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Toggle mouse tracking." + Chr(10) + Chr(10) +
                  "- ENTER: Clear the traced line."

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

ProcedureC GetThresholdedImage(*imgHSV.IplImage)
  *imgThresh.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  cvInRangeS(*imgHSV, 160, 140, 40, 0, 179, 255, 255, 0, *imgThresh)
  ProcedureReturn *imgThresh
EndProcedure

ProcedureC TrackObject(*imgThresh.IplImage)
  moments.CvMoments
  cvMoments(*imgThresh, @moments, 1)
  moment10.d = moments\m10
  moment01.d = moments\m01
  area.d = moments\m00

  If area > 1000
    posX = moment10 / area
    posY = moment01 / area

    If lastX >= 0 And lastY >= 0 And posX >= 0 And posY >= 0
      cvLine(*imgTracking, posX, posY, lastX, lastY, 0, 0, 255, 0, 4, #CV_AA, #Null)

      If nCursor : SetCursorPos_(posX + 25, posY + 45) : EndIf

    EndIf
    lastX = posX
    lastY = posY
  EndIf
EndProcedure

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
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
  *imgTracking = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  cvSetZero(*imgTracking)
  lastX = -1
  lastY = -1
  *imgHSV.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvSmooth(*image, *image, #CV_GAUSSIAN, 3, 3, 0, 0)
      cvCvtColor(*image, *imgHSV, #CV_BGR2HSV, 1)
      *imgThresh.IplImage = GetThresholdedImage(*imgHSV)
      cvSmooth(*imgThresh, *imgThresh, #CV_GAUSSIAN, 3, 3, 0, 0)
      TrackObject(*imgThresh)
      cvReleaseImage(@*imgThresh)
      cvAdd(*image, *imgTracking, *image, #Null)
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(10)

      Select keyPressed
        Case 13
          cvSetZero(*imgTracking)
          lastX = -1
          lastY = -1
        Case 32
          nCursor ! 1
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*imgHSV)
  cvReleaseImage(@*imgTracking)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 34
; FirstLine = 18
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
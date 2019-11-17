IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Draws moving and static shapes using various filters."

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
  ptLeft = FrameWidth / 2 - 200
  ptTop = FrameHeight / 2 - 100
  ptRight = ptLeft + 400
  ptBottom = ptTop + 200
  width = 200
  radius = 100
  x = 500
  angle.d = 4
  Dim pts1.CvPoint(4)
  pts1(0)\x = 50
  pts1(0)\y = 50
  pts1(1)\x = 200
  pts1(1)\y = 50
  pts1(2)\x = 200
  pts1(2)\y = 400
  pts1(3)\x = 100
  pts1(3)\y = 200
  npts1 = ArraySize(pts1())
  Dim pts2.CvPoint(4)
  pts2(0)\x = 500
  pts2(0)\y = 50
  pts2(1)\x = 500
  pts2(1)\y = 300
  pts2(2)\x = 400
  pts2(2)\y = 100
  pts2(3)\x = 400
  pts2(3)\y = 50
  npts2 = ArraySize(pts2())
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)

      If width = 200 : adjust1.b = #True : ElseIf width = 10 : adjust1 = #False : EndIf
      If adjust1 : width - 10 : Else : width + 10 : EndIf
      If radius = 100 : adjust2.b = #True : ElseIf radius = 5 : adjust2 = #False : EndIf
      If adjust2 : radius - 5 : Else : radius + 5 : EndIf
      If x = 500 : adjust3.b = #True : ElseIf x = 20 : adjust3 = #False : EndIf
      If adjust3 : x - 20 : Else : x + 20 : EndIf
      If angle = 45 : adjust4.b = #True : ElseIf angle = 180 : adjust4 = #False : EndIf
      If adjust4 : angle - 5 : Else : angle + 5 : EndIf

      cvRectangle(*image, ptLeft, ptTop, ptRight, ptBottom, 0, 0, 255, 0, 2, #CV_AA, #Null)
      cvRectangleR(*image, ptLeft + 100, ptTop + 100, width, 200, 0, 255, 0, 0, #CV_FILLED, #CV_AA, #Null)
      cvCircle(*image, ptLeft, 120, radius, 255, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
      cvLine(*image, x, 100, 200, 400, 0, 255, 255, 0, 4, #CV_AA, #Null)
      cvEllipse(*image, 400, 250, 200, 100, angle, 0, 360, 255, 0, 255, 0, 3, #CV_AA, #Null)
      cvPolyLine(*image, pts1(), @npts1, 1, #False, 255, 200, 100, 0, 2, #CV_AA, #Null)
      cvFillPoly(*image, pts2(), @npts2, 1, 100, 200, 255, 0, #CV_AA, #Null)
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(100)
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 102
; FirstLine = 78
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
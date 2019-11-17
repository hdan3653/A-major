IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Pixel manipulation through direct memory access, demonstrating various webcam effects." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Toggle fisheye / mirror."

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
  halfFrame = FrameWidth / 2
  frameBytes = FrameWidth * 3 - 1
  *fisheye.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)

      If camStuff
        For i = 0 To FrameHeight - 1
          offset = i * FrameWidth * 3

          For j = 0 To halfFrame - 1
            jBytes = offset + frameBytes - (j * 3)
            ojBytes = offset + (j * 3)
            PokeA(@*image\imageData\b + jBytes - 2, PeekA(@*image\imageData\b + ojBytes))
            PokeA(@*image\imageData\b + jBytes - 1, PeekA(@*image\imageData\b + ojBytes + 1))
            PokeA(@*image\imageData\b + jBytes, PeekA(@*image\imageData\b + ojBytes + 2))
          Next
        Next
        cvShowImage(#CV_WINDOW_NAME, *image)
      Else
        For y = 0 To FrameHeight - 1
          For x = 0 To FrameWidth - 1
            rp.d = Sqr(40 * 40 + Pow((x - FrameWidth / 2), 2) + Pow(y - FrameHeight / 2, 2))
            vx = rp * (x - FrameWidth / 2) / FrameWidth + FrameWidth / 2
            vy = rp * (y - FrameHeight / 2) / FrameWidth + FrameHeight / 2

            If vx >= 0 And vx < FrameWidth And vy >= 0 And vy < FrameHeight
              PokeA(@*fisheye\imageData\b + *fisheye\widthStep * y + x * 3, PeekA(@*image\imageData\b + *image\widthStep * vy + vx * 3))
              PokeA(@*fisheye\imageData\b + *fisheye\widthStep * y + x * 3 + 1, PeekA(@*image\imageData\b + *image\widthStep * vy + vx * 3 + 1))
              PokeA(@*fisheye\imageData\b + *fisheye\widthStep * y + x * 3 + 2, PeekA(@*image\imageData\b + *image\widthStep * vy + vx * 3 + 2))
      			EndIf
          Next
        Next
        cvShowImage(#CV_WINDOW_NAME, *fisheye)
      EndIf
      keyPressed = cvWaitKey(10)

      If keyPressed = 32 : camStuff ! 1 : EndIf

    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*fisheye)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
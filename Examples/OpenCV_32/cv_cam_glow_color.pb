IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, nB, nG, nR

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Adds a glow effect to red objects." + Chr(10) + Chr(10) +
                  "- TRACKBAR 1: Adjust Blue value." + Chr(10) + Chr(10) +
                  "- TRACKBAR 2: Adjust Green value." + Chr(10) + Chr(10) +
                  "- TRACKBAR 3: Adjust Red value." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Toggle white core."

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

ProcedureC CvTrackbarCallback1(pos)
  nB = pos
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  nG = pos
EndProcedure

ProcedureC CvTrackbarCallback3(pos)
  nR = pos
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
  cvResizeWindow(#CV_WINDOW_NAME, FrameWidth, FrameHeight + 48 + 42 + 84)
  nR = 120
  cvCreateTrackbar("Blue", #CV_WINDOW_NAME, @nB, 255, @CvTrackbarCallback1())
  cvCreateTrackbar("Green", #CV_WINDOW_NAME, @nG, 255, @CvTrackbarCallback2())
  cvCreateTrackbar("Red", #CV_WINDOW_NAME, @nR, 255, @CvTrackbarCallback3())
  *blur.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 3))
  *hsv.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 3))
  *output.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 1))
  *copy1.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 1))
  *copy2.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 3))
  *white.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 3))
  *kernel.IplConvKernel = cvCreateStructuringElementEx(3, 3, 1, 1, #CV_SHAPE_RECT, #Null)
  *image.CvMat
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvSmooth(*image, *blur, #CV_GAUSSIAN, 11, 11, 0, 0)
      cvCvtColor(*blur, *hsv, #CV_BGR2HSV, 1)
      cvInRangeS(*hsv, 160, 140, 40, 0, 179, 255, 255, 0, *output)
      cvSmooth(*output, *copy1, #CV_GAUSSIAN, 101, 101, 0, 0)
      cvCvtColor(*copy1, *copy2, #CV_GRAY2BGR, 1)
      cvCvtColor(*output, *white, #CV_GRAY2BGR, 1)
      cvDilate(*white, *white, *kernel, 1)
      cvErode(*white, *white, *kernel, 1)
      cvSmooth(*white, *white, #CV_GAUSSIAN, 21, 21, 0, 0)

      For i = 0 To FrameHeight - 1
        For j = 0 To FrameWidth - 1
          B.f = PeekA(@*copy2\ptr\b + i * *copy2\Step + j * 3 + 0)
          G.f = PeekA(@*copy2\ptr\b + i * *copy2\Step + j * 3 + 1)
          R.f = PeekA(@*copy2\ptr\b + i * *copy2\Step + j * 3 + 2)
          PokeA(@*copy2\ptr\b + i * *copy2\Step + j * 3 + 0, B / 255 * nB)
          PokeA(@*copy2\ptr\b + i * *copy2\Step + j * 3 + 1, G / 255 * nG)
          PokeA(@*copy2\ptr\b + i * *copy2\Step + j * 3 + 2, R / 255 * nR)
        Next
      Next
      cvMul(*copy2, *copy2, *copy2, 5)
      cvAdd(*image, *copy2, *image, #Null)

      If white : cvAdd(*image, *white, *image, #Null) : EndIf

      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(10)

      If keyPressed = 32 : white ! 1 : EndIf

    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseStructuringElement(@*kernel)
  cvReleaseMat(@*white)
  cvReleaseMat(@*copy2)
  cvReleaseMat(@*copy1)
  cvReleaseMat(@*output)
  cvReleaseMat(@*hsv)
  cvReleaseMat(@*blur)
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
IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Detect skin tones using the YUV (Luma [Y] and Chroma [UV]) color space." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Toggle skin mode." + Chr(10) + Chr(10) +
                  "- [ S ] KEY: Toggle smooth filters."

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
  total = FrameWidth * FrameHeight
  *YUV.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *Y.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *U.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *V.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *mask.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *skin.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *kernel.IplConvKernel = cvCreateStructuringElementEx(3, 3, 1, 1, #CV_SHAPE_RECT, #Null)
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvCvtColor(*image, *YUV, #CV_BGR2YUV, 1)
      cvSplit(*YUV, *Y, *U, *V, #Null)
      cvSetZero(*mask)

      For rtnCount = 0 To total - 1
        nY = PeekA(@*Y\imageData\b + rtnCount)
        nU = PeekA(@*U\imageData\b + rtnCount) - 152
        nV = PeekA(@*V\imageData\b + rtnCount) - 109
        x1 = (819 * nU - 614 * nV) / 32 + 51
        y1 = (819 * nU + 614 * nV) / 32 + 77
        x1 * 41 / 1024
        y1 * 73 / 1024
        value = x1 * x1 + y1 * y1

        If nY < 0
          If value < 700 : PokeA(@*mask\imageData\b + rtnCount, 255) : Else : PokeA(@*mask\imageData\b + rtnCount, 0) : EndIf
        Else
          If value < 850 : PokeA(@*mask\imageData\b + rtnCount, 255) : Else : PokeA(@*mask\imageData\b + rtnCount, 0) : EndIf
        EndIf
      Next

      If smooth        
        cvErode(*mask, *mask, *kernel, 1)
        cvDilate(*mask, *mask, *kernel, 1)
        cvSmooth(*mask, *mask, #CV_GAUSSIAN, 21, 0, 0, 0)
        cvThreshold(*mask, *mask, 130, 255, #CV_THRESH_BINARY | #CV_THRESH_OTSU)
      EndIf

      If skin
        cvSetZero(*skin)
        cvCopy(*image, *skin, *mask)
        cvShowImage(#CV_WINDOW_NAME, *skin)
      Else
        cvShowImage(#CV_WINDOW_NAME, *mask)
      EndIf
      keyPressed = cvWaitKey(10)

      Select keyPressed
        Case 32
          skin ! 1
        Case 83, 115
          smooth ! 1
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseStructuringElement(@*kernel)
  cvReleaseImage(@*skin)
  cvReleaseImage(@*mask)
  cvReleaseImage(@*V)
  cvReleaseImage(@*U)
  cvReleaseImage(@*Y)
  cvReleaseImage(@*YUV)
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
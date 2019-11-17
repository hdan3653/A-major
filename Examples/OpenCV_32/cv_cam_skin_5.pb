IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Detect skin tones using the RG (Red and Green) color space." + Chr(10) + Chr(10) +
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
  *mask.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *skin.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *kernel.IplConvKernel = cvCreateStructuringElementEx(3, 3, 1, 1, #CV_SHAPE_RECT, #Null)
  Aup.d = -1.8423
  Bup.d = 1.5294
  Cup.d = 0.0422
  Adown.d = -0.7279
  Bdown.d = 0.6066
  Cdown.d = 0.1766
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvSetZero(*mask)

      For y = 0 To FrameHeight - 1
        For x = 0 To FrameWidth - 1
          nB = PeekA(@*image\imageData\b + (y * *image\widthStep) + (x * 3))
          nG = PeekA(@*image\imageData\b + (y * *image\widthStep) + (x * 3) + 1)
          nR = PeekA(@*image\imageData\b + (y * *image\widthStep) + (x * 3) + 2)
          S = nB + nG + nR
          R.d = nR / S
          G.d = nG / S
          Gup.d = Aup * R * R + Bup * R + Cup
          Gdown.d = Adown * R * R + Bdown * R + Cdown
          WR.d = (R - 0.33) * (R - 0.33) + (G - 0.33) * (G - 0.33)

          If G < Gup And G > Gdown And WR > 0.004
            PokeA(@*mask\imageData\b + (y * *mask\widthStep) + x, 255)
          Else
            PokeA(@*mask\imageData\b + (y * *mask\widthStep) + x, 0)
          EndIf
        Next
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
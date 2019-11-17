IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, nX, nY

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Display the HSV and BGR color space values determined by the X/Y mouse pointer location." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Lock color values." + Chr(10) + Chr(10) +
                  "- ENTER: Reset display view." + Chr(10) + Chr(10) +
                  "- [ V ] KEY: Change display view."

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
    Case #CV_EVENT_MOUSEMOVE
      nX = x : nY = y
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
  *blur.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *hsv.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  scalar1.CvScalar : scalar2.CvScalar
  font1.CvFont: cvInitFont(@font1, #CV_FONT_HERSHEY_SIMPLEX, 1, 1, #Null, 2, #CV_AA)
  font2.CvFont : cvInitFont(@font2, #CV_FONT_HERSHEY_SIMPLEX, 0.5, 0.5, #Null, 1, #CV_AA)
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvSmooth(*image, *blur, #CV_BLUR, 3, 3, 0, 0)
      cvCvtColor(*blur, *hsv, #CV_BGR2HSV, 1)
      cvGet2D(@scalar1, *hsv, nY, nX)
      h.s = Right("00" + Str(scalar1\val[0]), 3)
      s.s = Right("00" + Str(scalar1\val[1]), 3)
      v.s = Right("00" + Str(scalar1\val[2]), 3)
      b.s = Right("00" + Str(scalar2\val[0]), 3)
      g.s = Right("00" + Str(scalar2\val[1]), 3)
      r.s = Right("00" + Str(scalar2\val[2]), 3)
      x.s = Right("00" + Str(nX), 3)
      y.s = Right("00" + Str(nY), 3)

      If show = 0 Or show = 2
        cvPutText(*image, "H: " + h, 20, 40, @font1, 0, 255, 255, 0)
        cvPutText(*image, "S: " + s, 20, 80, @font1, 0, 255, 255, 0)
        cvPutText(*image, "V: " + v, 20, 120, @font1, 0, 255, 255, 0)
        cvGet2D(@scalar2, *blur, nY, nX)
        cvPutText(*image, "B: " + b, 250, 40, @font1, 255, 255, 255, 0)
        cvPutText(*image, "G: " + g, 250, 80, @font1, 255, 255, 255, 0)
        cvPutText(*image, "R: " + r, 250, 120, @font1, 255, 255, 255, 0)
        cvPutText(*image, "X: " + x, 480, 40, @font1, 0, 255, 0, 0)
        cvPutText(*image, "Y: " + y, 480, 80, @font1, 0, 255, 0, 0)
      EndIf

      If show = 0 Or show = 3
        Select value
          Case 0
            cvCircle(*image, 10, *image\height - 190 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 1
            cvCircle(*image, 10, *image\height - 170 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 2
            cvCircle(*image, 10, *image\height - 150 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 3
            cvCircle(*image, 10, *image\height - 130 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 4
            cvCircle(*image, 10, *image\height - 110 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 5
            cvCircle(*image, 10, *image\height - 90 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 6
            cvCircle(*image, 10, *image\height - 70 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 7
            cvCircle(*image, 10, *image\height - 50 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 8
            cvCircle(*image, 10, *image\height - 30 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          Case 9
            cvCircle(*image, 10, *image\height - 10 - 5, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
        EndSelect
        cvPutText(*image, "01. " + hsv1.s, 20, *image\height - 190, @font2, 0, 255, 255, 0)
        cvPutText(*image, "02. " + hsv2.s, 20, *image\height - 170, @font2, 0, 255, 255, 0)
        cvPutText(*image, "03. " + hsv3.s, 20, *image\height - 150, @font2, 0, 255, 255, 0)
        cvPutText(*image, "04. " + hsv4.s, 20, *image\height - 130, @font2, 0, 255, 255, 0)
        cvPutText(*image, "05. " + hsv5.s, 20, *image\height - 110, @font2, 0, 255, 255, 0)
        cvPutText(*image, "06. " + hsv6.s, 20, *image\height - 90, @font2, 0, 255, 255, 0)
        cvPutText(*image, "07. " + hsv7.s, 20, *image\height - 70, @font2, 0, 255, 255, 0)
        cvPutText(*image, "08. " + hsv8.s, 20, *image\height - 50, @font2, 0, 255, 255, 0)
        cvPutText(*image, "09. " + hsv9.s, 20, *image\height - 30, @font2, 0, 255, 255, 0)
        cvPutText(*image, "10. " + hsv10.s, 20, *image\height - 10, @font2, 0, 255, 255, 0)
        cvPutText(*image, "01. " + bgr1.s, 250, *image\height - 190, @font2, 255, 255, 255, 0)
        cvPutText(*image, "02. " + bgr2.s, 250, *image\height - 170, @font2, 255, 255, 255, 0)
        cvPutText(*image, "03. " + bgr3.s, 250, *image\height - 150, @font2, 255, 255, 255, 0)
        cvPutText(*image, "04. " + bgr4.s, 250, *image\height - 130, @font2, 255, 255, 255, 0)
        cvPutText(*image, "05. " + bgr5.s, 250, *image\height - 110, @font2, 255, 255, 255, 0)
        cvPutText(*image, "06. " + bgr6.s, 250, *image\height - 90, @font2, 255, 255, 255, 0)
        cvPutText(*image, "07. " + bgr7.s, 250, *image\height - 70, @font2, 255, 255, 255, 0)
        cvPutText(*image, "08. " + bgr8.s, 250, *image\height - 50, @font2, 255, 255, 255, 0)
        cvPutText(*image, "09. " + bgr9.s, 250, *image\height - 30, @font2, 255, 255, 255, 0)
        cvPutText(*image, "10. " + bgr10.s, 250, *image\height - 10, @font2, 255, 255, 255, 0)
        cvPutText(*image, "01. " + xy1.s, 480, *image\height - 190, @font2, 0, 255, 0, 0)
        cvPutText(*image, "02. " + xy2.s, 480, *image\height - 170, @font2, 0, 255, 0, 0)
        cvPutText(*image, "03. " + xy3.s, 480, *image\height - 150, @font2, 0, 255, 0, 0)
        cvPutText(*image, "04. " + xy4.s, 480, *image\height - 130, @font2, 0, 255, 0, 0)
        cvPutText(*image, "05. " + xy5.s, 480, *image\height - 110, @font2, 0, 255, 0, 0)
        cvPutText(*image, "06. " + xy6.s, 480, *image\height - 90, @font2, 0, 255, 0, 0)
        cvPutText(*image, "07. " + xy7.s, 480, *image\height - 70, @font2, 0, 255, 0, 0)
        cvPutText(*image, "08. " + xy8.s, 480, *image\height - 50, @font2, 0, 255, 0, 0)
        cvPutText(*image, "09. " + xy9.s, 480, *image\height - 30, @font2, 0, 255, 0, 0)
        cvPutText(*image, "10. " + xy10.s, 480, *image\height - 10, @font2, 0, 255, 0, 0)
      EndIf
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(10)

      Select keyPressed
        Case 13
          value = 0 : show = 0
          hsv1 = "" : hsv2 = "" : hsv3 = "" : hsv4 = "" : hsv5 = "" : hsv6 = "" : hsv7 = "" : hsv8 = "" : hsv9 = "" : hsv10 = ""
          bgr1 = "" : bgr2 = "" : bgr3 = "" : bgr4 = "" : bgr5 = "" : bgr6 = "" : bgr7 = "" : bgr8 = "" : bgr9 = "" : bgr10 = ""
          xy1 = "" : xy2 = "" : xy3 = "" : xy4 = "" : xy5 = "" : xy6 = "" : xy7 = "" : xy8 = "" : xy9 = "" : xy10 = ""
        Case 32
          Select value
            Case 0
              hsv1 = "H: " + h + " S: " + s + " V: " + v
              bgr1 = "B: " + b + " G: " + g + " R: " + r
              xy1 = "X: " + x + " Y: " + y
            Case 1
              hsv2 = "H: " + h + " S: " + s + " V: " + v
              bgr2 = "B: " + b + " G: " + g + " R: " + r
              xy2 = "X: " + x + " Y: " + y
            Case 2
              hsv3 = "H: " + h + " S: " + s + " V: " + v
              bgr3 = "B: " + b + " G: " + g + " R: " + r
              xy3 = "X: " + x + " Y: " + y
            Case 3
              hsv4 = "H: " + h + " S: " + s + " V: " + v
              bgr4 = "B: " + b + " G: " + g + " R: " + r
              xy4 = "X: " + x + " Y: " + y
            Case 4
              hsv5 = "H: " + h + " S: " + s + " V: " + v
              bgr5 = "B: " + b + " G: " + g + " R: " + r
              xy5 = "X: " + x + " Y: " + y
            Case 5
              hsv6 = "H: " + h + " S: " + s + " V: " + v
              bgr6 = "B: " + b + " G: " + g + " R: " + r
              xy6 = "X: " + x + " Y: " + y
            Case 6
              hsv7 = "H: " + h + " S: " + s + " V: " + v
              bgr7 = "B: " + b + " G: " + g + " R: " + r
              xy7 = "X: " + x + " Y: " + y
            Case 7
              hsv8 = "H: " + h + " S: " + s + " V: " + v
              bgr8 = "B: " + b + " G: " + g + " R: " + r
              xy8 = "X: " + x + " Y: " + y
            Case 8
              hsv9 = "H: " + h + " S: " + s + " V: " + v
              bgr9 = "B: " + b + " G: " + g + " R: " + r
              xy9 = "X: " + x + " Y: " + y
            Case 9
              hsv10 = "H: " + h + " S: " + s + " V: " + v
              bgr10 = "B: " + b + " G: " + g + " R: " + r
              xy10 = "X: " + x + " Y: " + y
          EndSelect

          If value = 9 : value = 0 : Else : value + 1 : EndIf

        Case 86, 118
          show = (show + 1) % 4
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*hsv)
  cvReleaseImage(@*blur)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
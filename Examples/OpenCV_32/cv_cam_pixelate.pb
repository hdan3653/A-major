IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, nBlock

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Pixelizes a webcam stream by averaging NxN block regions, and applying the color values " +
                  "to grid squares." + Chr(10) + Chr(10) + "- TRACKBAR: Adjust block size."

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

ProcedureC CvTrackbarCallback(pos)  
  Select pos
    Case 0
      nBlock = 0
    Case 1
      nBlock = 60
    Case 2
      nBlock = 40
    Case 3
      nBlock = 25
  EndSelect
EndProcedure

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
Until nCreate = 5 Or *capture

If *capture
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_NORMAL)
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
  cvResizeWindow(#CV_WINDOW_NAME, FrameWidth, FrameHeight + 48)
  nDefault = 2 : nBlock = 40
  cvCreateTrackbar("Block Size", #CV_WINDOW_NAME, @nDefault, 3, @CvTrackbarCallback())
  scalar.CvScalar
  *frame.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)  
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)

      If nBlock > 0
        blockSize = *image\width / nBlock - 1
        pixelCount = Pow(blockSize, 2)

        For x = 0 To *image\width - 1
          For y = 0 To *image\height - 1
            nB = 0
            nG = 0
            nR = 0

            If blockSize + x > *image\width - 1 : blockSizeX = *image\width - 1 - x : Else : blockSizeX = blockSize : EndIf
            If blockSize + y > *image\height - 1 : blockSizeY = *image\height - 1 - y : Else : blockSizeY = blockSize : EndIf

            For px = 0 To blockSizeX - 1
              For py = 0 To blockSizeY - 1
                cvGet2D(@scalar, *image, y + py, x + px)
                nB + scalar\val[0]
                nG + scalar\val[1]
                nR + scalar\val[2]
              Next
            Next
            B = nB / pixelCount
            G = nG / pixelCount
            R = nR / pixelCount
            cvRectangle(*frame, x, y, x + blockSizeX, y + blockSizeY, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
            y + blockSize
          Next
          x + blockSize
        Next
      Else
        *frame = *image
      EndIf
      cvShowImage(#CV_WINDOW_NAME, *frame)
      keyPressed = cvWaitKey(10)
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
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
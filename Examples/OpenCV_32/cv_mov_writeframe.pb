IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Draws text to a movie file and saves it as an AVI (Audio Video Interleaved); includes a " +
                  "blur-in / blur-out effect." + Chr(10) + Chr(10) + "NOTE:" + Chr(10) + "OpenCV only supports " +
                  "a single video track, no audio." + Chr(10) + Chr(10) + "File size may be increased exponentially " +
                  "(including loss in quality) depending on the codec." + Chr(10) + Chr(10) +
                  "Double-Click the window to open the folder where the file is saved."

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
    Case #CV_EVENT_LBUTTONDBLCLK
      RunProgram("explorer", "..\Videos", "")
  EndSelect
EndProcedure

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateFileCapture("movies/ball.mp4")
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

  If FileSize("../Videos") <> -2 : CreateDirectory("../Videos") : EndIf

  sVideo.s = "../Videos/ball.avi"
  fps.d = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FPS)
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  *writer.CvVideoWriter = cvCreateVideoWriter(sVideo, CV_FOURCC("D", "I", "V", "X"), fps, FrameWidth, FrameHeight, #True)

  If Not *writer : *writer = cvCreateVideoWriter(sVideo, CV_FOURCC("M", "S", "V", "C"), fps, FrameWidth, FrameHeight, #True) : EndIf

  If *writer
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_TRIPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
    *image.IplImage
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)
    BlurIn = fps * 3 * 2
    BlurOut = 1

    Repeat
      *image = cvQueryFrame(*capture)

      If *image
        cvPutText(*image, "JHPJHP", 10, 30, @font, 255, 0, 0, 0)
        FramePos.d = cvGetCaptureProperty(*capture, #CV_CAP_PROP_POS_FRAMES)
        FrameCount.d = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_COUNT)

        If FramePos <= fps * 3
          BlurIn - 2
          cvSmooth(*image, *image, #CV_BLUR, BlurIn, 0, 0, 0)
        ElseIf FrameCount - FramePos <= fps * 3
          BlurOut + 2
          cvSmooth(*image, *image, #CV_BLUR, BlurOut, 0, 0, 0)
        EndIf
        cvWriteFrame(*writer, *image)
        cvShowImage(#CV_WINDOW_NAME, *image)
        keyPressed = cvWaitKey(10)
      Else
        Break
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseVideoWriter(@*writer)
  EndIf
  cvDestroyAllWindows()  
  cvReleaseCapture(@*capture)
EndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
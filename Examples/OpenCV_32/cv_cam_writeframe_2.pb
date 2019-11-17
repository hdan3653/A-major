IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Images are saved to a folder." + Chr(10) + Chr(10) +
                  "Use the context menu to start / stop capture." + Chr(10) + Chr(10) +
                  "Double-Click the window to open the folder where the files are saved."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared CaptureCV.b, exitCV.b

  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          If CaptureCV
            SetMenuItemText(0, 1, "Capture")
            CaptureCV = #False
          Else
            If FileSize("../Frames") <> -2 : CreateDirectory("../Frames") : EndIf

            SetMenuItemText(0, 1, "Pause")
            CaptureCV = #True
          EndIf
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
      RunProgram("explorer", "..\Frames", "")
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
    MenuItem(1, "Capture")
    MenuBar()
    MenuItem(10, "Exit")
  EndIf
  hWnd = GetParent_(window_handle)
  opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
  SendMessage_(hWnd, #WM_SETICON, 0, opencv)
  wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)
  SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))
  cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
  ToolTip(window_handle, #CV_DESCRIPTION)
  sVideo.s = "../Frames/1. " + FormatDate("%mm-%dd-%yyyy %hh-%ii-%ss", Date()) + ".png"
  fps.d = 7
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  *writer.CvVideoWriter = cvCreateVideoWriter(sVideo, #CV_FOURCC_DEFAULT, fps, FrameWidth, FrameHeight, #True)

  If *writer
    *image.IplImage
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      *image = cvQueryFrame(*capture)

      If *image
        cvFlip(*image, #Null, 1)

        If CaptureCV : cvWriteFrame(*writer, *image) : EndIf

        cvShowImage(#CV_WINDOW_NAME, *image)
        keyPressed = cvWaitKey(100)
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseVideoWriter(@*writer)
  EndIf
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
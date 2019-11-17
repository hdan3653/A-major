IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Saves an online video to a folder using FFMPEG." + Chr(10) + Chr(10) +
                  "Double-Click the window to open the folder where the file is saved."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared CaptureCV.b, exitCV.b

  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 10
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
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

URL.s = "http://www.fileformat.info/format/mpeg/sample/567fd6a0e0da4a8e81bdeb870de3b19c/DELTA.MPG"

Repeat
  nCreate + 1
  *capture.CvCapture_FFMPEG = cvCreateFileCapture_FFMPEG(URL)
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

  sVideo.s = "../Videos/" + FormatDate("%mm-%dd-%yyyy %hh-%ii-%ss", Date()) + ".mpeg"
  avi_ratio.d = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_POS_AVI_RATIO)
  FrameWidth = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_FRAME_HEIGHT)
  fps.d = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_FPS)
  FOURCC.d = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_FOURCC)
  frame_count.d = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_FRAME_COUNT)
  *writer.CvVideoWriter_FFMPEG = cvCreateVideoWriter_FFMPEG(sVideo, CV_FOURCC("P", "I", "M", "1"), fps, FrameWidth, FrameHeight, #True)

  If *writer
    *image.IplImage
    *frame.IplImage = cvCreateImage(500, 430, #IPL_DEPTH_8U, 1)
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 0.5, 0.5, #Null, 1, #CV_AA)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If cvGrabFrame_FFMPEG(*capture)
        cvRetrieveFrame_FFMPEG(*capture, @*image, @cvStep, @width, @height, @cn)

        If *image
          msec.d = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_POS_MSEC)
          frame_position.d = cvGetCaptureProperty_FFMPEG(*capture, #CV_FFMPEG_CAP_PROP_POS_FRAMES)
          cvSetZero(*frame)
          cvPutText(*frame, "FRAME MSEC: " + Str(msec), 20, 40, @font, 255, 255, 255, 0)
          cvPutText(*frame, "FRAME POSITION: " + Str(frame_position), 20, 80, @font, 255, 255, 255, 0)
          cvPutText(*frame, "AVI RATIO: " + Str(avi_ratio), 20, 120, @font, 255, 255, 255, 0)
          cvPutText(*frame, "WIDTH: " + Str(FrameWidth), 20, 160, @font, 255, 255, 255, 0)
          cvPutText(*frame, "HEIGHT: " + Str(FrameHeight), 20, 200, @font, 255, 255, 255, 0)
          cvPutText(*frame, "FPS: " + Str(fps), 20, 240, @font, 255, 255, 255, 0)
          cvPutText(*frame, "FOURCC: " + Str(FOURCC), 20, 280, @font, 255, 255, 255, 0)
          cvPutText(*frame, "FRAME COUNT: " + Str(frame_count), 20, 320, @font, 255, 255, 255, 0)
          cvPutText(*frame, "-----------------------------------", 20, 360, @font, 255, 255, 255, 0)
          cvWriteFrame_FFMPEG(*writer, *image, cvStep, width, height, cn, #IPL_ORIGIN_TL)
          cvShowImage(#CV_WINDOW_NAME, *frame)
          keyPressed = cvWaitKey(1)
        EndIf
      Else
        cvPutText(*frame, "SAVED FILE: " + sVideo, 20, 400, @font, 255, 255, 255, 0)
        cvShowImage(#CV_WINDOW_NAME, *frame)
        cvReleaseVideoWriter_FFMPEG(@*writer)
        cvWaitKey(0)
        Break
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseImage(@*frame)
    cvReleaseVideoWriter_FFMPEG(@*writer)
  EndIf
  cvDestroyAllWindows()
  cvReleaseCapture_FFMPEG(@*capture)
EndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
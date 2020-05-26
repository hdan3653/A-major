IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Calculates the angle of a line between two tracked object, one red and one blue, " +
                  "relative to their horizontal position." + Chr(10) + Chr(10) +
                  "Double-Click the window to open a link to a demonstration video."

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
      RunProgram("http://www.youtube.com/watch?v=njab2bBps6U")
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
  *hsv.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *threshold1.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *threshold2.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *threshold3.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  moments1.CvMoments
  moments2.CvMoments
  font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_SIMPLEX, 1, 1, #Null, 2, #CV_AA)
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvCvtColor(*image, *hsv, #CV_BGR2HSV, 1)
      cvInRangeS(*hsv, 160, 140, 40, 0, 179, 255, 255, 0, *threshold1)
      cvInRangeS(*hsv, 40, 140, 160, 0, 179, 255, 255, 0, *threshold2)
      cvInRangeS(*hsv, 105, 180, 40, 0, 120, 255, 100, 0, *threshold3)
      cvAdd(*threshold1, *threshold2, *threshold1, #Null)
      cvMoments(*threshold1, @moments1, 0)
      cvMoments(*threshold3, @moments2, 0)
      area1.d = moments1\m00
      area2.d = moments2\m00

      If area1 > 200000 And area2 > 100000
        x1.d = moments1\m10 / area1
        y1.d = moments1\m01 / area1
        x2.d = moments2\m10 / area2
        y2.d = moments2\m01 / area2
        angle.d = ATan((y1 - y2) / (x2 - x1))
        cvLine(*image, x1, y1, *image\width, y1, 0, 255, 0, 0, 4, #CV_AA, #Null)
        cvLine(*image, x1, y1, x2, y2, 0, 255, 0, 0, 4, #CV_AA, #Null)
        cvCircle(*image, x1, y1, 2, 0, 255, 255, 0, 20, #CV_AA, #Null)
        cvCircle(*image, x2, y2, 2, 0, 255, 255, 0, 20, #CV_AA, #Null)
        cvPutText(*image, Str(x1) + "," + Str(y1), x1, y1 + 40, @font, 255, 255, 255, 0)
        cvPutText(*image, Str(x2) + "," + Str(y2), x2, y2 + 40, @font, 255, 255, 255, 0)
        cvPutText(*image, Str(Degree(angle)), x1 + 50, (y2 + y1) / 2, @font, 255, 255, 255, 0)
      EndIf
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(100)
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*threshold3)
  cvReleaseImage(@*threshold2)
  cvReleaseImage(@*threshold1)
  cvReleaseImage(@*hsv)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
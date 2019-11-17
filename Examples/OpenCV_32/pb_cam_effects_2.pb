IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Setting 1: Calculates the per-element bit-wise conjunction." + Chr(10) + Chr(10) +
                  "Setting 2: Calculates the per-element bit-wise “exclusive Or” operation."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared exitCV.b

  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 0
          SetFocus_(WindowID(0))
        Case 10
          HideWindow(0, 1)
          exitCV = #True
      EndSelect
    Case #WM_CHAR
      Select wParam
        Case #VK_ESCAPE
          HideWindow(0, 1)
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
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
  cvMoveWindow(#CV_WINDOW_NAME, -1000, -1000)
  cvResizeWindow(#CV_WINDOW_NAME, FrameWidth, FrameHeight)
  window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
  *window_name = cvGetWindowName(window_handle)
  lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())
  hWnd = GetParent_(window_handle)
  ShowWindow_(hWnd, #SW_HIDE)

  If OpenWindow(0, 0, 0, FrameWidth, FrameHeight + 60, #CV_WINDOW_NAME, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    SetWindowLongPtr_(WindowID(0), #GWL_WNDPROC, @WindowCallback())
    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
    SendMessage_(WindowID(0), #WM_SETICON, 0, opencv)
    ButtonGadget(0, 10, 490, 620, 40, "Toggle this button to change the webcam view between the Logical AND effect and the Logical XOR effect", #PB_Button_Toggle)

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(10, "Exit")
    EndIf
    ToolTip(window_handle, #CV_DESCRIPTION)
    SetParent_(window_handle, WindowID(0))
    BringToTop(WindowID(0))
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_SIMPLEX, 1.0, 1.0, #Null, 2, #CV_AA)
    *AND.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
    cvRectangleR(*AND, ptLeft, ptTop, FrameWidth, FrameHeight, 255, 255, 255, 0, #CV_FILLED, #CV_AA, #Null)
    cvLine(*AND, 120, 240, 295, 240, 255, 0, 0, 0, 8, #CV_AA, #Null)
    cvLine(*AND, 345, 240, 520, 240, 0, 0, 255, 0, 8, #CV_AA, #Null)
    cvLine(*AND, 320, 040, 320, 215, 0, 255, 255, 0, 8, #CV_AA, #Null)
    cvLine(*AND, 320, 265, 320, 440, 0, 255, 0, 0, 8, #CV_AA, #Null)
    cvCircle(*AND, 320, 240, 100, 0, 0, 0, 0, 8, #CV_AA, #Null)
    cvCircle(*AND, 320, 240, 200, 0, 0, 0, 0, 8, #CV_AA, #Null)
    cvPutText(*AND, "AND Effect", 10, 40, @font, 0, 0, 0, 0)
    cvPutText(*AND, "AND Effect", 7, 37, @font, 0, 0, 255, 0)
    *XOR.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
    cvRectangleR(*XOR, ptLeft, ptTop, FrameWidth, FrameHeight, 0, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
    cvLine(*XOR, 120, 240, 295, 240, 0, 255, 255, 0, 8, #CV_AA, #Null)
    cvLine(*XOR, 345, 240, 520, 240, 255, 255, 0, 0, 8, #CV_AA, #Null)
    cvLine(*XOR, 320, 040, 320, 215, 255, 0, 0, 0, 8, #CV_AA, #Null)
    cvLine(*XOR, 320, 265, 320, 440, 255, 0, 255, 0, 8, #CV_AA, #Null)
    cvCircle(*XOR, 320, 240, 100, 255, 255, 255, 0, 8, #CV_AA, #Null)
    cvCircle(*XOR, 320, 240, 200, 255, 255, 255, 0, 8, #CV_AA, #Null)
    cvPutText(*XOR, "XOR Effect", 10, 40, @font, 255, 255, 255, 0)
    cvPutText(*XOR, "XOR Effect", 7, 37, @font, 255, 0, 255, 0)
    *logical.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
    *image.IplImage

    Repeat
      *image = cvQueryFrame(*capture)

      If *image
        cvFlip(*image, #Null, 1)

        If GetGadgetState(0) : cvXor(*image, *XOR, *logical, #Null) : Else : cvAnd(*image, *AND, *logical, #Null) : EndIf

        cvShowImage(#CV_WINDOW_NAME, *logical)
        cvWaitKey(100)
      EndIf
    Until WindowEvent() = #PB_Event_CloseWindow Or exitCV
    cvReleaseImage(@*logical)
    FreeMemory(*param)
  EndIf
  cvReleaseImage(@*XOR)
  cvReleaseImage(@*AND)
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
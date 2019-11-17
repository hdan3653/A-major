IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, *capture.CvCapture, Dim size.Size(0)

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Builds a resolution list supported by your webcam, adding it as a context submenu."

ProcedureC SetResolution(hWnd, Resolution.s)
  nPosition = FindString(Resolution, "x")
  width = Val(Left(Resolution, nPosition - 1))
  height = Val(Mid(Resolution, nPosition + 1))
  BringToTop(WindowID(0))
  cvSetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH, width)
  cvSetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT, height)
  Delay(1000) : ResizeWindow(0, 10, 10, width, height)
  SetWindowPos_(hWnd, 0, 0, 0, width, height, #SWP_NOMOVE | #SWP_NOZORDER | #SWP_NOACTIVATE)
EndProcedure

ProcedureC ResolutionList(MaxWidth = 1280, nInterval = 100)
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)

  Select #True
    Case Bool(MaxWidth < FrameWidth)
      MaxWidth = FrameWidth
    Case Bool(nInterval > FrameWidth)
      nInterval = FrameWidth
    Case Bool(nInterval < 50)
      nInterval = 50
  EndSelect

  For rtnCount = 1 To MaxWidth / nInterval
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH, rtnCount * nInterval)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT, rtnCount * nInterval)
    tmpFrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)

    If Not FindString(SearchString.s, Str(tmpFrameWidth) + ";")
      ReDim size(ArraySize(size()) + 1)
      size(ArrayCount)\cx = tmpFrameWidth
      size(ArrayCount)\cy = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
      FrameWidth = size(ArrayCount)\cx : FrameHeight = size(ArrayCount)\cy
      SearchString + Str(tmpFrameWidth) + ";"
      ArrayCount + 1
    EndIf
    SetGadgetText(2, GetGadgetText(2) + ".")
  Next
  ProcedureReturn ArraySize(size())
EndProcedure

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared exitCV.b

  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 10
          HideWindow(0, 1)
          exitCV = #True
        Default
          SetResolution(WindowID(0), GetMenuItemText(0, wParam)) : x = 3

          Repeat
            SetMenuItemState(0, x, 0) : x + 1
          Until GetMenuItemText(0, x) = ""
          SetMenuItemState(0, wParam, 1)
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
  *capture = cvCreateCameraCapture(#CV_CAP_ANY)
Until nCreate = 5 Or *capture

If *capture
  FrameWidth = 600 : FrameHeight = 300
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
  cvMoveWindow(#CV_WINDOW_NAME, -1000, -1000)
  cvResizeWindow(#CV_WINDOW_NAME, FrameWidth, FrameHeight)
  window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
  *window_name = cvGetWindowName(window_handle)
  lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())
  hWnd = GetParent_(window_handle)
  ShowWindow_(hWnd, #SW_HIDE)

  If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, #CV_WINDOW_NAME, #PB_Window_BorderLess | #PB_Window_ScreenCentered | #WS_THICKFRAME)
    SetWindowLongPtr_(WindowID(0), #GWL_WNDPROC, @WindowCallback())
    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
    SendMessage_(WindowID(0), #WM_SETICON, 0, opencv)
    LoadFont(1, "Comic Sans MS", 44, #PB_Font_Italic)
    TextGadget(0, 0, 10, 580, 90, "Building", #PB_Text_Center) : SetGadgetColor(0, #PB_Gadget_FrontColor, RGB(0, 39, 0))
    TextGadget(1, 0, 110, 580, 90, "Resolution", #PB_Text_Center) : SetGadgetColor(1, #PB_Gadget_FrontColor, RGB(0, 39, 0))
    TextGadget(2, 0, 210, 580, 90, "List", #PB_Text_Center) : SetGadgetColor(2, #PB_Gadget_FrontColor, RGB(0, 39, 0))
    SetGadgetFont(0, FontID(1)) : SetGadgetFont(1, FontID(1)) : SetGadgetFont(2, FontID(1)) : BringToTop(WindowID(0))
    nSize = ResolutionList()

    If nSize
      HideGadget(0, 1) : HideGadget(1, 1) : HideGadget(2, 1)
      SetWindowLong_(WindowID(0), #GWL_STYLE, GetWindowLong_(WindowID(0), #GWL_STYLE) & ~#WS_THICKFRAME | #WS_CAPTION | #WS_SYSMENU)

      If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
        OpenSubMenu("Resolution")

        For rtnCount = 0 To nSize - 1
          MenuItem(rtnCount + 3, Str(size(rtnCount)\cx) + "x" + Str(size(rtnCount)\cy))
        Next
        CloseSubMenu()
        MenuBar()
        MenuItem(10, "Exit")
        SetResolution(WindowID(0), GetMenuItemText(0, nSize + 2))
        SetMenuItemState(0, nSize + 2, 1)
      EndIf
      ToolTip(window_handle, #CV_DESCRIPTION)
      SetParent_(window_handle, WindowID(0))
      *image.IplImage
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        *image = cvQueryFrame(*capture)

        If *image
          cvFlip(*image, #Null, 1)
          cvShowImage(#CV_WINDOW_NAME, *image)
          cvWaitKey(100)
        EndIf
      Until WindowEvent() = #PB_Event_CloseWindow Or exitCV
      FreeMemory(*param)
    EndIf
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
IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, *capture.CvCapture
Global DefBrightness.d, MaxBrightness.d, MinBrightness.d, DefContrast.d, MaxContrast.d, MinContrast.d
Global DefGamma.d, MaxGamma.d, MinGamma.d, DefSaturation.d, MaxSaturation.d, MinSaturation.d
Global DefHue.d, MaxHue.d, MinHue.d, DefSharpness.d, MaxSharpness.d, MinSharpness.d
Global DefExposure.d, MaxExposure.d, MinExposure.d

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Creates an interface to the webcam's parameters such as brightness, contrast, hue, etc." + Chr(10) + Chr(10) +
                  "NOTE:" + Chr(10) + "A default preference file is created if one cannot be found."

ProcedureC ReadCamData()
  If OpenPreferences("default/preferences.txt")
    DefBrightness = ReadPreferenceLong("DefBrightness", 1)
    DefContrast =  ReadPreferenceLong("DefContrast", 1)
    DefGamma = ReadPreferenceLong("DefGamma", 1)
    DefSaturation = ReadPreferenceLong("DefSaturation", 1)
    DefHue = ReadPreferenceLong("DefHue", 1)
    DefSharpness = ReadPreferenceLong("DefSharpness", 1)
    DefExposure = ReadPreferenceLong("DefExposure", 1)
    MaxBrightness = ReadPreferenceLong("MaxBrightness", 1)
    MaxContrast = ReadPreferenceLong("MaxContrast", 1)
    MaxGamma = ReadPreferenceLong("MaxGamma", 1)
    MaxSaturation = ReadPreferenceLong("MaxSaturation", 1)
    MaxHue = ReadPreferenceLong("MaxHue", 1)
    MaxSharpness = ReadPreferenceLong("MaxSharpness", 1)
    MaxExposure = ReadPreferenceLong("MaxExposure", 1)
    MinBrightness = ReadPreferenceLong("MinBrightness", 1)
    MinContrast =  ReadPreferenceLong("MinContrast", 1)
    MinGamma = ReadPreferenceLong("MinGamma", 1)
    MinSaturation = ReadPreferenceLong("MinSaturation", 1)
    MinHue = ReadPreferenceLong("MinHue", 1)
    MinSharpness = ReadPreferenceLong("MinSharpness", 1)
    MinExposure = ReadPreferenceLong("MinExposure", 1)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS, DefBrightness)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST, DefContrast)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA, DefGamma)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION, DefSaturation)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_HUE, DefHue)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS, DefSharpness)
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE, DefExposure)
  Else
    CreatePreferences("default/preferences.txt")
    defValue.d = 0
    value.d = 0
    retValue.d = 0
    OpenWindow(0, 0, 0, 300, 100, #CV_WINDOW_NAME, #PB_Window_ScreenCentered | #PB_Window_Tool)
    TextGadget(30, 10,  40, 280, 20, "Testing webcam parameters...", #PB_Text_Center)
    defValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS)
    WritePreferenceLong("DefBrightness", defValue)
    DefBrightness = defValue

    For k = defValue To 1000 Step 1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MaxBrightness", cvGetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS))
    MaxBrightness = retValue

    For k = defValue To 0 Step -1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MinBrightness", cvGetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS))
    MinBrightness = retValue
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS, defValue)
    defValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST)
    WritePreferenceLong("DefContrast", defValue)
    DefContrast = defValue

    For k = defValue To 1000 Step 1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MaxContrast", cvGetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST))
    MaxContrast = retValue

    For k = defValue To 0 Step -1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST)

      If value < retValue : Break : EndIf

    Next
    WritePreferenceLong("MinContrast", cvGetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST))
    MinContrast = retValue
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST, defValue)
    defValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA)
    WritePreferenceLong("DefGamma", defValue)
    DefGamma = defValue

    For k = defValue To 1000 Step 5
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MaxGamma", cvGetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA))
    MaxGamma = retValue

    For k = defValue To 0 Step -5
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA)

      If value < retValue : Break : EndIf

    Next
    WritePreferenceLong("MinGamma", cvGetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA))
    MinGamma = retValue
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA, defValue)
    defValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION)
    WritePreferenceLong("DefSaturation", defValue)
    DefSaturation = defValue

    For k = defValue To 1000 Step 1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION, value) 
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MaxSaturation", cvGetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION))
    MaxSaturation = retValue

    For k = defValue To 0 Step -1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION)

      If value < retValue : Break : EndIf

    Next
    WritePreferenceLong("MinSaturation", cvGetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION))
    MinSaturation = retValue
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION, defValue)
    defValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_HUE)
    WritePreferenceLong("DefHue", defValue)
    DefHue = defValue

    For k = defValue To 1000 Step 1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_HUE, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_HUE)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MaxHue", cvGetCaptureProperty(*capture, #CV_CAP_PROP_HUE))
    MaxHue = retValue

    For k = defValue To 0 Step -1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_HUE, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_HUE)

      If value < retValue : Break : EndIf

    Next
    WritePreferenceLong("MinHue", cvGetCaptureProperty(*capture, #CV_CAP_PROP_HUE))
    MinHue = retValue
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_HUE, defValue)
    defValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS)
    WritePreferenceLong("DefSharpness", defValue)
    DefSharpness = defValue

    For k = defValue To 1000 Step 1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MaxSharpness", cvGetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS))
    MaxSharpness = retValue

    For k = defValue To 0 Step -1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS)

      If value < retValue : Break : EndIf

    Next
    WritePreferenceLong("MinSharpness", cvGetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS))
    MinSharpness = retValue
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS, defValue)
    defValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE)
    WritePreferenceLong("DefExposure", defValue)
    DefExposure = defValue

    For k = defValue To 1000 Step 1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE)

      If value > retValue : Break : EndIf

    Next
    WritePreferenceLong("MaxExposure", cvGetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE))
    MaxExposure = retValue

    For k = defValue To 0 Step -1
      value = k
      cvSetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE, value)
      retValue = cvGetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE)

      If value < retValue : Break : EndIf

    Next
    WritePreferenceLong("MinExposure", cvGetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE))
    MinExposure = retValue
    cvSetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE, defValue)
    CloseWindow(0)
  EndIf
EndProcedure

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared exitCV.b

  Select Msg
    Case #WM_NOTIFY
      val.d = GetGadgetState(wParam)

      Select wParam
        Case 7
          cvSetCaptureProperty(*capture, #CV_CAP_PROP_BRIGHTNESS, val)
          WritePreferenceLong("DefBrightness", val)
        Case 8
          cvSetCaptureProperty(*capture, #CV_CAP_PROP_CONTRAST, val)
          WritePreferenceLong("DefContrast", val)
        Case 9
          cvSetCaptureProperty(*capture, #CV_CAP_PROP_GAMMA, val)
          WritePreferenceLong("DefGamma", val)
        Case 10
          cvSetCaptureProperty(*capture, #CV_CAP_PROP_SATURATION, val)
          WritePreferenceLong("DefSaturation", val)
        Case 11
          cvSetCaptureProperty(*capture, #CV_CAP_PROP_HUE, val)
          WritePreferenceLong("DefHue", val)
        Case 12
          cvSetCaptureProperty(*capture, #CV_CAP_PROP_SHARPNESS, val)
          WritePreferenceLong("DefSharpness", val)
        Case 13
          cvSetCaptureProperty(*capture, #CV_CAP_PROP_EXPOSURE, val)
          WritePreferenceLong("DefExposure", val)
      EndSelect
      SetFocus_(WindowID(0))
    Case #WM_COMMAND
      Select wParam
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
  *capture = cvCreateCameraCapture(#CV_CAP_ANY)
Until nCreate = 5 Or *capture

If *capture
  FrameWidth = 640
  FrameHeight = 480
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
  cvMoveWindow(#CV_WINDOW_NAME, -1000, -1000)
  cvResizeWindow(#CV_WINDOW_NAME, FrameWidth, FrameHeight)
  window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
  *window_name = cvGetWindowName(window_handle)
  lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())
  hWnd = GetParent_(window_handle)
  ShowWindow_(hWnd, #SW_HIDE)
  ReadCamData()
  cvSetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH, FrameWidth)
  cvSetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT, FrameHeight)

  If OpenWindow(0, 0, 0, 800, 480, #CV_WINDOW_NAME, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    SetWindowLongPtr_(WindowID(0), #GWL_WNDPROC, @WindowCallback())
    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
    SendMessage_(WindowID(0), #WM_SETICON, 0, opencv)
    TextGadget(0, 650, 25, 60, 20, "Brightness:", #PB_Text_Right)
    TextGadget(1, 650, 50, 60, 20, "Contrast:", #PB_Text_Right)
    TextGadget(2, 650, 75, 60, 20, "Gamma:", #PB_Text_Right)
    TextGadget(3, 650, 100, 60, 20, "Saturation:", #PB_Text_Right)
    TextGadget(4, 650, 125, 60, 20, "Hue:", #PB_Text_Right)
    TextGadget(5, 650, 150, 60, 20, "Sharpness:", #PB_Text_Right)
    TextGadget(6, 650, 175, 60, 20, "Exposure:", #PB_Text_Right)
    SpinGadget(7, 715, 20, 50, 20, MinBrightness, MaxBrightness, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
    SetGadgetState(7, DefBrightness)
    SpinGadget(8, 715, 45, 50, 20, MinContrast, MaxContrast, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
    SetGadgetState(8, DefContrast)
    SpinGadget(9, 715, 70, 50, 20, MinGamma, MaxGamma, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
    SetGadgetState(9, DefGamma)
    SpinGadget(10, 715, 95, 50, 20, MinSaturation, MaxSaturation, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
    SetGadgetState(10, DefSaturation)
    SpinGadget(11, 715, 120, 50, 20, MinHue, MaxHue, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
    SetGadgetState(11, DefHue)
    SpinGadget(12, 715, 145, 50, 20, MinSharpness, MaxSharpness, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
    SetGadgetState(12, DefSharpness)
    SpinGadget(13, 715, 170, 50, 20, MinExposure, MaxExposure, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
    SetGadgetState(13, DefExposure)

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(10, "Exit")
    EndIf
    ToolTip(window_handle, #CV_DESCRIPTION)
    SetParent_(window_handle, WindowID(0))
    BringToTop(WindowID(0))
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)
    *image.IplImage

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
  ClosePreferences()
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
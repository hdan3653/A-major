IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Builds a direct and inverse Haar Wavelet transform." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Toggle direct / inverse." +
                  Chr(10) + Chr(10) + "- [ S ] KEY: Shrinkage (inverse only)."

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

Procedure.f Sgn(x.f)
  Select #True
    Case Bool(x = 0)
      ProcedureReturn 0
    Case Bool(x > 0)
      ProcedureReturn 1
    Case Bool(x < 0)
      ProcedureReturn -1
  EndSelect
EndProcedure

Procedure.f HardShrink(d.f, T.f)
  If Abs(d) > T : ProcedureReturn d : Else : ProcedureReturn 0 : EndIf
EndProcedure

Procedure.f SoftShrink(d.f, T.f)
  If Abs(d) > T : ProcedureReturn Sgn(d) * (Abs(d) - T) : Else : ProcedureReturn 0 : EndIf
EndProcedure

Procedure.f GarrotShrink(d.f, T.f)
  If Abs(d) > T : ProcedureReturn d - T * T / d : Else : ProcedureReturn 0 : EndIf
EndProcedure

ProcedureC HaarWavelet(*src.CvMat, *dst.CvMat, nIterations)
  width = *src\cols
  height = *src\rows

  For k = 0 To nIterations - 1
    For y = 0 To (height >> (k + 1)) - 1
      For x = 0 To (width >> (k + 1)) - 1
        c.f = (cvmGet(*src, 2 * y, 2 * x) + cvmGet(*src, 2 * y, 2 * x + 1) + cvmGet(*src, 2 * y + 1, 2 * x) + cvmGet(*src, 2 * y + 1, 2 * x + 1)) * 0.5
        cvmSet(*dst, y, x, c)
        dh.f = (cvmGet(*src, 2 * y, 2 * x) + cvmGet(*src, 2 * y + 1, 2 * x) - cvmGet(*src, 2 * y, 2 * x + 1) - cvmGet(*src, 2 * y + 1, 2 * x + 1)) * 0.5
        cvmSet(*dst, y, x + (width >> (k + 1)), dh)
        dv.f = (cvmGet(*src, 2 * y, 2 * x) + cvmGet(*src, 2 * y, 2 * x + 1) - cvmGet(*src, 2 * y + 1, 2 * x) - cvmGet(*src, 2 * y + 1, 2 * x + 1)) * 0.5
        cvmSet(*dst, y + (height >> (k + 1)), x, dv)
        dd.f = (cvmGet(*src, 2 * y, 2 * x) - cvmGet(*src, 2 * y, 2 * x + 1) - cvmGet(*src, 2 * y + 1, 2 * x) + cvmGet(*src, 2 * y + 1, 2 * x + 1)) * 0.5
        cvmSet(*dst, y + (height >> (k + 1)), x + (width >> (k + 1)), dd)
      Next
    Next
    cvCopy(*dst, *src, #Null)
  Next
EndProcedure

#NONE = 0
#HARD = 1
#SOFT = 2
#GARROTE = 3

ProcedureC InverseHaarWavelet(*src.CvMat, *dst.CvMat, nIterations, SHRINKAGE_TYPE, SHRINKAGE_T.f)
  temp.CvMat
  width = *src\cols
  height = *src\rows

  For k = nIterations To 1 Step -1
    For y = 0 To (height >> k) - 1
      For x = 0 To (width >> k) - 1
        c.f = cvmGet(*src, y, x)
        dh.f = cvmGet(*src, y, x + (width >> k))
        dv.f = cvmGet(*src, y + (height >> k), x)
        dd.f = cvmGet(*src, y + (height >> k), x + (width >> k))
        
        Select SHRINKAGE_TYPE
          Case #HARD
            dh = HardShrink(dh, SHRINKAGE_T)
            dv = HardShrink(dv, SHRINKAGE_T)
            dd = HardShrink(dd, SHRINKAGE_T)
          Case #SOFT
            dh = SoftShrink(dh, SHRINKAGE_T)
            dv = SoftShrink(dv, SHRINKAGE_T)
            dd = SoftShrink(dd, SHRINKAGE_T)
          Case #GARROTE
            dh = GarrotShrink(dh, SHRINKAGE_T)
            dv = GarrotShrink(dv, SHRINKAGE_T)
            dd = GarrotShrink(dd, SHRINKAGE_T)
        EndSelect
        cvmSet(*dst, 2 * y, 2 * x, 0.5 * (c + dh + dv + dd))
        cvmSet(*dst, 2 * y, 2 * x + 1, 0.5 * (c - dh + dv - dd))
        cvmSet(*dst, 2 * y + 1, 2 * x, 0.5 * (c + dh - dv - dd))
        cvmSet(*dst, 2 * y + 1, 2 * x + 1, 0.5 * (c - dh - dv + dd))
      Next
    Next
    *D.CvMat = cvGetSubRect(*dst, @temp, 0, 0, width >> (k - 1), height >> (k - 1))
    *S.CvMat = cvGetSubRect(*src, @temp, 0, 0, width >> (k - 1), height >> (k - 1))
    cvCopy(*D, *S, #Null)
  Next
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
  nIterations = 4
  *gray.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 1))
  *src.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_32F, 1))
  *dst.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_32F, 1))
  *temp.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_32F, 1))
  *filtered.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_32F, 1))
  *image.CvMat
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvCvtColor(*image, *gray, #CV_BGR2GRAY, 1)
      cvConvert(*gray, *src)
      cvSetZero(*dst)
      HaarWavelet(*src, *dst, nIterations)
      cvCopy(*dst, *temp, #Null)

      Select SHRINKAGE_TYPE
        Case 0
          InverseHaarWavelet(*temp, *filtered, nIterations, SHRINKAGE_TYPE + 1, 60)
        Case 1
          InverseHaarWavelet(*temp, *filtered, nIterations, SHRINKAGE_TYPE + 1, 30)
        Case 2
          InverseHaarWavelet(*temp, *filtered, nIterations, SHRINKAGE_TYPE + 1, 50)
      EndSelect
      cvMinMaxLoc(*dst, @min_val.d, @max_val.d, #Null, #Null, #Null)

      If max_val - min_val > 0 : cvMul(*dst, *dst, *dst, (1 / (max_val - min_val)) - min_val / (max_val - min_val)) : EndIf

      cvMinMaxLoc(*filtered, @min_val.d, @max_val.d, #Null, #Null, #Null)

      If max_val - min_val > 0 : cvMul(*filtered, *filtered, *filtered, (1 / (max_val - min_val)) - min_val / (max_val - min_val)) : EndIf      
      If filter : cvShowImage(#CV_WINDOW_NAME, *filtered) : Else : cvShowImage(#CV_WINDOW_NAME, *dst) : EndIf

      keyPressed = cvWaitKey(5)

      Select keyPressed
        Case 32
          filter ! 1
        Case 83, 115
          SHRINKAGE_TYPE = (SHRINKAGE_TYPE + 1) % 3
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV
  cvReleaseMat(@*filtered)
  cvReleaseMat(@*temp)
  cvReleaseMat(@*dst)
  cvReleaseMat(@*src)
  cvReleaseMat(@*gray)
  FreeMemory(*param)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
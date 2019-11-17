IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Dense optical flow technique using the Gunnar Farneback algorithm."

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

ProcedureC DrawOptFlowMap(*flow.CvMat, *flowmap.CvMat, scale.d, B, G, R)
  *fxy.CvPoint2D32f

  For y = 16 To *flowmap\rows - 16 Step 16
    For x = 16 To *flowmap\cols - 16 Step 16
      CV_MAT_ELEM(*flow, CvPoint2D32f, y, x, *fxy)
      cvLine(*flowmap, x, y, x + *fxy\x, y + *fxy\y, B, G, R, 0, 1, #CV_AA, #Null)
      cvCircle(*flowmap, x, y, 2, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
    Next
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
  *next.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 1))
  *prev.CvMat = cvCreateMat(*next\rows, *next\cols, *next\type)
  *flow.CvMat = cvCreateMat(*next\rows, *next\cols, CV_MAKETYPE(#CV_32F, 2))
  *flowmap.CvMat = cvCreateMat(*next\rows, *next\cols, CV_MAKETYPE(#CV_8U, 3))
  *swap_mat.CvMat
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvCvtColor(*image, *next, #CV_BGR2GRAY, 1)

      If *prev\ptr\b
        cvCalcOpticalFlowFarneback(*prev, *next, *flow, 0.5, 3, 10, 3, 5, 1.1, #OPTFLOW_USE_INITIAL_FLOW)
        cvCvtColor(*prev, *flowmap, #CV_GRAY2BGR, 1)
        DrawOptFlowMap(*flow, *flowmap, 1.5, 0, 255, 0)
        cvShowImage(#CV_WINDOW_NAME, *flowmap)
      EndIf
      keyPressed = cvWaitKey(10)
      CV_SWAP(*prev, *next, *swap_mat)
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseMat(@*flowmap)
  cvReleaseMat(@*flow)
  cvReleaseMat(@*prev)
  cvReleaseMat(@*next)
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
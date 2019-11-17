IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Performs a discrete Cosine transform of a 1D array, displaying its power spectrum."

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

  If FrameWidth % 2 = 0 : width = FrameWidth : Else : width = FrameWidth + 1 : EndIf
  If FrameHeight % 2 = 0 : height = FrameHeight : Else : height = FrameHeight + 1 : EndIf

  *gray.CvMat = cvCreateMat(FrameHeight, FrameWidth, CV_MAKETYPE(#CV_8U, 1))
  *border.CvMat = cvCreateMat(height, width, CV_MAKETYPE(#CV_8U, 1))
  *dct.CvMat = cvCreateMat(height, width, CV_MAKETYPE(#CV_64F, 1))
  *frequency1.CvMat = cvCreateMat(height, width, CV_MAKETYPE(#CV_64F, 1))
  *frequency2.CvMat = cvCreateMat(height, width, CV_MAKETYPE(#CV_8U, 1))
  *big.CvMat = cvCreateMat(height, width * 2, CV_MAKETYPE(#CV_8U, 1))
  *roi1.CvMat : *roi2.CvMat : roi1.CvMat : roi2.CvMat
  *image.CvMat
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvCvtColor(*image, *gray, #CV_RGB2GRAY, 1)
      cvCopyMakeBorder(*gray, *border, height - FrameHeight, width - FrameWidth, #IPL_BORDER_REPLICATE, 0, 0, 0, 0)
      cvConvert(*border, *dct)
      cvDCT(*dct, *frequency1, #DCT_FORWARD)
      cvAbs(*frequency1, *frequency1)
      cvLog(*frequency1, *frequency1)
      cvNormalize(*frequency1, *frequency1, 0, 255, #NORM_MINMAX, #Null)
      cvConvert(*frequency1, *frequency2)
      *roi1 = cvGetSubRect(*big, @roi1, 0, 0, width, height)
      cvCopy(*border, *roi1, #Null)
      *roi2 = cvGetSubRect(*big, @roi2, width, 0, width, height)
      cvCopy(*frequency2, *roi2, #Null)
      cvShowImage(#CV_WINDOW_NAME, *big)
      keyPressed = cvWaitKey(1)
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseMat(@*big)
  cvReleaseMat(@*frequency2)
  cvReleaseMat(@*frequency1)
  cvReleaseMat(@*dct)
  cvReleaseMat(@*border)
  cvReleaseMat(@*gray)
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
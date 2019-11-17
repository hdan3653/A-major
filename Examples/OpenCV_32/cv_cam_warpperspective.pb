IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, nFlag, nAnchor, Dim srcPoint.CvPoint2D32f(4), Dim dstPoint.CvPoint2D32f(4)

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Calculates a perspective transform from four pairs of corresponding points." +
                  Chr(10) + Chr(10) + "- MOUSE: Modify warp dimensions." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Toggle control anchors." +
                  Chr(10) + Chr(10) + "- ENTER: Reset warp dimensions."

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

ProcedureC InRectangle(pX, pY, tlX, tlY, brX, brY)
 If pX >= tlX And pX <= brX And pY >= tlY And pY <= brY : ProcedureReturn 1 : Else : ProcedureReturn 0 : EndIf
EndProcedure

ProcedureC SetDimensions(width, height)
  srcPoint(0)\x = 0
  srcPoint(0)\y = 0
  srcPoint(1)\x = width - 1
  srcPoint(1)\y = 0
  srcPoint(2)\x = 0
  srcPoint(2)\y = height - 1
  srcPoint(3)\x = width - 1
  srcPoint(3)\y = height - 1
  dstPoint(0)\x = width * 0.05
  dstPoint(0)\y = height * 0.33
  dstPoint(1)\x = width * 0.9
  dstPoint(1)\y = height * 0.25
  dstPoint(2)\x = width * 0.2
  dstPoint(2)\y = height * 0.7
  dstPoint(3)\x = width * 0.8
  dstPoint(3)\y = height * 0.9
EndProcedure

ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)
  Select event
    Case #CV_EVENT_RBUTTONDOWN
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      If nAnchor
        For rtnCount = 0 To 4 - 1
          If InRectangle(x, y, dstPoint(rtnCount)\x - 5, dstPoint(rtnCount)\y - 5, dstPoint(rtnCount)\x + 5, dstPoint(rtnCount)\y + 5)
            nFlag = rtnCount
            Break
          EndIf
          nFlag = -1
        Next
      EndIf
    Case #CV_EVENT_MOUSEMOVE
      If nFlag <> -1 And Bool(flags & #CV_EVENT_FLAG_LBUTTON)
        dstPoint(nFlag)\x = x
        dstPoint(nFlag)\y = y
      EndIf
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
  nFlag = -1 : nAnchor = 1
  SetDimensions(FrameWidth, FrameHeight)
  *warp.CvMat = cvCreateMat(3, 3, CV_MAKETYPE(#CV_32F, 1))
  *matrix.IplImage
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvReleaseImage(@*matrix)
      *matrix = cvCloneImage(*image)

      If nAnchor
        cvGetPerspectiveTransform(@srcPoint(), @dstPoint(), *warp)
        cvWarpPerspective(*image, *matrix, *warp, #CV_INTER_LINEAR + #CV_WARP_FILL_OUTLIERS, 100, 100, 50, 0)

        For rtnCount = 0 To 4 - 1
          cvRectangle(*matrix, dstPoint(rtnCount)\x - 5, dstPoint(rtnCount)\y - 5, dstPoint(rtnCount)\x + 5, dstPoint(rtnCount)\y + 5, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
        Next
      Else
        cvWarpPerspective(*image, *matrix, *warp, #CV_INTER_LINEAR + #CV_WARP_FILL_OUTLIERS, 100, 100, 50, 0)
      EndIf
      cvShowImage(#CV_WINDOW_NAME, *matrix)
      keyPressed = cvWaitKey(10)

      Select keyPressed
        Case 13
          nFlag = -1 : nAnchor = 1
          SetDimensions(FrameWidth, FrameHeight)
        Case 32
          nAnchor ! 1
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*matrix)
  cvReleaseMat(@*warp)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
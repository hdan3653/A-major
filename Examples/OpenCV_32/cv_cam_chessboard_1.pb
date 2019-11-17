IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "After finding the positions of internal corners for a 10 x 7 chessboard pattern, " +
                  "a video is embedded using a warping algorithm." + Chr(10) + Chr(10) +
                  "Double-Click the window to open a link to a printable chessboard pattern."

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
      RunProgram("http://www.clipartbest.com/cliparts/RiA/5yo/RiA5yoKiL.png")
  EndSelect
EndProcedure

Repeat
  nCreate + 1
  *capture1.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
Until nCreate = 5 Or *capture1
nCreate = 0

Repeat
  nCreate + 1
  *capture2.CvCapture = cvCreateFileCapture("movies/ball.mp4")
Until nCreate = 5 Or *capture2

If *capture1 And *capture2
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
  FrameWidth1 = cvGetCaptureProperty(*capture1, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight1 = cvGetCaptureProperty(*capture1, #CV_CAP_PROP_FRAME_HEIGHT)
  FrameWidth2 = cvGetCaptureProperty(*capture2, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight2 = cvGetCaptureProperty(*capture2, #CV_CAP_PROP_FRAME_HEIGHT)
  #CORNER_ROW = 6 : #CORNER_COL = 9
  #PATTERN_SIZE = #CORNER_ROW * #CORNER_COL
  Dim corners.CvPoint2D32f(#PATTERN_SIZE)
  Dim srcPoint.CvPoint2D32f(4)
  Dim dstPoint.CvPoint2D32f(4)
  Dim pts.CvPoint(4)
  npts = ArraySize(pts())
  srcPoint(0)\x = 0
  srcPoint(0)\y = 0
  srcPoint(1)\x = FrameWidth2
  srcPoint(1)\y = 0
  srcPoint(2)\x = FrameWidth2
  srcPoint(2)\y = FrameHeight2
  srcPoint(3)\x = 0
  srcPoint(3)\y = FrameHeight2
  *matrix.CvMat = cvCreateMat(3, 3, CV_MAKETYPE(#CV_32F, 1))
  *gray.IplImage = cvCreateImage(FrameWidth1, FrameHeight1, #IPL_DEPTH_8U, 1)
  *blank.IplImage = cvCreateImage(FrameWidth2, FrameHeight2, #IPL_DEPTH_8U, 3)
  *negative.IplImage = cvCreateImage(FrameWidth1, FrameHeight1, #IPL_DEPTH_8U, 3)
  *copy.IplImage = cvCreateImage(FrameWidth1, FrameHeight1, #IPL_DEPTH_8U, 3)
  *image.IplImage : *frame.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture1)

    If *image
      cvFlip(*image, #Null, 1)
      cvCvtColor(*image, *gray, #CV_BGR2GRAY, 1)

      If cvCheckChessboard(*gray, #CORNER_COL, #CORNER_ROW)
        found = cvFindChessboardCorners(*gray, #CORNER_COL, #CORNER_ROW, @corners(), @corner_count, #CV_CALIB_CB_FAST_CHECK)

        If found
          cvFindCornerSubPix(*gray, @corners(), corner_count, 11, 11, -1, -1, #CV_TERMCRIT_ITER | #CV_TERMCRIT_EPS, 20, 0.03)

          If corner_count = #PATTERN_SIZE
            *frame = cvQueryFrame(*capture2)

            If *frame
              dstPoint(0)\x = corners(53)\x : pts(0)\x = dstPoint(0)\x
              dstPoint(0)\y = corners(53)\y : pts(0)\y = dstPoint(0)\y
              dstPoint(1)\x = corners(45)\x : pts(1)\x = dstPoint(1)\x
              dstPoint(1)\y = corners(45)\y : pts(1)\y = dstPoint(1)\y
              dstPoint(2)\x = corners(0)\x : pts(2)\x = dstPoint(2)\x
              dstPoint(2)\y = corners(0)\y : pts(2)\y = dstPoint(2)\y
              dstPoint(3)\x = corners(8)\x : pts(3)\x = dstPoint(3)\x
              dstPoint(3)\y = corners(8)\y : pts(3)\y = dstPoint(3)\y
              cvGetPerspectiveTransform(@srcPoint(), @dstPoint(), *matrix)
              cvSetZero(*blank)
              cvNot(*blank, *blank)
              cvWarpPerspective(*frame, *negative, *matrix, #CV_INTER_LINEAR | #CV_WARP_FILL_OUTLIERS, 0, 0, 0, 0)
              cvWarpPerspective(*blank, *copy, *matrix, #CV_INTER_LINEAR | #CV_WARP_FILL_OUTLIERS, 0, 0, 0, 0)
              cvNot(*copy, *copy)
              cvAnd(*copy, *image, *copy, #Null)
              cvOr(*copy, *negative, *image, #Null)
              cvPolyLine(*image, pts(), @npts, 1, #True, 0, 255, 255, 0, 2, #CV_AA, #Null)
            EndIf
          EndIf
        EndIf
      EndIf
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(1)
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*copy)
  cvReleaseImage(@*negative)
  cvReleaseImage(@*blank)
  cvReleaseImage(@*gray)
  cvReleaseMat(@*matrix)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture2)
  cvReleaseCapture(@*capture1)
Else
  If *capture1
    MessageBox_(0, "Unable to load video - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
  Else
    MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
  EndIf
EndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
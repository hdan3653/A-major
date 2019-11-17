IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Calculates a histogram for the Red, Green, and Blue channels." +
                  Chr(10) + Chr(10) + "- [ R ] KEY: Toggle red channel." +
                  Chr(10) + Chr(10) + "- [ G ] KEY: Toggle green channel." +
                  Chr(10) + Chr(10) + "- [ B ] KEY: Toggle blue channel." +
                  Chr(10) + Chr(10) + "- [ V ] KEY: Change PIP view."

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
  iRatio.d = 150 / FrameWidth
  iWidth = FrameWidth * iRatio
  iHeight = FrameHeight * iRatio
  *PIP.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 3)
  bins = 256
  Dim range.f(2) : range(0) = 0 : range(1) = 256
  PokeL(@*ranges, @range())
  *hist_blue.CvHistogram = cvCreateHist(1, @bins, #CV_HIST_ARRAY, @*ranges, 1)
  *hist_green.CvHistogram = cvCreateHist(1, @bins, #CV_HIST_ARRAY, @*ranges, 1)
  *hist_red.CvHistogram = cvCreateHist(1, @bins, #CV_HIST_ARRAY, @*ranges, 1)
  B.b = #True
  G.b = #True
  R.b = #True
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      *histogram.IplImage = cvLoadImage("images/scale.png", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
      *blue.IplImage = cvCreateImage(*histogram\width, *histogram\height, #IPL_DEPTH_8U, 3)
      *green.IplImage = cvCreateImage(*histogram\width, *histogram\height, #IPL_DEPTH_8U, 3)
      *red.IplImage = cvCreateImage(*histogram\width, *histogram\height, #IPL_DEPTH_8U, 3)
      Dim *blue_channel.IplImage(1) : *blue_channel(0) = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
      Dim *green_channel.IplImage(1) : *green_channel(0) = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
      Dim *red_channel.IplImage(1) : *red_channel(0) = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
      max_blue.d = 0
      max_green.d = 0
      max_red.d = 0
      max_value.d = 0
      cvSplit(*image, *blue_channel(0), *green_channel(0), *red_channel(0), #Null)
      cvCalcHist(*blue_channel(), *hist_blue, #False, #Null)
      cvCalcHist(*green_channel(), *hist_green, #False, #Null)
      cvCalcHist(*red_channel(), *hist_red, #False, #Null)

      For rtnCount = 0 To bins - 1
        max1.d = cvQueryHistValue_1D(*hist_blue, rtnCount)
        max2.d = cvQueryHistValue_1D(*hist_green, rtnCount)
        max3.d = cvQueryHistValue_1D(*hist_red, rtnCount)

        If max1 > max_blue : max_blue = max1 : EndIf
        If max2 > max_green : max_green = max2 : EndIf
        If max3 > max_red : max_red = max3 : EndIf

      Next
      max_value = max_blue
      CV_MAX(max_value, max_green)
      CV_MAX(max_value, max_red)

      If R
        cvConvertScale(*hist_red\bins, *hist_red\bins, 448 / max_value, 0)

        For rtnCount = 0 To bins - 1
          bottom = 448 - Round(cvQueryHistValue_1D(*hist_red, rtnCount), #PB_Round_Nearest)
          cvRectangle(*red, rtnCount * 3 + 15, 448, rtnCount * 3 + 16, bottom, 0, 0, 255, 0, #CV_FILLED, 8, #Null)
        Next
        cvAdd(*histogram, *red, *histogram, #Null)
      EndIf

      If G
        cvConvertScale(*hist_green\bins, *hist_green\bins, 448 / max_value, 0)

        For rtnCount = 0 To bins - 1
          bottom = 448 - Round(cvQueryHistValue_1D(*hist_green, rtnCount), #PB_Round_Nearest)
          cvRectangle(*green, rtnCount * 3 + 15, 448, rtnCount * 3 + 16, bottom, 0, 255, 0, 0, #CV_FILLED, 8, #Null)
        Next
        cvAdd(*histogram, *green, *histogram, #Null)
      EndIf

      If B
        cvConvertScale(*hist_blue\bins, *hist_blue\bins, 448 / max_value, 0)

        For rtnCount = 0 To bins - 1
          bottom = 448 - Round(cvQueryHistValue_1D(*hist_blue, rtnCount), #PB_Round_Nearest)
          cvRectangle(*blue, rtnCount * 3 + 15, 448, rtnCount * 3 + 16, bottom, 255, 0, 0, 0, #CV_FILLED, 8, #Null)
        Next
        cvAdd(*histogram, *blue, *histogram, #Null)
      EndIf
      cvResize(*image, *PIP, #CV_INTER_AREA)

      Select PIP
        Case 0
          cvSetImageROI(*histogram, 20 + 18, 20, iWidth, iHeight)
          cvAndS(*histogram, 0, 0, 0, 0, *histogram, #Null)
          cvAdd(*histogram, *PIP, *histogram, #Null)
          cvResetImageROI(*histogram)
          cvRectangleR(*histogram, 19 + 18, 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
        Case 1
          cvSetImageROI(*histogram, *histogram\width - (150 + 20), 20, iWidth, iHeight)
          cvAndS(*histogram, 0, 0, 0, 0, *histogram, #Null)
          cvAdd(*histogram, *PIP, *histogram, #Null)
          cvResetImageROI(*histogram)
          cvRectangleR(*histogram, *histogram\width - (150 + 21), 19, iWidth + 2, iHeight + 2, 0, 255, 255, 0, 1, #CV_AA, #Null)
      EndSelect
      cvShowImage(#CV_WINDOW_NAME, *histogram)
      keyPressed = cvWaitKey(10)

      Select keyPressed
        Case 66, 98
          B ! 1
        Case 71, 103
          G ! 1
        Case 82, 114
          R ! 1
        Case 86, 118
          PIP = (PIP + 1) % 3
      EndSelect
      cvReleaseImage(@*red_channel(0))
      cvReleaseImage(@*green_channel(0))
      cvReleaseImage(@*blue_channel(0))
      cvReleaseImage(@*red)
      cvReleaseImage(@*green)
      cvReleaseImage(@*blue)
      cvReleaseImage(@*histogram)
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseHist(@*hist_red)
  cvReleaseHist(@*hist_green)
  cvReleaseHist(@*hist_blue)
  cvReleaseImage(@*PIP)
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
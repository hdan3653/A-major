IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Calculates the contour areas, finding the convex hull of point sets to convexity defects." +
                  Chr(10) + Chr(10) + "Small circles for each defect:" +
                  Chr(10) + "- start: Green" + Chr(10) + "- end: Red" + Chr(10) + "- depth_point: Blue" +
                  Chr(10) + Chr(10) + "- SPACEBAR: Switch between views."

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

ProcedureC GetConvexHull(*image.IplImage, *contours.CvSeq)
  *hull.CvSeq = cvConvexHull2(*contours, #Null, #CV_CLOCKWISE, #False)
  *pt1.CvPoint = cvGetSeqElem(*hull, *hull\total - 1) : *pt2.CvPoint

  For rtnCount = 0 To *hull\total - 1
    *pt2 = cvGetSeqElem(*hull, rtnCount)
    pt1 = PeekL(*pt1\x) : pt2 = PeekL(*pt1\x + 4)
    pt3 = PeekL(*pt2\x) : pt4 = PeekL(*pt2\x + 4)
    cvLine(*image, pt1, pt2, pt3, pt4, 0, 255, 255, 0, 2, #CV_AA, #Null)
    *pt1 = *pt2
  Next
  ProcedureReturn *hull
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
  font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
  *YCrCb.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *mask.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *contour.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *kernel.IplConvKernel = cvCreateStructuringElementEx(3, 3, 1, 1, #CV_SHAPE_RECT, #Null)
  *storage.CvMemStorage = cvCreateMemStorage(0)
  *hull.CvSeq
  *defect.CvSeq
  *contours.CvSeq
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvSetZero(*mask)
      cvCvtColor(*image, *YCrCb, #CV_BGR2YCrCb, 1)
      cvSplit(*YCrCb, #Null, *mask, #Null, #Null)
      cvErode(*mask, *mask, *kernel, 2)
      cvDilate(*mask, *mask, *kernel, 3)
      cvSmooth(*mask, *mask, #CV_GAUSSIAN, 21, 0, 0, 0)
      cvThreshold(*mask, *mask, 130, 255, #CV_THRESH_BINARY | #CV_THRESH_OTSU)
      cvClearMemStorage(*storage)
      nContours = cvFindContours(*mask, *storage, @*contours, SizeOf(CvContour), #CV_RETR_EXTERNAL, #CV_CHAIN_APPROX_NONE, 0, 0)
      cvSetZero(*contour)

      If nContours
        For rtnCount = 0 To nContours - 1
          area.d = cvContourArea(*contours, 0, #CV_WHOLE_SEQ_END_INDEX, 0)

          If area > 20000 And area < 100000
            cvDrawContours(*contour, *contours, 255, 155, 0, 0, 155, 255, 0, 0, 0, #CV_FILLED, #CV_AA, 0, 0)
            *hull = GetConvexHull(*image, *contours)
            *defect = cvConvexityDefects(*contours, *hull, #Null)
            Dim elements.CvConvexityDefect(*defect\total)
            cvCvtSeqToArray(*defect, @elements(), 0, #CV_WHOLE_SEQ_END_INDEX)

            For rtnDefect = 0 To *defect\total - 1
              If elements(rtnDefect)\depth > 15 And elements(rtnDefect)\depth < 250
                startX = elements(rtnDefect)\start\x : startY = elements(rtnDefect)\start\y
                endX = elements(rtnDefect)\end\x : endY = elements(rtnDefect)\end\y
                depth_pointX = elements(rtnDefect)\depth_point\x : depth_pointY = elements(rtnDefect)\depth_point\y
                cvCircle(*image, startX, startY, 5, 0, 255, 0, 0, #CV_FILLED, #CV_AA, #Null)
                cvCircle(*image, endX, endY, 5, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
                cvCircle(*image, depth_pointX, depth_pointY, 5, 255, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
              EndIf
            Next
          EndIf
          *contours = *contours\h_next
        Next
      EndIf

      Select view
        Case 0
          cvShowImage(#CV_WINDOW_NAME, *image)
        Case 1
          cvShowImage(#CV_WINDOW_NAME, *mask)
        Case 2
          cvShowImage(#CV_WINDOW_NAME, *contour)
      EndSelect
      keyPressed = cvWaitKey(10)

      If keyPressed = 32 : view = (view + 1) % 3 : EndIf

    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseMemStorage(@*storage)
  cvReleaseStructuringElement(@*kernel)
  cvReleaseImage(@*contour)
  cvReleaseImage(@*mask)
  cvReleaseImage(@*YCrCb)
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
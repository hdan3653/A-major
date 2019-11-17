IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Contour extraction and calculation is used to determine finger, palm, and depth locations." +
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

Global *pstorage.CvMemStorage, *palm.CvSeq
#CV_SEQ_ELTYPE_POINT = CV_MAKETYPE(#CV_32S, 2)
*pstorage = cvCreateMemStorage(0) : cvClearMemStorage(*pstorage)
*palm = cvCreateSeq(#CV_SEQ_ELTYPE_POINT, SizeOf(CvSeq), SizeOf(CvPoint), *pstorage)

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
  *element.CvConvexityDefect : pt.CvPoint
  *storage.CvMemStorage = cvCreateMemStorage(0) : cvClearMemStorage(*storage)
  *defect.CvSeq = cvConvexityDefects(*contours, *hull, *storage)

  For rtnCount = 0 To *defect\total - 1
    *element = cvGetSeqElem(*defect, rtnCount)

    If *element\depth > 10
      pt\x = *element\depth_point\x
      pt\y = *element\depth_point\y
      cvCircle(*image, pt\x, pt\y, 5, 255, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
      cvSeqPush(*palm, @pt)
    EndIf
  Next
  cvReleaseMemStorage(@*storage)
EndProcedure

Global *fstorage.CvMemStorage, *finger.CvSeq
*fstorage = cvCreateMemStorage(0) : cvClearMemStorage(*fstorage)
*finger = cvCreateSeq(#CV_SEQ_ELTYPE_POINT, SizeOf(CvSeq), SizeOf(CvPoint), *fstorage)

ProcedureC DetectFingers(*image.IplImage, *contours.CvSeq, centerX, centerY)
  *p0.CvPoint : *p1.CvPoint : *p2.CvPoint
  vector1.CvPoint : vector2.CvPoint
  minP0.CvPoint : minP1.CvPoint : minP2.CvPoint
  l1.CvPoint : l2.CvPoint : l3.CvPoint
  Dim finger.CvPoint(100) : Dim fLocation(100)

  For rtnCount = 0 To *contours\total - 1
    *p0 = cvGetSeqElem(*contours, (rtnCount + 40) % *contours\total)
    *p1 = cvGetSeqElem(*contours, rtnCount)
    *p2 = cvGetSeqElem(*contours,(rtnCount + 80) % *contours\total)
    vector1\x = *p0\x - *p1\x
    vector1\y = *p0\y - *p1\y
    vector2\x = *p0\x - *p2\x
    vector2\y = *p0\y - *p2\y
    dotProduct = vector1\x * vector2\x + vector1\y * vector2\y
    length1.f = Sqr(vector1\x * vector1\x + vector1\y * vector1\y)
    length2.f = Sqr(vector2\x * vector2\x + vector2\y * vector2\y)
    angle.f = Abs(dotProduct / (length1 * length2))

    If angle < 0.1
      If Not signal
        signal = #True
        minP0\x = *p0\x
        minP0\y = *p0\y
        minP1\x = *p1\x
        minP1\y = *p1\y
        minP2\x = *p2\x
        minP2\y = *p2\y
        minAngle.f = angle
      Else
        If angle <= minAngle
          minP0\x = *p0\x
          minP0\y = *p0\y
          minP1\x = *p1\x
          minP1\y = *p1\y
          minP2\x = *p2\x
          minP2\y = *p2\y
          minAngle.f = angle
        EndIf
      EndIf
    Else
      If signal
        signal = #False
        l1\x = minP0\x - centerX
        l1\y = minP0\y - centerY
        l2\x = minP1\x - centerX
        l2\y = minP1\y - centerY
        l3\x = minP2\x - centerX
        l3\y = minP2\y - centerY
        length0 = Sqr(l1\x * l1\x + l1\y * l1\y)
        length1 = Sqr(l2\x * l2\x + l2\y * l2\y)
        length2 = Sqr(l3\x * l3\x + l3\y * l3\y)

        If length0 > length1 And length0 > length2
          finger(count) = minP0
          fLocation(count) = rtnCount + 20
          count + 1
        ElseIf length0 < length1 And length0 < length2
          cvSeqPush(*palm, @minP0)
        EndIf
      EndIf
    EndIf
  Next

  For rtnCount = 0 To count - 1
    If rtnCount > 0
      If fLocation(rtnCount) - fLocation(rtnCount - 1) > 40
        cvCircle(*image, finger(rtnCount)\x, finger(rtnCount)\y, 6, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
        cvCircle(*image, finger(rtnCount)\x, finger(rtnCount)\y, 10, 0, 255, 0, 0, 2, #CV_AA, #Null)
      EndIf
    Else
      cvCircle(*image, finger(rtnCount)\x, finger(rtnCount)\y, 6, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
      cvCircle(*image, finger(rtnCount)\x, finger(rtnCount)\y, 10, 0, 255, 0, 0, 2, #CV_AA, #Null)
    EndIf
  Next
EndProcedure

Global palmPositionFull.b = #False, palmCountFull.b = #False

ProcedureC DetectHand(*image.IplImage, *contours.CvSeq)
  useAvePalm.b = #True

  If *palm\total <= 2
    useAvePalm = #False
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
    cvPutText(*image, "ERROR: Palm Position!", 10, 30, @font, 0, 0, 255, 0)
    *palmTemp.CvPoint : *temp.CvPoint : *additional.CvPoint
    *storage.CvMemStorage = cvCreateMemStorage(0) : cvClearMemStorage(*storage)
    *palm2.CvSeq = cvCreateSeq(#CV_SEQ_ELTYPE_POINT, SizeOf(CvSeq), SizeOf(CvPoint), *storage)

    For i = 0 To *palm\total - 1
      *palmTemp = cvGetSeqElem(*palm, i)

      For j = 1 To *contours\total - 1
        *temp = cvGetSeqElem(*contours, j)

        If *temp\y = *palmTemp\y And *temp\x = *palmTemp\x
          *additional = cvGetSeqElem(*contours, j + (*contours\total / 2) % *contours\total)

          If *additional\y <= *palmTemp\y
            cvCircle(*image, *additional\x, *additional\y, 10, 255, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
            cvSeqPush(*palm2, *additional)
          EndIf
        EndIf
      Next
    Next

    For i = 0 To *palm2\total - 1
      *temp = cvGetSeqElem(*palm2, i)
      cvSeqPush(*palm, *temp)
    Next

    For i = 1 To *contours\total - 1
      *temp = cvGetSeqElem(*contours, 1)
      
      If *additional
        If *temp\y <= *additional\y : *additional = *temp : EndIf
      EndIf
    Next

    If *additional
      cvCircle(*image, *additional\x, *additional\y, 10, 255, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
      cvSeqPush(*palm, *additional)
    EndIf
  EndIf
  minCircleCenter.CvPoint2D32f

  If *palm\total : cvMinEnclosingCircle(*palm, @minCircleCenter, @radius.f) : EndIf

  If useAvePalm
    avePalmCenter.CvPoint : disTemp.CvPoint

    For i = 0 To *palm\total - 1
      *temp = cvGetSeqElem(*palm, i)
      avePalmCenter\x + *temp\x
      avePalmCenter\y + *temp\y
    Next
    avePalmCenter\x = avePalmCenter\x / *palm\total
    avePalmCenter\y = avePalmCenter\y / *palm\total

    For i = 0 To *palm\total - 1
      *temp = cvGetSeqElem(*palm, i)
      disTemp\x = *temp\x - avePalmCenter\x
      disTemp\y = *temp\y - avePalmCenter\y
      lengthTemp = Sqr(disTemp\x * disTemp\x + disTemp\y * disTemp\y)
      radius2 + lengthTemp
    Next
    radius2 = radius2 / *palm\total
    radius = 0.5 * radius + 0.5 * radius2
    minCircleCenter\x = 0.5 * minCircleCenter\x + 0.5 * avePalmCenter\x
    minCircleCenter\y = 0.5 * minCircleCenter\y + 0.5 * avePalmCenter\y
  EndIf
  Dim palmPosition.CvPoint(5)
  palmPosition(palmPositionCount)\x = Round(minCircleCenter\x, #PB_Round_Nearest)
  palmPosition(palmPositionCount)\y = Round(minCircleCenter\y, #PB_Round_Nearest)
  palmPositionCount + 1 % 3

  If palmPositionFull
    For i = 0 To 3 - 1
      xTemp.f + palmPosition(i)\x
      yTemp.f + palmPosition(i)\y
    Next
    minCircleCenter\x = Round(xtemp / 3, #PB_Round_Nearest)
    minCircleCenter\y = Round(ytemp / 3, #PB_Round_Nearest)
  EndIf

  If palmPositionCount = 2 And palmPositionFull = #False : palmPositionFull = #True : EndIf

  cvCircle(*image, minCircleCenter\x, minCircleCenter\y, 10, 255, 255, 0, 0, 4, #CV_AA, #Null)
  Dim palmSize(5) : palmSize(palmSizeCount) = Round(radius, #PB_Round_Nearest)
  palmSizeCount + 1 % 3

  If palmCountFull
    For i = 0 To 3 - 1
      tempCount + palmSize(i)
    Next
    radius = tempCount / 3
  EndIf

  If palmSizeCount = 2 And palmCountFull = #False : palmCountFull = #True : EndIf

  cvCircle(*image, minCircleCenter\x, minCircleCenter\y, Round(radius, #PB_Round_Nearest), 0, 0, 255, 0, 2, #CV_AA, #Null)
  cvCircle(*image, minCircleCenter\x, minCircleCenter\y, Round(radius * 1.2, #PB_Round_Nearest), 255, 0, 255, 0, 2, #CV_AA, #Null)
  tipLength.CvPoint : *point.CvPoint

  For i = 0 To *finger\total - 1
    *point = cvGetSeqElem(*finger, i)
    tipLength\x = *point\x - minCircleCenter\x
    tipLength\y = *point\y - minCircleCenter\y
    fingerLength = Sqr(tipLength\x * tipLength\x + tipLength\y * tipLength\y)

    If fingerLength > Round(radius * 1.2, #PB_Round_Nearest)
      cvCircle(*image, *point\x, *point\y, 6, 0, 255, 0, 0, #CV_FILLED, #CV_AA, #Null)
    EndIf
  Next
  cvClearSeq(*finger)
  cvClearSeq(*palm)
  cvReleaseMemStorage(@*storage)
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
  *YCrCb.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *mask.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *contour.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *kernel.IplConvKernel = cvCreateStructuringElementEx(3, 3, 1, 1, #CV_SHAPE_RECT, #Null)
  *storage.CvMemStorage = cvCreateMemStorage(0)
  *contours.CvSeq : contourCenter.CvBox2D
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
            cvMinAreaRect2(@contourCenter, *contours, #Null)
            GetConvexHull(*image, *contours)
            DetectFingers(*image, *contours, contourCenter\center\x, contourCenter\center\y)
            DetectHand(*image, *contours)
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
  cvReleaseMemStorage(@*fstorage)
  cvReleaseMemStorage(@*pstorage)
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
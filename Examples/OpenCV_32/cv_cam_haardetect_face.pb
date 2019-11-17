IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, scaleFactor, minNeighbors

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Tries to detect a frontal-face using HaarCascades." + Chr(10) + Chr(10) +
                  "- TRACKBAR 1: Adjust scale factor." + Chr(10) + Chr(10) +
                  "- TRACKBAR 2: Minimum neighbors." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Change HaarCascade." + Chr(10) + Chr(10) +
                  "- [ M ] KEY: Switch between masks." + Chr(10) + Chr(10) +
                  "- [ S ] KEY: Toggle scale-factor flag."

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

ProcedureC CvTrackbarCallback1(pos)
  scaleFactor = pos
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  minNeighbors = pos
EndProcedure

ProcedureC SetMask(*frame.IplImage, mask.s, x, y, width, height)
  *image.IplImage = cvLoadImage(mask, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
  *resize.IplImage = cvCreateImage(width, height, #IPL_DEPTH_8U, 3)
  *mask.IplImage = cvCreateImage(width, height, #IPL_DEPTH_8U, 1)
  Dim *resizeChannel.IplImage(3)
  *resizeChannel(0) = cvCreateImage(width, height, #IPL_DEPTH_8U, 1)
  *resizeChannel(1) = cvCreateImage(width, height, #IPL_DEPTH_8U, 1)
  *resizeChannel(2) = cvCreateImage(width, height, #IPL_DEPTH_8U, 1)
  Dim *maskResult.IplImage(3)
  *maskResult(0) = cvCreateImage(width, height, #IPL_DEPTH_8U, 1)
  *maskResult(1) = cvCreateImage(width, height, #IPL_DEPTH_8U, 1)
  *maskResult(2) = cvCreateImage(width, height, #IPL_DEPTH_8U, 1)
  *merge.IplImage = cvCreateImage(width, height, #IPL_DEPTH_8U, 3)
  *kernel.IplConvKernel = cvCreateStructuringElementEx(3, 3, 1, 1, #CV_SHAPE_RECT, #Null)
  cvResize(*image, *resize, #CV_INTER_AREA)
  cvCvtColor(*resize, *mask, #CV_BGR2GRAY, 1)
  cvErode(*mask, *mask, *kernel, 1)
  cvDilate(*mask, *mask, *kernel, 3)
  cvSmooth(*mask, *mask, #CV_GAUSSIAN, 7, 7, 0, 0)
  cvThreshold(*mask, *mask, 240, 255, #CV_THRESH_BINARY_INV)
  cvSplit(*resize, *resizeChannel(0), *resizeChannel(1), *resizeChannel(2), #Null)
  cvAnd(*resizeChannel(0), *mask, *maskResult(0), #Null)
  cvAnd(*resizeChannel(1), *mask, *maskResult(1), #Null)
  cvAnd(*resizeChannel(2), *mask, *maskResult(2), #Null)
  cvMerge(*maskResult(0), *maskResult(1), *maskResult(2), #Null, *merge)
  cvSetImageROI(*frame, x, y, width, height)
  cvCopy(*merge, *frame, *mask)
  cvResetImageROI(*frame)
  cvReleaseStructuringElement(@*kernel)
  cvReleaseImage(@*merge)
  cvReleaseImage(@*maskResult(2))
  cvReleaseImage(@*maskResult(1))
  cvReleaseImage(@*maskResult(0))
  cvReleaseImage(@*resizeChannel(2))
  cvReleaseImage(@*resizeChannel(1))
  cvReleaseImage(@*resizeChannel(0))
  cvReleaseImage(@*mask)
  cvReleaseImage(@*resize)
  cvReleaseImage(@*image)
  ProcedureReturn *frame
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
  cvResizeWindow(#CV_WINDOW_NAME, FrameWidth, FrameHeight + 48 + 42)
  flags = 1
  minNeighbors = 2
  cvCreateTrackbar("Scale", #CV_WINDOW_NAME, @scaleFactor, 9, @CvTrackbarCallback1())
  cvCreateTrackbar("Neighbors", #CV_WINDOW_NAME, @minNeighbors, 4, @CvTrackbarCallback2())
  Dim haarcascade.s(4)
  haarcascade(0) = "haarcascade_frontalface_default.xml"
  haarcascade(1) = "haarcascade_frontalface_alt.xml"
  haarcascade(2) = "haarcascade_frontalface_alt2.xml"
  haarcascade(3) = "haarcascade_frontalface_alt_tree.xml"
  haarcascade(4) = "haarcascade_frontalface_JHPJHP.xml"
  scale = 2
  iWidth = Round(FrameWidth / scale, #PB_Round_Nearest)
  iHeight = Round(FrameHeight / scale, #PB_Round_Nearest)
  *gray.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
  *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 1)
  *cascade.CvHaarClassifierCascade = cvLoad(haarcascade(face), #Null, #Null, #Null)
  *storage.CvMemStorage = cvCreateMemStorage(0)
  *faces.CvSeq
  *element.CvRect
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvCvtColor(*image, *gray, #CV_BGR2GRAY, 1)
      cvEqualizeHist(*gray, *gray)
      cvResize(*gray, *resize, #CV_INTER_AREA)
      cvClearMemStorage(*storage)

      If flags
        *faces = cvHaarDetectObjects(*resize, *cascade, *storage, 1 + ((scaleFactor + 1) / 10), minNeighbors, #CV_HAAR_SCALE_IMAGE, 100, 100, 0, 0)
      Else
        *faces = cvHaarDetectObjects(*resize, *cascade, *storage, 1 + ((scaleFactor + 1) / 10), minNeighbors, #CV_HAAR_DO_CANNY_PRUNING | #CV_HAAR_FIND_BIGGEST_OBJECT | #CV_HAAR_DO_ROUGH_SEARCH, 100, 100, 0, 0)
      EndIf

      For rtnPoint = 0 To *faces\total
        *element = cvGetSeqElem(*faces, rtnPoint)

        If *element
          If Abs(x - *element\x * scale) > 20 Or Abs(y - *element\y * scale) > 20
            x = *element\x * scale
            y = *element\y * scale
            width = (*element\x + *element\width) * scale
            height = (*element\y + *element\height) * scale
          EndIf

          Select mask
            Case 0
              Select face
                Case 0
                  cvRectangle(*image, x, y, width, height, 0, 255, 255, 0, 2, #CV_AA, #Null)
                Case 1
                  cvRectangle(*image, x, y, width, height, 255, 0, 0, 0, 2, #CV_AA, #Null)
                Case 2
                  cvRectangle(*image, x, y, width, height, 0, 255, 0, 0, 2, #CV_AA, #Null)
                Case 3
                  cvRectangle(*image, x, y, width, height, 0, 0, 255, 0, 2, #CV_AA, #Null)
                Case 4
                  cvRectangle(*resize1, x, y, width, height, 255, 255, 0, 0, 2, #CV_AA, #Null)
              EndSelect
            Case 1 To 4
              *image = SetMask(*image, "images/mask" + Str(mask) + ".jpg", x, y * 0.8, Abs(width - x), Abs(height - y) * 1.2)
          EndSelect
          Break
        Else
          If mask > 0
            If x > 0 And y > 0 And width > 0 And height > 0
              *image = SetMask(*image, "images/mask" + Str(mask) + ".jpg", x, y * 0.8, Abs(width - x), Abs(height - y) * 1.2)
            EndIf
          EndIf
        EndIf
      Next
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(1)

      Select keyPressed
        Case 32
          face = (face + 1) % 5

          If FileSize(haarcascade(face)) = -1 : face = (face + 1) % 5 : EndIf

          *cascade = cvLoad(haarcascade(face), #Null, #Null, #Null)
        Case 77, 109
          mask = (mask + 1) % 5
        Case 83, 115
          flags ! 1
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseMemStorage(@*storage)
  cvReleaseHaarClassifierCascade(@*cascade)
  cvReleaseImage(@*resize)
  cvReleaseImage(@*gray)
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
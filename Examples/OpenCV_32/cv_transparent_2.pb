IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, selection.CvRect, select_object, nSelect, nLoDiff, nUpDiff

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Flood fill a color area to transparency, applied when the image has been saved to a PNG file." +
                  Chr(10) + Chr(10) + "- TRACKBAR 1: Maximal lower color / brightness difference between pixels." +
                  Chr(10) + Chr(10) + "- TRACKBAR 2: Maximal upper color / brightness difference between pixels." +
                  Chr(10) + Chr(10) + "- MOUSE: Select transparency area." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Flood fill selected area." +
                  Chr(10) + Chr(10) + "- ENTER: Reset the image." +
                  Chr(10) + Chr(10) + "- [ B ] KEY: Filter for black pixels." +
                  Chr(10) + Chr(10) + "- [ F ] KEY: Flip image/transparency." +
                  Chr(10) + Chr(10) + "- [ I ] KEY: Invert the image." +
                  Chr(10) + Chr(10) + "- [ S ] KEY: Toggle select mode."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          getCV = #True
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
        Case 2 
          FileName.s = SaveFile(1)

          If FileName
            params.SAVE_INFO

            Select LCase(GetExtensionPart(FileName))
              Case "jpeg", "jpg", "jpe"
                params\paramId = #CV_IMWRITE_JPEG_QUALITY
                params\paramValue = 95
              Case "png"
                params\paramId = #CV_IMWRITE_PNG_COMPRESSION
                params\paramValue = 3
              Case "ppm", "pgm", "pbm"
                params\paramId = #CV_IMWRITE_PXM_BINARY
                params\paramValue = 1
              Default
                Select SelectedFilePattern()
                  Case 0
                    FileName + ".jpg"
                    params\paramId = #CV_IMWRITE_JPEG_QUALITY
                    params\paramValue = 95
                  Case 1
                    FileName + ".png"
                    params\paramId = #CV_IMWRITE_PNG_COMPRESSION
                    params\paramValue = 3
                  Case 2
                    FileName + ".ppm"
                    params\paramId = #CV_IMWRITE_PXM_BINARY
                    params\paramValue = 1
                EndSelect
            EndSelect
            cvSaveImage(FileName, *save, @params)
          EndIf
        Case 10
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
      EndSelect
    Case #WM_DESTROY
      exitCV = #True
  EndSelect
  ProcedureReturn CallWindowProc_(lpPrevWndFunc, hWnd, Msg, wParam, lParam)
EndProcedure

ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)
  Shared origin.CvPoint
  Static pt1.CvPoint

  If select_object > 0
    selection\x = origin\x
    selection\y = origin\y
    CV_MIN(selection\x, x)
    CV_MIN(selection\y, y)
    selection\width = selection\x + CV_IABS(x - origin\x)
    selection\height = selection\y + CV_IABS(y - origin\y)
    CV_MAX(selection\x, 0)
    CV_MAX(selection\y, 0)
    CV_MIN(selection\width, *param\uPointer1\width)
    CV_MIN(selection\height, *param\uPointer1\height)
    selection\width - selection\x
    selection\height - selection\y
  EndIf

  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      If nSelect
        origin\x = x
        origin\y = y
        selection\x = x
        selection\y = y
        selection\width = 0
        selection\height = 0
        select_object = 1
      Else
        pt1\x = x
        pt1\y = y
      EndIf
    Case #CV_EVENT_LBUTTONUP
      If nSelect
        If selection\width > 2 Or selection\height > 2
          *overlay.IplImage = cvCloneImage(*param\uPointer1)
          opacity.d = 0.4
          cvRectangle(*param\uPointer1, selection\x, selection\y, selection\x + selection\width, selection\y + selection\height, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          cvAddWeighted(*param\uPointer1, opacity, *overlay, 1 - opacity, 0, *param\uPointer1)
          cvReleaseImage(@*overlay)
          select_object = -1
        Else
          cvCircle(*param\uPointer1, selection\x, selection\y, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
          select_object = 0
        EndIf
        cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
        *param\uPointer1 = cvCloneImage(*param\uPointer2)
      Else
        If Not Bool(flags And #CV_EVENT_FLAG_LBUTTON)
          pt1\x = -1
          pt1\y = -1
        EndIf
      EndIf
    Case #CV_EVENT_MOUSEMOVE
      If nSelect
        If select_object
          If selection\width > 2 Or selection\height > 2
            *overlay.IplImage = cvCloneImage(*param\uPointer1)
            opacity.d = 0.4
            cvRectangle(*param\uPointer1, selection\x, selection\y, selection\x + selection\width, selection\y + selection\height, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
            cvAddWeighted(*param\uPointer1, opacity, *overlay, 1 - opacity, 0, *param\uPointer1)
            cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
            cvCopy(*param\uPointer2, *param\uPointer1, #Null)
            cvReleaseImage(@*overlay)
          EndIf
        EndIf
      Else
        If Bool(flags And #CV_EVENT_FLAG_LBUTTON)
          pt2.CvPoint
          pt2\x = x
          pt2\y = y

          If pt1\x > 0 And pt2\x < 60000 And pt2\y < 60000
            cvLine(*param\uPointer1, pt1\x, pt1\y, pt2\x, pt2\y, 0, 255, 0, 0 , 4, #CV_AA, #Null)
            cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
            pt1 = pt2
          EndIf
        EndIf
      EndIf
  EndSelect
EndProcedure

ProcedureC CvTrackbarCallback1(pos)
  nLoDiff = pos
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  nUpDiff = pos
EndProcedure

ProcedureC OpenCV(ImageFile.s)
  If FileSize(ImageFile) > 0
    cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
    window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
    *window_name = cvGetWindowName(window_handle)
    lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(1, "Open")
      MenuBar()
      MenuItem(2, "Save")
      MenuBar()
      MenuItem(10, "Exit")
    EndIf
    hWnd = GetParent_(window_handle)
    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
    SendMessage_(hWnd, #WM_SETICON, 0, opencv)
    wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)
    SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))
    *image.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    dtWidth = DesktopWidth(0)
    dtHeight = DesktopHeight(0)

    If *image\width >= dtWidth - 100 Or *image\height >= dtHeight - (100 + 48 + 42)
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / *image\width
      iHeight = dtHeight - (100 + 48 + 42)
      iRatio2.d = iHeight / *image\height

      If iRatio1 < iRatio2
        iWidth = *image\width * iRatio1
        iHeight = *image\height * iRatio1
      Else
        iWidth = *image\width * iRatio2
        iHeight = *image\height * iRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight + 48 + 42)
      *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image\nChannels)
      cvResize(*image, *resize, #CV_INTER_AREA)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height + 48 + 42)
      *resize.IplImage = cvCloneImage(*image)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)

    If *resize\width > 200 And *resize\height > 200
      nLoDiff = 20
      nUpDiff = 50
      cvCreateTrackbar("loDiff", #CV_WINDOW_NAME, @nLoDiff, 255, @CvTrackbarCallback1())
      cvCreateTrackbar("upDiff", #CV_WINDOW_NAME, @nUpDiff, 255, @CvTrackbarCallback2())
      comp.CvConnectedComp
      nFlags = 4 + (255 << 8) + #CV_FLOODFILL_FIXED_RANGE

      If *resize\nChannels = 1
        *temp.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 3)
        cvCvtColor(*resize, *temp, #CV_GRAY2BGR, 1)
        *resize = cvCloneImage(*temp)
        cvReleaseImage(@*temp)
      EndIf
      *transparent.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 4)
      cvCvtColor(*resize, *transparent, #CV_BGR2BGRA, 1)
      *reset.IplImage = cvCloneImage(*transparent)
      *floodfill.IplImage = cvCloneImage(*resize)
      *mask.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)
      selection\x = 0
      selection\y = 0
      selection\width = 0
      selection\height = 0
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *transparent
      *param\uPointer2 = *reset
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *floodfill
          cvShowImage(#CV_WINDOW_NAME, *floodfill)
          keyPressed = cvWaitKey(0)

          Select keyPressed
            Case 13
              cvCvtColor(*resize, *transparent, #CV_BGR2BGRA, 1)
              cvReleaseImage(@*reset)
              cvReleaseImage(@*floodfill)
              *reset = cvCloneImage(*transparent)
              *floodfill = cvCloneImage(*resize)
              *param\uPointer1 = *transparent
              *param\uPointer2 = *reset
            Case 32
              If nSelect
                If select_object = -1
                  cvRectangle(*floodfill, selection\x, selection\y, selection\x + selection\width, selection\y + selection\height, 0, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
                Else
                  cvFloodFill(*floodfill, selection\x, selection\y, 0, 0, 0, 0, nLoDiff, nLoDiff, nLoDiff, 0, nUpDiff, nUpDiff, nUpDiff, 0, @comp, nFlags, #Null)
                EndIf
                cvInRangeS(*floodfill, 0, 0, 0, 0, 0, 0, 0, 0, *mask)               
                cvNot(*mask, *mask)
              Else
                cvCvtColor(*transparent, *floodfill, #CV_BGRA2BGR, 1)

                For y = 0 To *floodfill\height - 1
                  For x = 0 To *floodfill\width - 1
                    B = PeekA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 0)
                    G = PeekA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 1)
                    R = PeekA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 2)

                    If B = 0 And G = 255 And R = 0
                      Continue
                    Else
                      PokeA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 0, 0)
                      PokeA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 1, 0)
                      PokeA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 2, 0)
                    EndIf
                  Next
                Next
                cvFloodFill(*floodfill, 0, 0, 255, 255, 255, 0, nLoDiff, nLoDiff, nLoDiff, 0, nUpDiff, nUpDiff, nUpDiff, 0, @comp, nFlags, #Null)
                cvInRangeS(*floodfill, 0, 0, 0, 0, 0, 0, 0, 0, *mask)
              EndIf
              cvSetZero(*transparent)              
              cvCopy(*reset, *transparent, *mask)
              cvReleaseImage(@*reset)
              *reset = cvCloneImage(*transparent)
              cvCvtColor(*transparent, *floodfill, #CV_BGRA2BGR, 1)
              *param\uPointer1 = *transparent
              *param\uPointer2 = *reset
            Case 66, 98
              cvInRangeS(*floodfill, 0, 0, 0, 0, 64, 64, 64, 0, *mask)
              cvNot(*mask, *mask)
              cvCvtColor(*mask, *reset, #CV_GRAY2BGRA, 1)
              cvCvtColor(*mask, *floodfill, #CV_GRAY2BGR, 1)
              cvSetZero(*transparent)
              cvCopy(*reset, *transparent, *mask)
              cvReleaseImage(@*reset)
              *reset = cvCloneImage(*transparent)
              *param\uPointer1 = *transparent
              *param\uPointer2 = *reset
            Case 70, 102
              cvInRangeS(*floodfill, 0, 0, 0, 0, 0, 0, 0, 0, *mask)
              cvCvtColor(*resize, *reset, #CV_BGR2BGRA, 1)
              cvSetZero(*transparent)
              cvCopy(*reset, *transparent, *mask)
              cvReleaseImage(@*reset)
              *reset = cvCloneImage(*transparent)
              cvCvtColor(*transparent, *floodfill, #CV_BGRA2BGR, 1)
              *param\uPointer1 = *transparent
              *param\uPointer2 = *reset
            Case 73, 105
              For y = 0 To *reset\height - 1
                For x = 0 To *reset\width - 1
                  PokeA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 0, 255 - PeekA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 0))
                  PokeA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 1, 255 - PeekA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 1))
                  PokeA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 2, 255 - PeekA(@*floodfill\imageData\b + (y * *floodfill\widthStep) + (x * 3) + 2))
                Next
              Next
              cvInRangeS(*floodfill, 0, 0, 0, 0, 0, 0, 0, 0, *mask)
              cvCvtColor(*floodfill, *reset, #CV_BGR2BGRA, 1)
              cvNot(*mask, *mask)
              cvSetZero(*transparent)
              cvCopy(*reset, *transparent, *mask)
              cvReleaseImage(@*reset)
              *reset = cvCloneImage(*transparent)
              *param\uPointer1 = *transparent
              *param\uPointer2 = *reset
            Case 83, 115
              cvCvtColor(*floodfill, *transparent, #CV_BGR2BGRA, 1)
              *param\uPointer1 = *transparent
              nSelect ! 1
          EndSelect
          select_object = 0
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
      cvReleaseImage(@*mask)
      cvReleaseImage(@*floodfill)
      cvReleaseImage(@*reset)
      cvReleaseImage(@*transparent)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If getCV
        getCV = #False
        exitCV = #False
        OpenCV(GetImage())
      EndIf
    Else
      MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the size requirements, please try a larger image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/plane.jpg")
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
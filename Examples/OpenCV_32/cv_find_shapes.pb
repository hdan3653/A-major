IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Approximates a polygonal curve(s) with the specified precision." + Chr(10) + Chr(10) +
                  "Marking each point set:" + Chr(10) +
                  "- 3 sides: RED" + Chr(10) + "- 4 sides: GREEN" + Chr(10) + "- 9 sides: BLUE" + Chr(10) + "- ? sides: YELLOW"

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          getCV = #True
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
        Case 2
          FileName.s = SaveFile()

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
  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
  EndSelect
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

    If *image\width >= dtWidth - 100 Or *image\height >= dtHeight - 100
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / *image\width
      iHeight = dtHeight - 100
      iRatio2.d = iHeight / *image\height

      If iRatio1 < iRatio2
        iWidth = *image\width * iRatio1
        iHeight = *image\height * iRatio1
      Else
        iWidth = *image\width * iRatio2
        iHeight = *image\height * iRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight)
      *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image\nChannels)
      cvResize(*image, *resize, #CV_INTER_AREA)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
      *resize.IplImage = cvCloneImage(*image)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)

    If *resize\nChannels = 1
      *gray.IplImage = cvCloneImage(*resize)
    Else
      *gray.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)
      cvCvtColor(*resize, *gray, #CV_BGR2GRAY, 1)
    EndIf
    cvThreshold(*gray, *gray, 128, 255, #CV_THRESH_BINARY)
    *storage.CvMemStorage = cvCreateMemStorage(0)
    cvClearMemStorage(*storage)
    *contours.CvSeq
    nContours = cvFindContours(*gray, *storage, @*contours, SizeOf(CvContour), #CV_RETR_LIST, #CV_CHAIN_APPROX_SIMPLE, 0, 0)

    If nContours
      *poly.CvSeq
      *pt1.CvPoint
      *pt2.CvPoint

      For rtnCount = 0 To nContours - 1
        area.d = cvContourArea(*contours, 0, #CV_WHOLE_SEQ_END_INDEX, 0)

        If area >= 35 And area <= 100000
          *poly = cvApproxPoly(*contours, SizeOf(CvContour), *storage, #CV_POLY_APPROX_DP, cvContourPerimeter(*contours) * 0.02, 0)
          total = *poly\total

          For rtnPoint = 0 To total - 1
            *pt1 = cvGetSeqElem(*poly, rtnPoint)
            *pt2 = cvGetSeqElem(*poly, (rtnPoint + 1) % total)

            Select total
              Case 3
                cvLine(*resize, *pt1\x, *pt1\y, *pt2\x, *pt2\y, 0, 0, 255, 0, 2, #CV_AA, #Null)
              Case 4
                cvLine(*resize, *pt1\x, *pt1\y, *pt2\x, *pt2\y, 0, 255, 0, 0, 2, #CV_AA, #Null)
              Case 9
                cvLine(*resize, *pt1\x, *pt1\y, *pt2\x, *pt2\y, 255, 0, 0, 0, 2, #CV_AA, #Null)
              Default
                cvLine(*resize, *pt1\x, *pt1\y, *pt2\x, *pt2\y, 0, 255, 255, 0, 2, #CV_AA, #Null)
            EndSelect
          Next
        EndIf
        *contours = *contours\h_next
      Next
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *resize
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *resize
          cvShowImage(#CV_WINDOW_NAME, *resize)
          keyPressed = cvWaitKey(0)
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
    EndIf
    cvReleaseMemStorage(@*storage)
    cvReleaseImage(@*gray)
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()

    If getCV
      getCV = #False
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/shapes.png")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
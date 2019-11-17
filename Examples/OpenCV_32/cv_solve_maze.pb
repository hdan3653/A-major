IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc, Dim *clear.IplImage(1), maze

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Maze game / solve a maze using a morphological transformation." + Chr(10) + Chr(10) +
                  "- MOUSE: Manually solve the maze." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Show maze solution." + Chr(10) + Chr(10) +
                  "- ENTER: Switch between mazes." + Chr(10) + Chr(10) +
                  "- [ C ] KEY: Clear to last point / Reset." + Chr(10) + Chr(10) +
                  "NOTE: " + #DQUOTE$ + "Perfect Maze" + #DQUOTE$ + " requirements..." + Chr(10) +
                  "Only one path from any point to any other point, no sections, no circular paths, " +
                  "and no open areas." + Chr(10) + Chr(10) +
                  "Double-Click the window to open a link to a Maze Generator."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
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
  Static pt1.CvPoint

  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      If *param\uMsg = ""
        cvCircle(*param\uPointer1, x, y, 8, 0, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
        pt1\x = x
        pt1\y = y
      EndIf
    Case #CV_EVENT_LBUTTONUP
      If Not Bool(flags And #CV_EVENT_FLAG_LBUTTON)
        pt1\x = -1
        pt1\y = -1
        count = ArraySize(*clear()) + 1
        ReDim *clear(count)
        *clear(count - 1) = cvCloneImage(*param\uPointer1)
      EndIf
    Case #CV_EVENT_MOUSEMOVE
      If Bool(flags And #CV_EVENT_FLAG_LBUTTON)
        If *param\uMsg = ""
          pt2.CvPoint
          pt2\x = x
          pt2\y = y

          If pt1\x > 0 And pt2\x < 60000 And pt2\y < 60000
            cvLine(*param\uPointer1, pt1\x, pt1\y, pt2\x, pt2\y, 255, 0, 0, 0, 4, #CV_AA, #Null)
            cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
            pt1 = pt2
          EndIf
        EndIf
      EndIf
    Case #CV_EVENT_LBUTTONDBLCLK
      RunProgram("http://mazegenerator.net/")
  EndSelect
EndProcedure

ProcedureC OpenCV(ImageFile.s)
  If FileSize(ImageFile) > 0
    cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
    window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
    *window_name = cvGetWindowName(window_handle)
    lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

    If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
      MenuItem(1, "Save")
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
    *clear(0) = cvCloneImage(*resize)
    *gray.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)
    cvCvtColor(*resize, *gray, #CV_BGR2GRAY, 1)
    BringToTop(hWnd)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *resize
    *param\uMsg = ""
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If *resize
        cvShowImage(#CV_WINDOW_NAME, *resize)
        keyPressed = cvWaitKey(0)

        If keyPressed = 67 Or keyPressed = 99
          count = ArraySize(*clear()) - 1

          If count > 0
            ReDim *clear(count)
            cvReleaseImage(@*resize)
            *resize = cvCloneImage(*clear(count - 1))
            *param\uPointer1 = *resize
          EndIf
        EndIf
      EndIf
    Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 32 Or exitCV

    If keyPressed = 32
      cvThreshold(*gray, *gray, 100, 255, #CV_THRESH_BINARY_INV)
      *storage.CvMemStorage = cvCreateMemStorage(0)
      cvClearMemStorage(*storage)
      *contours.CvSeq
      nContours = cvFindContours(*gray, *storage, @*contours, SizeOf(CvContour), #CV_RETR_EXTERNAL, #CV_CHAIN_APPROX_NONE, 0, 0)

      If nContours = 2
        *path.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1) : cvSetZero(*path)
        *erode.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1) : cvSetZero(*erode)
        Dim *channel.IplImage(3)

        For rtnCount = 0 To 3 - 1
          *channel(rtnCount) = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1) : cvSetZero(*channel(rtnCount))
        Next
        *maze.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 3) : cvSetZero(*maze)
        *kernel.IplConvKernel = cvCreateStructuringElementEx(19, 19, 9, 9, #CV_SHAPE_RECT, 1)
        cvDrawContours(*path, *contours, 255, 255, 255, 0, 255, 255, 255, 0, 0, #CV_FILLED, #CV_AA, 0, 0)
        cvDilate(*path, *path, *kernel, 1)
        cvErode(*path, *erode, *kernel, 1)
        cvAbsDiff(*path, *erode, *path)
        cvSplit(*resize, *channel(0), *channel(1), *channel(2), #Null)
        cvXor(*path, *channel(0), *channel(0), #Null)
        cvXor(*path, *channel(1), *channel(1), #Null)
        cvMerge(*channel(0), *channel(1), *channel(2), #Null, *maze)
        BringToTop(hWnd)
        *param\uPointer1 = *maze
        *param\uMsg = "X"

        Repeat
          If *maze
            cvShowImage(#CV_WINDOW_NAME, *maze)
            keyPressed = cvWaitKey(0)
          EndIf
        Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 67 Or keyPressed = 99 Or exitCV
        cvReleaseStructuringElement(@*kernel)
        cvReleaseImage(@*maze)

        For rtnCount = 0 To 3 - 1
          cvReleaseImage(@*channel(rtnCount))
        Next
        cvReleaseImage(@*erode)
        cvReleaseImage(@*path)
        FreeMemory(*param)
      EndIf
      cvReleaseMemStorage(@*storage)
    EndIf
    cvReleaseImage(@*gray)

    For rtnCount = 0 To ArraySize(*clear()) - 1
      cvReleaseImage(@*clear(rtnCount))
    Next
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()

    If keyPressed = 13 Or keyPressed = 67 Or keyPressed = 99
      exitCV = #False

      If keyPressed = 13
        maze = (maze + 1) % 3
        Dim *clear.IplImage(1)
      EndIf
      OpenCV("images/maze" + Str(maze + 1) + ".jpg")
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/maze1.jpg")
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
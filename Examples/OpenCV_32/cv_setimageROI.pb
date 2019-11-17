IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Simulates zooming a section of a resized image by loading the Region Of Interest (ROI) for a given rectangle " +
                  "from the original image." + Chr(10) + Chr(10) +
                  "- MOUSE: Click an area of the resized image to zoom a Region Of Interest." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Resets the displayed image back to the resized image."

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
  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      If *param\uMsg = ""
        *param\uMsg = "zoom"
        *roi.IplImage = cvCloneImage(*param\uPointer1)

        For rtnCount = 1 To 201 Step 50
          cvSmooth(*param\uPointer1, *roi, #CV_MEDIAN, rtnCount, 0, 0, 0)
          cvShowImage(#CV_WINDOW_NAME, *roi)
          cvWaitKey(1)
        Next
        ratio.d = *param\uPointer2\width / *roi\width
        roiX = x * ratio - (*roi\width / 2)
        roiY = y * ratio - (*roi\height / 2)
        rectX = (*roi\width / 2) - 100
        rectY = (*roi\height / 2) - 50

        If roiX < 0 : roiX = 0 : rectX = x * ratio - 100 : EndIf
        If roiY < 0 : roiY = 0 : rectY = y * ratio - 50 : EndIf
        If rectX < 5 : rectX = 5 : EndIf
        If rectY < 5 : rectY = 5 : EndIf

        If roiX + *roi\width > *param\uPointer2\width
          roiX = *param\uPointer2\width - *roi\width
          rectX = *param\uPointer1\width - 100 - ((*param\uPointer1\width * ratio) - (x * ratio))

          If rectX + 205 > *param\uPointer1\width : rectX = *param\uPointer1\width - 205 : EndIf

        EndIf

        If roiY + *roi\height > *param\uPointer2\height
          roiY = *param\uPointer2\height - *roi\height
          rectY = *param\uPointer1\height - 50 - ((*param\uPointer1\height * ratio) - (y * ratio))

          If rectY + 105 > *param\uPointer1\height : rectY = *param\uPointer1\height - 105 : EndIf

        EndIf
        cvSetImageROI(*param\uPointer2, roiX, roiY, *roi\width, *roi\height)
        cvCopy(*param\uPointer2, *roi, #Null)
        cvResetImageROI(*param\uPointer2)

        For rtnCount = 201 To 1 Step - 50
          cvSmooth(*roi, *param\uPointer1, #CV_MEDIAN, rtnCount, 0, 0, 0)
          cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
          cvWaitKey(1)
        Next
        *overlay.IplImage = cvCloneImage(*param\uPointer1)
        cvRectangle(*param\uPointer1, rectX, rectY, rectX + 200, rectY + 100, 0, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
        opacity.d = 0.6
        cvAddWeighted(*overlay, opacity, *param\uPointer1, 1 - opacity, 0, *param\uPointer1)
        cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
        cvReleaseImage(@*overlay)
        cvReleaseImage(@*roi)
      EndIf
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
    *reset.IplImage = cvCloneImage(*resize)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = cvCloneImage(*resize)
    *param\uPointer2 = *image
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If *param\uPointer1
        cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
        keyPressed = cvWaitKey(0)

        If keyPressed = 32 And *param\uMsg = "zoom"
          For rtnCount = 1 To 201 Step 50
            cvSmooth(*param\uPointer1, *param\uPointer1, #CV_MEDIAN, rtnCount, 0, 0, 0)
            cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
            cvWaitKey(1)
          Next
          *reset.IplImage = cvCloneImage(*resize)
          *param\uMsg = ""

          For rtnCount = 201 To 1 Step - 50
            cvSmooth(*reset, *param\uPointer1, #CV_MEDIAN, rtnCount, 0, 0, 0)
            cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
            cvWaitKey(1)
          Next
          cvReleaseImage(@*reset)
        EndIf
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/map.jpg")
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
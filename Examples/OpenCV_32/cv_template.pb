IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Compares a template against overlapped image regions; matching one face against many faces." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Find a similar face." +
                  Chr(10) + Chr(10) + "- ENTER: Switch to the next face."

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
    iRatio.d = *resize\width / *image\width
    min_loc.CvPoint
    max_loc.CvPoint
    offset = 5
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *resize
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      If *resize
        *temp.IplImage = cvLoadImage("images/face" + Str(nFace + 1) + ".jpg", #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
        *template.IplImage = cvCreateImage(*temp\width * iRatio, *temp\height * iRatio, #IPL_DEPTH_8U, *image\nChannels)
        cvResize(*temp, *template, #CV_INTER_AREA)
        *result.IplImage = cvCreateImage(*resize\width - *template\width + 1, *resize\height - *template\height + 1, #IPL_DEPTH_32F, 1)
        cvMatchTemplate(*resize, *template, *result, #CV_TM_SQDIFF)
        cvMinMaxLoc(*result, @min_val.d, @max_val.d, @min_loc, @max_loc, #Null)
        cvRectangle(*resize, min_loc\x, min_loc\y, min_loc\x + *template\width, min_loc\y + *template\height, 0, 0, 255, 0, 2, #CV_AA, #Null)
        *border.IplImage = cvCreateImage(*temp\width + offset - 1, *temp\height + offset - 1, #IPL_DEPTH_8U, *temp\nChannels)
        cvCopyMakeBorder(*temp, *border, (offset - 1) / 2, (offset - 1) / 2, #IPL_BORDER_CONSTANT, 0, 255, 255, 0)
        cvSetImageROI(*resize, 20, 20, *border\width, *border\height)
        cvAndS(*resize, 0, 0, 0, 0, *resize, #Null)
        cvAdd(*resize, *border, *resize, #Null)
        cvResetImageROI(*resize)
        cvShowImage(#CV_WINDOW_NAME, *resize)
        keyPressed = cvWaitKey(0)

        If keyPressed = 13 : nFace = (nFace + 1) % 5 : EndIf

        If keyPressed <> 32
          cvReleaseImage(@*resize)
          *resize = cvCloneImage(*reset)
        EndIf
        cvReleaseImage(@*border)
        cvReleaseImage(@*result)
        cvReleaseImage(@*template)
        cvReleaseImage(@*temp)
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseImage(@*reset)
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/faces.jpg")
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
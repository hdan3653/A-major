IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Using a default image, the absolute difference is calculated against a directory of images, " +
                  "returning the closest match." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Show first/next match."

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

Structure IMAGE_COMPARE
  name.s
  ratio.f
EndStructure

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
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *resize
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      cvShowImage(#CV_WINDOW_NAME, *resize)
      keyPressed = cvWaitKey(0)
    Until keyPressed = 27 Or keyPressed = 32 Or exitCV

    If keyPressed = 32
      *reset.IplImage = cvCloneImage(*resize)
      font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_PLAIN, 1, 1, #Null, 1, #CV_AA)
      cvPutText(*resize, "Searching...", 20, 50, @font, 255, 255, 255, 0)
      cvShowImage(#CV_WINDOW_NAME, *resize)
      cvWaitKey(100)
      dirImages = ExamineDirectory(#PB_Any, "images/", "*.*")

      If dirImages
        Dim iCompare.IMAGE_COMPARE(0)

        While NextDirectoryEntry(dirImages)
          imageName.s = DirectoryEntryName(dirImages)

          Select GetExtensionPart(imageName)
            Case "bmp", "dib", "jpeg", "jpg", "jpe", "png", "tiff", "tif"
              If "images/" + imageName <> ImageFile
                *temp.IplImage = cvLoadImage("images/" + imageName, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)

                If *temp\nChannels = *image\nChannels And *temp\width > 200
                  *compare.IplImage = cvCreateImage(*image\width, *image\height, *image\depth, *image\nChannels)
                  cvResize(*temp, *compare, #CV_INTER_AREA)
                  cvSmooth(*compare, *compare, #CV_GAUSSIAN, 3, 0, 0, 0)
                  ReDim iCompare(arrCount)
                  iCompare(arrCount)\name = "images/" + imageName
                  iCompare(arrCount)\ratio = cvNorm(*image, *compare, #CV_L2, #Null)
                  arrCount + 1
                  cvReleaseImage(@*compare)
                EndIf
                cvReleaseImage(@*temp)
              EndIf
          EndSelect
        Wend
        FinishDirectory(dirImages)

        If ArraySize(iCompare())
          SortStructuredArray(iCompare(), #PB_Sort_Ascending, OffsetOf(IMAGE_COMPARE\ratio), TypeOf(IMAGE_COMPARE\ratio))
          *compare.IplImage = cvLoadImage(iCompare(0)\name, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
        EndIf
      EndIf

      Repeat
        If *resize
          If ArraySize(iCompare())
            If *compare\nChannels = 1
              *temp.IplImage = cvCloneImage(*compare)
              cvReleaseImage(@*compare)
              *compare.IplImage = cvCreateImage(*temp\width, *temp\height, #IPL_DEPTH_8U, 3)
              cvCvtColor(*temp, *compare, #CV_GRAY2BGR, 1)
              cvReleaseImage(@*temp)
            EndIf

            If *compare\width > 100
              iRatio.d = 100 / *compare\width
              iWidth = *compare\width * iRatio
              iHeight = *compare\height * iRatio
              *match.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *compare\nChannels)
              cvResize(*compare, *match, #CV_INTER_AREA)
            Else
              *match = cvCloneImage(*compare)
            EndIf
            offset = 5
            *border.IplImage = cvCreateImage(*match\width + offset - 1, *match\height + offset - 1, #IPL_DEPTH_8U, *match\nChannels)
            cvCopyMakeBorder(*match, *border, (offset - 1) / 2, (offset - 1) / 2, #IPL_BORDER_CONSTANT, 0, 255, 255, 0)
            cvSetImageROI(*resize, 20, 20, *border\width, *border\height)
            cvAndS(*resize, 0, 0, 0, 0, *resize, #Null)
            cvAdd(*resize, *border, *resize, #Null)
            cvResetImageROI(*resize)
            cvReleaseImage(@*border)
            cvReleaseImage(@*match)
          EndIf
          cvShowImage(#CV_WINDOW_NAME, *resize)
          keyPressed = cvWaitKey(0)

          If keyPressed = 32
            If compare = ArraySize(iCompare()) : compare = 0 : Else : compare + 1 : EndIf

            cvReleaseImage(@*resize)
            *resize = cvCloneImage(*reset)
            cvReleaseImage(@*compare)
            *compare.IplImage = cvLoadImage(iCompare(compare)\name, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
            *param\uPointer1 = *resize
          EndIf
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
      cvReleaseImage(@*compare)
      cvReleaseImage(@*reset)
    EndIf
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/album1.jpg")
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
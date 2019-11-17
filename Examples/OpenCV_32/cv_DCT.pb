IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Performs a discrete Cosine transform of a 1D array, first displaying its power spectrum " +
                  "then incrementally reducing noise." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Start next stage." +
                  Chr(10) + Chr(10) + "- ENTER: Reset the image."

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
    *image.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_GRAYSCALE)
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
    width = *resize\width
    height = *resize\height

    If width % 2 = 0 : width2 = width : Else : width2 = width + 1 : EndIf
    If height % 2 = 0 : height2 = height : Else : height2 = height + 1 : EndIf

    *border.IplImage = cvCreateImage(width2, height2, #IPL_DEPTH_8U, 1)
    *convert.IplImage = cvCreateImage(width2, height2, #IPL_DEPTH_8U, 1)
    *dct.CvMat = cvCreateMat(height2, width2, CV_MAKETYPE(#CV_64F, 1))
    *frequency.CvMat = cvCreateMat(height2, width2, CV_MAKETYPE(#CV_64F, 1))
    *inverse.CvMat = cvCreateMat(height2, width2, CV_MAKETYPE(#CV_64F, 1))
    *reset.CvMat
    cvCopyMakeBorder(*resize, *border, width2 - width, height2 - height, #IPL_BORDER_REPLICATE, 0, 0, 0, 0)
    cvConvert(*border, *dct)
    cvNormalize(*dct, *dct, 0, 1, #CV_MINMAX, #Null)
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_PLAIN, 1, 1, #Null, 1, #CV_AA)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *resize
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

    Repeat
      Repeat
        cvShowImage(#CV_WINDOW_NAME, *dct)
        keyPressed = cvWaitKey(0)
      Until keyPressed = 27 Or keyPressed = 32 Or exitCV

      If keyPressed = 32
        cvDCT(*dct, *frequency, #DCT_FORWARD)
        cvReleaseMat(@*reset)
        *reset = cvCloneMat(*frequency)
        cvConvertScale(*frequency, *convert, 255, 0)
        *param\uPointer1 = *convert

        Repeat
          cvShowImage(#CV_WINDOW_NAME, *frequency)
          keyPressed = cvWaitKey(0)
        Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 32 Or exitCV

        If keyPressed = 32
          *param\uPointer1 = *convert

          If *frequency
            For rtnCount = 1 To 100
              For y = rtnCount To *frequency\rows - 1
                For x = rtnCount To *frequency\cols - 1
                  cvmSet(*frequency, y, x, 0)
                Next
              Next
              cvDCT(*frequency, *inverse, #DCT_INVERSE)
              cvPutText(*inverse, "Noise Reduction: " + Right("00" + Str(rtnCount), 3), 20, 30, @font, 0, 0, 0, 0)
              cvShowImage(#CV_WINDOW_NAME, *inverse)
              cvConvertScale(*inverse, *convert, 255, 0)
              keyPressed = cvWaitKey(1)

              If keyPressed = 13 : Break : ElseIf keyPressed = 27 Or exitCV : Break 2 : EndIf

              cvReleaseMat(@*frequency)
              *frequency = cvCloneMat(*reset)
            Next

            If keyPressed <> 13
              Repeat : keyPressed = cvWaitKey(0) : Until keyPressed = 13 Or keyPressed = 27 Or exitCV
            EndIf
          EndIf
        EndIf
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseMat(@*reset)
    cvReleaseMat(@*inverse)
    cvReleaseMat(@*frequency)
    cvReleaseMat(@*dct)
    cvReleaseImage(@*convert)
    cvReleaseImage(@*border)
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
OpenCV("images/sketch1.jpg")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
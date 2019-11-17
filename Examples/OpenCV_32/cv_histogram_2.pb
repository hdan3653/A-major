IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nBrightness, nContrast, Dim lut.b(256)

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Calculates a histogram based on brightness and contrast levels." + Chr(10) + Chr(10) +
                  "- TRACKBAR 1: Adjust the brightness." + Chr(10) + Chr(10) +
                  "- TRACKBAR 2: Adjust the contrast."

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

ProcedureC UpdateBrightnessContrast()
  brightness = nBrightness - 100
  contrast = nContrast - 100

  If contrast > 0
    delta.d = 127 * contrast / 100
    a.d = 255 / (255 - delta * 2)
    b.d = a * (brightness - delta)
  Else
    delta.d = -128 * contrast / 100
    a.d = (256 - delta * 2) / 255
    b.d = a * brightness + delta
  EndIf

  For i = 0 To 256 - 1
    v = Round(a * i + b, #PB_Round_Nearest)

    If v < 0 : v = 0 : EndIf
    If v > 255 : v = 255 : EndIf

    lut(i) = v
  Next
EndProcedure

ProcedureC CvTrackbarCallback1(pos)
  nBrightness = pos
  UpdateBrightnessContrast()
  keybd_event_(#VK_RETURN, 0, 0, 0)
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  nContrast = pos
  UpdateBrightnessContrast()
  keybd_event_(#VK_RETURN, 0, 0, 0)
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

    If *image\width >= dtWidth - 100 Or *image\height >= dtHeight - (100 + 48 + 42)
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / *image\width
      iHeight = dtHeight - (100 + 48 + 42)
      iRatio2.d = iHeight / (*image\height)

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
      nBrightness = 100
      nContrast = 100
      cvCreateTrackbar("Brightness", #CV_WINDOW_NAME, @nBrightness, 200, @CvTrackbarCallback1())
      cvCreateTrackbar("Contrast", #CV_WINDOW_NAME, @nContrast, 200, @CvTrackbarCallback2())
      Dim *clone.IplImage(1) : *clone(0) = cvCloneImage(*resize)
      *hist.IplImage = cvCreateImage(193, 100, #IPL_DEPTH_8U, 1)
      *gray.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)
      *color.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 3)
      *lut = cvCreateMatHeader(1, 256, CV_MAKETYPE(#CV_8U, 1))
      bins = 64
      Dim range.f(2) : range(0) = 0 : range(1) = 256
      PokeL(@*ranges, @range())
      *histogram.CvHistogram = cvCreateHist(1, @bins, #CV_HIST_ARRAY, @*ranges, 1)
      cvSetData(*lut, @lut(), 0)
      UpdateBrightnessContrast()
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *gray
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *resize
          cvSetZero(*clone(0))
          cvLUT(*resize, *clone(0), *lut)
          cvCalcHist(*clone(), *histogram, #False, #Null)
          cvGetMinMaxHistValue(*histogram, #Null, @max_value.f, #Null, #Null)
          cvConvertScale(*histogram\bins, *histogram\bins, *hist\height / max_value, 0)
          cvSet(*hist, 255, 255, 255, 0, #Null)
          bin = Round(*hist\width / bins, #PB_Round_Nearest)

          For i = 0 To bins - 1
            x1 = i * bin
            y1 = *hist\height
            x2 = (i + 1) * bin
            y2 = *hist\height - Round(cvGetReal1D(*histogram\bins, i), #PB_Round_Nearest)
            cvRectangle(*hist, x1, y1, x2, y2, 0, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
          Next
          cvCopy(*clone(0), *gray, #Null)
          cvSetImageROI(*gray, 20, 20, 193, 100)
          cvAndS(*gray, 0, 0, 0, 0, *gray, #Null)
          cvAdd(*gray, *hist, *gray, #Null)
          cvResetImageROI(*gray)
          cvCvtColor(*gray, *color, #CV_GRAY2BGR, 1)
          cvRectangleR(*color, 19, 19, 193 + 2, 100 + 2, 0, 255, 255, 0, 2, #CV_AA, #Null)
          cvShowImage(#CV_WINDOW_NAME, *color)
          keyPressed = cvWaitKey(0)
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
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
      cvReleaseHist(@*histogram)
      cvReleaseMat(@*lut)
      cvReleaseImage(@*color)
      cvReleaseImage(@*gray)
      cvReleaseImage(@*hist)
      cvReleaseImage(@*clone(0))
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/building.jpg")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = --
; EnableXP
; CurrentDirectory = binaries\
IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nThreshold

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Calculates the distance to the closest zero pixel for each pixel of the source image." + Chr(10) + Chr(10) +
                  "- TRACKBAR: Adjust the threshold." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Iterate various modes." + Chr(10) + Chr(10) +
                  "- [ V ] KEY: Toggle Voronoi pixel type."

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

ProcedureC CvTrackbarCallback(pos)
  nThreshold = pos + 1
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

    If *image\width >= dtWidth - 100 Or *image\height >= dtHeight - (100 + 48)
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / *image\width
      iHeight = dtHeight - (100 + 48)
      iRatio2.d = iHeight / (*image\height)

      If iRatio1 < iRatio2
        iWidth = *image\width * iRatio1
        iHeight = *image\height * iRatio1
      Else
        iWidth = *image\width * iRatio2
        iHeight = *image\height * iRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight + 48)
      *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image\nChannels)
      cvResize(*image, *resize, #CV_INTER_AREA)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height + 48)
      *resize.IplImage = cvCloneImage(*image)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)

    If *resize\width > 200 And *resize\height > 200
      nThreshold = 100
      cvCreateTrackbar("Threshold", #CV_WINDOW_NAME, @nThreshold, 255, @CvTrackbarCallback())
      *dist.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_32F, 1)
      *dist8u.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 3)
      *dist8u1.IplImage = cvCloneImage(*resize)
      *dist8u2.IplImage = cvCloneImage(*resize)
      *dist32s.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_32S, 1)
      *edge.IplImage = cvCloneImage(*resize)
      *labels.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_32S, 1)
      Dim colors(9, 3)
      colors(0, 0) = 0 : colors(0, 1) = 0 : colors(0, 2) = 0
      colors(1, 0) = 255 : colors(1, 1) = 0 : colors(1, 2) = 0
      colors(2, 0) = 255 : colors(2, 1) = 128 : colors(2, 2) = 0
      colors(3, 0) = 255 : colors(3, 1) = 255 : colors(3, 2) = 0
      colors(4, 0) = 0 : colors(4, 1) = 255 : colors(4, 2) = 0
      colors(5, 0) = 0 : colors(5, 1) = 128 : colors(5, 2) = 255
      colors(6, 0) = 0 : colors(6, 1) = 255 : colors(6, 2) = 255
      colors(7, 0) = 0 : colors(7, 1) = 0 : colors(7, 2) = 255
      colors(8, 0) = 255 : colors(8, 1) = 0 : colors(8, 2) = 255
      dist_type = #CV_DIST_L1
      mask_size = #CV_DIST_MASK_3
      *ll.LONG
      *dd.FLOAT
      *d.BYTE
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *dist8u
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *edge
          cvThreshold(*resize, *edge, nThreshold, nThreshold, #CV_THRESH_BINARY)

          If build_voronoi
            cvDistTransform(*edge, *dist, dist_type, mask_size, #Null, *labels, labeltype)
          Else
            cvDistTransform(*edge, *dist, dist_type, mask_size, #Null, #Null, #CV_DIST_LABEL_CCOMP)
          EndIf

          If build_voronoi
            For i = 0 To *labels\height - 1
              *ll = @*labels\imageData\b + i * *labels\widthStep
              *dd = @*dist\imageData\b + i * *dist\widthStep
              *d = @*dist8u\imageData\b + i * *dist8u\widthStep

              For j = 0 To *labels\width - 1
                If PeekL(@*ll\l + j * 4) = 0 Or PeekF(@*dd\f + j * 4) = 0
                  idx = 0
                Else
                  idx = (PeekL(@*ll\l + j * 4) - 1) % 8 + 1
                EndIf
                b = colors(idx, 0)
                g = colors(idx, 1)
                r = colors(idx, 2)
                PokeA(@*d\b + j * 3, b)
                PokeA(@*d\b + j * 3 + 1, g)
                PokeA(@*d\b + j * 3 + 2, r)
              Next
            Next
          Else
            cvConvertScale(*dist, *dist, 5000, 0)
            cvPow(*dist, *dist, 0.5)
            cvConvertScale(*dist, *dist32s, 1, 0.5)
            cvAndS(*dist32s, 255, 255, 255, 0, *dist32s, #Null)
            cvConvertScale(*dist32s, *dist8u1, 1, 0)
            cvConvertScale(*dist32s, *dist32s, -1, 0)
            cvAddS(*dist32s, 255, 255, 255, 0, *dist32s, #Null)
            cvConvertScale(*dist32s, *dist8u2, 1, 0)
            cvMerge(*dist8u1, *dist8u2, *dist8u2, 0, *dist8u)
          EndIf
          cvShowImage(#CV_WINDOW_NAME, *dist8u)
          keyPressed = cvWaitKey(0)

          Select keypressed
            Case 32
              mask = (mask + 1) % 8

              Select mask
                Case 0
                  build_voronoi = #False
                  dist_type = #CV_DIST_L1
                  mask_size = #CV_DIST_MASK_3
                Case 1
                  dist_type = #CV_DIST_L2
                Case 2
                  dist_type = #CV_DIST_L2
                  mask_size = #CV_DIST_MASK_5
                Case 3
                  dist_type = #CV_DIST_L2
                  mask_size = #CV_DIST_MASK_PRECISE
                Case 4
                  dist_type = #CV_DIST_C
                  mask_size = #CV_DIST_MASK_3
                Case 5
                  build_voronoi = #True
                  dist_type = #CV_DIST_L1
                  mask_size = #CV_DIST_MASK_5
                Case 6
                  dist_type = #CV_DIST_L2
                Case 7
                  dist_type = #CV_DIST_C
              EndSelect
            Case 86, 118
              labeltype ! 1

              If build_voronoi = #False
                mask = 5
                build_voronoi = #True
                dist_type = #CV_DIST_L1
                mask_size = #CV_DIST_MASK_5
              EndIf
          EndSelect
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
      cvReleaseImage(@*labels)
      cvReleaseImage(@*edge)
      cvReleaseImage(@*dist32s)
      cvReleaseImage(@*dist8u2)
      cvReleaseImage(@*dist8u1)
      cvReleaseImage(@*dist8u)
      cvReleaseImage(@*dist)
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
OpenCV("images/baboon.jpg")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
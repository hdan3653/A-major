IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nDistort, nAngle, nTrackbar

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Distort a color image by manipulating pixel locations." + Chr(10) + Chr(10) +
                  "- TRACKBAR 1: Adjust distortion." + Chr(10) + Chr(10) +
                  "- TRACKBAR 2: Adjust SIN/angle." + Chr(10) + Chr(10) +
                  "- MOUSE: Outline an area to distort." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Set distortion method." + Chr(10) + Chr(10) +
                  "- ENTER: Reset the image." + Chr(10) + Chr(10) +
                  "- [ X ] KEY: Exit selection mode."

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

Global Dim pts.CvPoint(0)

ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)
  Static pt1.CvPoint

  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      Dim pts.CvPoint(0)
      nTrackbar ! 1 : keybd_event_(#VK_SPACE, 0, 0, 0)
      pt1\x = x
      pt1\y = y
    Case #CV_EVENT_LBUTTONUP
      If Not Bool(flags And #CV_EVENT_FLAG_LBUTTON)
        If ArraySize(pts()) < 40 : keybd_event_(#VK_X, 0, 0, 0) : EndIf

        pt1\x = -1
        pt1\y = -1
      EndIf
    Case #CV_EVENT_MOUSEMOVE
      If Bool(flags And #CV_EVENT_FLAG_LBUTTON)
        pt2.CvPoint
        pt2\x = x
        pt2\y = y

        If pt1\x > 0 And pt2\x < 60000 And pt2\y < 60000
          cvLine(*param\uPointer1, pt1\x, pt1\y, pt2\x, pt2\y, 255, 0, 0, 0 , 4, #CV_AA, #Null)
          cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
          arrCount = ArraySize(pts())
          ReDim pts(arrCount + 1)
          pts(arrCount)\x = x
          pts(arrCount)\y = y
          pt1 = pt2
        EndIf
      EndIf
  EndSelect
EndProcedure

ProcedureC CvTrackbarCallback1(pos)
  nDistort = pos
  keybd_event_(#VK_Z, 0, 0, 0)
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  nAngle = pos * 4
  keybd_event_(#VK_Z, 0, 0, 0)
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

    If *resize\width > 200 And *resize\height > 200 And *resize\nChannels = 3
      cvCreateTrackbar("Distortion", #CV_WINDOW_NAME, @nDistort, 20, @CvTrackbarCallback1())
      cvCreateTrackbar("Angle", #CV_WINDOW_NAME, @nAngle, 20, @CvTrackbarCallback2())
      *reset.IplImage = cvCloneImage(*resize)
      *mask.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)
      *input.CvMat = cvCreateMat(*resize\height, *resize\width, CV_MAKETYPE(#CV_32F, 3))
      *output.CvMat = cvCreateMat(*resize\height, *resize\width, CV_MAKETYPE(#CV_32F, 3))
      *distort.CvMat = cvCreateMat(*resize\height, *resize\width, CV_MAKETYPE(#CV_8U, 3))
      *draw.CvMat = cvCreateMat(*resize\height, *resize\width, CV_MAKETYPE(#CV_8U, 3))
      Dim pts(4) : pts(0)\x = 0: pts(0)\y = 0 : pts(1)\x = *mask\width : pts(1)\y = 0
      pts(2)\x = *mask\width: pts(2)\y = *mask\height : pts(3)\x = 0 : pts(3)\y = *mask\height
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *draw
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *resize
          cvConvert(*resize, *input)

          If nDistort And keyPressed = 122
            cvSetZero(*mask)
            npts = ArraySize(pts())
            cvFillPoly(*mask, pts(), @npts, 1, 255, 255, 255, 0, #CV_AA, #Null)

            For j = 0 To *mask\height - 1
              For i = 0 To *mask\width - 1
                If PeekA(@*mask\imageData\b + j * *mask\widthStep + i) = 255
                  If nTrackbar
                    xo.d = nDistort * Sin(2 * #PI * i / (nAngle + 128))
                    yo.d = nDistort * Sin(2 * #PI * j / (nAngle + 128))
                  Else
                    xo.d = nDistort * Sin(2 * #PI * j / (nAngle + 128))
                    yo.d = nDistort * Sin(2 * #PI * i / (nAngle + 128))
                  EndIf
                  maxA = 0 : maxB = i + xo
                  CV_MAX(maxA, maxB)
                  ix = *mask\width - 1
                  CV_MIN(ix, maxA)
                  maxA = 0 : maxB = j + yo
                  CV_MAX(maxA, maxB)
                  iy = *mask\height - 1
                  CV_MIN(iy, maxA)
                  PokeF(@*output\fl\f + j * *output\Step + (i * 3 + 0) * 4, PeekF(@*input\fl\f + iy * *input\Step + (ix * 3 + 0) * 4))
                  PokeF(@*output\fl\f + j * *output\Step + (i * 3 + 1) * 4, PeekF(@*input\fl\f + iy * *input\Step + (ix * 3 + 1) * 4))
                  PokeF(@*output\fl\f + j * *output\Step + (i * 3 + 2) * 4, PeekF(@*input\fl\f + iy * *input\Step + (ix * 3 + 2) * 4))
                Else
                  PokeF(@*output\fl\f + j * *output\Step + (i * 3 + 0) * 4, PeekF(@*input\fl\f + j * *input\Step + (i * 3 + 0) * 4))
                  PokeF(@*output\fl\f + j * *output\Step + (i * 3 + 1) * 4, PeekF(@*input\fl\f + j * *input\Step + (i * 3 + 1) * 4))
                  PokeF(@*output\fl\f + j * *output\Step + (i * 3 + 2) * 4, PeekF(@*input\fl\f + j * *input\Step + (i * 3 + 2) * 4))
                EndIf
              Next
            Next
            cvConvert(*output, *distort)
          Else
            cvConvert(*input, *distort)
          EndIf
          cvCopy(*distort, *draw, #Null)
          cvShowImage(#CV_WINDOW_NAME, *distort)
          keyPressed = cvWaitKey(0)

          Select keyPressed
            Case 13
              nTrackbar = 0
              Dim pts(4) : pts(0)\x = 0: pts(0)\y = 0 : pts(1)\x = *mask\width : pts(1)\y = 0
              pts(2)\x = *mask\width: pts(2)\y = *mask\height : pts(3)\x = 0 : pts(3)\y = *mask\height
              cvSetTrackbarPos("Distortion", #CV_WINDOW_NAME, 0)
              cvSetTrackbarPos("Angle", #CV_WINDOW_NAME, 0)
              cvCreateTrackbar("Distortion", #CV_WINDOW_NAME, @nDistort, 20, @CvTrackbarCallback1())
              cvReleaseImage(@*resize)
              *resize = cvCloneImage(*reset)
            Case 32
              nTrackbar ! 1
              cvSetTrackbarPos("Distortion", #CV_WINDOW_NAME, 0)

              If nTrackbar
                cvCreateTrackbar("Distortion", #CV_WINDOW_NAME, @nDistort, 10, @CvTrackbarCallback1())
              Else
                cvCreateTrackbar("Distortion", #CV_WINDOW_NAME, @nDistort, 20, @CvTrackbarCallback1())
              EndIf
              cvCopy(*distort, *resize, #Null)
            Case 88, 120
              Dim pts(4) : pts(0)\x = 0: pts(0)\y = 0 : pts(1)\x = *mask\width : pts(1)\y = 0
              pts(2)\x = *mask\width: pts(2)\y = *mask\height : pts(3)\x = 0 : pts(3)\y = *mask\height
              cvSetTrackbarPos("Distortion", #CV_WINDOW_NAME, 0)

              If nTrackbar
                cvCreateTrackbar("Distortion", #CV_WINDOW_NAME, @nDistort, 10, @CvTrackbarCallback1())
              Else
                cvCreateTrackbar("Distortion", #CV_WINDOW_NAME, @nDistort, 20, @CvTrackbarCallback1())
              EndIf
              cvCopy(*distort, *resize, #Null)
          EndSelect
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
      cvReleaseMat(@*draw)
      cvReleaseMat(@*distort)
      cvReleaseMat(@*output)
      cvReleaseMat(@*input)
      cvReleaseImage(@*mask)
      cvReleaseImage(@*reset)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If getCV
        getCV = #False
        exitCV = #False
        nDistort = 0
        nAngle = 0
        nTrackbar = 0
        OpenCV(GetImage())
      EndIf
    Else
      If *resize\nChannels = 3
        MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the size requirements, please try a larger image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      Else
        MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the channel requirements, please try a color image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      EndIf
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/lena.jpg")
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
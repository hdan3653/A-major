IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nRadius, nPower

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Applies the Vignette effect, the process by which there is loss in clarity towards " +
                  "the corners and sides of an image." + Chr(10) + Chr(10) +
                  "- TRACKBAR 1: Adjust the Raduis." + Chr(10) + Chr(10) +
                  "- TRACKBAR 2: Adjust the Power." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Execute Vignette effect."

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

ProcedureC CvTrackbarCallback1(pos)
  nRadius = pos
  keybd_event_(#VK_SPACE, 0, 0, 0)
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  nPower = pos
  keybd_event_(#VK_SPACE, 0, 0, 0)
EndProcedure

ProcedureC.d GetDistance(x1, y1, x2, y2)
  ProcedureReturn Sqr(Pow(x1 - x2, 2) + Pow(y1 - y2, 2))
EndProcedure

ProcedureC.d GetMaxDistanceFromCorners(nWidth, nHeight, nX, nY)
  Dim corners.CvPoint(4)
  corners(0)\x = 0
  corners(0)\y = 0
  corners(1)\x = nWidth
  corners(1)\y = 0
  corners(2)\x = 0
  corners(2)\y = nHeight
  corners(3)\x = nWidth
  corners(3)\y = nHeight

  For rtnCount = 0 To 4 - 1
    nDistance.d = GetDistance(corners(i)\x, corners(i)\y, nX, nY)

    If maxDistance.d < nDistance : maxDistance = nDistance : EndIf

  Next
  ProcedureReturn maxDistance
EndProcedure

ProcedureC GenerateGradient(*mask.CvMat)
  maxImageRad.d = ((11 - (nRadius + 5)) / 10) * GetMaxDistanceFromCorners(*mask\cols, *mask\rows, *mask\cols / 2, *mask\rows / 2)
  cvSet(*mask, 1, 1, 1, 1, #Null)

  For i = 0 To *mask\rows - 1
    For j = 0 To *mask\cols - 1
      nTemp.d = GetDistance(*mask\cols / 2, *mask\rows / 2, j, i) / maxImageRad
      nTemp * ((nPower + 5) / 10)
      nTemp_s.d = Pow(Cos(nTemp), 4)
      PokeD(@*mask\db\d + i * *mask\Step + j * 8, nTemp_s)
    Next
  Next
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
      nRadius = 1 : nPower = 1
      cvCreateTrackbar("Radius", #CV_WINDOW_NAME, @nRadius, 2, @CvTrackbarCallback1())
      cvCreateTrackbar("Power", #CV_WINDOW_NAME, @nPower, 2, @CvTrackbarCallback2())
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *resize
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        cvShowImage(#CV_WINDOW_NAME, *resize)
        keyPressed = cvWaitKey(0)
      Until keyPressed = 27 Or keyPressed = 32 Or exitCV

      If keyPressed = 32
        *mask.CvMat = cvCreateMat(*resize\height, *resize\width, CV_MAKETYPE(#CV_64F, 1))
        *lab.CvMat = cvCreateMat(*resize\height, *resize\width, CV_MAKETYPE(#CV_8U, 3))
        *vignette.CvMat = cvCreateMat(*resize\height, *resize\width, CV_MAKETYPE(#CV_8U, 3))
        *param\uPointer1 = *vignette

        Repeat
          If *vignette
            cvCvtColor(*resize, *lab, #CV_BGR2Lab, 1)
            GenerateGradient(*mask)

            For i = 0 To *lab\rows - 1
              For j = 0 To *lab\cols - 1
                PokeA(@*lab\ptr\b + i * *lab\Step + j * 3, PeekA(@*lab\ptr\b + i * *lab\Step + j * 3) * PeekD(@*mask\db\d + i * *mask\Step + j * 8))       
              Next
            Next
            cvCvtColor(*lab, *vignette, #CV_Lab2BGR, 1)
            cvShowImage(#CV_WINDOW_NAME, *vignette)
            keyPressed = cvWaitKey(0)
          EndIf
        Until keyPressed = 27 Or exitCV
        FreeMemory(*param)
        cvReleaseMat(@*vignette)
        cvReleaseMat(@*lab)
        cvReleaseMat(@*mask)
      EndIf
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If getCV
        getCV = #False
        exitCV = #False
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
OpenCV("images/style1.jpg")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
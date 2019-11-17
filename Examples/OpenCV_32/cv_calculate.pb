IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nB, nG, nR

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Add, subtract, multiply, or divide every array element of an image." + Chr(10) + Chr(10) +
                  "- TRACKBAR 1: Adjust Blue value." + Chr(10) + Chr(10) +
                  "- TRACKBAR 2: Adjust Green value." + Chr(10) + Chr(10) +
                  "- TRACKBAR 3: Adjust Red value." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Change the operation."

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
  nB = pos
  keybd_event_(#VK_RETURN, 0, 0, 0)
EndProcedure

ProcedureC CvTrackbarCallback2(pos)
  nG = pos
  keybd_event_(#VK_RETURN, 0, 0, 0)
EndProcedure

ProcedureC CvTrackbarCallback3(pos)
  nR = pos
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
    *image.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_ANYDEPTH | #CV_LOAD_IMAGE_ANYCOLOR)
    dtWidth = DesktopWidth(0)
    dtHeight = DesktopHeight(0)

    If *image\width >= dtWidth - 100 Or *image\height >= dtHeight - (100 + 48 + 42 + 84)
      iWidth = dtWidth - 100
      iRatio1.d = iWidth / *image\width
      iHeight = dtHeight - (100 + 48 + 42 + 84)
      iRatio2.d = iHeight / *image\height

      If iRatio1 < iRatio2
        iWidth = *image\width * iRatio1
        iHeight = *image\height * iRatio1
      Else
        iWidth = *image\width * iRatio2
        iHeight = *image\height * iRatio2
      EndIf
      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight + 48 + 42 + 84)
      *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image\nChannels)
      cvResize(*image, *resize, #CV_INTER_AREA)
    Else
      cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height + 48 + 42 + 84)
      *resize.IplImage = cvCloneImage(*image)
    EndIf
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    ToolTip(window_handle, #CV_DESCRIPTION)

    If *resize\width > 200 And *resize\height > 200
      cvCreateTrackbar("Blue", #CV_WINDOW_NAME, 0, 255, @CvTrackbarCallback1())
      cvCreateTrackbar("Green", #CV_WINDOW_NAME, 0, 255, @CvTrackbarCallback2())
      cvCreateTrackbar("Red", #CV_WINDOW_NAME, 0, 255, @CvTrackbarCallback3())
      *reset.IplImage = cvCloneImage(*resize)
      *caculate.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, *resize\nChannels)
      font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
      cvPutText(*resize, "ADD", 22, 42, @font, 0, 0, 0, 0)
      cvPutText(*resize, "ADD", 20, 40, @font, 255, 255, 255, 0)
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *resize
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        If *resize
          cvShowImage(#CV_WINDOW_NAME, *resize)
          keyPressed = cvWaitKey(0)
          cvReleaseImage(@*resize)
          *resize = cvCloneImage(*reset)

          If keyPressed = 32
            caculate = (caculate + 1) % 4

            Select caculate
              Case 0
                cvCreateTrackbar("Blue", #CV_WINDOW_NAME, @nB, 255, @CvTrackbarCallback1())
                cvCreateTrackbar("Green", #CV_WINDOW_NAME, @nG, 255, @CvTrackbarCallback2())
                cvCreateTrackbar("Red", #CV_WINDOW_NAME, @nR, 255, @CvTrackbarCallback3())
                cvSetTrackbarPos("Blue", #CV_WINDOW_NAME, 0)
                cvSetTrackbarPos("Green", #CV_WINDOW_NAME, 0)
                cvSetTrackbarPos("Red", #CV_WINDOW_NAME, 0)
              Case 1
                cvCreateTrackbar("Blue", #CV_WINDOW_NAME, @nB, 255, @CvTrackbarCallback1())
                cvCreateTrackbar("Green", #CV_WINDOW_NAME, @nG, 255, @CvTrackbarCallback2())
                cvCreateTrackbar("Red", #CV_WINDOW_NAME, @nR, 255, @CvTrackbarCallback3())
                cvSetTrackbarPos("Blue", #CV_WINDOW_NAME, 0)
                cvSetTrackbarPos("Green", #CV_WINDOW_NAME, 0)
                cvSetTrackbarPos("Red", #CV_WINDOW_NAME, 0)
              Case 2
                cvCreateTrackbar("Blue", #CV_WINDOW_NAME, @nB, 25, @CvTrackbarCallback1())
                cvCreateTrackbar("Green", #CV_WINDOW_NAME, @nG, 25, @CvTrackbarCallback2())
                cvCreateTrackbar("Red", #CV_WINDOW_NAME, @nR, 25, @CvTrackbarCallback3())
                cvSetTrackbarPos("Blue", #CV_WINDOW_NAME, 1)
                cvSetTrackbarPos("Green", #CV_WINDOW_NAME, 1)
                cvSetTrackbarPos("Red", #CV_WINDOW_NAME, 1)
              Case 3
                cvCreateTrackbar("Blue", #CV_WINDOW_NAME, @nB, 25, @CvTrackbarCallback1())
                cvCreateTrackbar("Green", #CV_WINDOW_NAME, @nG, 25, @CvTrackbarCallback2())
                cvCreateTrackbar("Red", #CV_WINDOW_NAME, @nR, 25, @CvTrackbarCallback3())
                cvSetTrackbarPos("Blue", #CV_WINDOW_NAME, 1)
                cvSetTrackbarPos("Green", #CV_WINDOW_NAME, 1)
                cvSetTrackbarPos("Red", #CV_WINDOW_NAME, 1)
            EndSelect
          EndIf
          cvSet(*caculate, nB, nG, nR, 0, #Null)

          Select caculate
            Case 0
              cvAdd(*resize, *caculate, *resize, #Null)
              cvPutText(*resize, "ADD", 22, 42, @font, 0, 0, 0, 0)
              cvPutText(*resize, "ADD", 20, 40, @font, 255, 255, 255, 0)
            Case 1
              cvSub(*resize, *caculate, *resize, #Null)
              cvPutText(*resize, "SUBTRACT", 22, 42, @font, 0, 0, 0, 0)
              cvPutText(*resize, "SUBTRACT", 20, 40, @font, 255, 255, 255, 0)
            Case 2
              cvMul(*resize, *caculate, *resize, 1)
              cvPutText(*resize, "MULTIPLY", 22, 42, @font, 0, 0, 0, 0)
              cvPutText(*resize, "MULTIPLY", 20, 40, @font, 255, 255, 255, 0)
            Case 3
              cvDiv(*resize, *caculate, *resize, 1)
              cvPutText(*resize, "DIVIDE", 22, 42, @font, 0, 0, 0, 0)
              cvPutText(*resize, "DIVIDE", 20, 40, @font, 255, 255, 255, 0)
          EndSelect
        EndIf
      Until keyPressed = 27 Or exitCV
      FreeMemory(*param)
      cvReleaseImage(@*caculate)
      cvReleaseImage(@*reset)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If getCV
        getCV = #False
        exitCV = #False
        nB = 0
        nG = 0
        nR = 0
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
OpenCV("images/starrynight.jpg")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
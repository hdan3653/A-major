IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, select_object, Dim selected.CvRect(0)

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Create an image mask by replacing any pixel colors that fall within the selected " +
                  "range with black, and any other pixels with white." +
                  Chr(10) + Chr(10) + "- MOUSE: Highlight / Select area." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Create image mask." +
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
  Shared selection.CvRect
  Shared origin.CvPoint

  If select_object > 0 And *param\uPointer2
    *select.IplImage
    cvReleaseImage(@*select)
    *select = cvCloneImage(*param\uPointer2)
    selection\x = origin\x
    selection\y = origin\y
    CV_MIN(selection\x, x)
    CV_MIN(selection\y, y)
    selection\width = selection\x + CV_IABS(x - origin\x)
    selection\height = selection\y + CV_IABS(y - origin\y)
    CV_MAX(selection\x, 0)
    CV_MAX(selection\y, 0)
    CV_MIN(selection\width, *select\width)
    CV_MIN(selection\height, *select\height)
    selection\width - selection\x
    selection\height - selection\y
  EndIf

  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      If *param\uPointer2
        origin\x = x
        origin\y = y
        selection\x = x
        selection\y = y
        selection\width = 0
        selection\height = 0
        select_object = 1
      EndIf
    Case #CV_EVENT_LBUTTONUP
      If *param\uPointer2
        count = ArraySize(selected())
        ReDim selected(count + 1)
        selected(count)\x = selection\x
        selected(count)\y = selection\y
        selected(count)\width = selection\width
        selected(count)\height = selection\height
        select_object = -1
        CvMouseCallback(#CV_EVENT_MOUSEMOVE, x, y, #Null, *param)
      EndIf
    Case #CV_EVENT_MOUSEMOVE
      Select select_object
        Case 0
          selection\x = 0
          selection\y = 0
          selection\width = 0
          selection\height = 0
        Case -1
          opacity.d = 0.4
          *select.IplImage = cvCloneImage(*param\uPointer2)
          cvRectangle(*select, selection\x, selection\y, selection\x + selection\width, selection\y + selection\height, 255, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
          cvRectangle(*param\uPointer2, selection\x, selection\y, selection\x + selection\width, selection\y + selection\height, 255, 0, 0, 0, #CV_FILLED, #CV_AA, #Null)
          cvAddWeighted(*select, opacity, *param\uPointer1, 1 - opacity, 0, *select)
          cvShowImage(#CV_WINDOW_NAME, *select)
          cvReleaseImage(@*select)
          select_object = 0
        Case 1
          opacity.d = 0.4

          If selection\x = 0 : selection\x = 2 : EndIf
          If selection\x + selection\width >= *select\width : selection\width - 3 : EndIf
          If selection\y = 0 : selection\y = 2 : EndIf
          If selection\y + selection\height >= *select\height : selection\height - 3 : EndIf

          cvSetImageROI(*select, selection\x, selection\y, selection\width, selection\height)
          cvXorS(*select, 255, 0, 255, 0, *select, #Null)
          cvResetImageROI(*select)
          cvAddWeighted(*select, opacity, *param\uPointer1, 1 - opacity, 0, *select)
          cvRectangle(*select, selection\x, selection\y, selection\x + selection\width, selection\y + selection\height, 0, 0, 255, 0, 1, #CV_AA, #Null)
          cvShowImage(#CV_WINDOW_NAME, *select)
          cvReleaseImage(@*select)
      EndSelect
  EndSelect
EndProcedure

Structure BGR_RANGE
  lB.l
  lG.l
  lR.l
  hB.l
  hG.l
  hR.l
EndStructure

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

    If *resize\width > 200 And *resize\height > 200 And *resize\nChannels = 3
      BringToTop(hWnd)
      *select.IplImage = cvCloneImage(*resize)
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *resize
      *param\uPointer2 = *select
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)
      cvShowImage(#CV_WINDOW_NAME, *select)

      Repeat
        keyPressed = cvWaitKey(0)
      Until keyPressed = 13 Or keyPressed = 27 Or (keyPressed = 32 And ArraySize(selected()) > 0) Or exitCV
      *param\uPointer2 = #Null

      If keyPressed = 32
        Dim value.BGR_RANGE(ArraySize(selected()))

        For rtnCount = 0 To ArraySize(selected()) - 1
          value(rtnCount)\lB = 255
          value(rtnCount)\lG = 255
          value(rtnCount)\lR = 255
          value(rtnCount)\hB = 0
          value(rtnCount)\hG = 0
          value(rtnCount)\hR = 0

          For y = selected(rtnCount)\y To selected(rtnCount)\y + selected(rtnCount)\height - 1
            For x = selected(rtnCount)\x To selected(rtnCount)\x + selected(rtnCount)\width - 1
              B = PeekA(@*resize\imageData\b + (y * *resize\widthStep) + x * 3 + 0)
              G = PeekA(@*resize\imageData\b + (y * *resize\widthStep) + x * 3 + 1)
              R = PeekA(@*resize\imageData\b + (y * *resize\widthStep) + x * 3 + 2)

              If B < value(rtnCount)\lB : value(rtnCount)\lB = B : EndIf
              If G < value(rtnCount)\lG : value(rtnCount)\lG = G : EndIf
              If R < value(rtnCount)\lR : value(rtnCount)\lR = R : EndIf
              If B > value(rtnCount)\hB : value(rtnCount)\hB = B : EndIf
              If G > value(rtnCount)\hG : value(rtnCount)\hG = G : EndIf
              If R > value(rtnCount)\hR : value(rtnCount)\hR = R : EndIf

            Next
          Next
        Next

        Dim *mask.IplImage(ArraySize(selected()))

        For rtnCount = 0 To ArraySize(selected()) - 1
          *mask(rtnCount) = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)
          cvInRangeS(*resize, value(rtnCount)\lB, value(rtnCount)\lG, value(rtnCount)\lR, 0, value(rtnCount)\hB, value(rtnCount)\hG, value(rtnCount)\hR, 0, *mask(rtnCount))
          cvNot(*mask(rtnCount), *mask(rtnCount))  
        Next
        *final.IplImage = cvCloneImage(*mask(0))

        For rtnCount = 1 To ArraySize(selected()) - 1
          For y = 0 To *mask(rtnCount)\height - 1
            For x = 0 To *mask(rtnCount)\width - 1
              If PeekA(@*mask(rtnCount)\imageData\b + (y * *mask(rtnCount)\widthStep) + x) = 0 : PokeA(@*final\imageData\b + (y * *final\widthStep) + x, 0) : EndIf
            Next
          Next 
        Next
        *param\uPointer1 = *final

        Repeat
          If *final
            cvShowImage(#CV_WINDOW_NAME, *final)
            keyPressed = cvWaitKey(0)
          EndIf
        Until keyPressed = 13 Or keyPressed = 27 Or exitCV
        cvReleaseImage(@*final)

        For rtnCount = ArraySize(selected()) - 1 To 0 Step -1
          cvReleaseImage(@*mask(rtnCount))
        Next
      EndIf
      FreeMemory(*param)
      cvReleaseImage(@*select)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If keyPressed = 13
        exitCV = #False
        Dim selected.CvRect(0)
        OpenCV(ImageFile)
      ElseIf getCV
        getCV = #False
        exitCV = #False
        Dim selected.CvRect(0)
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
; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
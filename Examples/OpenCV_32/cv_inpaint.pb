IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nInpaint, nSize

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Restores the selected region in an image using the region neighborhood." + Chr(10) + Chr(10) +
                  "- MOUSE: Mark the repair area." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Apply the repair." + Chr(10) + Chr(10) +
                  "- ENTER: Reset the image." + Chr(10) + Chr(10) +
                  "- [ < / > ] KEYS: Adjust inpaint size." + Chr(10) + Chr(10) +
                  "- [ I ] KEY: Toggle inpainting method." + Chr(10) + Chr(10) +
                  "-- BLUE: Navier-Stokes" + Chr(10) +
                  "-- GREEN: [Telea04]" + Chr(10) +
                  "-- RED: Navier-Stokes && [Telea04]"

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
  Static pt1.CvPoint

  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDOWN
      pt1\x = x
      pt1\y = y
    Case #CV_EVENT_LBUTTONUP
      If Not Bool(flags And #CV_EVENT_FLAG_LBUTTON)
        pt1\x = -1
        pt1\y = -1
      EndIf
    Case #CV_EVENT_MOUSEMOVE
      If Bool(flags And #CV_EVENT_FLAG_LBUTTON)
        pt2.CvPoint
        pt2\x = x
        pt2\y = y

        If pt1\x > 0 And pt2\x < 60000 And pt2\y < 60000
          Select nInpaint
            Case 0
              cvLine(*param\uPointer1, pt1\x, pt1\y, pt2\x, pt2\y, 255, 0, 0, 0 , nSize, #CV_AA, #Null)
            Case 1
              cvLine(*param\uPointer1, pt1\x, pt1\y, pt2\x, pt2\y, 0, 255, 0, 0 , nSize, #CV_AA, #Null)
            Case 2
              cvLine(*param\uPointer1, pt1\x, pt1\y, pt2\x, pt2\y, 0, 0, 255, 0 , nSize, #CV_AA, #Null)
          EndSelect
          cvLine(*param\uPointer2, pt1\x, pt1\y, pt2\x, pt2\y, 255, 0, 0, 0 , nSize, #CV_AA, #Null)
          cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
          pt1 = pt2
        EndIf
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
    offset = 40 : B = 255 : G = 0 : R = 0 : size = 1 : nSize = 4
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_DUPLEX, 1, 1, #Null, 1, #CV_AA)
    cvCircle(*resize, 25, 25, 20, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
    cvPutText(*resize, "1", 15, 35, @font, 0, 0, 0, 0)
    *temp.IplImage = cvCloneImage(*resize)
    *mask.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 1)
    cvSetZero(*mask)
    *inpaint.IplImage = cvCloneImage(*resize)
    keybd_event_(#VK_RETURN, 0, 0, 0)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uPointer1 = *temp
    *param\uPointer2 = *mask
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)

    Repeat
      If *resize
        Select keyPressed
          Case 13
            cvCircle(*resize, 25, 25, 20, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
            cvPutText(*resize, Str(size), 15, 35, @font, 0, 0, 0, 0)
            cvSetZero(*mask)
            cvCopy(*resize, *temp, #Null)
            cvCopy(*resize, *inpaint, #Null)
            cvShowImage(#CV_WINDOW_NAME, *resize)
          Case 32
            If nInpaint > 1
              cvInpaint(*inpaint, *mask, *inpaint, 0, #CV_INPAINT_NS)
              cvInpaint(*inpaint, *mask, *inpaint, 0, #CV_INPAINT_TELEA)
            Else
              cvInpaint(*inpaint, *mask, *inpaint, 0, inpaint)
            EndIf
            cvCircle(*inpaint, 25, 25, 20, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
            cvPutText(*inpaint, Str(size), 15, 35, @font, 0, 0, 0, 0)
            cvSetZero(*mask)
            cvCopy(*inpaint, *temp, #Null)
            cvShowImage(#CV_WINDOW_NAME, *inpaint)
          Case 44, 60
            If size > 2 : size - 1 : nSize = size * 10 : Else : size = 1 : nSize = 4 : EndIf

            cvCircle(*temp, 25, 25, 20, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
            cvPutText(*temp, Str(size), 15, 35, @font, 0, 0, 0, 0)
            cvShowImage(#CV_WINDOW_NAME, *temp)
          Case 46, 62
            If size < 5 : size + 1 : nSize = size * 10 : EndIf

            cvCircle(*temp, 25, 25, 20, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
            cvPutText(*temp, Str(size), 15, 35, @font, 0, 0, 0, 0)
            cvShowImage(#CV_WINDOW_NAME, *temp)
          Case 73, 105
            nInpaint = (nInpaint + 1) % 3
            cvSetZero(*mask)

            Select nInpaint
              Case 0
                B = 255
                G = 0
                R = 0
              Case 1
                B = 0
                G = 255
                R = 0
              Case 2
                B = 0
                G = 0
                R = 255
            EndSelect
            cvCircle(*inpaint, 25, 25, 20, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
            cvPutText(*inpaint, Str(size), 15, 35, @font, 0, 0, 0, 0)
            cvCopy(*inpaint, *temp, #Null)
            cvShowImage(#CV_WINDOW_NAME, *inpaint)
        EndSelect
        keyPressed = cvWaitKey(0)
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseImage(@*inpaint)
    cvReleaseImage(@*mask)
    cvReleaseImage(@*temp)
    cvReleaseImage(@*resize)
    cvReleaseImage(@*image)
    cvDestroyAllWindows()

    If getCV
      nInpaint = 0
      getCV = #False
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/seams1.jpg")
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
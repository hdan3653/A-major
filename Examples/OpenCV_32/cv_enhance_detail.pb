IncludeFile "includes/cv_functions.pbi"

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nEnhance

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Enhance the details of an image." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Start the enhancement." + Chr(10) + Chr(10) +
                  "- ENTER: Switch to next image."

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

ProcedureC DiffX(*image.IplImage, *temp.IplImage)
  w = *image\width
  h = *image\height

  For i = 0 To h - 1
    For j = 0 To w - 2
      PokeF(@CV_IMAGE_ELEM(*temp, i, j * 4), PeekF(@CV_IMAGE_ELEM(*image, i, (j + 1) * 4)) - PeekF(@CV_IMAGE_ELEM(*image, i, j * 4)))
    Next
  Next
EndProcedure

ProcedureC DiffY(*image.IplImage, *temp.IplImage)
  w = *image\width
  h = *image\height

  For i = 0 To h - 2
    For j = 0 To w - 1
      PokeF(@CV_IMAGE_ELEM(*temp, i, j * 4), PeekF(@CV_IMAGE_ELEM(*image, (i + 1), j * 4)) - PeekF(@CV_IMAGE_ELEM(*image, i, j * 4)))
    Next
  Next
EndProcedure

ProcedureC EnhanceFilter(*enhance.CvMat, *horiz.CvMat, sigma_h.f)
  h = *enhance\rows
  w = *enhance\cols
  a.f = Exp(-Sqr(2) / sigma_h)
  *temp.CvMat = cvCreateMat(h, w, CV_MAKETYPE(#CV_32F, 3))

	For i = 0 To h - 1
	  For j = 0 To w - 1
      cvSet2D(*temp, i, j, cvmGet(*enhance, i, j), cvmGet(*enhance, i, j + 1), cvmGet(*enhance, i, j + 2), 0)
	  Next
	Next
	*V.CvMat = cvCreateMat(h, w, CV_MAKETYPE(#CV_32F, 1))

	For i = 0 To h - 1
	  For j = 0 To w - 1
	    cvmSet(*V, i, j, Pow(a, cvmGet(*horiz, i, j)))
	  Next
	Next
	scalar1.CvScalar
	scalar2.CvScalar

	For i = 0 To h - 1
	  For j = 1 To w - 1
	    cvGet2D(@scalar1, *temp, i, j)
	    cvGet2D(@scalar2, *temp, i, j - 1)
	    V.f = cvmGet(*V, i, j)
	    val0.f = scalar1\val[0] + (scalar2\val[0] - scalar1\val[0]) * V
	    val1.f = scalar1\val[1] + (scalar2\val[1] - scalar1\val[1]) * V
	    val2.f = scalar1\val[2] + (scalar2\val[2] - scalar1\val[2]) * V
	    cvSet2D(*temp, i, j, val0, val1, val2, 0)
	  Next
	Next

	For i = 0 To h - 1
	  For j = w - 2 To 0 Step - 1
	    cvGet2D(@scalar1, *temp, i, j)
	    cvGet2D(@scalar2, *temp, i, j + 1)
	    V.f = cvmGet(*V, i, j + 1)
	    val0.f = scalar1\val[0] + (scalar2\val[0] - scalar1\val[0]) * V
	    val1.f = scalar1\val[1] + (scalar2\val[1] - scalar1\val[1]) * V
	    val2.f = scalar1\val[2] + (scalar2\val[2] - scalar1\val[2]) * V
	    cvSet2D(*temp, i, j, val0, val1, val2, 0)
	  Next
	Next

	For i = 0 To h - 1
	  For j = 0 To w - 1
	    cvGet2D(@scalar1, *temp, i, j)
	    cvmSet(*enhance, i, j + 0, scalar1\val[0])
	    cvmSet(*enhance, i, j + 1, scalar1\val[1])
	    cvmSet(*enhance, i, j + 2, scalar1\val[2])
	  Next
	Next
	cvReleaseMat(@*V)
	cvReleaseMat(@*temp)
EndProcedure

ProcedureC EnhanceDetail(*image.IplImage, sigma_s.f, sigma_r.f)
  w = *image\width
  h = *image\height
	*derivx.IplImage = cvCreateImage(w - 1, h, #IPL_DEPTH_32F, 1)
	*derivy.IplImage = cvCreateImage(w, h - 1, #IPL_DEPTH_32F, 1)
	*distx.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 1)
	*disty.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 1)
	cvSetZero(*derivx)
	cvSetZero(*derivy)
	cvSetZero(*distx)
	cvSetZero(*disty)
	DiffX(*image, *derivx)
	DiffY(*image, *derivy)

	For i = 0 To h - 1
	  k = 1

	  For j = 0 To w - 2
	    PokeF(@CV_IMAGE_ELEM(*distx, i, k * 4), PeekF(@CV_IMAGE_ELEM(*distx, i, k * 4)) + Abs(PeekF(@CV_IMAGE_ELEM(*derivx, i, j * 4))))
	    k + 1
	  Next
	Next
	k = 1

	For i = 0 To h - 2
	  For j = 0 To w - 1
	    PokeF(@CV_IMAGE_ELEM(*disty, k, j * 4), PeekF(@CV_IMAGE_ELEM(*disty, k, j * 4)) + Abs(PeekF(@CV_IMAGE_ELEM(*derivy, i, j * 4))))
	  Next
	  k + 1
	Next
	*horiz.CvMat = cvCreateMat(h, w, CV_MAKETYPE(#CV_32F, 1))
  *vert.CvMat = cvCreateMat(h, w, CV_MAKETYPE(#CV_32F, 1))

  For i = 0 To h - 1
    For j = 0 To w - 1
      cvmSet(*horiz, i, j, 1 + (sigma_s / sigma_r) * PeekF(@CV_IMAGE_ELEM(*distx, i, j * 4)))
      cvmSet(*vert, i, j, 1 + (sigma_s / sigma_r) * PeekF(@CV_IMAGE_ELEM(*disty, i, j * 4)))
    Next
  Next
  *vert_t.CvMat = cvCreateMat(w, h, CV_MAKETYPE(#CV_32F, 1))
  cvTranspose(*vert, *vert_t)
  *enhance.CvMat = cvCreateMat(h ,w, CV_MAKETYPE(#CV_32F, 1))
	*enhance_t.CvMat = cvCreateMat(w, h, CV_MAKETYPE(#CV_32F, 1))

  For i = 0 To h - 1
    For j = 0 To w - 1
      cvmSet(*enhance, i, j, PeekF(@CV_IMAGE_ELEM(*image, i, j * 4)))
    Next
  Next
  sigma_h.f = sigma_s * Sqr(3) / Sqr(Pow(4, 1) - 1)
  EnhanceFilter(*enhance, *horiz, sigma_h)
  cvTranspose(*enhance, *enhance_t)
  EnhanceFilter(*enhance_t, *vert_t, sigma_h)
  cvTranspose(*enhance_t, *enhance)
  cvReleaseMat(@*enhance_t)
  cvReleaseMat(@*vert_t)
  cvReleaseMat(@*vert)
  cvReleaseMat(@*horiz)
  cvReleaseImage(@*disty)
  cvReleaseImage(@*distx)
  cvReleaseImage(@*derivy)
  cvReleaseImage(@*derivx)
  ProcedureReturn *enhance
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

    If *resize\nChannels = 3
      BringToTop(hWnd)
      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
      *param\uPointer1 = *resize
      *param\uValue = window_handle
      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

      Repeat
        cvShowImage(#CV_WINDOW_NAME, *resize)
        keyPressed = cvWaitKey(0)
      Until keyPressed = 13 Or keyPressed = 27 Or keyPressed = 32 Or exitCV

      If keyPressed = 32
        w = *resize\width
        h = *resize\height
    	  channel = *resize\nChannels
        *resize32.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 3)
        cvConvertScale(*resize, *resize32, 1 / 255, 0)
        font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_COMPLEX | #CV_FONT_ITALIC, 1, 1, #Null, 1, #CV_AA)
        cvPutText(*resize, "Working...", 20, 40, @font, 0, 0, 255, 0)
        cvShowImage(#CV_WINDOW_NAME, *resize)
        cvWaitKey(100)
    		sigma_s.f = 10
    		sigma_r.f = 0.15
    		factor.f = 3
    		*lab.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 3)
    		cvCvtColor(*resize32, *lab, #CV_BGR2Lab, 1)
    		*L_channel.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 1)
    		*A_channel.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 1)
    		*B_channel.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 1)
    		cvSplit(*lab, *L_channel, *A_channel, *B_channel, #Null)
    		*L.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 1)
    		cvConvertScale(*L_channel, *L, 1 / 255, 0)
    		*enhance.CvMat = EnhanceDetail(*L, sigma_s, sigma_r)
    		*detail.CvMat = cvCreateMat(h, w, CV_MAKETYPE(#CV_32F, 1))

    		For i = 0 To h - 1
    		  For j = 0 To w - 1
    		    cvmSet(*detail, i, j, PeekF(@CV_IMAGE_ELEM(*L, i, j * 4)) - cvmGet(*enhance, i, j))
    		  Next
    		Next

    		For i = 0 To h - 1
    		  For j = 0 To w - 1
    		    PokeF(@CV_IMAGE_ELEM(*L, i, j * 4), cvmGet(*enhance, i, j) + factor * cvmGet(*detail, i, j))
    		  Next
    		Next
    		cvConvertScale(*L, *L_channel, 255, 0)

    		For i = 0 To h - 1
    		  For j = 0 To w - 1
      		  PokeF(@CV_IMAGE_ELEM(*lab, i, (j * channel + 0) * 4), PeekF(@CV_IMAGE_ELEM(*L_channel, i, j * 4)))
            PokeF(@CV_IMAGE_ELEM(*lab, i, (j * channel + 1) * 4), PeekF(@CV_IMAGE_ELEM(*A_channel, i, j * 4)))
            PokeF(@CV_IMAGE_ELEM(*lab, i, (j * channel + 2) * 4), PeekF(@CV_IMAGE_ELEM(*B_channel, i, j * 4)))
    		  Next
    		Next
    		*result.IplImage = cvCreateImage(w, h, #IPL_DEPTH_32F, 3)
    		cvCvtColor(*lab, *result, #CV_Lab2BGR, 1)
    		*final.IplImage = cvCreateImage(w, h, #IPL_DEPTH_8U, 3)
    		cvConvertScale(*result, *final, 255, 0)
        *param\uPointer1 = *final

        Repeat
          If *final
            cvShowImage(#CV_WINDOW_NAME, *final)
            keyPressed = cvWaitKey(0)
          EndIf
        Until keyPressed = 13 Or keyPressed = 27 Or exitCV
        FreeMemory(*param)
        cvReleaseImage(@*final)
        cvReleaseImage(@*result)
        cvReleaseMat(@*detail)
        cvReleaseMat(@*enhance)
        cvReleaseImage(@*L)
        cvReleaseImage(@*B_channel)
        cvReleaseImage(@*A_channel)
        cvReleaseImage(@*L_channel)
        cvReleaseImage(@*lab)
        cvReleaseImage(@*resize32)
      EndIf
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()

      If keyPressed = 13
        exitCV = #False
        nEnhance = (nEnhance + 1) % 2
        OpenCV("images/enhance" + Str(nEnhance + 1) + ".jpg")
      ElseIf getCV
        getCV = #False
        exitCV = #False
        OpenCV(GetImage())
      EndIf
    Else
      MessageBox_(0, ImageFile + Chr(10) + Chr(10) + "... does not meet the channel requirements, please try a color image.", #CV_WINDOW_NAME, #MB_ICONERROR)
      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      exitCV = #False
      OpenCV(GetImage())
    EndIf
  EndIf
EndProcedure

ExamineDesktops()
OpenCV("images/enhance1.jpg")
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
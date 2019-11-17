IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc, *image.IplImage, nFont.CvFont, nActivate

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Fractal Art: Created by calculating fractal objects represented as images." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Predefined settings."

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

Global nMax = 255, rMax.d = 20, crValue, ciValue

ProcedureC GetNumber(i, j)
  cRealPart.d = (crValue - 50) / 100 * 2 * 2
  cImaginaryPart.d = (ciValue - 50) / 100 * 2 * 2
  RealPart.d = i / *image\width
  ImaginaryPart.d = j / *image\height

  While n < nMax
    ZM.d = RealPart * RealPart + ImaginaryPart * ImaginaryPart

    If ZM > rMax : Break : EndIf

    tRealPart.d = RealPart * RealPart - ImaginaryPart * ImaginaryPart + cRealPart
    tImaginaryPart.d = 2 * ImaginaryPart * RealPart + cImaginaryPart
    RealPart = tRealPart
		ImaginaryPart = tImaginaryPart
		n + 1
	Wend
	ProcedureReturn n
EndProcedure

ProcedureC CvTrackbarCallback(pos)
  If nActivate
    cvPutText(*image, "Working...", 22, 42, @nFont, 0, 0, 0, 0)
    cvPutText(*image, "Working...", 20, 40, @nFont, 255, 255, 255, 0)
    cvShowImage(#CV_WINDOW_NAME, *image)
    cvWaitKey(1)
    cvSetZero(*image)
    scalar1.CvScalar
    scalar2.CvScalar

    For i = 0 To *image\height - 1
      For j = 0 To *image\width - 1
        n1 = GetNumber(i, j)
  			n2 = GetNumber(j, i)
  			n3 = GetNumber(j, i / 2)

  			If n1 > nMax - 2 : n1 = 0 : EndIf
  			If n2 > nMax - 2 : n2 = 0 : EndIf
  			If n3 > nMax - 2 : n3 = 0 : EndIf

  			scalar1\val[0] = Abs(255 * n1 / nMax)
  			scalar1\val[1] = Abs(255 * n2 / nMax)
  			scalar1\val[2] = Abs(255 * n3 / nMax)
  			cvSet2D(*image, i, j, scalar1\val[0], scalar1\val[1], scalar1\val[2], 0)
      Next
    Next
    nValue.d = cvNorm(*image, 0, #CV_C, #Null)

    For i = 0 To *image\height - 1
      For j = 0 To *image\width - 1
        cvGet2D(@scalar2, *image, i, j)
        scalar1\val[0] = Abs(255 * scalar2\val[0] / nValue)
  			scalar1\val[1] = Abs(255 * scalar2\val[1] / nValue)
  			scalar1\val[2] = Abs(255 * scalar2\val[2] / nValue)
  			cvSet2D(*image, i, j, scalar1\val[0], scalar1\val[1], scalar1\val[2], 0)
      Next
    Next
    cvShowImage(#CV_WINDOW_NAME, *image)
  EndIf
EndProcedure

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
*image = cvCreateImage(700, 500, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
cvCreateTrackbar("Real", #CV_WINDOW_NAME, @crValue, 100, @CvTrackbarCallback())
cvCreateTrackbar("Imaginary", #CV_WINDOW_NAME, @ciValue, 100, @CvTrackbarCallback())
cvInitFont(@nFont, #CV_FONT_HERSHEY_SIMPLEX, 1, 1, #Null, 1, #CV_AA)
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)

Repeat
  If *image
    Select fractal
      Case 0
        crValue = 30 : ciValue = 45
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 1
        crValue = 38 : ciValue = 35
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 2
        crValue = 38 : ciValue = 36
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 3
        crValue = 40 : ciValue = 24
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 4
        crValue = 46 : ciValue = 29
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 5
        crValue = 48 : ciValue = 34
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 6
        crValue = 50 : ciValue = 30
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 7
        crValue = 53 : ciValue = 63
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 8
        crValue = 59 : ciValue = 51
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
      Case 9
        crValue = 59 : ciValue = 52
        nActivate = #False
        cvSetTrackbarPos("Real", #CV_WINDOW_NAME, crValue)
        cvSetTrackbarPos("Imaginary", #CV_WINDOW_NAME, ciValue)
        nActivate = #True
        CvTrackbarCallback(0)
    EndSelect
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(0)

    If keyPressed = 32 : fractal = (fractal + 1) % 10 : EndIf

  EndIf
Until keyPressed = 27 Or exitCV
FreeMemory(*param)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
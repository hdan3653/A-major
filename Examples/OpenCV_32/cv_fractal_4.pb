IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Generates a Julia Set, a popular geometrical fractal." + Chr(10) + Chr(10) + "- SPACEBAR: Flip RGB / BGR."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          FileName.s = SaveFile(1)

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
*image.IplImage = cvCreateImage(800, 400, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
cvSetZero(*image)
xStart.d = -2
yStart.d = -1
xScale.d = 4
yScale.d = 2
x.d = -0.4
y.d = 0.6
bOut.d = 4
xIncrement.d = xScale / *image\width
yIncrement.d = yScale / *image\height
iMax = 1000
*julia.IplImage = cvCreateImage(*image\width, *image\height, #IPL_DEPTH_8U, 3)
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *julia
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)
y1.d = yStart

For nLine = 0 To *image\height - 1
  x1.d = xStart

  For nPixel = 0 To *image\width - 1
    xScale = x1
    yScale = y1
    i = 0

    While xScale * xScale + yScale * yScale <= bOut And i < iMax
      temp.d = (xScale * xScale) - (yScale * yScale) + x
      yScale = (2 * xScale * yScale) + y
      xScale = temp
      i + 1
    Wend

    If i >= iMax
      PokeA(@*image\imageData\b + *image\widthStep * (*image\height - 1 - nLine) + nPixel * 3 + 0, 0)
      PokeA(@*image\imageData\b + *image\widthStep * (*image\height - 1 - nLine) + nPixel * 3 + 1, 0)
      PokeA(@*image\imageData\b + *image\widthStep * (*image\height - 1 - nLine) + nPixel * 3 + 2, 0)
    Else
      PokeA(@*image\imageData\b + *image\widthStep * (*image\height - 1 - nLine) + nPixel * 3 + 0, i % 255)
      PokeA(@*image\imageData\b + *image\widthStep * (*image\height - 1 - nLine) + nPixel * 3 + 1, 255)
      PokeA(@*image\imageData\b + *image\widthStep * (*image\height - 1 - nLine) + nPixel * 3 + 2, 255)
    EndIf
    x1 + xIncrement
  Next

  If fractal : cvCvtColor(*image, *julia, #CV_HSV2BGR, 1) : Else : cvCvtColor(*image, *julia, #CV_HSV2RGB, 1) : EndIf

  cvShowImage(#CV_WINDOW_NAME, *julia)
  keyPressed = cvWaitKey(1)

  If keyPressed = 27 Or exitCV : Break : ElseIf keyPressed = 32 : fractal ! 1 : EndIf

  y1 + yIncrement
Next

If keyPressed <> 27 And exitCV = #False
  Repeat
    If *julia
      cvShowImage(#CV_WINDOW_NAME, *julia)
      keyPressed = cvWaitKey(0)

      If keypressed = 32
        fractal ! 1

        If fractal : cvCvtColor(*image, *julia, #CV_HSV2BGR, 1) : Else : cvCvtColor(*image, *julia, #CV_HSV2RGB, 1) : EndIf

      EndIf
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
EndIf
cvReleaseImage(@*julia)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
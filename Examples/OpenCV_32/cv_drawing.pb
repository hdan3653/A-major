IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "A demonstration of OpenCV's drawing and text output functions."

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

ProcedureC RandomColor(rng.q)
  *scalar.CvScalar = AllocateMemory(SizeOf(CvScalar))
  iColor = UnsignedLong(cvRandInt(rng))
  R = iColor & 255
  G = iColor >> 8 & 255
  B = iColor >> 16 & 255
  *scalar\val[0] = R
  *scalar\val[1] = G
  *scalar\val[2] = B
  ProcedureReturn *scalar
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
*image.IplImage = cvCreateImage(1000, 650, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)
nCount = 100
rng = cvRNG(Random(2147483647))
width = *image\width * 3
height = *image\height * 3
*scalar.CvScalar

For rtnCount = 0 To nCount - 1
  pt1x = UnsignedLong(cvRandInt(rng)) % width - *image\width
  pt1y = UnsignedLong(cvRandInt(rng)) % height - *image\height
  pt2x = UnsignedLong(cvRandInt(rng)) % width - *image\width
  pt2y = UnsignedLong(cvRandInt(rng)) % height - *image\height
  *scalar = RandomColor(rng)
  thickness = UnsignedLong(cvRandInt(rng)) % 10
  cvLine(*image, pt1x, pt1y, pt2x, pt2y, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, thickness, #CV_AA, #Null)
  cvShowImage(#CV_WINDOW_NAME, *image)
  keyPressed = cvWaitKey(5)

  If keyPressed = 27 Or exitCV : Break : EndIf

Next

If keyPressed <> 27 And exitCV = #False
  For rtnCount = 0 To nCount - 1
    pt1x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pt1y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pt2x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pt2y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    *scalar = RandomColor(rng)
    thickness = UnsignedLong(cvRandInt(rng)) % 10 - 1
    cvRectangle(*image, pt1x, pt1y, pt2x, pt2y, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, thickness, #CV_AA, #Null)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(5)

    If keyPressed = 27 Or exitCV : Break : EndIf

  Next
EndIf

If keyPressed <> 27 And exitCV = #False
  For rtnCount = 0 To nCount - 1
    pt1x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pt1y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    szWidth = UnsignedLong(cvRandInt(rng)) % 200
    szHeight = UnsignedLong(cvRandInt(rng)) % 200
    angle = (UnsignedLong(cvRandInt(rng)) % 1000) * 0.180
    *scalar = RandomColor(rng)
    thickness = UnsignedLong(cvRandInt(rng)) % 10 - 1
    cvEllipse(*image, pt1x, pt1y, szWidth, szHeight, angle, angle - 100, angle + 200, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, thickness, #CV_AA, #Null)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(5)

    If keyPressed = 27 Or exitCV : Break : EndIf

  Next
EndIf

If keyPressed <> 27 And exitCV = #False
  Dim pts1.CvPoint(4)
  Dim pts2.CvPoint(4)
  npts1 = ArraySize(pts1())
  npts2 = ArraySize(pts2())

  For rtnCount = 0 To nCount - 1
    pts1(0)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts1(0)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts1(1)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts1(1)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts1(2)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts1(2)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts1(3)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts1(3)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts2(0)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts2(0)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts2(1)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts2(1)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts2(2)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts2(2)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts2(3)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts2(3)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    *scalar = RandomColor(rng)
    thickness = UnsignedLong(cvRandInt(rng)) % 10
    cvPolyLine(*image, pts1(), @npts1, 1, #True, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, thickness, #CV_AA, #Null)
    cvPolyLine(*image, pts2(), @npts2, 1, #True, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, thickness, #CV_AA, #Null)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(5)

    If keyPressed = 27 Or exitCV : Break : EndIf

  Next
EndIf

If keyPressed <> 27 And exitCV = #False
  Dim pts1.CvPoint(3)
  Dim pts2.CvPoint(3)
  npts1 = ArraySize(pts1())
  npts2 = ArraySize(pts2())

  For rtnCount = 0 To nCount - 1
    pts1(0)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts1(0)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts1(1)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts1(1)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts1(2)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts1(2)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts2(0)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts2(0)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts2(1)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts2(1)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    pts2(2)\x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pts2(2)\y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    *scalar = RandomColor(rng)
    cvFillPoly(*image, pts1(), @npts1, 1, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, #CV_AA, #Null)
    cvFillPoly(*image, pts2(), @npts2, 1, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, #CV_AA, #Null)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(5)

    If keyPressed = 27 Or exitCV : Break : EndIf

  Next
EndIf

If keyPressed <> 27 And exitCV = #False
  For rtnCount = 0 To nCount - 1
    pt1x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pt1y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    radius = UnsignedLong(cvRandInt(rng)) % 300
    *scalar = RandomColor(rng)
    thickness = UnsignedLong(cvRandInt(rng)) % 10 - 1
    cvCircle(*image, pt1x, pt1y, radius, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0, thickness, #CV_AA, #Null)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(5)

    If keyPressed = 27 Or exitCV : Break : EndIf

  Next
EndIf

If keyPressed <> 27 And exitCV = #False
  font.CvFont

  For rtnCount = 0 To nCount - 1
    pt1x = UnsignedLong(cvRandInt(rng)) % width - *image\width
    pt1y = UnsignedLong(cvRandInt(rng)) % height - *image\height
    font_face = UnsignedLong(cvRandInt(rng)) % 8
    temp = UnsignedLong(cvRandInt(rng)) % 100
    hscale.d = temp * 0.05 + 0.1
    temp = UnsignedLong(cvRandInt(rng)) % 100
    vscale.d = temp * 0.05 + 0.1
    temp = UnsignedLong(cvRandInt(rng)) % 10
    thickness = Round(temp, #PB_Round_Nearest)
    temp = UnsignedLong(cvRandInt(rng)) % 5
    shear.d = temp * 0.1
    cvInitFont(@font, font_face, hscale, vscale, shear, thickness, #CV_AA)
    *scalar = RandomColor(rng)
    cvPutText(*image, "OpenCV", pt1x, pt1y, @font, *scalar\val[0], *scalar\val[1], *scalar\val[2], 0)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(5)

    If keyPressed = 27 Or exitCV : Break : EndIf

  Next
EndIf

If keyPressed <> 27 And exitCV = #False
  cvInitFont(@font, #CV_FONT_HERSHEY_TRIPLEX, 3, 3, 0.0, 5, #CV_AA)
  text_size.CvSize
  cvGetTextSize("PureBasic!", @font, @text_size, @baseline)
  pt1x = (*image\width - text_size\width) / 2
  pt1y = (*image\height + text_size\height) / 2
  *clone.IplImage = cvCloneImage(*image)

  For rtnCount = 0 To 255 - 1
    cvSubS(*clone, rtnCount, rtnCount, rtnCount, rtnCount, *image, #Null)
    cvPutText(*image, "PureBasic!", pt1x, pt1y, @font, rtnCount, rtnCount, 255, 0)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(5)

    If keyPressed = 27 Or exitCV : Break : EndIf

  Next
  cvReleaseImage(@*clone)
EndIf

If keyPressed <> 27 And exitCV = #False
  Repeat
    If *image : keyPressed = cvWaitKey(0) : EndIf
  Until keyPressed = 27 Or exitCV
EndIf
FreeMemory(*param)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
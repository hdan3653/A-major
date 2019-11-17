IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Finds the convex hull of a point set." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Create a new point set."

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
*image.IplImage = cvCreateImage(500, 500, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
rng = cvRNG(Random(2147483647))
*points.CvPoint
*hull.LONG
*pointMat.CvMat
*hullMat.CvMat
pt1.CvPoint
pt2.CvPoint
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)

Repeat
  If *image
    count = UnsignedLong(cvRandInt(rng)) % 100 + 1

    If count < 6 : count = 6 : EndIf

    *points = AllocateMemory(count * SizeOf(CvPoint))
    *hull = AllocateMemory(count * SizeOf(LONG))
    *pointMat = cvMat(1, count, CV_MAKETYPE(#CV_32S, 2), *points)
    *hullMat = cvMat(1, count, CV_MAKETYPE(#CV_32S, 1), *hull)

    For i = 0 To count - 1
      pt1\x = Random(*image\width - 100, 100)
      pt1\y = Random(*image\height - 100, 100)
      PokeL(@*points\x + i * 8, pt1\x)
      PokeL(@*points\y + i * 8, pt1\y)
    Next
    cvConvexHull2(*pointMat, *hullMat, #CV_CLOCKWISE, #False)
    cvSetZero(*image)
    hullcount = *hullMat\cols
    pt1\x = PeekL(@*points\x + 8 * PeekL(@*hull\l + (hullcount - 1) * 4))
    pt1\y = PeekL(@*points\y + 8 * PeekL(@*hull\l + (hullcount - 1) * 4))

    For i = 0 To hullcount - 1
      pt2\x = PeekL(@*points\x + 8 * PeekL(@*hull\l + i * 4))
      pt2\y = PeekL(@*points\y + 8 * PeekL(@*hull\l + i * 4))
      cvLine(*image, pt1\x, pt1\y, pt2\x, pt2\y, 0, 255, 0, 0, 1, #CV_AA, #Null)
      pt1 = pt2
    Next

    For i = 0 To count - 1
      cvCircle(*image, PeekL(@*points\x + i * 8), PeekL(@*points\y + i * 8), 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
    Next
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(0)
    FreeMemory(*hull)
    FreeMemory(*points)
  EndIf
Until keyPressed = 27 Or exitCV
FreeMemory(*param)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
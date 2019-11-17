IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Random construction of delaunay triangulation." + Chr(10) + Chr(10) +
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
*image.IplImage = cvCreateImage(800, 600, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
rng = cvRNG(Random(2147483647))
*storage.CvMemStorage = cvCreateMemStorage(0)
*subdiv.CvSubdiv2D
Dim triangleDirections(2)
triangleDirections(0) = #CV_NEXT_AROUND_LEFT
triangleDirections(1) = #CV_NEXT_AROUND_RIGHT
*edge.CvQuadEdge2D
*pt.CvSubdiv2DPoint
Dim buf.CvPoint(3)
reader.CvSeqReader
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)

Repeat
  If *image
    cvSetZero(*image)
    count = UnsignedLong(cvRandInt(rng)) % 100

    If count < 6 : count = 6 : EndIf

    cvClearMemStorage(*storage)
    *subdiv = cvCreateSubdivDelaunay2D(0, 0, 800, 600, *storage)

    For i = 0 To count - 1
      x = Random(*image\width - 100, 100)
      y = Random(*image\height - 100, 100)

      If x > 10 And y > 10 : cvSubdivDelaunay2DInsert(*subdiv, x, y) : EndIf

    Next
    total = *subdiv\edges\total
    elem_size = *subdiv\edges\elem_size
    cvStartReadSeq(*subdiv\edges, @reader, 0)

    For tdi = 0 To 2 - 1
      triangleDirection = triangleDirections(tdi)

      For i = 0 To total - 1
        *edge = reader\ptr

        If CV_IS_SET_ELEM(*edge)
          edge = *edge
          shouldPaint = 1

          For j = 0 To 3 - 1
            *pt = cvSubdiv2DEdgeOrg(edge)

            If Not *pt : Break : EndIf

            buf(j)\x = Round(*pt\pt\x, #PB_Round_Nearest)
            buf(j)\y = Round(*pt\pt\y, #PB_Round_Nearest)
            edge = cvSubdiv2DGetEdge(edge, triangleDirection)

            If buf(j)\x < 0 Or buf(j)\x > *image\width : shouldPaint = 0 : EndIf
            If buf(j)\y < 0 Or buf(j)\y > *image\height : shouldPaint = 0 : EndIf
            If shouldPaint : cvCircle(*image, buf(j)\x, buf(j)\y, 3, 0, 0, 255, 0, 1, #CV_AA, #Null) : EndIf

          Next

          If shouldPaint
    				cvLine(*image, buf(0)\x, buf(0)\y, buf(1)\x, buf(1)\y, 0, 255, 0, 0, 1, #CV_AA, #Null)
    				cvLine(*image, buf(1)\x, buf(1)\y, buf(2)\x, buf(2)\y, 0, 255, 0, 0, 1, #CV_AA, #Null)
    				cvLine(*image, buf(2)\x, buf(2)\y, buf(0)\x, buf(0)\y, 0, 255, 0, 0, 1, #CV_AA, #Null)
    			EndIf
    		EndIf
    		CV_NEXT_SEQ_ELEM(elem_size, reader)
    	Next
    Next
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(0)
  EndIf
Until keyPressed = 27 Or exitCV
FreeMemory(*param)
cvReleaseMemStorage(@*storage)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
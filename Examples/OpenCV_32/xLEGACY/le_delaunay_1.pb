IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc, Dim pt.CvPoint(0)

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Manual construction of delaunay triangulation."+ Chr(10) + Chr(10) +
                  "- MOUSE: Add new points." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Rebuild triangulation." + Chr(10) + Chr(10) +
                  "- ENTER: Reset triangulation."

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
    Case #CV_EVENT_LBUTTONDOWN
      arrSize = ArraySize(pt()) + 1
      ReDim pt.CvPoint(arrSize)
      pt(arrSize - 1)\x = x
      pt(arrSize - 1)\y = y
      cvCircle(*param\uPointer1, x, y, 3, 0, 0, 255, 0, #CV_FILLED, #CV_AA, #Null)
      cvShowImage(#CV_WINDOW_NAME, *param\uPointer1)
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
*image.IplImage = cvCreateImage(600, 400, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
keybd_event_(#VK_RETURN, 0, 0, 0)
*storage.CvMemStorage = cvCreateMemStorage(0)
*subdiv.CvSubdiv2D
reader.CvSeqReader
Dim triangleDirections(2)
triangleDirections(0) = #CV_NEXT_AROUND_LEFT
triangleDirections(1) = #CV_NEXT_AROUND_RIGHT
*edge.CvQuadEdge2D
*pt.CvSubdiv2DPoint
Dim buf.CvPoint(3)
keybd_event_(#VK_SPACE, 0, 0, 0)
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)

Repeat
  If *image
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(0)

    Select keyPressed
      Case 13
        Dim pt.CvPoint(15)
        pt(0)\x = 200 : pt(0)\y = 300 : pt(1)\x = 300 : pt(1)\y = 320 : pt(2)\x = 330 : pt(2)\y = 310
        pt(3)\x = 300 : pt(3)\y = 200 : pt(4)\x = 230 : pt(4)\y = 300 : pt(5)\x = 250 : pt(5)\y = 310
        pt(6)\x = 300 : pt(6)\y = 330 : pt(7)\x = 340 : pt(7)\y = 315 : pt(8)\x = 305 : pt(8)\y = 309
        pt(9)\x = 240 : pt(9)\y = 315 : pt(10)\x = 260 : pt(10)\y = 310 : pt(11)\x = 300 : pt(11)\y = 340
        pt(12)\x = 330 : pt(12)\y = 290 : pt(13)\x = 300 : pt(13)\y = 100 : pt(14)\x = 260 : pt(14)\y = 310
        keybd_event_(#VK_SPACE, 0, 0, 0)
      Case 32
        cvSetZero(*image)
        cvClearMemStorage(*storage)
        *subdiv = cvCreateSubdivDelaunay2D(0, 0, 600, 400, *storage)

        For i = 0 To ArraySize(pt()) - 1
          x.f = pt(i)\x
          y.f = pt(i)\y
          cvSubdivDelaunay2DInsert(*subdiv, x, y)
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
    EndSelect
  EndIf
Until keyPressed = 27 Or exitCV
FreeMemory(*param)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 Beta 1 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
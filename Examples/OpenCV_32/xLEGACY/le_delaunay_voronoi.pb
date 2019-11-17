IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Iterative construction of delaunay triangulation and voronoi tesselation." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Stop the process and draw a voronoi diagram." + Chr(10) + Chr(10) +
                  "- ENTER: Start a new construction."

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

ProcedureC InitDelaunay(*storage.CvMemStorage, x, y, width, height)
  *subdiv.CvSubdiv2D = cvCreateSubdiv2D(#CV_SEQ_KIND_SUBDIV2D, SizeOf(CvSubdiv2D), SizeOf(CvSubdiv2DPoint), SizeOf(CvQuadEdge2D), *storage)
  cvInitSubdivDelaunay2D(*subdiv, x, y, width, height)
  ProcedureReturn *subdiv
EndProcedure

ProcedureC DrawEdge(*image.IplImage, *edge, B, G, R, thickness)
  *org_pt.CvSubdiv2DPoint = cvSubdiv2DEdgeOrg(*edge)
  *dst_pt.CvSubdiv2DPoint = cvSubdiv2DEdgeDst(*edge)

  If *org_pt & *dst_pt
    org.CvPoint2D32f = *org_pt\pt
    dst.CvPoint2D32f = *dst_pt\pt
    x1 = Round(org\x, #PB_Round_Nearest)
    y1 = Round(org\y, #PB_Round_Nearest)
    x2 = Round(dst\x, #PB_Round_Nearest)
    y2 = Round(dst\y, #PB_Round_Nearest)
    cvLine(*image, x1, y1, x2, y2, B, G, R, 0, thickness, #CV_AA, #Null)
  EndIf
EndProcedure

ProcedureC DrawPoint(*image.IplImage, x.f, y.f, B, G, R)
  cvCircle(*image, Round(x, #PB_Round_Nearest), Round(y, #PB_Round_Nearest), 3, B, G, R, 0, #CV_FILLED, #CV_AA, #Null)
EndProcedure

ProcedureC DrawSubdiv(*image.IplImage, *subdiv.CvSubdiv2D, B1, G1, R1, B2, G2, R2)
  reader.CvSeqReader
  total = *subdiv\edges\total
  elem_size = *subdiv\edges\elem_size
  cvStartReadSeq(*subdiv\edges, @reader, 0)
  *edge.CvQuadEdge2D

  For rtnCount = 0 To total - 1
    *edge = reader\ptr

    If CV_IS_SET_ELEM(*edge)
      DrawEdge(*image, *edge + 1, B1, G1, R1, 2)
      DrawEdge(*image, *edge, B2, G2, R2, 1)
    EndIf
    CV_NEXT_SEQ_ELEM(elem_size, reader)
  Next
EndProcedure

ProcedureC LocatePoint(*subdiv.CvSubdiv2D, x.f, y.f, *image.IplImage, B, G, R)
  *vertex.CvSubdiv2DPoint
  cvSubdiv2DLocate(*subdiv, x, y, @edge, @*vertex)

  If edge
    edge_test = edge

    Repeat
      DrawEdge(*image, edge_test, B, G, R, 2)
      edge_test = cvSubdiv2DGetEdge(edge_test, #CV_NEXT_AROUND_LEFT)
    Until edge_test = edge
  EndIf
  DrawPoint(*image, x, y, B, G, R)
EndProcedure

ProcedureC DrawFacet(*image.IplImage, edge)
  edge_test = edge

  Repeat
    count + 1
    edge_test = cvSubdiv2DGetEdge(edge_test, #CV_NEXT_AROUND_LEFT)
  Until edge_test = edge

  *pt.CvSubdiv2DPoint
  Dim buf.CvPoint(count)

  For rtnCount = 0 To count - 1
    *pt = cvSubdiv2DEdgeOrg(edge_test)

    If Not *pt : Break : EndIf

    buf(rtnCount)\x = Round(*pt\pt\x, #PB_Round_Nearest)
    buf(rtnCount)\y = Round(*pt\pt\y, #PB_Round_Nearest)
    edge_test = cvSubdiv2DGetEdge(edge_test, #CV_NEXT_AROUND_LEFT)
  Next

  If rtnCount = count
    *pt = cvSubdiv2DEdgeDst(cvSubdiv2DRotateEdge(edge, 1))
    cvFillConvexPoly(*image, buf(), count, Random(255), Random(255), Random(255), 0, #CV_AA, #Null)
    cvPolyLine(*image, buf(), @count, 1, #True, 0, 0, 0, 0, 1, #CV_AA, #Null)
    DrawPoint(*image, *pt\pt\x, *pt\pt\y, 0, 0, 0)
  EndIf
EndProcedure

ProcedureC PaintVoronoi(*subdiv.CvSubdiv2D, *image.IplImage)
  reader.CvSeqReader
  total = *subdiv\edges\total
  elem_size = *subdiv\edges\elem_size
  cvCalcSubdivVoronoi2D(*subdiv)
  cvStartReadSeq(*subdiv\edges, @reader, 0)
  *edge.CvQuadEdge2D

  For rtnCount = 0 To total - 1
    *edge = reader\ptr

    If CV_IS_SET_ELEM(*edge)
      edge_test = *edge
      DrawFacet(*image, cvSubdiv2DRotateEdge(edge_test, 1))
      DrawFacet(*image, cvSubdiv2DRotateEdge(edge_test, 3))
    EndIf
    CV_NEXT_SEQ_ELEM(elem_size, reader)
  Next
EndProcedure

ProcedureC RunDelaunay(*image.IplImage)
  cvSet(*image, 255, 255, 255, 0, #False)
  *storage.CvMemStorage = cvCreateMemStorage(0)
  cvClearMemStorage(*storage)
  *subdiv.CvSubdiv2D = InitDelaunay(*storage, 0, 0, *image\width, *image\height)

  For rtnCount = 0 To 200 - 1
    x.f = ValF(Str(Random(32767) % (*image\width - 10) + 5))
    y.f = ValF(Str(Random(32767) % (*image\height - 10) + 5))
    LocatePoint(*subdiv, x, y, *image, 0, 0, 255)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(100)

    If keyPressed = 13
      RunDelaunay(*image)
      Break
    Else
      If keyPressed = 27 Or keyPressed = 32 Or exitCV : Break : EndIf
    EndIf
    cvSubdivDelaunay2DInsert(*subdiv, x, y)
    cvCalcSubdivVoronoi2D(*subdiv)
    cvSet(*image, 255, 255, 255, 0, #Null)
    DrawSubdiv(*image, *subdiv, 255, 0, 0, 0, 255, 0)
  Next

  If keyPressed <> 27 And Not exitCV
    cvSet(*image, 255, 255, 255, 0, #Null)
    PaintVoronoi(*subdiv, *image)

    Repeat
      If *image
        cvShowImage(#CV_WINDOW_NAME, *image)
        keyPressed = cvWaitKey(0)

        If keyPressed = 13 : RunDelaunay(*image) : EndIf

      EndIf
    Until keyPressed = 27 Or exitCV
  EndIf
  cvReleaseMemStorage(@*storage) : End
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
*image.IplImage = cvCreateImage(640, 480, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)
RunDelaunay(*image)
FreeMemory(*param)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = --
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
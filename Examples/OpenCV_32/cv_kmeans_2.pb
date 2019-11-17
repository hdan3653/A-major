IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Generates an image with random points grouped by a random number of cluster centers." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Generate new random points of grouped cluster centers."

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
#MAX_CLUSTERS = 5
rng = cvRNG(Random(2147483647))
chunk.CvMat
*pt1.CvPoint2D32f
*pt2.CvPoint2D32f
*pt_swap.CvPoint2D32f
Dim scalar.CvScalar(#MAX_CLUSTERS)
scalar(0)\val[0] = 255
scalar(0)\val[1] = 0
scalar(0)\val[2] = 0
scalar(1)\val[0] = 0
scalar(1)\val[1] = 255
scalar(1)\val[2] = 0
scalar(2)\val[0] = 100
scalar(2)\val[1] = 100
scalar(2)\val[2] = 255
scalar(3)\val[0] = 255
scalar(3)\val[1] = 0
scalar(3)\val[2] = 255
scalar(4)\val[0] = 255
scalar(4)\val[1] = 255
scalar(4)\val[2] = 0
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)

Repeat
  If *image
    If keyPressed = 0 Or keyPressed = 32
      cluster_count = UnsignedLong(cvRandInt(rng)) % #MAX_CLUSTERS + 1
      sample_count = UnsignedLong(cvRandInt(rng)) % 1000 + 1
      *points.CvMat = cvCreateMat(sample_count, 1, CV_MAKETYPE(#CV_32F, 2))
      *clusters.CvMat = cvCreateMat(sample_count, 1, CV_MAKETYPE(#CV_32S, 1))
      CV_MIN(cluster_count, sample_count)

      For rtnCount = 0 To cluster_count - 1
        cx = UnsignedLong(cvRandInt(rng)) % *image\width
        cy = UnsignedLong(cvRandInt(rng)) % *image\height

        If rtnCount = cluster_count - 1
          cvGetRows(*points, @chunk, rtnCount * sample_count / cluster_count, sample_count, 1)
        Else
          cvGetRows(*points, @chunk, rtnCount * sample_count / cluster_count, (rtnCount + 1) * sample_count / cluster_count, 1)
        EndIf
        cvRandArr(@rng, @chunk, #CV_RAND_NORMAL, cx, cy, 0, 0, *image\width * 0.1, *image\height * 0.1, 0, 0)
      Next

      For rtnCount = 0 To sample_count / 2 - 1
        temp = UnsignedLong(cvRandInt(rng)) % sample_count
        *pt1 = *points\fl + temp
        temp = UnsignedLong(cvRandInt(rng)) % sample_count
        *pt2 = *points\fl + temp
        CV_SWAP(*pt1, *pt2, *pt_swap)
      Next
      cvKMeans2(*points, cluster_count, *clusters, #CV_TERMCRIT_ITER | #CV_TERMCRIT_EPS, 10, 1.0, 5, 0, 0, 0, 0)
      cvSetZero(*image)

      For rtnCount = 0 To sample_count - 1
        cluster_idx = PeekL(@*clusters\i\l + rtnCount * *clusters\Step)
        x = PeekF(@*points\fl\f + rtnCount * *points\Step)
        y = PeekF(@*points\fl\f + rtnCount * *points\Step + 4)
        cvCircle(*image, x, y, 3, scalar(cluster_idx)\val[0], scalar(cluster_idx)\val[1], scalar(cluster_idx)\val[2], 0, #CV_FILLED, #CV_AA, #Null)
      Next
      cvReleaseMat(@*clusters)
      cvReleaseMat(@*points)
      cvShowImage(#CV_WINDOW_NAME, *image)
    EndIf
    keyPressed = cvWaitKey(0)
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
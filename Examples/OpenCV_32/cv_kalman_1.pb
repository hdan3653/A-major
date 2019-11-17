IncludeFile "includes/cv_functions.pbi"

Global *save.IplImage, exitCV.b, lpPrevWndFunc

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "The Kalman filter is an algorithm which operates recursively on streams of noisy input data to " +
                  "produce a statistically optimal estimate of the underlying system state." + Chr(10) + Chr(10) +
                  "Demonstrated in the following example by tracking the mouse." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Change Measurement." + Chr(10) + Chr(10) +
                  "Double-Click the window to open a link to more information."

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
  Shared pt_Measurement.CvPoint

  Select event
    Case #CV_EVENT_RBUTTONDOWN
      *save = *param\uPointer1
      DisplayPopupMenu(0, *param\uValue)
    Case #CV_EVENT_LBUTTONDBLCLK
      RunProgram("http://www.cs.unc.edu/~welch/kalman/media/pdf/Kalman1960.pdf")
    Default
      pt_Measurement\x = x
      pt_Measurement\y = y
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
*image.IplImage = cvCreateImage(720, 480, #IPL_DEPTH_8U, 3)
cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)
cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
ToolTip(window_handle, #CV_DESCRIPTION)
Dim A.f(16)
A(0) = 1 : A(1) = 0 : A(2) = 1 : A(3) = 0
A(4) = 0 : A(5) = 1 : A(6) = 0 : A(7) = 1
A(8) = 0 : A(9) = 0 : A(10) = 1 : A(11) = 0
A(12) = 0 : A(13) = 0 : A(14) = 0 : A(15) = 1
Dim H.f(8)
H(0) = 1 : H(1) = 0 : H(2) = 0 : H(3) = 0
H(4) = 0 : H(5) = 1 : H(6) = 0 : H(7) = 0
Dim H_no_measurement(8)
H_no_measurement(0) = 0 : H_no_measurement(1) = 0 : H_no_measurement(2) = 0 : H_no_measurement(3) = 0
H_no_measurement(4) = 0 : H_no_measurement(5) = 0 : H_no_measurement(6) = 0 : H_no_measurement(7) = 0
*kalman.CvKalman = cvCreateKalman(4, 2, 0)
CopyMemory(A(), @*kalman\transition_matrix\fl\f, ArraySize(A()) * SizeOf(FLOAT))
CopyMemory(H(), @*kalman\measurement_matrix\fl\f, ArraySize(H()) * SizeOf(FLOAT))
cvSetIdentity(*kalman\process_noise_cov, 0.00001, 0, 0, 0)
cvSetIdentity(*kalman\measurement_noise_cov, 0.1, 0, 0, 0)
cvSetIdentity(*kalman\error_cov_post, 10000000000, 0, 0, 0)
pt_Prediction.CvPoint
pt_Correction.CvPoint
measurement_frame = 4
max_trace = 300
*measurement.CvMat = cvCreateMat(2, 1, CV_MAKETYPE(#CV_32F, 1))
Dim vt_Prediction.CvPoint(0)
Dim vt_Correction.CvPoint(0)
Dim vt_Measurement.CvPoint(0)
font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_SIMPLEX, 0.4, 0.4, 0, 1, #CV_AA)
SetCursorPos_(*image\width / 2 + 20, *image\height / 2 + 20)
*param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
*param\uPointer1 = *image
*param\uValue = window_handle
cvSetMouseCallback(*window_name, @cvMouseCallback(), *param)

Repeat
  If *image
    cvKalmanPredict(*kalman, 0)
    pt_Prediction\x = PeekF(@*kalman\state_pre\fl\f)
    pt_Prediction\y = PeekF(@*kalman\state_pre\fl\f + 4)

    If Not FrameCount % measurement_frame : IsMeasurementExist = 1 : Else : IsMeasurementExist = 0 : EndIf

    PokeF(@*measurement\fl\f, pt_Measurement\x)
    PokeF(@*measurement\fl\f + 4, pt_Measurement\y)

    If IsMeasurementExist
      CopyMemory(H(), @*kalman\measurement_matrix\fl\f, ArraySize(H()) * SizeOf(FLOAT))
    Else
      CopyMemory(H_no_measurement(), @*kalman\measurement_matrix\fl\f, ArraySize(H_no_measurement()) * SizeOf(FLOAT))
    EndIf
    cvKalmanCorrect(*kalman, *measurement)
    pt_Correction\x = PeekF(@*kalman\state_post\fl\f)
    pt_Correction\y = PeekF(@*kalman\state_post\fl\f + 4)
    ReDim vt_Prediction(arrCount1)
    ReDim vt_Correction(arrCount1)
    vt_Prediction(arrCount1) = pt_Prediction
    vt_Correction(arrCount1) = pt_Correction

    If FrameCount > 100
      arrCount1 + 1

      If IsMeasurementExist
        ReDim vt_Measurement(arrCount2)
        vt_Measurement(arrCount2) = pt_Measurement
        arrCount2 + 1
      EndIf
      cvSetZero(*image)

      If ArraySize(vt_Prediction()) > max_trace : x = ArraySize(vt_Prediction()) - max_trace : Else : x = 0 : EndIf

      For k = x To ArraySize(vt_Prediction()) - 1
        cvLine(*image, vt_Prediction(k)\x, vt_Prediction(k)\y, vt_Prediction(k + 1)\x, vt_Prediction(k + 1)\y, 0, 0, 255, 0, 2, #CV_AA, #Null)
        cvLine(*image, vt_Correction(k)\x, vt_Correction(k)\y, vt_Correction(k + 1)\x, vt_Correction(k + 1)\y, 255, 0, 0, 0, 2, #CV_AA, #Null)
      Next

      If ArraySize(vt_Measurement()) > max_trace / measurement_frame : x = ArraySize(vt_Measurement()) - max_trace / measurement_frame : Else : x = 0 : EndIf

      For k = x To ArraySize(vt_Measurement()) - 1
        cvCircle(*image, vt_Measurement(k + 1)\x, vt_Measurement(k + 1)\y, 3, 0, 255, 0, 0, #CV_FILLED, #CV_AA, #Null)
      Next
    Else
      cvSetZero(*image)
    EndIf
    cvPutText(*image, "Kalman Prediction", *image\width - 180, 30, @font, 255, 255, 255, 0)
    cvPutText(*image, "Measurement:  0" + Str(measurement_frame), *image\width - 180, 45, @font, 255, 255, 255, 0)
    cvPutText(*image, "Kalman Correction", *image\width - 180, 60, @font, 255, 255, 255, 0)
    cvLine(*image, *image\width - 16, 26, *image\width - 24, 26, 0, 0, 255, 0, 2, #CV_AA, #Null)
    cvCircle(*image, *image\width - 20, 41, 4, 0, 255, 0, 0, #CV_FILLED, #CV_AA, #Null)
    cvLine(*image, *image\width - 16, 56, *image\width - 24, 56, 255, 0, 0, 0, 2, #CV_AA, #Null)
    cvShowImage(#CV_WINDOW_NAME, *image)
    keyPressed = cvWaitKey(1)

    If keyPressed = 32
      Dim vt_Measurement(0)
      arrCount1 = 0
      arrCount2 = 0
      FrameCount = -1
      measurement_frame = (measurement_frame + 1) % 5

      If measurement_frame = 0 : measurement_frame + 1 : EndIf

    EndIf
    FrameCount + 1
  EndIf
Until keyPressed = 27 Or exitCV
FreeMemory(*param)
cvReleaseMat(@*measurement)
cvReleaseKalman(@*kalman)
cvReleaseImage(@*image)
cvDestroyAllWindows()
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 1
; Folding = -
; EnableXP
; DisableDebugger
; CurrentDirectory = binaries\
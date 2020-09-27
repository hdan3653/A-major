;IncludeFile "includes/cv_functions.pbi"

Global lpPrevWndFunc, *image.IplImage, nX, nY, *frame.IplImage
#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Using the Camshift algorithm, color information is used to track an object along an image sequence." +
                  Chr(10) + Chr(10) + "- MOUSE: Select a rectangle centered tightly on your face." +
                  Chr(10) + Chr(10) + "- SPACEBAR: Show/Hide Histogram." +
                  Chr(10) + Chr(10) + "- ENTER: Clear the selected object." +
                  Chr(10) + Chr(10) + "- [ P ] KEY: Toggle Projection Mode."

ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Shared exitCV.b
  
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 10
          exitCV = #True
      EndSelect
    Case #WM_DESTROY
      exitCV = #True
  EndSelect
  ProcedureReturn CallWindowProc_(lpPrevWndFunc, hWnd, Msg, wParam, lParam)
EndProcedure

ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)
  Shared select_object
  Shared projection_obj
  Select event
    Case #CV_EVENT_LBUTTONDOWN
      select_object = 1
    Case #CV_EVENT_LBUTTONUP
      select_object = 0
      projection_obj =-1
  EndSelect
EndProcedure

ProcedureC HSV2RGB(hue.f)
  Dim color(3)
  Dim sector_data(6, 3)
  sector_data(0, 0) = 0
  sector_data(0, 1) = 2
  sector_data(0, 2) = 1
  sector_data(1, 0) = 1
  sector_data(1, 1) = 2
  sector_data(1, 2) = 0
  sector_data(2, 0) = 1
  sector_data(2, 1) = 0
  sector_data(2, 2) = 2
  sector_data(3, 0) = 2
  sector_data(3, 1) = 0
  sector_data(3, 2) = 1
  sector_data(4, 0) = 2
  sector_data(4, 1) = 1
  sector_data(4, 2) = 0
  sector_data(5, 0) = 0
  sector_data(5, 1) = 1
  sector_data(5, 2) = 2
  hue * 0.0333333333333333333
  sector = cvFloor(hue)
  p = Round(255 * (hue - sector), #PB_Round_Nearest)
  
  If sector & 1 : p ! 255 : Else : p ! 0 : EndIf
  
  color(sector_data(sector, 0)) = 255
  color(sector_data(sector, 1)) = 0
  color(sector_data(sector, 2)) = p
  ProcedureReturn cvScalar(color(2), color(1), color(0), 0)
EndProcedure


ProcedureC TrackRed(*imgHSV.IplImage)
  ;  *imgThresh.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  *imgThresh.IplImage = *imgHSV
  
  cvSmooth(*imgThresh, *imgThresh, #CV_GAUSSIAN, 11, 11, 0, 0)
  ;cvInRangeS(*imgHSV, 200, 200, 200, 0, 255, 255, 255, 0, *imgThresh)
  cvInRangeS(*imgHSV, 180, 0, 0, 0, 255, 0, 0, 0, *imgThresh)
  moments.CvMoments
  cvMoments(*imgThresh, @moments, 1)
  moment10.d = moments\m10
  moment01.d = moments\m01
  area.d = moments\m00
  
  If area > 100
    posX = moment10 / area
    posY = moment01 / area
    
    If posX >= 0 And posY >= 0 
      cvCircle(*frame, posX, posY, 10, 0, 0, 255, 0, 2, #CV_AA, #Null)
      marker1X = posX
      marker1Y = posY
      
    EndIf
  EndIf
  
  ProcedureReturn *imgThresh
  
EndProcedure


Procedure Createcali()
  
  space_mode = #True
  
  Repeat
    nCreate + 1
    *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
  Until nCreate = 5 Or *capture
  
  If *capture
    cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
    window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
    *window_name = cvGetWindowName(window_handle)
    lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())
    
    hWnd = GetParent_(window_handle)
    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
    SendMessage_(hWnd, #WM_SETICON, 0, opencv)
    wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)
    SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))
    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
    
    FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
    FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
    FrameRate = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FPS)
    Debug "frame w: " + FrameWidth + " frame h: " + FrameHeight + " frame rate: " + FrameRate
    *frame.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
    *hsv.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
    Dim *hue.IplImage(1) : *hue(0) = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
    *mask.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
    *projection.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 1)
    smin = 30 : vmin = 10 : vmax = 255
    bins = 50
    Dim range.f(2) : range(0) = 0 : range(1) = 180
    PokeL(@*ranges, @range())
    *histogram.CvHistogram = cvCreateHist(1, @bins, #CV_HIST_ARRAY, @*ranges, 1)
    *color.CvScalar
    window.CvRect
    comp.CvConnectedComp
    box.CvBox2D
    font.CvFont : cvInitFont(@font, #CV_FONT_HERSHEY_SCRIPT_COMPLEX, 1, 1, #Null, 1, #CV_AA)
    *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
    *param\uValue = window_handle
    cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)
    
    scalar1.CvScalar : scalar2.CvScalar
    font1.CvFont: cvInitFont(@font1, #CV_FONT_HERSHEY_SIMPLEX, 1, 1, #Null, 2, #CV_AA)
    font2.CvFont : cvInitFont(@font2, #CV_FONT_HERSHEY_SIMPLEX, 0.5, 0.5, #Null, 1, #CV_AA)
    
    Cen_x = 300
    Cen_y= 300
    radius = 100
    
    Repeat
      *image = cvQueryFrame(*capture)
      
      If *image
        cvFlip(*image, #Null, 1)
        cvCopy(*image, *frame, #Null)
        cvCvtColor(*frame, *hsv, #CV_BGR2HSV, 1)
        
        If projection_obj
          cvInRangeS(*hsv, 0, smin, vmin, 0, 180, 256, vmax, 0, *mask)       
          cvSplit(*hsv, *hue(0), #Null, #Null, #Null)
          
          If projection_obj < 0
            cvSetImageROI(*hue(0), Cen_x-radius, Cen_y-radius, radius*2, radius*2)
            cvSetImageROI(*mask, Cen_x-radius, Cen_y-radius, radius*2, radius*2)
            cvCalcHist(*hue(), *histogram, #False, *mask)
            cvGetMinMaxHistValue(*histogram, #Null, @max_value.f, #Null, #Null)
            If max_value : scale.d = 255 / max_value : Else : scale.d = 0 : EndIf
            cvConvertScale(*histogram\bins, *histogram\bins, scale, 0)
            cvResetImageROI(*mask)
            cvResetImageROI(*hue(0))
            
            projection_obj = 1
          EndIf
          cvCalcBackProject(*hue(), *projection, *histogram)
          cvAnd(*projection, *mask, *projection, #Null)
          If projection_mode : cvCvtColor(*projection, *frame, #CV_GRAY2BGR, 1) : EndIf
          
        EndIf
        If select_object
          cvSetImageROI(*frame, Cen_x-radius, Cen_y-radius, radius*2, radius*2)                 
          cvXorS(*frame, 255, 255, 255, 0, *frame, #Null)
          cvResetImageROI(*frame)
        EndIf
        cvCircle(*frame, Cen_x, Cen_y, radius*1.414, 0, 0, 255, 0, 2, #CV_AA, #Null)  
        
        TrackRed(*projection)
        
        If projection_mode 
          cvShowImage(#CV_WINDOW_NAME, TrackRed(*projection))  
          ;cvShowImage(#CV_WINDOW_NAME, *projection)  
        Else 
          cvShowImage(#CV_WINDOW_NAME, *frame) 
        EndIf
        
        
        Select event
          Case #CV_EVENT_LBUTTONDOWN
            select_object = 1
          Case #CV_EVENT_LBUTTONUP
            select_object = 0
            projection_obj =-1
        EndSelect
 
        ;cvShowImage(#CV_WINDOW_NAME, *frame)
        keyPressed = cvWaitKey(10)
        Select keyPressed
          Case 13
            projection_obj = 0
          Case 32
            
            If   space_mode
              select_object = 1
              space_mode = #False   
            ElseIf space_mode = #False
              select_object = 0
              projection_obj =-1
              space_mode = #True
            EndIf 
            
          Case 80, 112
            projection_mode ! #True
            
            
        EndSelect
      EndIf
    Until keyPressed = 27 Or exitCV
    FreeMemory(*param)
    cvReleaseHist(@*histogram)
    cvReleaseImage(@*hist)
    cvReleaseImage(@*mask)
    cvReleaseImage(@*hue(0))
    cvReleaseImage(@*hsv)
    cvReleaseImage(@*frame)
    cvDestroyAllWindows()
    cvReleaseCapture(@*capture)
    
    ProcedureReturn
  Else
    MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
  EndIf
  
  ProcedureReturn
EndProcedure









; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 77
; FirstLine = 68
; Folding = -
; EnableXP
IncludeFile "../includes/cv_functions.pbi"
;IncludeFile "includes/cv_functions.pbi"
;프로젝트 파일로 따로 빼놔서 경로 수정함

Global lpPrevWndFunc, *imgTracking.IplImage,*imgTracking2.IplImage
Global lastX, lastY, last2X, last2Y, last3X, last3Y, nCursor
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Define Com.i, Int1.l, Int2.l, Recv.l, Ptr.i
Global Dim ptBox.CvPoint(7, 4)

#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
#CV_DESCRIPTION = "Tracks red objects demonstrated by drawing a line that traces its location." + Chr(10) + Chr(10) +
                  "- SPACEBAR: Toggle mouse tracking." + Chr(10) + Chr(10) +
                  "- ENTER: Clear the traced line."

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
  Select event
    Case #CV_EVENT_RBUTTONDOWN
      DisplayPopupMenu(0, *param\uValue)
  EndSelect
EndProcedure

ProcedureC GetThresholdedImage(*imgHSV.IplImage)
  *imgThresh.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  cvInRangeS(*imgHSV, 160, 140, 40, 0, 179, 255, 255, 0, *imgThresh)
  ProcedureReturn *imgThresh
EndProcedure

ProcedureC GetThresholdedImage2(*imgHSV.IplImage)
  *imgThresh2.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  cvInRangeS(*imgHSV, 65 , 60, 60, 0, 80, 255, 255, 0, *imgThresh2)
  ProcedureReturn *imgThresh2
EndProcedure

Procedure checkState()
;  Debug("state :: " + Str(markerState))
  
  i = 0
  Repeat
    i + 1
  Until i = 7
EndProcedure

ProcedureC TrackRed(*imgHSV.IplImage)
  *imgThresh.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  cvInRangeS(*imgHSV, 160, 140, 40, 0, 179, 255, 255, 0, *imgThresh)
  moments.CvMoments
  cvMoments(*imgThresh, @moments, 1)
  moment10.d = moments\m10
  moment01.d = moments\m01
  area.d = moments\m00
  
  If area > 1000
    posX = moment10 / area
    posY = moment01 / area
   
    If posX >= 0 And posY >= 0 
      cvCircle(*imgTracking, posX, posY, 10, 0, 0, 255, 0, 2, #CV_AA, #Null)
      marker1X = posX
      marker1Y = posY
      
    EndIf
  EndIf

EndProcedure

ProcedureC TrackGreen(*imgHSV.IplImage)
  
  *imgThresh2.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  cvInRangeS(*imgHSV, 65 , 60, 60, 0, 80, 255, 255, 0, *imgThresh2)
  moments.CvMoments
  cvMoments(*imgThresh2, @moments, 1)
  moment10.d = moments\m10
  moment01.d = moments\m01
  area.d = moments\m00

  If area > 1000
    posX = moment10 / area
    posY = moment01 / area

    If posX >= 0 And posY >= 0
      cvCircle(*imgTracking, posX, posY, 10, 0, 255, 0, 0, 2, #CV_AA, #Null)
      marker2X = posX
      marker2Y = posY
    EndIf
  EndIf
EndProcedure

Procedure calcBoxs()
  ptLeft = 0
  ptTop = 0
  ptRight = 0
  ptBottom = 0
  ptLength = 0
  direction = 0
  
  If marker2X > marker1X
    ptLeft = marker1X
    ptRight = marker2X
  Else
    ptLeft = marker2X
    ptRight = marker1X
  EndIf
  
  If marker2Y > marker1Y
    ptTop = marker1Y
    ptBottom = marker2Y
  Else
    ptTop = marker2Y
    ptBottom = marker1Y
  EndIf
  
  If ptRight-ptLeft > ptBottom-ptTop
    ptLength = (ptRight-ptLeft)/7
    direction = 0
  Else
    ptLength = (ptBottom-ptTop)/7
    direction = 1
  EndIf
  
  count = 0
  Repeat
    If direction = 1
      left = ptLeft
      top = ptTop + count*ptLength
      right = ptRight
      bottom = ptTop + (count+1)*ptLength      
    Else
      left = ptLeft + count*ptLength
      top = ptTop
      right = ptLeft + (count+1)*ptLength
      bottom = ptBottom
    EndIf
    
    ptBox(count, 0)\x = left
    ptBox(count, 0)\y = top
    ptBox(count, 2)\x = right
    ptBox(count, 2)\y = bottom
    
    count+1
  Until count >= 7
  
EndProcedure

Procedure drawBoxs(*image)
  ; 박스 0-6이 있고 각 꼭짓점을 4개 만듦, 현재는 0과 2만 씀(좌상단과 우하단) 타입은 CvPoint
  cvLine(*image, ptBox(0, 0)\x, ptBox(0, 0)\y, ptBox(6, 2)\x, ptBox(6, 2)\y, 0, 255, 255, 0, 4, #CV_AA, #Null)
  
  ; 그리기 상태일 때 박스들의 좌표값을 계산한다.
  If markerState = 0
    calcBoxs()
  EndIf
  
  ; 7개의 박스를 그린다
  count = 0
  Repeat
    cvRectangle(*image, ptBox(count, 0)\x, ptBox(count, 0)\y, ptBox(count, 2)\x, ptBox(count, 2)\y, 0, 0, 255, 0, 2, #CV_AA, #Null)
    count+1
  Until count >= 7
  
EndProcedure

;소리 재생하는 함수 (.a : ascii 타입 변수)
Procedure playPianoSound(sound.a)
  ; 무슨 음인지 출력해주기 위해서 만듦
  text.s = ""
  Select sound.a
    Case 0
      text = "도"
    Case 1
      text = "레"
    Case 2
      text = "미"
    Case 3
      text = "파"
    Case 4
      text = "솔"
    Case 5
      text = "라"
    Case 6
      text = "시"
  EndSelect
  Debug(text)
  
  ;PlaySound(#Sound [, Flags [, Volume]]), loop -> 반복재생, 20 -> 소리크기
  PlaySound(sound)
;  Delay(1000)
EndProcedure

; 그려진 박스에 대한 위치 값을 계산해서 어떤 음을 출력할 것인지 결정하는 함수
Procedure calcArea(x, y)
  tone = -1
  i = 0
  Repeat
    If (ptBox(i, 0)\x < x) And (ptBox(i, 2)\x > x)
      If (ptBox(i, 0)\y < y) And (ptBox(i, 2)\y > y)
        tone = i
        Break
      EndIf
    EndIf
    i + 1
  Until i >= 7
  
  ProcedureReturn tone ; 음을 반환
EndProcedure

; 음을 출력하기 위한 함수
Procedure checkArea(bit$)
  If(bit$ = "1")
;    Debug("GREEN : " + Str(marker2X) + ", " + Str(marker2Y))
    tone = calcArea(marker2X, marker2Y)
  ElseIf(bit$ = "2")
;    Debug("RED : " + Str(marker1X) + ", " + Str(marker1Y))
    tone = calcArea(marker1X, marker1Y)
  EndIf
  
  ; 음이 도-시 사이인 경우만 출력
  If tone > -1 And tone < 7
    playPianoSound(tone)
  EndIf

EndProcedure  

;포트연결
Com = OpenSerialPort(#PB_Any, "COM4", 115200, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 64, 64)
Debug Com

;초기 상태값 설정
markerState = 0

;사운드 시스템 초기화, 점검
If InitSound() = 0 
  MessageRequester("Error", "Sound system is not available",  0)
  End
EndIf

;각 음정 wav파일 불러오기, 0~6까지 도~시에 대응 ;여기도 경로 수정함
;Result = LoadSound(#Sound, Filename$ [, Flags])
LoadSound(0, "piano_sound/piano-도.wav")
LoadSound(1, "piano_sound/piano-레.wav")
LoadSound(2, "piano_sound/piano-미.wav")
LoadSound(3, "piano_sound/piano-파.wav")
LoadSound(4, "piano_sound/piano-솔.wav")
LoadSound(5, "piano_sound/piano-라.wav")
LoadSound(6, "piano_sound/piano-시.wav")

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
Until nCreate = 5 Or *capture

If *capture
  cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)
  window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)
  *window_name = cvGetWindowName(window_handle)
  lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

  If CreatePopupImageMenu(0, #PB_Menu_ModernLook)
    MenuItem(10, "Exit")
  EndIf
  hWnd = GetParent_(window_handle)
  opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)
  SendMessage_(hWnd, #WM_SETICON, 0, opencv)
  wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)
  SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))
  cvMoveWindow(#CV_WINDOW_NAME, 20, 20)
  ToolTip(window_handle, #CV_DESCRIPTION)
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  *imgTracking = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *imgTracking2 = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  cvSetZero(*imgTracking)
  cvSetZero(*imgTracking2)
  lastX = -1
  lastY = -1
  last2X = -1
  last2Y = -1
  *imgHSV.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *imgHSV2.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *image.IplImage
  *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))
  *param\uValue = window_handle
  cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

  Repeat
    *image = cvQueryFrame(*capture)

    If *image
      cvFlip(*image, #Null, 1)
      cvSmooth(*image, *image, #CV_GAUSSIAN, 3, 3, 0, 0)
      cvCvtColor(*image, *imgHSV, #CV_BGR2HSV, 1)
      cvSmooth(*imgThresh, *imgThresh, #CV_GAUSSIAN, 3, 3, 0, 0)
      cvSmooth(*imgThresh2, *imgThresh2, #CV_GAUSSIAN, 3, 3, 0, 0)
      
      If IsSerialPort(Com) <> 0
        If AvailableSerialPortInput(Com) > 0 
          ;마이크로비트 포트 값
          If ReadSerialPortData(Com, @Buffer, 1)
            micbit$ = Chr(Buffer)
            If(micbit$ = "1")
  ;            Debug "this is from Blue"
              TrackGreen(*imgHSV)
            ElseIf(micbit$ = "2")
  ;            Debug "this is from Yellow"
              TrackRed(*imgHSV)
            EndIf
            
            ;상태가 음 출력 상태이면 음을 출력한다
            If markerState = 1
              checkArea(micbit$)
            EndIf 
            
            ;현재 상태가 무엇인지 확인하기 위한 함수
  ;          checkState()
          EndIf
        EndIf
      EndIf
      
      cvReleaseImage(@*imgThresh)
      cvReleaseImage(@*imgThresh2)
      cvAdd(*image, *imgTracking, *image, #Null)
      cvAdd(*image, *imgTracking2, *image, #Null)
      
      ;선과 박스를 그리는 함수
      drawBoxs(*image)
                
      cvShowImage(#CV_WINDOW_NAME, *image)
      keyPressed = cvWaitKey(10)
      
      Select keyPressed
        Case 13
          cvSetZero(*imgTracking)
          cvSetZero(*imgTracking2)         
          lastX = -1
          lastY = -1
          last2X = -1
          last2Y =-1
        Case 32
          nCursor ! 1
          ;스페이스바를 누르면 상태를 음 출력 상태로 바꿈
          markerState = 1
          Debug("State changed")
          ;          checkState()
          
; TEMP :: 비트가 없을 경우를 위해 만든 코드
        Case 114; 'r'
          TrackRed(*imgHSV)
          ;상태가 음 출력 상태이면 음을 출력한다
          If markerState = 1
            checkArea("2")
          EndIf 
        Case 103; 'g'
          TrackGreen(*imgHSV)
          If markerState = 1
            checkArea("1")
          EndIf 
; TEMP :: 비트가 없을 경우를 위해 만든 코드
          
      EndSelect
    EndIf
  Until keyPressed = 27 Or exitCV
  FreeMemory(*param)
  cvReleaseImage(@*imgHSV)
  cvReleaseImage(@*imgHSV2)
  cvReleaseImage(@*imgTracking)
  cvReleaseImage(@*imgTracking2)
  cvDestroyAllWindows()
  cvReleaseCapture(@*capture)
Else
  MessageBox_(0, "Unable to connect to a webcam - operation cancelled.", #CV_WINDOW_NAME, #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; Folding = ---
; EnableXP
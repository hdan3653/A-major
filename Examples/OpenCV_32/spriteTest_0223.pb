IncludeFile "includes/cv_functions.pbi"

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력

Global Window_0, Screen_0, Window_1
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, keyFlag, answerTone
Global Scissors, LineClipped
Global Dim Lines.i(7)
Global Dim Note.i(7)
Global Dim ptBox.CvPoint(7, 4)

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

Procedure playPianoSound(sound.a)
  ; 무슨 음인지 출력해주기 위해서 만듦
  text.s = ""
  Select sound
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

Procedure checkArea(key)
  If(key = #PB_Key_2)
    ;    Debug("GREEN : " + Str(marker2X) + ", " + Str(marker2Y))
    tone = calcArea(marker2X, marker2Y)
  ElseIf(key = #PB_Key_1)
    ;    Debug("RED : " + Str(marker1X) + ", " + Str(marker1Y))
    tone = calcArea(marker1X, marker1Y)
  EndIf
  
  ; 음이 도-시 사이인 경우만 출력
  If tone > -1 And tone < 7
    playPianoSound(tone)
    keyFlag = 1
    answerTone = tone
  EndIf
  
EndProcedure

; 나무에 매달린 7음을 그리는 함수. 음 입력 시 해당 음은 잘린 상태로 출력
Procedure drawLines()
  a = 0
  x = 820
  y = 160
  While a < 7
    If keyFlag = 1 And a = answerTone
      DisplayTransparentSprite(LineClipped, x+35, y)
    Else
      DisplayTransparentSprite(Lines(a), x, y)
    EndIf
    
    x = x + 80
    a = a + 1 
  Wend
EndProcedure

  
  Procedure dropNote()  
    y = 200
    x = 820 + answerTone*80
    
    DisplayTransparentSprite(Scissors, x, y)
    DisplayTransparentSprite(Note(answerTone), x+20, 650)
    
    FlipBuffers()
    ;Delay(1000)
    
  EndProcedure
  
  
  keyFlag = 0 ; 음 입력 여부
  markerState = 0 ; 마커 입력 상태
  
  ;사운드 시스템 초기화, 점검
  If InitSound() = 0 
    MessageRequester("Error", "Sound system is not available",  0)
    End
  EndIf
  
  ;각 음정 wav파일 불러오기, 0~6까지 도~시에 대응
  ;Result = LoadSound(#Sound, Filename$ [, Flags])
  LoadSound(0, "piano-도.wav")
  LoadSound(1, "piano-레.wav")
  LoadSound(2, "piano-미.wav")
  LoadSound(3, "piano-파.wav")
  LoadSound(4, "piano-솔.wav")
  LoadSound(5, "piano-라.wav")
  LoadSound(6, "piano-시.wav")
  
  Repeat
    nCreate + 1
    *capture.CvCapture = cvCreateCameraCapture(#CV_CAP_ANY)
  Until nCreate = 5 Or *capture
  
  If *capture
    FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
    FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
    *image.IplImage : pbImage = CreateImage(#PB_Any, FrameWidth, FrameHeight)
    
    If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
      
      Window_1=OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; 웹캠용 윈도우
      ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
      StickyWindow(1, #True) ; 항상 위에 고정
      SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(0), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; 윈도우 타이틀 바 제거
      
      InitSprite()
      InitKeyboard()
      
      ;Screen과 Sprite 생성
      Screen_0 = OpenWindowedScreen(WindowID(Window_0), 0, 0, WindowWidth(0), WindowHeight(0))
      
      UsePNGImageDecoder()
      Background = LoadSprite(#PB_Any, "graphics/background.png" )
      
      Lines(0) = LoadSprite(#PB_Any, "graphics/line1.png")
      Lines(1) = LoadSprite(#PB_Any, "graphics/line2.png")
      Lines(2) = LoadSprite(#PB_Any, "graphics/line3.png")
      Lines(3) = LoadSprite(#PB_Any, "graphics/line4.png")
      Lines(4) = LoadSprite(#PB_Any, "graphics/line5.png")
      Lines(5) = LoadSprite(#PB_Any, "graphics/line6.png")
      Lines(6) = LoadSprite(#PB_Any, "graphics/line7.png")
      LineClipped = LoadSprite(#PB_Any, "graphics/line_clipped.png")
      
      Ant = LoadSprite(#PB_Any, "graphics/ant.png")
      Container = LoadSprite(#PB_Any, "graphics/container.png")
      Scissors = LoadSprite(#PB_Any, "graphics/cut.png")
      
      Note(0) = LoadSprite(#PB_Any, "graphics/do.png")
      Note(1) = LoadSprite(#PB_Any, "graphics/re.png")
      Note(2) = LoadSprite(#PB_Any, "graphics/mi.png")
      Note(3) = LoadSprite(#PB_Any, "graphics/fa.png")
      Note(4) = LoadSprite(#PB_Any, "graphics/so.png")
      Note(5) = LoadSprite(#PB_Any, "graphics/la.png")
      Note(6) = LoadSprite(#PB_Any, "graphics/ti.png")
        
      ClearScreen(RGB(255, 255, 255))
        
      Repeat
        *image = cvQueryFrame(*capture)
        
        If *image
          cvFlip(*image, #Null, 1)
          
          DisplaySprite(Background, 0, 0)
          drawLines()
          DisplayTransparentSprite(Container, 790, 600)
          DisplayTransparentSprite(Note(0), 800, 610)
          DisplayTransparentSprite(Note(2), 840, 610)
          DisplayTransparentSprite(Ant, 730, 630)
          
          
          ;키보드 이벤트
          ExamineKeyboard()
          If KeyboardReleased(#PB_Key_1)
            keyInput = #PB_Key_1
            GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
            marker1X = mouse_x
            marker1Y = mouse_y - (WindowHeight(0)/2 - 200)
            If (markerState = 1)
              checkArea(keyInput)
            EndIf
          EndIf
          If KeyboardReleased(#PB_Key_2)
            keyInput = #PB_Key_2
            GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
            marker2X = mouse_x
            marker2Y = mouse_y - (WindowHeight(0)/2 - 200)
            If (markerState = 1)
              checkArea(keyInput)
            EndIf
          EndIf
          If KeyboardReleased(#PB_Key_Space)
            markerState = 1
          EndIf
          
          If keyFlag = 1
            dropNote()
            ;keyFlag = 0
          EndIf
                   
        EndIf
        
        drawBoxs(*image)
        
        *mat.CvMat = cvEncodeImage(".bmp", *image, 0)     
        Result = CatchImage(1, *mat\ptr)
        SetGadgetState(0, ImageID(1))     
        cvReleaseMat(@*mat)  
        
        FlipBuffers()
        
      Until WindowEvent() = #PB_Event_CloseWindow
    EndIf
    FreeImage(pbImage)
    cvReleaseCapture(@*capture)
  Else
    MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
  EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 301
; Folding = 5-
; EnableXP
; DisableDebugger
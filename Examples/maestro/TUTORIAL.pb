;IncludeFile "includes/cv_functions.pbi"


; [KEYBOARD] 1: green tracking(실제 입력), 2: red tracking(사운드 출력만), 3: 정답 화음 듣기, 4: 입력값 취소, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력, 키보드 3으로 정답 화음 재생


Global Tutorial_State

Enumeration InGameStatus
  #Tutorial_Intro
  #Tutorial_GameInPlay
  #Tutorial_GameInPause
EndEnumeration


Global *rectimg.IplImage, *loadbox1.IplImage, *loadbox2.IplImage
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global.i keyInput, answerTone, currentTime, stageNum, answerNum, direction
Global.l hMidiOut
Global Dim ptBox.CvPoint(7, 4)
Global NewList sprite_list.mySprite()
Global NewList position_list.myPosition()
Global Dim chord_list(5, 2)
Global Dim currentProblem(3)
Global Dim answer(2)
Global Dim line_position(6)
Global Dim elements(2) ; container 안에 3개 element spirte 구조체 포인터 저장
Global Dim keyColor.color(6)

Global Tutorial_Num = 0

Global Tuto_Lock_5 = #False, Tuto_Lock_6 = #False, Tuto_Lock_10 = #False, Tuto_Lock_15= #False  


Procedure CheckArea_Tutorial(key)
  If(key = #PB_Key_2)
    ;    Debug("GREEN : " + Str(marker2X) + ", " + Str(marker2Y))
    tone = CalcArea(marker2X, marker2Y)
  ElseIf(key = #PB_Key_1)
    ;    Debug("RED : " + Str(marker1X) + ", " + Str(marker1Y))
    tone = CalcArea(marker1X, marker1Y)
  EndIf
  
  ; 음이 도-시 사이인 경우만 출력
  If tone > -1 And tone < 7
    PlayPianoSound(tone+1)
    If keyInput = #PB_Key_2

      ProcedureReturn
    EndIf 
  EndIf
  
EndProcedure

Procedure WriteScript(script.s, pos_x, pos_y)
     *p = FindSprite("script_box")
     SetMySprite(*p, 0, 0, 1) 
     Font40 = LoadFont(#PB_Any, "Impact", 40) 
     StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
     DrawText(pos_x, pos_y, script , RGB(0,0,0))
     StopDrawing()

     
EndProcedure

Procedure Tutorial_play()
  
  
  scriptPos_x = 50
  scriptPos_y = 50
  
   Select Tutorial_Num
       
       
     Case 0 
 
           WriteScript("튜토리얼에 오신걸 환영합니다.", scriptPos_x, scriptPos_y)
     Case 1

   
           WriteScript("지금부터 기본적인 사용방법을 알아봅시다.", scriptPos_x, scriptPos_y)
         Case 2 
           

      WriteScript("먼저 하단 왼쪽 의 화면은 당신의 모습입니다.어쩌고", scriptPos_x, scriptPos_y)
    Case 3
      

      WriteScript("상반신이 잘 보이도록 위치를 조절해주세요.", scriptPos_x, scriptPos_y) 
    Case 4 

         WriteScript("두손에 마커를 쥐었으면 이제 입력을 해봅시다.", scriptPos_x, scriptPos_y) 
       Case 5 
         

         WriteScript("화면에 빨간 마커가 잘 보이도록 들고 \n 상단을 터치하여 버튼을 눌러보세요.", scriptPos_x, scriptPos_y)
        Tuto_Lock_5 = #True

       Case 6          

        WriteScript("화면에 초록 마커가 잘 보이도록 들고 하단을 터치하여 버튼을 눌러보세요.", scriptPos_x, scriptPos_y) 
        Tuto_Lock_6 = #True
        
      Case 7 
        
        WriteScript("색깔 박스가 잘 그려졋나요? 마커를 이용하여 박스의 크기를 적절히 조절해 보세요.", scriptPos_x, scriptPos_y) 

      Case 8 

        WriteScript("다음은 기본이되는 음을 알아봅시다.", scriptPos_x, scriptPos_y) 
        For i = 1 To 7
        *p = FindSprite("line"+i)
        SetMySprite(*p, 750 + 90*i , 160, 0)
      Next
        *p = FindSprite("highlight2")
        SetMySprite(*p, 750, 160, 0)
      Case 9 
        

        *p = FindSprite("highlight2")
        SetMySprite(*p, 750, 160, 1)
        WriteScript("나뭇가지에 매달린 과일들이 보이시나요....?", scriptPos_x, scriptPos_y)       
        For i = 1 To 7
        *p = FindSprite("line"+i)
        SetMySprite(*p, 750 + 90*i , 160, 1)
        Next


      Case 10
        *p = FindSprite("highlight2")
        SetMySprite(*p, 750, 160, 0)

        WriteScript("마커로 음을 입력하기 위해 space를 눌러 마커 모드를 음 입력모드로 바꿀 수 있습니다.", scriptPos_x, scriptPos_y) 
        Tuto_Lock_10= #True
  
      Case 11
        WriteScript("이 과일들은 차례로 도레미파솔라시도 어쩌고 입니다 <-이걸 어떻게 쉽게 풀어서 쓰지", scriptPos_x, scriptPos_y)
          
      Case 12 
        WriteScript("이 과일들은 각각 음을 가지고 있고 캠 화면의 같은 색깔의 상자에 대응됩니다.", scriptPos_x, scriptPos_y)
    
      Case 13 
        WriteScript("마커를 이용하여 자유롭게 음 입력을 해보고 소리를 들어보세요.", scriptPos_x, scriptPos_y)
      Case 14 
        WriteScript("다음은 화음에 대해 알아보겠습니다.", scriptPos_x, scriptPos_y)
                                                                      
      Case 15 
              WriteScript("상자의 모양이 바뀌었습니다. 앞서 말했던 음들이 세가지가 모이면 조화로운 소리가 어쩌고 <-화음정의찾아서 어쩌고", scriptPos_x, scriptPos_y)
              Tuto_Lock_15 = #True
      Case 16 
               WriteScript("화음 설명 어쩌고 저쩌고", scriptPos_x, scriptPos_y)
               Tuto_Lock_15 = #True
      Case 17 
               WriteScript("아래는 화음 개미(?)입니다. 개미가 세개의 음을 모아 화음으로 굴려줍니다", scriptPos_x, scriptPos_y)
      Case 18 
               WriteScript("마커를 이용하여 화음을 잘 듣고 기억하세요.", scriptPos_x, scriptPos_y)
      Case 19 
              WriteScript("1단계에서는 화음을 듣고 화음에 맞는 음 맞추기, 총 3단계", scriptPos_x, scriptPos_y)
      Case 20 
            WriteScript("2단계에서는 멜로디에 맞는 화음을 넣는 단계", scriptPos_x, scriptPos_y)
      Case 21 
              WriteScript("3단계에서는 직접 작곡을 해볼 수 있습니다.", scriptPos_x, scriptPos_y)   
      Case 22 
          WriteScript("이상으로 튜토리얼을 마치겠습니다.", scriptPos_x, scriptPos_y)

   EndSelect
   
   

EndProcedure

Procedure CreateTutorial()
  
  Shared MainWindow
  
  Tutorial_State = #Tutorial_Intro   
  
   If  Tutorial_State = #Tutorial_Intro
      Tutorial_State = #Tutorial_GameInPlay
   EndIf 
  
  
  
OpenConsole()
markerState = 0 ; 마커 입력 상태
answerNum = 0
answer(0) = -1
answer(1) = -1
answer(2) = -1

keyColor(0)\r = 216
  keyColor(0)\g = 63
  keyColor(0)\b = 34
  keyColor(1)\r = 234
  keyColor(1)\g = 143
  keyColor(1)\b = 49
  keyColor(2)\r = 246
  keyColor(2)\g = 224
  keyColor(2)\b = 20
  keyColor(3)\r = 144
  keyColor(3)\g = 200
  keyColor(3)\b = 75
  keyColor(4)\r = 0
  keyColor(4)\g = 57
  keyColor(4)\b = 137
  keyColor(5)\r = 135
  keyColor(5)\g = 80
  keyColor(5)\b = 46
  keyColor(6)\r = 104
  keyColor(6)\g = 25
  keyColor(6)\b = 146
  

InitChords()
;stageNum = SelectedStage
InitProblem()

;사운드 시스템 초기화, 점검
If InitSound() = 0 
  MessageRequester("Error", "Sound system is not available",  0)
  End
EndIf

OutDev.l
result = midiOutOpen_(@hMidiOut, OutDev, 0, 0, 0)
PrintN(Str(result))

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(0)
Until nCreate = 5 Or *capture

If *capture
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  *image.IplImage : pbImage = CreateImage(#PB_Any, 640, 480) ; image 글로벌로 뺄까
  *rectimg = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
   *loadbox1 = cvLoadImage("../graphics/chord_box.png", 1)
  *loadbox2 = cvLoadImage("../graphics/chord_box2.png", 1)
  ;If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
   If MainWindow 
    OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; 웹캠용 윈도우
    ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
    StickyWindow(1, #True) ; 항상 위에 고정
    SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(1), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; 윈도우 타이틀 바 제거
    SetForegroundWindow_(WindowID(0)) ; 포커스 이동
    InitSprite()
    InitKeyboard()
    
    ;Screen과 Sprite 생성
    ;OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0), WindowHeight(0))
    
    UsePNGImageDecoder()
    
    TransparentSpriteColor(#PB_Default, RGB(255, 0, 255))
    InitMySprite("background", "graphics/background.png", 0, 0)
    InitMySprite("line1", "graphics/line1.png", 800, 160,0)
    InitMySprite("line2", "graphics/line2.png", 890, 160,0)
    InitMySprite("line3", "graphics/line3.png", 990, 160,0)
    InitMySprite("line4", "graphics/line4.png", 1080, 160,0)
    InitMySprite("line5", "graphics/line5.png", 1170, 160,0)
    InitMySprite("line6", "graphics/line6.png", 1270, 160,0)
    InitMySprite("line7", "graphics/line7.png", 1350, 160,0)
    InitMySprite("lineclipped", "graphics/line_clipped.png", 0, 160, 0)
    InitMySprite("scissors", "graphics/scissors.png", 0, 200, 0)
  ;  InitMySprite("container", "graphics/container.png", 760, 600)
    InitMySprite("failed", "graphics/failed.png", 760, 750, 0)
    InitMySprite("note1", "graphics/do.png", 0, 650, 0)
    InitMySprite("note2", "graphics/re.png", 0, 650, 0)
    InitMySprite("note3", "graphics/mi.png", 0, 650, 0)
    InitMySprite("note4", "graphics/fa.png", 0, 650, 0)
    InitMySprite("note5", "graphics/so.png", 0, 650, 0)
    InitMySprite("note6", "graphics/la.png", 0, 650, 0)
    InitMySprite("note7", "graphics/ti.png", 0, 650, 0)
    InitMySprite("bubble1", "graphics/bubble1.png", 0, 650, 0)
    InitMySprite("bubble2", "graphics/bubble2.png", 0, 650, 0)
    InitMySprite("bubble3", "graphics/bubble3.png", 0, 650, 0)
    InitMySprite("bubble4", "graphics/bubble4.png", 0, 650, 0)
    InitMySprite("bubble5", "graphics/bubble5.png", 0, 650, 0)
    InitMySprite("bubble6", "graphics/bubble6.png", 0, 650, 0)
    InitMySprite("bubble7", "graphics/bubble7.png", 0, 650, 0)
    InitMySprite("ant", "graphics/ant.png", 700, 630,0)
    InitMySprite("antmove", "graphics/antmove.png", 700, 630, 0)
    InitMySprite("correct","graphics/correct.png", 500,500,0)
    InitMySprite("incorrect","graphics/incorrect.png", 500,500,0)
    InitMySprite("script_box","graphics/script_box.png", 500,500,0)
    InitMySprite("highlight2","graphics/highlight2.png", 700,200,0)
    
    
    
    line_position(0) = 800
    line_position(1) = 890
    line_position(2) = 990
    line_position(3) = 1080
    line_position(4) = 1170
    line_position(5) = 1270
    line_position(6) = 1350
    
    x_note1 = 780
    x_note2 = 830
    y_note1 = 620
    
    ; 문제 스프라이트 세팅
  ;  If stageNum = 1
  ;    *p.mySprite =  FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
  ;    SetMySprite(*p, x_note1, y_note1, 1)
  ;    elements(0) = *p
  ;    *p = FindSprite("bubble" + chord_list(currentProblem(0), currentProblem(2)))
  ;    SetMySprite(*p, x_note2, y_note1, 1)
  ;    elements(1) = *p
  ;  ElseIf stageNum = 2
  ;    *p.mySprite =  FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
  ;    SetMySprite(*p, x_note1, y_note1, 1)
  ;    elements(0) = *p
  ;  EndIf
    
    ; 애니메이션 스프라이트 세팅
  ;  *p = FindSprite("antmove")
  ;  *p\f_horizontal = 4
  ;  *p\f_width = *p\width / 4
  ;  *p\f_height = *p\height
  ;  *p = FindSprite("scissors")
  ;  *p\f_horizontal = 2
  ;  *p\f_width = *p\width / 2
  ;  *p\f_height = *p\height
    
    ClearScreen(RGB(255, 255, 255))
    
    testN = 1
    
    Repeat
      *image = cvQueryFrame(*capture)
      testN = testN + 1
    Until testN = 10
    
    
    Repeat
      
      If  Tutorial_State = #Tutorial_GameInPlay
      
      
      *image = cvQueryFrame(*capture)
      
      If *image
        cvFlip(*image, #Null, 1)
         
        ; 프레임 넘기기
        currentTime = GetTickCount_()
        ForEach sprite_list()
          FrameManager(sprite_list()) ;active 상태인 것들만 다음 프레임으로
        Next
        
        ; 렌더링
        ForEach sprite_list()
          DrawMySprite(sprite_list())
        Next
        
        Tutorial_play()
        ;키보드 이벤트
        ExamineKeyboard()
        If KeyboardReleased(#PB_Key_1) And Tuto_Lock_5 
          keyInput = #PB_Key_1
          GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
          marker1X = mouse_x
          marker1Y = mouse_y - (WindowHeight(0)/2 - 200)
          If (markerState = 1)
            If  Tuto_Lock_15 = #False 
            CheckArea_Tutorial(keyInput)
            ElseIf    Tuto_Lock_15 
            CheckArea_Lv2(keyInput)
            EndIf 
          EndIf
        EndIf
        If KeyboardReleased(#PB_Key_2)  And Tuto_Lock_6
          keyInput = #PB_Key_2
          GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
          marker2X = mouse_x
          marker2Y = mouse_y - (WindowHeight(0)/2 - 200)
          If (markerState = 1)
            If  Tuto_Lock_15 = #False 
            CheckArea_Tutorial(keyInput)
            ElseIf    Tuto_Lock_15 
            CheckArea_Lv2(keyInput)
            EndIf 
          EndIf
        EndIf
        If KeyboardReleased(#PB_Key_Space) And Tuto_Lock_10 ; 전환가능하도록햇음
          If  markerState = 1
            markerState = 0
          ElseIf  markerState = 0
            markerState = 1
          EndIf 
        EndIf
    ;    If KeyboardReleased(#PB_Key_3)
    ;      PlayChordSound()
    ;    EndIf 
    ;    If KeyboardReleased(#PB_Key_4)
    ;      RemoveAnswer()
    ;    EndIf 
        If KeyboardPushed(#PB_Key_Left) ; 
        If Tutorial_Num > 0
          Tutorial_Num = Tutorial_Num - 1  
          Delay(100)
        EndIf   
        EndIf 
      
        If KeyboardPushed(#PB_Key_Right) ; 
          Tutorial_Num = Tutorial_Num + 1  
          Delay(200)
        EndIf 
      
      
        If KeyboardPushed(#PB_Key_P) ; PAUSE
        Tutorial_State = #Tutorial_GameInPause  
        EndIf 

         If  Tuto_Lock_15 = #False 
          DrawBoxs(*image)
        
        ElseIf  Tuto_Lock_15
        DrawBoxs_Lv2(*image)
        EndIf 
        
        
      Debug Str(ptBox(0,0)\x) + "    " + Str(ptBox(0,0)\y) 
      *mat.CvMat = cvEncodeImage(".bmp", *image, 0)     
      Result = CatchImage(1, *mat\ptr)
      SetGadgetState(0, ImageID(1))     
      cvReleaseMat(@*mat)  
      
      Font40 = LoadFont(#PB_Any, "Impact", 40) 
      
     If markerState = 0
     StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
     DrawText(1040, 100, "마커모드 : 상자조절" , RGB(255,255,255))
     StopDrawing()
      
     ElseIf  markerState =1 
          StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
     DrawText(1040, 100, "마커모드 : 음 입력모드" , RGB(255,255,255))
     StopDrawing()
     EndIf  
      
     
     
     If Tutorial_Num = 0
     StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
     DrawText(1300+2*Sin(x), 150, "다음" , RGB(255,255,255))
   ;  DrawText(100-2*Sin(x), 150, "이전" , RGB(255,255,255))
     StopDrawing()
     ElseIf Tutorial_Num >=20
          StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
   ;  DrawText(1300+2*Sin(x), 150, "다음" , RGB(255,255,255))
     DrawText(100-2*Sin(x), 150, "이전" , RGB(255,255,255))
     StopDrawing()
   Else
               StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
     DrawText(1300+2*Sin(x), 150, "다음" , RGB(255,255,255))
     DrawText(100-2*Sin(x), 150, "이전" , RGB(255,255,255))
     StopDrawing()
     EndIf  
     
     x+1
     
     
     
     
     
     
      
     FlipBuffers()
     
     If  KeyboardPushed(#PB_Key_0) And Tutorial_State = #Tutorial_GameInPlay;Escape
          
            FreeImage(pbImage)
            cvReleaseCapture(@*capture)
          midiOutReset_(hMidiOut)
          midiOutClose_(hMidiOut)
          CloseWindow(1)
        EndIf 
      EndIf
     
         ElseIf Tutorial_State = #Tutorial_GameInPause      
      GamePause()      
    EndIf 
     
     
    Until WindowEvent() = #PB_Event_CloseWindow Or (KeyboardPushed(#PB_Key_0) And Tutorial_State = #Tutorial_GameInPlay)
  EndIf
  
  
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf

EndProcedure




; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 421
; FirstLine = 291
; Folding = 5
; EnableXP
; DisableDebugger
;IncludeFile "includes/cv_functions.pbi"


; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력, 키보드 3으로 정답 화음 재생


Global LEVEL1_State

Enumeration InGameStatus
  #Stage_Intro
  #Status1_GameInPlay
  #Status1_GameInPause
EndEnumeration



Structure mySprite
  sprite_id.i
  sprite_name.s
  filename.s
  
  x.i   ; 위치 x
  y.i   ; 위치 y
  width.i   ; 전체 가로 사이즈
  height.i  ; 전체 세로 사이즈
  
  present.i ; 현재 프레임
  frametime.i ; 프레임 넘길 타이밍
  
  f_width.i ; 한 프레임의 가로 사이즈
  f_height.i; 한 프레임의 세로 사이즈
  f_horizontal.i   ; 가로 프레임 수
  f_vertical.i     ; 세로 프레임 수
  
  active.i  ; 0(invisible)or 1(visible)
EndStructure

Structure myPosition
  *sprite.mySprite
  
  xmove.i
  ymove.i
  xmax.i
  ymax.i
  startdelay.i
  frametime.i
EndStructure

Structure Problem
  note1.i
  note2.i
  answer.i
EndStructure



Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, answerTone.i, currentTime, currentProblem.i
Global.l hMidiOut
Global Dim ptBox.CvPoint(7, 4)
Global NewList sprite_list.mySprite()
Global NewList position_list.myPosition()
Global Dim problem_list.Problem(17)
Global Dim PosLine(6)

Procedure DrawMySprite(*this.mySprite)
  If *this\active = 1
    ; 일반 스프라이트
    DisplayTransparentSprite(*this\sprite_id, *this\x, *this\y)
  EndIf
  
EndProcedure







;이미지 프레임 넘기는 함수
Procedure FrameManager(*this.mySprite)
  If *this\active = 1 And *this\f_horizontal > 1
    If *this\present = -1
      *this\frameTime = currentTime + 100
      *this\present = 0
      ClipSprite(*this\sprite_id, *this\present * *this\f_width, 0, *this\f_width, *this\f_height)
      *this\present = 1
    EndIf
    
    If *this\frameTime <= currentTime
      ClipSprite(*this\sprite_id, *this\present * *this\f_width, 0, *this\f_width, *this\f_height)
      *this\frameTime = currentTime + 100
      If *this\present = *this\f_horizontal - 1
        *this\present = 0
      Else
        *this\present = *this\present + 1
      EndIf
      
    EndIf 
  EndIf
EndProcedure


Procedure InitMySprite(name.s, filename.s, x.i, y.i, active.i = 1) ;active는 옵션
                                                                   ; 스프라이트 구조체 초기화
  CreateSprite(#PB_Any, width, height)
  mysprite = LoadSprite(#PB_Any, filename.s)
  *newsprite.mySprite = AddElement(sprite_list())
  
  *newsprite\sprite_id = mysprite
  *newsprite\sprite_name = name
  *newsprite\filename = filename
  
  *newsprite\width = SpriteWidth(mysprite)
  *newsprite\height = SpriteHeight(mysprite)
  
  *newsprite\f_width = SpriteWidth(mysprite)
  *newsprite\f_height = SpriteHeight(mysprite)
  *newsprite\present = -1 ; TODO
  
  *newsprite\x = x
  *newsprite\y = y
  
  *newsprite\f_horizontal = Int(width/f_width)
  *newsprite\f_vertical = Int(height/f_height)
  
  *newsprite\active = active  ; default : visible
  
EndProcedure

;스프라이트 좌표값, 활성화여부 변경
Procedure SetMySprite(*sprite.mySprite, x.i, y.i, active.i)
  *sprite\x = x
  *sprite\y = y
  *sprite\active = active
EndProcedure

;myPosition 초기화
Procedure InitMyPosition(*sprite.mySprite, xmove.i, ymove.i, xmax.i, ymax.i, startdelay.i)
  *this.myPosition = AddElement(position_list())
  
  *this\sprite = *sprite
  *this\xmove = xmove
  *this\ymove = ymove
  *this\xmax = xmax
  *this\ymax = ymax
  *this\startdelay = startdelay
EndProcedure

; 문제 리스트 생성
Procedure InitProblem()
  problem_list(0)\note1 = 1
  problem_list(0)\note2 = 3
  problem_list(0)\answer = 5
  problem_list(1)\note1 = 2
  problem_list(1)\note2 = 4
  problem_list(1)\answer = 5
  problem_list(2)\note1 = 3
  problem_list(2)\note2 = 5
  problem_list(2)\answer = 7
  problem_list(3)\note1 = 1
  problem_list(3)\note2 = 4
  problem_list(3)\answer = 6
  problem_list(4)\note1 = 2
  problem_list(4)\note2 = 5
  problem_list(4)\answer = 7
  problem_list(5)\note1 = 1
  problem_list(5)\note2 = 3
  problem_list(5)\answer = 6
  
  problem_list(6)\note1 = 1
  problem_list(6)\note2 = 5
  problem_list(6)\answer = 3
  problem_list(7)\note1 = 2
  problem_list(7)\note2 = 5
  problem_list(7)\answer = 4
  problem_list(8)\note1 = 3
  problem_list(8)\note2 = 7
  problem_list(8)\answer = 5
  problem_list(9)\note1 = 1
  problem_list(9)\note2 = 6
  problem_list(9)\answer = 4
  problem_list(10)\note1 = 2
  problem_list(10)\note2 = 7
  problem_list(10)\answer = 5
  problem_list(11)\note1 = 1
  problem_list(11)\note2 = 6
  problem_list(11)\answer = 3
  
  problem_list(12)\note1 = 5
  problem_list(12)\note2 = 3
  problem_list(12)\answer = 1
  problem_list(13)\note1 = 5
  problem_list(13)\note2 = 4
  problem_list(13)\answer = 2
  problem_list(14)\note1 = 7
  problem_list(14)\note2 = 5
  problem_list(14)\answer = 3
  problem_list(15)\note1 = 6
  problem_list(15)\note2 = 4
  problem_list(15)\answer = 1
  problem_list(16)\note1 = 7
  problem_list(16)\note2 = 5
  problem_list(16)\answer = 2
  problem_list(17)\note1 = 6
  problem_list(17)\note2 = 3
  problem_list(17)\answer = 1
EndProcedure

; sprite_list 에서 이름으로 구조체 찾기
Procedure FindSprite(name.s)
  *returnStructure.mySprite
  
  ForEach sprite_list()
    If sprite_list()\sprite_name = name
      returnStructrue = sprite_list()
    EndIf 
  Next
  
  ProcedureReturn returnStructrue
EndProcedure

Procedure DeleteSprite(name.s)
  ForEach sprite_list()
    If sprite_list()\sprite_name = name
      DeleteElement(sprite_list())
    EndIf 
  Next
EndProcedure

;초기 화면구성으로 재설정하는 함수
Procedure InitialSetting()
  
  *p.mySprite = LastElement(sprite_list()) ;answer sprite
  DeleteElement(sprite_list())
  
  *q.mySprite = FindSprite("line"+Str(answerTone+1))
  *q\active = 1
  *q = FindSprite("lineclipped")
  *q\active = 0
  *q = FindSprite("scissors")
  *q\active = 0
  *q = FindSprite("ant")
  *q\x = 700
  *q\active = 1
  *q = FindSprite("antmove")
  *q\x = 700
  *q\active = 0
  *q\present = -1
  *q = FindSprite("container")
  *q\x = 760
  *q\active = 1
  *q = FindSprite("failed")
  *q\active = 0
  *q = FindSprite("bubble" + Str(problem_list(currentProblem)\note1))
  *q\x = 780
  *q\y = 620
  *q = FindSprite("bubble" + Str(problem_list(currentProblem)\note2))
  *q\x = 830
  *q\y = 620
EndProcedure 

Procedure ChangeProblem()
  *q.mySprite = FindSprite("bubble" + Str(problem_list(currentProblem)\note1))
  *q\active = 0
  *q.mySprite = FindSprite("bubble" + Str(problem_list(currentProblem)\note2))
  *q\active = 0
  currentProblem = Random(17)
  *q.mySprite = FindSprite("bubble" + Str(problem_list(currentProblem)\note1))
  *q\active = 1
  *q.mySprite = FindSprite("bubble" + Str(problem_list(currentProblem)\note2))
  *q\active = 1
EndProcedure

; 콘솔에 정답 여부 출력
Procedure AnswerCheck()
  isCorrect = #False
  
  If problem_list(currentProblem)\answer = answerTone+1
    PrintN("Correct")
    *q.mySprite = FindSprite("answer1")
    *q\active = 1
    isCorrect = #True
  Else
    PrintN("Wrong")
    *q.mySprite = FindSprite("container")
    *q\active = 0
    *q = FindSprite("failed")
    SetMySprite(*q, PosLine(answerTone), 660, 1)
    *q = FindSprite("bubble" + Str(problem_list(currentProblem)\note1))
    SetMySprite(*q, *q\x, 650, 1)
    *q = FindSprite("bubble" + Str(problem_list(currentProblem)\note2))
    SetMySprite(*q, *q\x + 20, 650, 1)
    *q = FindSprite("answer1")
    SetMySprite(*q, *q\x + 100, 650, 1)
  EndIf
  
  DeleteSprite("fruit1")
  ForEach sprite_list()
      DrawMySprite(sprite_list())
  Next
  FlipBuffers()
  
  ProcedureReturn isCorrect
EndProcedure

Procedure CalcBoxs()
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

Procedure DrawBoxs(*image)
  ; 박스 0-6이 있고 각 꼭짓점을 4개 만듦, 현재는 0과 2만 씀(좌상단과 우하단) 타입은 CvPoint
  cvLine(*image, ptBox(0, 0)\x, ptBox(0, 0)\y, ptBox(6, 2)\x, ptBox(6, 2)\y, 0, 255, 255, 0, 4, #CV_AA, #Null)
  
  ; 그리기 상태일 때 박스들의 좌표값을 계산한다.
  If markerState = 0
    CalcBoxs()
  EndIf
  
  ; 7개의 박스를 그린다
  count = 0
  Repeat
    cvRectangle(*image, ptBox(count, 0)\x, ptBox(count, 0)\y, ptBox(count, 2)\x, ptBox(count, 2)\y, 0, 0, 255, 0, 2, #CV_AA, #Null)
    count+1
  Until count >= 7
  
EndProcedure

Procedure CalcArea(x, y)
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

; 좌표값 옮겨주는 함수
Procedure ChangePos(*this.myPosition)
  If *this\startdelay > 0
    *this\startdelay = *this\startdelay - 1
    ProcedureReturn
  ElseIf  *this\startdelay = 0
    *this\frameTime = GetTickCount_() + 100
    *this\startdelay = -1
  ElseIf  *this\startdelay = -1     
    If *this\frameTime <= currentTime
      *this\sprite\x = *this\sprite\x + *this\xmove
      *this\sprite\y = *this\sprite\y + *this\ymove
      *this\frameTime = currentTime + 100
    EndIf 
  EndIf
 
  ; 좌표 이동 끝나면 리스트에서 제거
  If *this\sprite\x = *this\xmax Or *this\sprite\y = *this\ymax
    DeleteElement(position_list())
  EndIf 
  
  
EndProcedure

Procedure GetNote(note)
  result.i
  Select note
    Case 1
      result = 60
    Case 2
      result = 62
    Case 3
      result = 64
    Case 4
      result = 65
    Case 5
      result = 67
    Case 6
      result = 69
    Case 7
      result = 71
  EndSelect
  
  ProcedureReturn result
EndProcedure

Procedure PlayPianoSound(note)
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note) << 8 | 127 << 16 )
  Delay(500)
  midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note) << 8 | 0 << 16)
  
EndProcedure

;정답 화음 or 사용자가 입력한 화음을 재생
Procedure PlayChordSound(flag.i = 0)
  Dim note(2)
  note(0) = problem_list(currentProblem)\note1
  note(1) = problem_list(currentProblem)\note2
  
  ;flag = 0 (default)일 때 정답 화음 / 그 외엔 사용자 입력 화음 재생
  If flag = 0
    note(2) = problem_list(currentProblem)\answer
  Else
    note(2) = answerTone + 1
  EndIf 
  
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note(0)) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note(1)) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note(2)) << 8 | 127 << 16 )
  Delay(1000)
  midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note(0)) << 8 | 0 << 16)
  midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note(1)) << 8 | 0 << 16)
  midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note(2)) << 8 | 0 << 16)
  
EndProcedure

; 음 클릭 시 동작하는 애니메이션과 사운드 재생
Procedure DropNote()  
  
  y = 200
  x = PosLine(AnswerTone)
  
  *p.mySprite = FindSprite("line"+Str(answerTone+1))
  *p\active = 0
  *p = FindSprite("lineclipped")
  *p\active = 1
  *p\x = x+35
  *p = FindSprite("scissors")
  *p\x = x
  *p\active = 1
  
  *p = FindSprite("bubble" + Str(answerTone+1))
  *bubble.mySprite = AddElement(sprite_list())
  *bubble\sprite_id = CopySprite(*p\sprite_id, #PB_Any)
  *bubble\sprite_name = "answer1"
  SetMySprite(*bubble, x + 20, 670, 0)
  
  *p = FindSprite("note"+Str(answerTone+1))  
  *answer.mySprite = AddElement(sprite_list())
  *answer\sprite_id = CopySprite(*p\sprite_id, #PB_Any)
  *answer\sprite_name = "fruit1"
  SetMySprite(*answer, x + 20, 500, 1)
  
  *ant.mySprite = FindSprite("ant")
  *ant\active = 0
  *antmove.mySprite = FindSprite("antmove")
  *antmove\active = 1
  *container.mySprite = FindSprite("container")
  *note1.mySprite = FindSprite("bubble" + Str(problem_list(currentProblem)\note1))
  *note2.mySprite = FindSprite("bubble" + Str(problem_list(currentProblem)\note2))
  
  InitMyPosition(*answer, 0, 10, 0, 650, 0)
  InitMyPosition(*antmove, 10, 0, PosLine(answerTone) - 80, 0, 20)
  InitMyPosition(*container, 10, 0, PosLine(answerTone) - 20, 0, 20)
  InitMyPosition(*note1, 10, 0, PosLine(answerTone), 0, 20)
  InitMyPosition(*note2, 10, 0, PosLine(answerTone) + 50, 0, 20)
  
  Repeat
    ;좌표 이동
    currentTime = GetTickCount_()
    ForEach position_list()
      ChangePos(position_list())
    Next
    
    ;프레임 넘기기
    currentTime = GetTickCount_()
    ForEach sprite_list()
      FrameManager(sprite_list())
    Next
    
    ;렌더링
    ForEach sprite_list()
      DrawMySprite(sprite_list())
    Next
    FlipBuffers()
  Until ListSize(position_list()) = 0
  
  ;answer check
  isCorrect = AnswerCheck()
  PlayChordSound(1)
  Delay(2000)
  
  If isCorrect = #True
    ChangeProblem()
  EndIf 
  InitialSetting()
  
EndProcedure


Procedure CheckArea(key)
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
    answerTone = tone
    DropNote()
  EndIf
  
EndProcedure



; ==================================================PAUSE ====================================================

Enumeration Image3
  #Image_PAUSE
EndEnumeration

UsePNGImageDecoder()
LoadImage(#Image_PAUSE, "PAUSE.png")

Procedure GamePause()
  
  UsePNGImageDecoder()
  LoadImage(#Image_PAUSE, "PAUSE.png")
  
  ClearScreen(RGB(0, 200, 0))
  
    
      Font40 = LoadFont(#PB_Any, "System", 40,#PB_Font_Bold)
  
    
  StartDrawing(ScreenOutput())
  ;Box(0, 0, 600, 600, RGB(215, 73, 11))
  DrawImage(ImageID(#Image_PAUSE), 0, 0, 1920, 1080)  
  DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
      StopDrawing()
      ExamineKeyboard()
        If KeyboardPushed(#PB_Key_5)
          LEVEL1_State = #Status1_GameInPlay
        EndIf  
              
FlipBuffers() 


EndProcedure

;==================================================PAUSE =========================================================


Procedure Gamestage(StageNum)
  
  
  Font100 = LoadFont(#PB_Any, "System", 100)
     StartDrawing(ScreenOutput())
     ;Box(0, 0, 600, 600, RGB(215, 73, 11))
     ;DrawImage(ImageID(#Image_PAUSE), 0, 0, 1920, 1080)  
     DrawingMode(#PB_2DDrawing_Transparent)

     DrawingFont(FontID(Font100))
     DrawText(800, 500, "Stage" + StageNum, TextColor)
     StopDrawing()
     
     FlipBuffers()
     
     
     
      Delay(2000)
      
EndProcedure












Procedure CreateLevel1(SelectedStage)
  
  Shared MainWindow
  
  
Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(0)
Until nCreate = 5 Or *capture

If *capture
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  *image.IplImage : pbImage = CreateImage(#PB_Any, 640, 480)
  
  If MainWindow
    
    OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; 웹캠용 윈도우
    ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
    StickyWindow(1, #True) ; 항상 위에 고정
    SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(1), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; 윈도우 타이틀 바 제거
    
    
    ;Delay(2000) ; <------------------- Use this time to click the IDE window bar to set focus
    ;PostMessage_(WindowID(0),#WM_SYSCOMMAND, #SC_RESTORE, 0)
    SetForegroundWindow_(WindowID(0))
    InitSprite()
    InitKeyboard()
    
    ;Screen과 Sprite 생성
    ;OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0), WindowHeight(0))
    
    UsePNGImageDecoder()
    
    TransparentSpriteColor(#PB_Default, RGB(255, 0, 255))
    InitMySprite("background", "graphics/background.png", 0, 0)
    InitMySprite("line1", "graphics/line1.png", 800, 160)
    InitMySprite("line2", "graphics/line2.png", 890, 160)
    InitMySprite("line3", "graphics/line3.png", 990, 160)
    InitMySprite("line4", "graphics/line4.png", 1080, 160)
    InitMySprite("line5", "graphics/line5.png", 1170, 160)
    InitMySprite("line6", "graphics/line6.png", 1270, 160)
    InitMySprite("line7", "graphics/line7.png", 1350, 160)
    InitMySprite("lineclipped", "graphics/line_clipped.png", 0, 160, 0)
    InitMySprite("scissors", "graphics/scissors.png", 0, 200, 0)
    InitMySprite("container", "graphics/container.png", 760, 600)
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
    InitMySprite("ant", "graphics/ant.png", 700, 630)
    InitMySprite("antmove", "graphics/antmove.png", 700, 630, 0)
    
    PosLine(0) = 800
    PosLine(1) = 890
    PosLine(2) = 990
    PosLine(3) = 1080
    PosLine(4) = 1170
    PosLine(5) = 1270
    PosLine(6) = 1350
    
    x_note1 = 780
    x_note2 = 830
    y_note1 = 620
    
    currentProblem = Random(17) ; 문제 랜덤 선택
    
    *p.mySprite =  FindSprite("bubble" + Str(problem_list(currentProblem)\note1))
    SetMySprite(*p, x_note1, y_note1, 1)
    *p = FindSprite("bubble" + Str(problem_list(currentProblem)\note2))
    SetMySprite(*p, x_note2, y_note1, 1)
    *p = FindSprite("antmove")
    *p\f_horizontal = 4
    *p\f_width = *p\width / 4
    *p\f_height = *p\height
    *p = FindSprite("scissors")
    *p\f_horizontal = 2
    *p\f_width = *p\width / 2
    *p\f_height = *p\height
    
    ClearScreen(RGB(255, 255, 255))
    
    
    
    LEVEL1_State = #Stage_Intro
    
    Repeat
      
      If  LEVEL1_State = #Stage_Intro
      
        Gamestage(SelectedStage)
        LEVEL1_State = #Status1_GameInPlay
        

      ElseIf  LEVEL1_State = #Status1_GameInPlay
      
      
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
        
               ;키보드 이벤트
               ExamineKeyboard()
                If KeyboardReleased(#PB_Key_1)
                   keyInput = #PB_Key_1
                    GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
                   marker1X = mouse_x
                  marker1Y = mouse_y - (WindowHeight(0)/2 - 200)
                    If (markerState = 1)
                   CheckArea(keyInput)
                  EndIf
                  EndIf
                  If KeyboardReleased(#PB_Key_2)
                 keyInput = #PB_Key_2
                 GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
                   marker2X = mouse_x
                  marker2Y = mouse_y - (WindowHeight(0)/2 - 200)
                  If (markerState = 1)
                    CheckArea(keyInput)
                  EndIf
               EndIf
               If KeyboardReleased(#PB_Key_Space)
                  markerState = 1
              EndIf
                If KeyboardReleased(#PB_Key_3)
                  PlayChordSound()
                  EndIf 
        
        
                  EndIf
      
                  DrawBoxs(*image)
      
              *mat.CvMat = cvEncodeImage(".bmp", *image, 0)     
             Result = CatchImage(1, *mat\ptr)
             SetGadgetState(0, ImageID(1))     
               cvReleaseMat(@*mat)  
      
               FlipBuffers()
               

               
            ElseIf LEVEL1_State = #Status1_GameInPause   
                GamePause()
            EndIf  
            
            
            
            
           If KeyboardPushed(#PB_Key_0)
           ; SceneNumber = #StartScene
             cvReleaseCapture(@*capture)
          
            FreeImage(pbImage)
            ;cvReleaseCapture(@*capture)
            ForEach sprite_list()
            PrintN(sprite_list()\sprite_name)
            Next
         
           PrintN("뭐가문제니")
            midiOutReset_(hMidiOut)
            midiOutClose_(hMidiOut)
            CloseWindow(1)
            
            ElseIf KeyboardPushed(#PB_Key_4)
              LEVEL1_State = #Status1_GameInPause
  
          EndIf

    Until WindowEvent() = #PB_Event_CloseWindow Or KeyboardPushed(#PB_Key_0)
  EndIf
  
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf
  
  EndProcedure
  
  
  
 ; CreateLevel1()



; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 739
; FirstLine = 725
; Folding = ----
; EnableXP
; DisableDebugger
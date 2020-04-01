IncludeFile "../OpenCV_32/includes/cv_functions.pbi"

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력

;-- TODO
; 문제 데이터에서 읽기 (csv)
; 개미 있을 때 화음 출력하면 개미 지우기
; 리스트에서 삭제?
; 재생

Structure mySprite
  sprite_id.i
  sprite_name.s
  filename.s
  
  x.i   ; 위치 x
  y.i   ; 위치 y
  width.i   ; 전체 가로 사이즈
  height.i  ; 전체 세로 사이즈
  
  present.i; 현재 프레임
  frametime.i
  
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

Enumeration Codes
  #CODE_C
  #CODE_G
  #CODE_F
  #CODE_Am
  #CODE_Dm
  #CODE_Em
EndEnumeration

Structure Note
  note.i
  length.f
EndStructure

Structure Bar
  noteCount.i
  Array note.Note(8)
EndStructure

Structure Problem_Lv2
  Array bars.Bar(8)
  Array answers.i(8)
EndStructure

Global Window_0, Screen_0, Window_1
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, answerTone, threadStatus, currentThread, currentTime, currentProblem.i
Global Dim ptBox.CvPoint(6, 4)
Global NewList sprite_list.mySprite()
Global NewList position_list.myPosition()
Global Dim problem_list.Problem_Lv2(1)
Global.l hMidiOut

Global currentBar.i
Global Dim userAnswers.i(8)
Global MaxBar = 8 ; 최대 8마디
Global Lv2_antX = 700
Global Lv2_antY = 630
Global Lv2_noteY = 610
Global Lv2_contX = 560
Global Lv2_contY = 600

Procedure DrawMySprite(*this.mySprite)
  If *this\active = 1
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
    EndIf
    
    If *this\frameTime <= currentTime
      ClipSprite(*this\sprite_id, *this\present * *this\f_width, 0, *this\f_width, *this\f_height)
      *this\frameTime = currentTime + 100
      *this\present = *this\present + 1
      If *this\present = *this\f_horizontal - 1
        *this\present = 0
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
  *newsprite\present = -1
  
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
  If *this\sprite\x = *this\xmax Or *this\sprite\y = *this\ymax
    
    DeleteElement(position_list())
  EndIf 
EndProcedure

; sprite_list 에서 이름으로 구조체 찾기. 퓨베 특성상 current element 이슈 때문에 도중에 일치해도 끝까지 루프를 돌아야함
Procedure FindSprite(name.s)
  *returnStructure.mySprite
  
  ForEach sprite_list()
    If sprite_list()\sprite_name = name
      returnStructrue = sprite_list()
    EndIf 
  Next
  
  ProcedureReturn returnStructrue
EndProcedure

;-- 여기까지 안건들임

Procedure InitProblem_Lv2()
  
  problem.Problem_Lv2
  
  problem\bars(0)\noteCount = 4
  problem\bars(0)\note(0)\note = 3:   problem\bars(0)\note(0)\length = 1.5
  problem\bars(0)\note(1)\note = 2:   problem\bars(0)\note(1)\length = 0.5
  problem\bars(0)\note(2)\note = 1:   problem\bars(0)\note(2)\length = 1
  problem\bars(0)\note(3)\note = 2:   problem\bars(0)\note(3)\length = 1
  
  problem\bars(1)\noteCount = 3
  problem\bars(1)\note(0)\note = 3:   problem\bars(1)\note(0)\length = 1
  problem\bars(1)\note(1)\note = 3:   problem\bars(1)\note(1)\length = 1
  problem\bars(1)\note(2)\note = 3:   problem\bars(1)\note(2)\length = 2
  
  problem\bars(2)\noteCount = 3
  problem\bars(2)\note(0)\note = 2:   problem\bars(2)\note(0)\length = 1
  problem\bars(2)\note(1)\note = 2:   problem\bars(2)\note(1)\length = 1
  problem\bars(2)\note(2)\note = 2:   problem\bars(2)\note(2)\length = 2
  
  problem\bars(3)\noteCount = 3
  problem\bars(3)\note(0)\note = 3:   problem\bars(3)\note(0)\length = 1
  problem\bars(3)\note(1)\note = 3:   problem\bars(3)\note(1)\length = 1
  problem\bars(3)\note(2)\note = 3:   problem\bars(3)\note(2)\length = 2
  
  problem\bars(4)\noteCount = 4
  problem\bars(4)\note(0)\note = 3:   problem\bars(4)\note(0)\length = 1.5
  problem\bars(4)\note(1)\note = 2:   problem\bars(4)\note(1)\length = 0.5
  problem\bars(4)\note(2)\note = 1:   problem\bars(4)\note(2)\length = 1
  problem\bars(4)\note(3)\note = 2:   problem\bars(4)\note(3)\length = 1
  
  problem\bars(5)\noteCount = 3
  problem\bars(5)\note(0)\note = 3:   problem\bars(5)\note(0)\length = 1
  problem\bars(5)\note(1)\note = 3:   problem\bars(5)\note(1)\length = 1
  problem\bars(5)\note(2)\note = 3:   problem\bars(5)\note(2)\length = 2
  
  problem\bars(6)\noteCount = 4
  problem\bars(6)\note(0)\note = 2:   problem\bars(6)\note(0)\length = 1
  problem\bars(6)\note(1)\note = 2:   problem\bars(6)\note(1)\length = 1
  problem\bars(6)\note(2)\note = 3:   problem\bars(6)\note(2)\length = 1
  problem\bars(6)\note(3)\note = 2:   problem\bars(6)\note(3)\length = 1
  
  problem\bars(7)\noteCount = 1
  problem\bars(7)\note(0)\note = 1:   problem\bars(7)\note(0)\length = 4
  
  problem\answers(0) = #CODE_C
  problem\answers(1) = #CODE_C
  problem\answers(2) = #CODE_C
  problem\answers(3) = #CODE_C
  problem\answers(4) = #CODE_C
  problem\answers(5) = #CODE_C
  problem\answers(6) = #CODE_C
  problem\answers(7) = #CODE_C
  
  problem_list(0) = problem
  problem_list(1) = problem
  
EndProcedure

;-- 초기 화면구성으로 재설정하는 함수
Procedure InitialSetting_Lv2()
  
  ForEach sprite_list()
    *p.mySprite = sprite_list()
;     PrintN("1 : " + Str(@sprite_list()))
    position1 = FindString(*p\sprite_name, "note")
    position2 = FindString(*p\sprite_name, "ant")
    position3 = FindString(*p\sprite_name, "container")
    position4 = FindString(*p\sprite_name, "barMarker")
    If position1 <> 0 Or position2 <> 0 Or position3 <> 0 Or position4 <> 0
;       PrintN("2 : " + Str(@sprite_list()))
      ;       DeleteElement(sprite_list())
      SetMySprite(*p, 0, 0, 0)
    EndIf
  Next
  
EndProcedure 

Procedure AnswerCheck_Lv2()
  For i=0 To MaxBar-1
    answer = problem_list(currentProblem)\answers(i)
    input = userAnswers(i)
    If answer = input
      PrintN(Str(i+1) + "번째 마디 정답")
    Else
      PrintN(Str(i+1) + "번째 마디 오답")
    EndIf
  Next
EndProcedure

Procedure CalcCodeBoxs()
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
    ptLength = (ptRight-ptLeft)/6
    direction = 0
  Else
    ptLength = (ptBottom-ptTop)/6
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
  Until count >= 6
  
EndProcedure

Procedure DrawButtons(*image)
  
  font1.CvFont : cvInitFont(@font1, #CV_FONT_HERSHEY_SIMPLEX, 1.5, 1.5, #Null, 1, #CV_AA)
  font2.CvFont : cvInitFont(@font2, #CV_FONT_HERSHEY_SIMPLEX, 1.0, 1.0, #Null, 3, #CV_AA)
  
  cvRectangle(*image, 600, 400, 700, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  
  cvPutText(*image, ">", 600, 450, @font2, 255, 255, 0, 0) ; 재생
  
EndProcedure

Procedure DrawBoxs(*image)
  ; 박스 0-5이 있고 각 꼭짓점을 4개 만듦, 현재는 0과 2만 씀(좌상단과 우하단) 타입은 CvPoint
  cvLine(*image, ptBox(0, 0)\x, ptBox(0, 0)\y, ptBox(5, 2)\x, ptBox(5, 2)\y, 0, 255, 255, 0, 4, #CV_AA, #Null)
  
  ; 그리기 상태일 때 박스들의 좌표값을 계산한다.
  If markerState = 0
    CalcCodeBoxs()
  EndIf
  
  ; 6개의 박스를 그린다
  count = 0
  Repeat
    cvRectangle(*image, ptBox(count, 0)\x, ptBox(count, 0)\y, ptBox(count, 2)\x, ptBox(count, 2)\y, 0, 0, 255, 0, 2, #CV_AA, #Null)
    count+1
  Until count >= 6
  
EndProcedure

Procedure GetNote_Lv2(note.s)
  result.i
  Select note
    Case "do"
      result = 60
    Case "re"
      result = 62
    Case "mi"
      result = 64
    Case "fa"
      result = 65
    Case "so"
      result = 67
    Case "la"
      result = 69
    Case "ti"
      result = 71
  EndSelect
  
  ProcedureReturn result
EndProcedure

Procedure CalcCodeArea(x, y)
  code = -1
  i = 0
  Repeat
    If (ptBox(i, 0)\x < x) And (ptBox(i, 2)\x > x)
      If (ptBox(i, 0)\y < y) And (ptBox(i, 2)\y > y)
        code = i
        Break
      EndIf
    EndIf
    i + 1
  Until i >= 6
  
  ProcedureReturn code ; 코드를 반환
EndProcedure


Procedure MoveAnt_Lv2()
  Repeat
    currentTime = GetTickCount_()
    ForEach position_list()
      ChangePos(position_list())
    Next
    currentTime = GetTickCount_()
    ForEach sprite_list()
      FrameManager(sprite_list()) ;active 상태인 것들만 다음 프레임으로
    Next
    ForEach sprite_list()
      DrawMySprite(sprite_list())
    Next
    FlipBuffers()
  Until ListSize(position_list()) = 0
  
EndProcedure

Procedure MakeAnt(code.i, bar.i, state.i)
  
  b.i
  
  If state = 0 ; static
    b = bar
    ; 비료
    InitMySprite("container"+Str(b), "../graphics/container.png", Lv2_contX, Lv2_contY)
    
  Else         ; moving
    b = currentBar
    InitMySprite("antmove"+Str(b), "../graphics/antmove.png", Lv2_antX-200, Lv2_antY)
    *p.mySprite = FindSprite("antmove"+Str(b))
    *p\f_horizontal = 4
    *p\f_width = 65
    *p\f_height = 69
    InitMyPosition(*p, 10, 0, Lv2_antX, 0, 20)
    
    ; 비료
    InitMySprite("container"+Str(b), "../graphics/container.png", Lv2_contX, Lv2_contY)
    *p2.mySprite = FindSprite("container"+Str(b))
    InitMyPosition(*p2, 10, 0, Lv2_antX+60, 0, 20)
  EndIf
  
  ;공통
  userAnswers(b) = code.i
  
  note0X = Lv2_antX-200+70
  note0Y = Lv2_noteY
  note1X = Lv2_antX-200+110
  note1Y = Lv2_noteY
  note2X = Lv2_antX-200+90
  note2Y = Lv2_noteY+40
  note0.s: note1.s: note2.s
  
  Select code
    Case #CODE_C
      note0 = "do":      note1 = "mi":      note2 = "so"
    Case #CODE_G
      note0 = "so":      note1 = "ti":      note2 = "re"
    Case #CODE_F
      note0 = "fa":      note1 = "la":      note2 = "do"
    Case #CODE_Am
      note0 = "la":      note1 = "do":      note2 = "mi"
    Case #CODE_Dm
      note0 = "re":      note1 = "fa":      note2 = "la"
    Case #CODE_Em
      note0 = "mi":      note1 = "so":      note2 = "ti"
  EndSelect
  
  InitMySprite("note"+Str(currentBar)+"\0", "../graphics/"+note0+".png", note0X, note0Y)
  InitMySprite("note"+Str(currentBar)+"\1", "../graphics/"+note1+".png", note1X, note1Y)
  InitMySprite("note"+Str(currentBar)+"\2", "../graphics/"+note2+".png", note2X, note2Y)
  
  *n0 = FindSprite("note"+Str(currentBar)+"\0")
  *n1 = FindSprite("note"+Str(currentBar)+"\1")
  *n2 = FindSprite("note"+Str(currentBar)+"\2")
  
  If state = 0 ; static
    
  Else         ; moving
    InitMyPosition(*n0, 10, 0, Lv2_antX+70, 0, 20)
    InitMyPosition(*n1, 10, 0, Lv2_antX+110, 0, 20)
    InitMyPosition(*n2, 10, 0, Lv2_antX+90, 0, 20)
    
    ; 소리 출력
    midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note0) << 8 | 127 << 16 )
    midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note1) << 8 | 127 << 16 )
    midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note2) << 8 | 127 << 16 )
    
    MoveAnt_Lv2()
    
    ; 개미 다 움직이면 끝나게
    midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note0) << 8 | 0 << 16 )
    midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note1) << 8 | 0 << 16 )
    midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note2) << 8 | 0 << 16 )
    
    *p\active = 0
  EndIf
  
  ;공통
  *p.mySprite = InitMySprite("ant"+Str(currentBar), "../graphics/ant.png", Lv2_antX, Lv2_antY)
  
EndProcedure

Procedure CheckArea_Lv2(key)
  
  code.i
  markerx.i
  markery.i
  If(key = #PB_Key_2)
    markerx = marker2X
    markery = marker2Y
  ElseIf(key = #PB_Key_1)
    markerx = marker1X
    markery = marker1Y
  EndIf
  
  code = CalcCodeArea(markerx, markery)
  
  ; 음이 도-시 사이인 경우만 출력
  If code >= #CODE_C And code <= #CODE_Em
    MakeAnt(code, 0, 1); moving
  EndIf
  
  If markery>400 And markerx>600
    ;     PrintN("----정답 체크----")
    AnswerCheck_Lv2()
  EndIf
  
EndProcedure

Procedure DrawBarMarker()
  posX = 100
  posY = 30
  For i=MaxBar-1 To 0 Step -1
    If i = currentBar
      InitMySprite("barMarker"+Str(i), "../graphics/re.png", posX+i*40, posY)
      ;       *p.mySprite = FindSprite("barMarker"+Str(i))
    Else
      InitMySprite("barMarker"+Str(i), "../graphics/fa.png", posX+i*40, posY)
    EndIf
  Next
  
EndProcedure

Procedure DrawNotes()
  
;   InitialSetting_Lv2()
  
  problem.Problem_Lv2 = problem_list(currentProblem)
  
  weight.f = 0.0
  distance.i = 790
  
  ; 배경 그려주기
  InitMySprite("background", "../graphics/background.png", 0, 0)
  
  DrawBarMarker()
  
  posX.i = distance
  posY.i = 160
  
  For b=currentBar To MaxBar-1
    
    bar.Bar = problem\bars(b)
    
    If userAnswers(b) <> -1
      MakeAnt(userAnswers(b), b, 0)
    EndIf
    
    If posX > WindowWidth(0)
      ; 화면에 넘치게 그려지면 더이상 그리지 않음
      Break
    EndIf
    
    For i=0 To bar\noteCount-1
      note.Note = bar\note(i)
      spriteName.s = "line" + Str(currentBar) + "/" + Str(i)
      ;     PrintN(Str(i) + " : " + Str(posX) + ", " + Str(posY) + " and " + Str(weight))
      InitMySprite(spriteName, "../graphics/line"+note\note+".png", posX, posY)
      
      ; 다음 음표를 위한 거리 가중치 (간격을 맞춰주기 위해)
      weight.f = note\length
      posX + Int(80*weight)
    Next
    
    If b <> MaxBar-1
      posX + 80
      InitMySprite("separator", "../graphics/line_clipped.png", posX, posY)
      posX + 80
    EndIf
    
  Next
  
EndProcedure

OpenConsole()

markerState = 0 ; 마커 입력 상태
threadStatus = 0; thread 상태. 0-실행안함, 1-실행중

InitProblem_Lv2()

;MIDI 설정
OutDev.l
result = midiOutOpen_(@hMidiOut, OutDev, 0, 0, 0)

Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(0)
Until nCreate = 5 Or *capture

If *capture
  FrameWidth = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_WIDTH)
  FrameHeight = cvGetCaptureProperty(*capture, #CV_CAP_PROP_FRAME_HEIGHT)
  *image.IplImage : pbImage = CreateImage(#PB_Any, 640, 480)
  
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
    TransparentSpriteColor(#PB_Default, RGB(255, 0, 255))
    
    InitMySprite("background", "../graphics/background.png", 0, 0)
    
    currentProblem = 0;-- Random(2)
    currentBar = 0
    For i=0 To MaxBar-1
      userAnswers(i) = -1
    Next
    
    DrawBarMarker()
    DrawNotes()
    
    ClearScreen(RGB(255, 255, 255))
    
    Repeat
      *image = cvQueryFrame(*capture)
      
      If *image
        cvFlip(*image, #Null, 1)
        
        currentTime = GetTickCount_()
        ForEach sprite_list()
          FrameManager(sprite_list()) ;active 상태인 것들만 다음 프레임으로
        Next
        
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
            CheckArea_Lv2(keyInput)
          EndIf
        EndIf
        
        If KeyboardReleased(#PB_Key_2)
          keyInput = #PB_Key_2
          GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
          marker2X = mouse_x
          marker2Y = mouse_y - (WindowHeight(0)/2 - 200)
          If (markerState = 1)
            CheckArea_Lv2(keyInput)
          EndIf
        EndIf
        
        If KeyboardReleased(#PB_Key_Space)
          markerState = 1
        EndIf
        
        If KeyboardReleased(#PB_Key_Left)
          ; 이전 마디로 이동
          If currentBar > 0
            currentBar-1
            DrawNotes()
          EndIf
          
        EndIf
        
        If KeyboardReleased(#PB_Key_Right)
          ; 다음 마디로 이동
          If currentBar < MaxBar-1
            currentBar+1
            DrawNotes()
          EndIf
        EndIf
        
      EndIf
      DrawButtons(*image);-- 재생 버튼만 남김
      DrawBoxs(*image)
      
      *mat.CvMat = cvEncodeImage(".bmp", *image, 0)
      Result = CatchImage(1, *mat\ptr)
      SetGadgetState(0, ImageID(1))
      cvReleaseMat(@*mat)  
      
      FlipBuffers()
    Until WindowEvent() = #PB_Event_CloseWindow
  EndIf
  
  ForEach sprite_list()
    PrintN(sprite_list()\sprite_name)
    FreeStructure(sprite_list())
  Next
  
  ForEach position_list()
    FreeStructure(position_list())
  Next
  
  FreeStructure(problem_list())
  
  FreeImage(pbImage)
  cvReleaseCapture(@*capture)
  
  midiOutReset_(hMidiOut)
  midiOutClose_(hMidiOut)
  
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf

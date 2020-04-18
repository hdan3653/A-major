IncludeFile "../OpenCV_32/includes/cv_functions.pbi"
IncludeFile "ReadCSV.pb"

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 1: 가입력 2: 입력 3: 악보 재생하기
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력

;-- TODO
; 개미 있을 때 화음 출력하면 개미 지우기
; 힐끔 보이는 마디에서도 개미 출력하기 
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

Structure Code
  note0.i
  note1.i
  note2.i
EndStructure

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
Global Dim problem_list.Problem_Lv2(10)
Global problem_count.i = 0
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
    *this\frameTime = GetTickCount_() + 50
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

; ################## LEVEL 2 ##################

Procedure InitProblem_Lv2()
  
  NewList entry.CSVEntry()
  ReadCSVFile("problems.csv", ',', entry.CSVEntry(), #CSV_WithDoubleQuotes)
  
  Define cnt_i.i = 0  ; i
  Define cnt_j.i = 0  ; j
  Define prob.i = 0   ; 문제 번호
  
  ForEach entry()
    
    If (cnt_i+1)%9 = 0 And cnt_i <> 0
      count.i = 0
      ForEach entry()\Item()
        If entry()\Item() = ""
          Break
        EndIf
        
        problem_list(prob)\answers(count) = ValD(entry()\Item())
        count+1
      Next
      
      ;-- add to problem_list
      prob+1
      
    Else
      cnt_j = 0
      cnt_k = 0
      
      ForEach entry()\Item()
        If entry()\Item() = ""
          Break
        EndIf
        
        If cnt_j=0
          count = ValD(entry()\Item())
          problem_list(prob)\bars(cnt_i%9)\noteCount = count
        ElseIf cnt_j%2 = 1
          newnote.i = ValD(entry()\Item())
          problem_list(prob)\bars(cnt_i%9)\note(cnt_k)\note.i = newnote.i
        ElseIf cnt_j%2 = 0
          newlength.f = ValF(entry()\Item())
          problem_list(prob)\bars(cnt_i%9)\note(cnt_k)\length.f = newlength.f
          ; index increase
          cnt_k+1
        EndIf
        
        ; index increase
        cnt_j+1
        
      Next
    EndIf
    
    ; index increase
    cnt_i+1
  Next
  
  problem_count = proc
EndProcedure

Procedure CalcCodeBoxs_Lv2()
  ptLeft = 0  :   ptRight = 0
  ptTop = 0   :   ptBottom = 0
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

Procedure CalcCodeArea_Lv2(x, y)
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

Procedure DrawBoxs(*image)
  ; 박스 0-5이 있고 각 꼭짓점을 4개 만듦, 현재는 0과 2만 씀(좌상단과 우하단) 타입은 CvPoint
  cvLine(*image, ptBox(0, 0)\x, ptBox(0, 0)\y, ptBox(5, 2)\x, ptBox(5, 2)\y, 0, 255, 255, 0, 4, #CV_AA, #Null)
  
  ; 그리기 상태일 때 박스들의 좌표값을 계산한다.
  If markerState = 0
    CalcCodeBoxs_Lv2()
  EndIf
  
  ; 6개의 박스를 그린다
  count = 0
  Repeat
    cvRectangle(*image, ptBox(count, 0)\x, ptBox(count, 0)\y, ptBox(count, 2)\x, ptBox(count, 2)\y, 0, 0, 255, 0, 2, #CV_AA, #Null)
    count+1
  Until count >= 6
  
EndProcedure

Procedure GetNote_Lv2(note.i)
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

Procedure GetCode(code.i, *note.Code)
  Select code
    Case #CODE_C  :          *note\note0 = 1:      *note\note1 = 3:      *note\note2 = 5
    Case #CODE_G  :          *note\note0 = 5:      *note\note1 = 7:      *note\note2 = 2
    Case #CODE_F  :          *note\note0 = 4:      *note\note1 = 6:      *note\note2 = 1
    Case #CODE_Am :          *note\note0 = 6:      *note\note1 = 1:      *note\note2 = 3
    Case #CODE_Dm :          *note\note0 = 2:      *note\note1 = 4:      *note\note2 = 6
    Case #CODE_Em :          *note\note0 = 3:      *note\note1 = 5:      *note\note2 = 7
  EndSelect  
EndProcedure

Procedure StaticAnt_Lv2(bar.i)
  b.i
  b = bar
  code = userAnswers(b)
  
  ; 비료
  InitMySprite("container"+Str(b), "../graphics/container.png", Lv2_antX+60, Lv2_contY)
  
  note0X = Lv2_antX+85
  note0Y = Lv2_noteY+20
  note1X = Lv2_antX+125
  note1Y = Lv2_noteY+20
  note2X = Lv2_antX+105
  note2Y = Lv2_noteY+60
  note.Code
  
  GetCode(code, @note)
  
  InitMySprite("note"+Str(currentBar)+"\0", "../graphics/bubble"+Str(note\note0)+".png", note0X, note0Y)
  InitMySprite("note"+Str(currentBar)+"\1", "../graphics/bubble"+Str(note\note1)+".png", note1X, note1Y)
  InitMySprite("note"+Str(currentBar)+"\2", "../graphics/bubble"+Str(note\note2)+".png", note2X, note2Y)
  
  *n0 = FindSprite("note"+Str(currentBar)+"\0")
  *n1 = FindSprite("note"+Str(currentBar)+"\1")
  *n2 = FindSprite("note"+Str(currentBar)+"\2")
  
  *p.mySprite = InitMySprite("ant"+Str(currentBar), "../graphics/ant.png", Lv2_antX, Lv2_antY)
  
EndProcedure

Procedure MovingAnt_Lv2(code.i, bar.i)
  
  b = currentBar
  ; 비료
  InitMySprite("container"+Str(b), "../graphics/container.png", Lv2_contX, Lv2_contY)
  *p2.mySprite = FindSprite("container"+Str(b))
  InitMyPosition(*p2, 10, 0, Lv2_antX+60, 0, 20)
  
  InitMySprite("antmove"+Str(b), "../graphics/antmove.png", Lv2_antX-200, Lv2_antY)
  *p.mySprite = FindSprite("antmove"+Str(b))
  *p\f_horizontal = 4
  *p\f_width = *p\width/4
  InitMyPosition(*p, 10, 0, Lv2_antX, 0, 20)
  
  ;공통
  userAnswers(b) = code.i
  
  note0X = Lv2_antX-200+85
  note0Y = Lv2_noteY+20
  note1X = Lv2_antX-200+125
  note1Y = Lv2_noteY+20
  note2X = Lv2_antX-200+105
  note2Y = Lv2_noteY+60
  
  note.Code
  GetCode(code, @note)
  
  InitMySprite("note"+Str(currentBar)+"\0", "../graphics/bubble"+Str(note\note0)+".png", note0X, note0Y)
  InitMySprite("note"+Str(currentBar)+"\1", "../graphics/bubble"+Str(note\note1)+".png", note1X, note1Y)
  InitMySprite("note"+Str(currentBar)+"\2", "../graphics/bubble"+Str(note\note2)+".png", note2X, note2Y)
  
  *n0 = FindSprite("note"+Str(currentBar)+"\0")
  *n1 = FindSprite("note"+Str(currentBar)+"\1")
  *n2 = FindSprite("note"+Str(currentBar)+"\2")
  
  InitMyPosition(*n0, 10, 0, Lv2_antX+85, 0, 20)
  InitMyPosition(*n1, 10, 0, Lv2_antX+125, 0, 20)
  InitMyPosition(*n2, 10, 0, Lv2_antX+105, 0, 20)
  
  ; 소리 출력
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note\note0) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note\note1) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note\note2) << 8 | 127 << 16 )
  
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
  
  ; 개미 다 움직이면 끝나게
  midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note\note0) << 8 | 0 << 16 )
  midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note\note1) << 8 | 0 << 16 )
  midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note\note2) << 8 | 0 << 16 )
  
  *p\active = 0
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
  
  code = CalcCodeArea_Lv2(markerx, markery)
  
  ; 음이 도-시 사이인 경우만 출력
  If code >= #CODE_C And code <= #CODE_Em
    MovingAnt_Lv2(code, 0)
  EndIf
  
EndProcedure

Procedure DrawBarMarker_Lv2()
  posX = 100
  posY = 30
  For i=MaxBar-1 To 0 Step -1
    If i = currentBar
      InitMySprite("barMarker"+Str(i), "../graphics/bubble2.png", posX+i*40, posY)
    Else
      InitMySprite("barMarker"+Str(i), "../graphics/bubble4.png", posX+i*40, posY)
    EndIf
  Next
  
EndProcedure

Procedure DrawNotes_Lv2()
  ;-- TODO DrawNote
;   ForEach sprite_list()
;     FindSprite("line"
;   Next
  
  problem.Problem_Lv2 = problem_list(currentProblem)
  
  weight.f = 0.0
  distance.i = 790
  
  ; 배경 그려주기
  InitMySprite("background", "../graphics/background.png", 0, 0)
  
  DrawBarMarker_Lv2()
  
  If userAnswers(currentBar) <> -1
    StaticAnt_Lv2(currentBar)
  EndIf
  
  posX.i = distance
  posY.i = 160
  
  For b=currentBar To MaxBar-1
    
    bar.Bar = problem\bars(b)
    
    If posX > WindowWidth(0)
      ; 화면에 넘치게 그려지면 더이상 그리지 않음
      Break
    EndIf
    
    For i=0 To bar\noteCount-1
      note.Note = bar\note(i)
      spriteName.s = "line" + Str(currentBar) + "/" + Str(i)
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

Procedure PlayNotes(parameter)
  
  beat.i = 500
  
  For i=0 To 7
    noteCount = problem_list(currentProblem)\bars(i)\noteCount
    
    For j=0 To noteCount-1
      note.i = problem_list(currentProblem)\bars(i)\note(j)\note
      lentgh.f = problem_list(currentProblem)\bars(i)\note(j)\length
      
      ; 화음
      PrintN(Str(i) + " : " + Str(userAnswers(i)))
      code.Code : code\note0 = -1 : code\note1 = -1 : code\note2 = -1
      If userAnswers(i) > -1 And userAnswers(i) < 6 And j = 0
        GetCode(userAnswers(i), @code)
        
        midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note0) << 8 | 127 << 16 )
        midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note1) << 8 | 127 << 16 )
        midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note2) << 8 | 127 << 16 )
      EndIf
      
      ; 화음과 겹치는 음은 빼고
      If note <> note0 And note <> note1 And note <> note2
        midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note) << 8 | 127 << 16 )
      EndIf
      
      temp.i = Int(lentgh*beat)
      Delay(temp)
      
      If note <> note0 And note <> note1 And note <> note2
        midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note) << 8 | 0 << 16 )    
      EndIf
      
      ; 화음
      If userAnswers(i) > -1 And userAnswers(i) < 6 And j = 0
        midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note0) << 8 | 0 << 16 )
        midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note1) << 8 | 0 << 16 )
        midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note2) << 8 | 0 << 16 )
      EndIf
      
    Next
  Next
  
  ; 정답 체크
  AnswerCheck_Lv2()
  
EndProcedure

OpenConsole()

markerState = 0 ; 마커 입력 상태
threadStatus = 0; thread 상태. 0-실행안함, 1-실행중

; @@
InitProblem_Lv2()

For i=0 To 7
  userAnswers(i) = 1
Next

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
    
    ;-- TODO random
    currentProblem = Random(1)
    PrintN("Problem Count is " + Str(problem_count))
    PrintN("Current Problem Number is " + Str(currentProblem))
    
    currentBar = 0
    For i=0 To MaxBar-1
      userAnswers(i) = -1
    Next
    
    DrawBarMarker_Lv2()
    DrawNotes_Lv2()
    
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
        
        If KeyboardReleased(#PB_Key_3)
          ; multi-thread
          CreateThread(@PlayNotes(), 0)
        EndIf
        
        If KeyboardReleased(#PB_Key_Space)
          markerState = 1
        EndIf
        
        If KeyboardReleased(#PB_Key_Left)
          ; 이전 마디로 이동
          If currentBar > 0
            currentBar-1
            DrawNotes_Lv2()
          EndIf
          
        EndIf
        
        If KeyboardReleased(#PB_Key_Right)
          ; 다음 마디로 이동
          If currentBar < MaxBar-1
            currentBar+1
            DrawNotes_Lv2()
          EndIf
        EndIf
        
      EndIf
      
      DrawBoxs(*image)
      
      *mat.CvMat = cvEncodeImage(".bmp", *image, 0)
      Result = CatchImage(1, *mat\ptr)
      SetGadgetState(0, ImageID(1))
      cvReleaseMat(@*mat)  
      
      FlipBuffers()
    Until WindowEvent() = #PB_Event_CloseWindow
  EndIf
  
  ; free memory
  FreeStructure(sprite_list())
  FreeStructure(position_list())
  FreeStructure(problem_list())
  
  FreeImage(pbImage)
  cvReleaseCapture(@*capture)
  
  midiOutReset_(hMidiOut)
  midiOutClose_(hMidiOut)
  
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf

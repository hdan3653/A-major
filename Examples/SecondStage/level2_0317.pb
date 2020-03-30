IncludeFile "../OpenCV_32/includes/cv_functions.pbi"

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력


;-- TODO
; 소리 출력
; 세세한 이미지 좌표 조정
; 정답 체크
; 문제 데이터에서 읽기

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
  #CODE_E
EndEnumeration

Structure Note
  note.i
  length.f
  posBar.i
  posNote.i
EndStructure

Structure Problem_Lv2
  note_count.i
  Array notes.Note(16)
  Array answers.i(8)
EndStructure

Global Window_0, Screen_0, Window_1
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, answerTone, threadStatus, currentThread, currentTime, currentProblem.i
Global Dim ptBox.CvPoint(7, 4)
Global NewList sprite_list.mySprite()
Global NewList position_list.myPosition()
Global Dim problem_list.Problem_Lv2(1)

Global currentBar.i
Global MaxBar = 8 ; 최대 8마디
Global Lv2_antX = 730
Global Lv2_antY = 630
Global Lv2_noteY = 610
Global Lv2_contX = 590
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

Procedure InitProblem()
  ;-- 파일 입출력으로 바꾸기
  ;   file = ReadFile(#PB_Any, "airplane.txt", #PB_UTF8)
  ;   
  ;   If file <> 0
  ;     While Eof(file) = 0
  ;       int.i = ReadInteger(file)
  ;       PrintN(Str(int))
  ;     Wend
  ;     CloseFile(file)
  ;   Else
  ;     PrintN("Open File Fail")
  ;   EndIf
  problem.Problem_Lv2
  
  ;미
  problem\notes(0)\posBar = 0 :  problem\notes(0)\posNote = 0
  problem\notes(0)\note = 3   :  problem\notes(0)\length = 1.5
  ;레
  problem\notes(1)\posBar = 0 :  problem\notes(1)\posNote = 1
  problem\notes(1)\note = 2   :  problem\notes(1)\length = 0.5
  ;도
  problem\notes(2)\posBar = 0 :  problem\notes(2)\posNote = 2
  problem\notes(2)\note = 1   :  problem\notes(2)\length = 1
  ;레
  problem\notes(3)\posBar = 0 :  problem\notes(3)\posNote = 3
  problem\notes(3)\note = 2   :  problem\notes(3)\length = 1
  
  ;미
  problem\notes(4)\posBar = 1 :  problem\notes(4)\posNote = 0
  problem\notes(4)\note = 3   :  problem\notes(4)\length = 1
  ;미
  problem\notes(5)\posBar = 1 :  problem\notes(5)\posNote = 1
  problem\notes(5)\note = 3   :  problem\notes(5)\length = 1
  ;미
  problem\notes(6)\posBar = 1 :  problem\notes(6)\posNote = 2
  problem\notes(6)\note = 3   :  problem\notes(6)\length = 2
  
  ;레
  problem\notes(7)\posBar = 2 :  problem\notes(7)\posNote = 0
  problem\notes(7)\note = 2   :  problem\notes(7)\length = 1
  ;레
  problem\notes(8)\posBar = 2 :  problem\notes(8)\posNote = 1
  problem\notes(8)\note = 2   :  problem\notes(8)\length = 1
  ;레
  problem\notes(9)\posBar = 2 :  problem\notes(9)\posNote = 2
  problem\notes(9)\note = 2   :  problem\notes(9)\length = 2
  
  ;미
  problem\notes(10)\posBar = 3 :  problem\notes(10)\posNote = 0
  problem\notes(10)\note = 3   :  problem\notes(10)\length = 1
  ;미
  problem\notes(11)\posBar = 3 :  problem\notes(11)\posNote = 1
  problem\notes(11)\note = 3   :  problem\notes(11)\length = 1
  ;미
  problem\notes(12)\posBar = 3 :  problem\notes(12)\posNote = 2
  problem\notes(12)\note = 3   :  problem\notes(12)\length = 2
  
  problem\answers(0) = #CODE_C
  problem\answers(1) = #CODE_G
  
  problem_list(0) = problem
  problem_list(1) = problem
  
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

;초기 화면구성으로 재설정하는 함수
Procedure InitialSetting()
  
  ;   *p.mySprite = LastElement(sprite_list()) ;answer sprite
  ;   DeleteElement(sprite_list())
  ;   
  ;   *q.mySprite = FindSprite("line"+Str(answerTone+1))
  ;   *q\active = 1
  ;   *q = FindSprite("lineclipped")
  ;   *q\active = 0
  ;   *q = FindSprite("scissors")
  ;   *q\active = 0
  ;   *q = FindSprite("ant")
  ;   *q\x = 730
  ;   *q\active = 1
  ;   *q = FindSprite("antmove")
  ;   *q\x = 730
  ;   *q\active = 0
  ;   *q\present = -1
  ;   *q = FindSprite("container")
  ;   *q\x = 790
  ; ;   *q = FindSprite("note" + Str(problem_list(currentProblem)\note1))
  ; ;   *q\x = 800
  ; ;   *q = FindSprite("note" + Str(problem_list(currentProblem)\note2))
  ; ;   *q\x = 840
EndProcedure 

Procedure AnswerCheck()
  ;   OpenConsole()
  ;   If problem_list(currentProblem)\answer = answerTone+1
  ;     PrintN("correct")
  ;   Else
  ;     PrintN("Wrong")
  ;   EndIf 
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

Procedure DrawButtons(*image)
  
  font1.CvFont : cvInitFont(@font1, #CV_FONT_HERSHEY_SIMPLEX, 1.5, 1.5, #Null, 1, #CV_AA)
  font2.CvFont : cvInitFont(@font2, #CV_FONT_HERSHEY_SIMPLEX, 1.0, 1.0, #Null, 3, #CV_AA)
  
  cvRectangle(*image, 0, 400, 100, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  cvRectangle(*image, 100, 400, 200, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  cvRectangle(*image, 200, 400, 300, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  cvRectangle(*image, 300, 400, 400, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  cvRectangle(*image, 400, 400, 500, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  cvRectangle(*image, 500, 400, 600, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  cvRectangle(*image, 600, 400, 700, 580, 0, 0, 255, 0, 2, #CV_AA, #Null)
  
  cvPutText(*image, "C", 35, 450, @font1, 255, 255, 0, 0)
  cvPutText(*image, "G", 130, 450, @font1, 255, 255, 0, 0)
  cvPutText(*image, "F", 240, 450, @font1, 255, 255, 0, 0)
  cvPutText(*image, "Am", 315, 450, @font1, 255, 255, 0, 0)
  cvPutText(*image, "Dm", 415, 450, @font1, 255, 255, 0, 0)
  cvPutText(*image, "E", 540, 450, @font1, 255, 255, 0, 0)
  cvPutText(*image, ">", 600, 450, @font2, 255, 255, 0, 0) ; 재생
  
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

Procedure PlayPianoSound(sound.a)
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
  If *this\sprite\x = *this\xmax Or *this\sprite\y = *this\ymax
    
    DeleteElement(position_list())
  EndIf 
  
  
EndProcedure

Procedure MoveAnt()
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
      ;--
      PrintN(sprite_list()\sprite_name)
      
      DrawMySprite(sprite_list())
    Next
    FlipBuffers()
  Until ListSize(position_list()) = 0
  
  ;answer check
  Delay(500)
  AnswerCheck()
  Delay(500)
  
EndProcedure

Procedure MakeAnt(code.i)
  
  ;-- Null pointer 체크를 하고 싶은데 어떻게 하는지 몰라
  ;   *temp.mySprite = FindSprite("note"+Str(currentBar)+"\0")
  ;   SetMySprite(*temp, 0, 0, 0)
  
  InitMySprite("antmove"+Str(currentBar), "../graphics/antmove.png", Lv2_antX-200, Lv2_antY)
  *p.mySprite = FindSprite("antmove"+Str(currentBar))
  *p\f_horizontal = 4
  *p\f_width = 65
  *p\f_height = 69
  
  InitMySprite("container"+Str(currentBar), "../graphics/container.png", Lv2_contX, Lv2_contY)
  *p2.mySprite = FindSprite("container"+Str(currentBar))
  
  InitMyPosition(*p, 10, 0, Lv2_antX, 0, 20)
  InitMyPosition(*p2, 10, 0, Lv2_antX+60, 0, 20)
  
  ;화음이 된 비료 속 좌표
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
    Case #CODE_E
      note0 = "mi":      note1 = "so":      note2 = "ti"
  EndSelect
  
  InitMySprite("note"+Str(currentBar)+"\0", "../graphics/"+note0+".png", note0X, note0Y)
  InitMySprite("note"+Str(currentBar)+"\1", "../graphics/"+note1+".png", note1X, note1Y)
  InitMySprite("note"+Str(currentBar)+"\2", "../graphics/"+note2+".png", note2X, note2Y)
  
  *n0 = FindSprite("note"+Str(currentBar)+"\0")
  *n1 = FindSprite("note"+Str(currentBar)+"\1")
  *n2 = FindSprite("note"+Str(currentBar)+"\2")
  
  InitMyPosition(*n0, 10, 0, Lv2_antX+70, 0, 20)
  InitMyPosition(*n1, 10, 0, Lv2_antX+110, 0, 20)
  InitMyPosition(*n2, 10, 0, Lv2_antX+90, 0, 20)
  
  MoveAnt()
  
  *p\active = 0
  *p.mySprite = InitMySprite("ant"+Str(currentBar), "../graphics/ant.png", Lv2_antX, Lv2_antY)
  
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
    PlayPianoSound(tone)
    answerTone = tone
    ;-- 비료에 음 추가? 몰라 ; 논의해야 함
  EndIf
  
  
  markerx.i
  markery.i
  If(key = #PB_Key_2)
    markerx = marker2X
    markery = marker2Y
  ElseIf(key = #PB_Key_1)
    markerx = marker1X
    markery = marker1Y
  EndIf
  
  ; 선택한 화음별로 개미 그려주기
  If markery>400
    If markerx<100
      MakeAnt(#CODE_C)
    ElseIf markerx<200
      MakeAnt(#CODE_G)
    ElseIf markerx<300
      MakeAnt(#CODE_F)
    ElseIf markerx<400
      MakeAnt(#CODE_Am)
    ElseIf markerx<500
      MakeAnt(#CODE_Dm)
    ElseIf markerx<600
      MakeAnt(#CODE_E)
    Else ; Play
      PrintN("재생")
    EndIf
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
  
  problem.Problem_Lv2 = problem_list(currentProblem)
  
  weight.f = 0.0
  distance.i = Lv2_antX
  current_bar.i = 0
  
  ; 배경 그려주기
  InitMySprite("background_clip", "../graphics/background_clip.png", Lv2_antX-100, 0)
  
  For i = 0 To ArraySize(problem\notes())-1
    ;     PrintN(Str(k) + ", " + Str(i) + " : " + Str(problem\notes(i)\note))
    note.Note = problem\notes(i)
    
    If note\posBar < currentBar
      ;       PrintN("skip" + Str(i))
      Continue
    EndIf
    
    line_num.s = Str(note\note)
    posX.i = distance+Int(80*weight)
    posY.i = 160
    
    If posX > WindowWidth(0)
      ; 화면에 넘치게 그려지면 더이상 그리지 않음
      PrintN("화면 초과")
      Break
    EndIf
    
    If current_bar < note\posBar
      ;-- 끝음인 경우에도 다음 마디 배경이 먼저 그려지는 것에 대한 문제를 해결하기 위해
      ;    If i < ArraySize(problem\notes())-1 And note\posBar <> problem\notes(i+1)\posBar
      ; 새로운 마디가 시작됨
      PrintN("마디변경")
      
      ; 배경 그려주기
      InitMySprite("background_clip", "../graphics/background_clip.png", Lv2_antX+450, 0)
      posX+160
      
    EndIf
    
    ; 음표 그리기 ; line0/2 : 0번째 마디의 3번째 음표
    spriteName.s = "line" + Str(note\posBar) + "/" + Str(note\posNote)
    PrintN(Str(i) + " : " + Str(posX) + ", " + Str(posY) + " and " + Str(weight))
    InitMySprite(spriteName, "../graphics/line"+line_num+".png", posX, posY)
    
    ; 다음 음표를 위한 거리 가중치 (간격을 맞춰주기 위해)
    weight.f = note\length
    distance = posX
    current_bar = note\posBar
    
  Next
  
EndProcedure

OpenConsole()

markerState = 0 ; 마커 입력 상태
threadStatus = 0; thread 상태. 0-실행안함, 1-실행중

InitProblem()

;사운드 시스템 초기화, 점검
If InitSound() = 0 
  MessageRequester("Error", "Sound system is not available",  0)
  End
EndIf

;각 음정 wav파일 불러오기, 0~6까지 도~시에 대응
;Result = LoadSound(#Sound, Filename$ [, Flags])
LoadSound(0, "../sound/piano-도.wav")
LoadSound(1, "../sound/piano-레.wav")
LoadSound(2, "../sound/piano-미.wav")
LoadSound(3, "../sound/piano-파.wav")
LoadSound(4, "../sound/piano-솔.wav")
LoadSound(5, "../sound/piano-라.wav")
LoadSound(6, "../sound/piano-시.wav")

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
    
    InitMySprite("background", "../graphics/background.png", 0, 0)
    
    currentProblem = 0;-- Random(2)
    currentBar = 0
    
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
        
        If KeyboardReleased(#PB_Key_Left)
          ; 이전 마디로 이동
          If currentBar > 0
            currentBar-1
            DrawBarMarker()
            DrawNotes()
          EndIf
          
        EndIf
        
        If KeyboardReleased(#PB_Key_Right)
          ; 다음 마디로 이동
          If currentBar < MaxBar-1
            currentBar+1
            DrawBarMarker()
            DrawNotes()
          EndIf
        EndIf
        
      EndIf
      DrawButtons(*image);-- 임시로 만든 화음 버튼
      DrawBoxs(*image)
      
      *mat.CvMat = cvEncodeImage(".bmp", *image, 0)
      Result = CatchImage(1, *mat\ptr)
      SetGadgetState(0, ImageID(1))
      cvReleaseMat(@*mat)  
      
      FlipBuffers()
    Until WindowEvent() = #PB_Event_CloseWindow
  EndIf
  
  FreeImage(pbImage)
  cvReleaseCapture(@*capture)
  
  ForEach sprite_list()
    FreeStructure(sprite_list())
  Next
  
  FreeStructure(position_list())
  FreeStructure(problem_list())
  
  cvReleaseCapture(@*capture)
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 763
; FirstLine = 609
; Folding = ----
; EnableXP
; DisableDebugger
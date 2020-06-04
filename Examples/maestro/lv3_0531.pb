IncludeFile "includes/cv_functions.pbi"

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력
; 키보드3 : 멜로디 입력 <-> 코드 입력 전환 (기본 상태는 멜로디 입력, 처음 누르면 코드 입력으로 전환)
; 키보드4 : 입력 <-> 수정 전환 (기본 상태는 입력, 처음 누르면 수정모드로 전환)
  
Structure mySprite
  sprite_id.i
  sprite_name.s
  filename.s
  
  num.i ; 몇 번 음(또는 화음)인지 저장
  beat.i ; 음표 스프라이트만 박자 저장
  
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

Structure color
  r.i
  g.i
  b.i
EndStructure

;-Structure Bar
Structure Bar
  List note.mySprite()
  List chord.mySprite()
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


Enumeration Chordes ;--2단계 코드에서 순서 바꿈!!
  
  #CHORD_C = 1 ;1부터 시작, 1도 화음
  #CHORD_Dm
  #CHORD_Em
  #CHORD_F
  #CHORD_G
  #CHORD_Am
  
EndEnumeration


Structure Problem
  note1.i
  note2.i
  answer.i
EndStructure


;-- 전역변수 선언

Global *rectimg.IplImage, *loadbox1.IplImage, *loadbox2.IplImage
Global.l hMidiOut
Global Window_0, Screen_0, Window_1
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, inputTone, answerTone, currentTime, direction, inputCount = -1
Global intervalStart = 0, intervalEnd = 0, dist, beat, beatSum = 0 ;박자 측정하기 위한 변수
Global Dim ptBox.CvPoint(7, 4)
Global NewList sprite_list.mySprite()
Global Dim bar_list.Bar(3)
Global NewList position_list.myPosition()
Global complete = 0 ;입력완료 flag
Global x = 800
Global barCount = 0, currentBar.i ;마디 수 측정
Global inputMode = 0              ;입력모드(화음 or 음 입력)
Global editMode = 0               ;편집모드
Global Dim note(2)
Global Lv2_antX = 700
Global Lv2_antY = 630
Global Lv2_noteY = 610
Global Lv2_contX = 560
Global Lv2_contY = 600
Global chordCount = 0
Global check = 0
Global chordFlag = 0
Global Dim score(7)

Global Dim keyColor.color(6)



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

Procedure InitMySprite_lv3(name.s, filename.s, x.i, y.i, type.i, active.i = 1) ;active는 옵션
                                                                   ; 스프라이트 구조체 초기화
  CreateSprite(#PB_Any, width, height)
  mysprite = LoadSprite(#PB_Any, filename.s)
  
  If type = 0 ;일반 스프라이트
    *newsprite.mySprite = AddElement(sprite_list())
  ElseIf type = 1 ;음표(과일) 스프라이트
    *newsprite.mySprite = AddElement(bar_list(currentBar)\note())   ;beat, bar 따로 저장
  ElseIf type = 2 ;화음 스프라이트
    *newsprite.mySprite = AddElement(bar_list(currentBar)\chord())
  EndIf  
  
  
  *newsprite\num = -1 
  *newsprite\beat = -1  ;일반 스프라이트
    
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
      *this\frameTime = currentTime + 50
    EndIf 
  EndIf
  
  
  If *this\sprite\x = *this\xmax Or *this\sprite\y = *this\ymax  
    DeleteElement(position_list())
  EndIf 
  
  
EndProcedure




Procedure MoveAnt_Lv3()
  Repeat
    currentTime = GetTickCount_()
    ForEach position_list()
      ChangePos(position_list())
    Next
    
    currentTime = GetTickCount_()
    ;For i=0 To 3 
    ForEach bar_list(currentBar)\note()
      FrameManager(bar_list(currentBar)\note())
    Next
    
    currentTime = GetTickCount_()
    ForEach bar_list(currentBar)\chord()
      FrameManager(bar_list(currentBar)\chord())
    Next
    ;Next
    
    currentTime = GetTickCount_()
    ForEach sprite_list()
      FrameManager(sprite_list()) ;active 상태인 것들만 다음 프레임으로
    Next

    
    ForEach sprite_list()
      DrawMySprite(sprite_list())
    Next
    
    ;For i=0 To 3 
    ForEach bar_list(currentBar)\note()
      DrawMySprite(bar_list(currentBar)\note())
    Next
    
    ForEach bar_list(currentBar)\chord()
      DrawMySprite(bar_list(currentBar)\chord())
    Next
    ;Next
    
    FlipBuffers()
  Until ListSize(position_list()) = 0
  
EndProcedure





;음 길이 계산하는 함수, 여기서 음 길이는 현재 입력 음이 아닌 바로 앞의 음에 해당(음 두 개의 간격으로 계산하므로)
Procedure CalcBeat()
  
  interval = intervalStart - intervalEnd ;현재 음 입력시간 - 이전 음 입력시간
  
 ; Debug Interval
  
  If Interval >=1000 And Interval <5000
    dist = 160
    beat = 600 ;두 박자(2분 음표), x좌표 간격 160으로 
  ElseIf Interval >=500 And Interval <1000
    dist = 80
    beat = 450  ;한 박자(4분 음표), x좌표 간격 80으로 
  ElseIf Interval < 500
    dist = 40
    beat = 300  ;반 박자(8분 음표), x좌표 간격 40으로
  ElseIf Interval >= 5000
    dist = 0
    beat = 0  ;간격이 매우 크다 -> 맨 처음 입력한 음 
  EndIf
  
  ;Debug beat
  
  ; 총 몇 박자인지 파악 (4박자 채우면 마디 넘김)
  beatSum = beatSum + dist
  ;Debug beatSum
  
EndProcedure


;입력한 음을 기억했다가 마디 이동시에 다시 그려주는 함수
Procedure DrawNote(b)
  
  ; 전체 음 다 지우기
  For i=0 To 3 
    ForEach bar_list(i)\note()
      bar_list(i)\note()\active = 0
    Next
    
    ForEach bar_list(i)\chord()
      bar_list(i)\chord()\active = 0
    Next

  Next
  
  ;Debug "b" + Str(b)
  ; 현재 화면의 음만 그려주기
  ForEach bar_list(b)\note()
    bar_list(b)\note()\active= 1
  Next
  
  
  ForEach bar_list(b)\chord()
    bar_list(b)\chord()\active= 1
  Next
  

  
EndProcedure


;음 입력하면 과일 그려주는 함수
Procedure AddNote()
  
  CalcBeat()
  
  y = 160
  xx = x
  x = xx + dist
  
    ;수정모드
  If editMode = 1 And inputCount = -1
    ClearList(bar_list(currentBar)\note())  
    x = 800
    barCount = currentBar
    beatSum = 0
  EndIf
 
  ;현재 화면 밖으로 벗어나는 경우
  If x > 1440
  ;If beatSum = 8  
    barCount = barCount + 1 ; 여기가 문제!!!!!!!!
    
    ;마디 수 체크
    If barCount > 3 And editMode = 0
      ;Debug "입력 끝"
      complete = 1
      barCount = 3
      ;--맨 마지막 음 박자 계산! 나중에는 마지막 마디 입력 끝나면 저장하는걸로 바꾸기!!
      *p.mySprite = LastElement(bar_list(3)\note())
      diff = 1480 - *p\x
      If diff = 160
        *p\beat = 600 ;두박자
      ElseIf diff = 80
        *p\beat = 450 ;한박자
      ElseIf diff = 40
        *p\beat = 300 ;반박자
      EndIf
      ;inputCount = -1
    
    ElseIf editMode = 1
      ;inputCount = -1
      editMode = 0
      Debug "에딧모드 종료"
      If complete = 1
        barCount = 3
      Else
        barCount = barCount - 1
      EndIf
      
    Else
      ;화면 전환, 앞에 그린 음 지우기
      For i=0 To 3 
        ForEach bar_list(i)\note()
          bar_list(i)\note()\active = 0
        Next
      Next
      
      ;Debug "화면 전환"
      currentBar = barCount
      
      *b.mySprite = FindSprite("background")
      *b\active = 0
      
      *b.mySprite = FindSprite("background2")
      *b\active = 1
      
      ;숫자 마디 (비)활성화 
      For i=1 To 8
        *p.mySprite = FindSprite("bar"+Str(i)+"_a")
        *p\active = 0
      Next
      
      *p.mySprite = FindSprite("bar"+Str(currentBar*2+1)+"_a")
      *p\active = 1
      
      
      x = 800 ;초기화, 첫 위치부터 다시 그림
      InitMySprite_lv3("note"+Str(inputTone+1), "graphics/lines"+Str(inputTone+1)+".png", x, y, 1, 1)
      bar_list(currentBar)\note()\num = inputTone+1
      *p.mySprite = LastElement(bar_list(currentBar-1)\note())
      diff = 1480 - *p\x
      If diff = 160
        *p\beat = 600 ;두박자
      ElseIf diff = 80
        *p\beat = 450 ;한박자
      ElseIf diff = 40
        *p\beat =300 ;반박자
      EndIf
      
      ;Debug "currentBar" + Str(currentBar)
      ;Debug "이전 음 beat" + Str(*p\beat) + "이전 음 x" + Str(*p\x)
      ;Debug "이전 음 x" + Str(*p\x)
      ;bar_list(currentBar)\note()\beat = beat

     
      beatSum = 0
    EndIf
    
  ;화면상에서 두번째 마디 시작
  ElseIf beatSum = 320
   
    currentBar = barCount
    
    ;숫자 마디 (비)활성화 
    For i=1 To 8
      *p.mySprite = FindSprite("bar"+Str(i)+"_a")
      *p\active = 0
    Next
    
    *p.mySprite = FindSprite("bar"+Str(currentBar*2+2)+"_a")
    *p\active = 1
    
    
    
    x = 1160 ;두번째 마디 시작점
    
    InitMySprite_lv3("note"+Str(inputTone+1), "graphics/lines"+Str(inputTone+1)+".png", x, y, 1, 1)
    bar_list(currentBar)\note()\num = inputTone+1
    ;bar_list(currentBar)\note()\beat = beat
    *p.mySprite = PreviousElement(bar_list(currentBar)\note())
    diff = 1160 - *p\x
    If diff = 200
      *p\beat = 600 ;두박자
    ElseIf diff = 120
      *p\beat = 450 ;한박자
    ElseIf diff = 80
      *p\beat = 300 ;반박자
    EndIf
    ;Debug "이전 음 beat" + Str(*p\beat)
    
  Else
    ;Debug "어디야"
    currentBar = barCount
    InitMySprite_lv3("note"+Str(inputTone+1), "graphics/lines"+Str(inputTone+1)+".png", x, y, 1, 1)
    bar_list(currentBar)\note()\num = inputTone+1
    If x<>800
      *p.mySprite = PreviousElement(bar_list(currentBar)\note())
      *p\beat = beat
    EndIf
    
    If x = 800
      ;숫자 마디 (비)활성화 
      For i=1 To 8
        *p.mySprite = FindSprite("bar"+Str(i)+"_a")
        *p\active = 0
      Next
      *p.mySprite = FindSprite("bar"+Str(currentBar*2+1)+"_a")
      *p\active = 1
      
    ElseIf x = 1160
      ;숫자 마디 (비)활성화 
      For i=1 To 8
        *p.mySprite = FindSprite("bar"+Str(i)+"_a")
        *p\active = 0
      Next
      
      *p.mySprite = FindSprite("bar"+Str(currentBar*2+2)+"_a")
      *p\active = 1
    EndIf
     ;Debug "currentBar" + Str(currentBar)
    
  EndIf
  
  ;Debug bar_list(currentBar)\note()\beat
  ;Debug bar_list(currentBar)\note()\num 
EndProcedure

;화음 입력하면 개미랑 비료 그려주는 함수
Procedure AddChord(tone)

  chord = tone

  If chordCount < 8 Or editMode = 1
    
  ;수정모드
    If editMode = 1
      If check = 0
        check = check + 1
        ClearList(bar_list(currentBar)\chord())
        
        *p.mySprite = FindSprite("ant")
        *p\active = 0
        *p.mySprite = FindSprite("ant2")
        *p\active = 0
      Else
        check = 0
      EndIf 
      ;Debug "currentBar : " + Str(currentBar)
      ;Debug "listSize : " + Str(ListSize(bar_list(currentBar)\chord()))

    EndIf
    
    InitMySprite_lv3("antmove"+Str(currentBar), "graphics/antmove.png", Lv2_antX-200, Lv2_antY, 0)
    *p.mySprite = FindSprite("antmove"+Str(currentBar))
    *p\f_horizontal = 4
    *p\f_width = 98
    *p\f_height = 112
 
    ;첫번째 화면의 첫번째 화음
    If ListSize(bar_list(currentBar)\chord()) = 0 And currentBar = 0
      InitMySprite_lv3("container"+Str(chordCount), "graphics/"+Str(chord+1)+".png", Lv2_contX, Lv2_contY, 2)
      
      *p2.mySprite = bar_list(currentBar)\chord()
      *p2\num = tone+1
    
      
      InitMySprite_lv3("bar_active_c"+Str(currentBar*2+1), "graphics/"+Str(chord+1)+"_active.png", 70, 30, 0)
      InitMySprite_lv3("bar_c"+Str(currentBar*2+1), "graphics/"+Str(chord+1)+"s.png", 70+80*(currentBar*2), 30, 0,0)
      
      InitMyPosition(*p2, 10, 0, Lv2_antX+60, 0, 20)
      ;*p2\active = 1
      
      InitMyPosition(*p, 10, 0, Lv2_antX, 0, 20)
      MoveAnt_Lv3()
      *p\active = 0
      *p.mySprite = FindSprite("ant2")
      *p\active = 1
      
      
      ;Debug "currentBar : " + Str(currentBar)
      ;Debug "listSize : " + Str(ListSize(bar_list(currentBar)\chord()))
        
    ;한 화면에서 두번째 마디  
    ElseIf ListSize(bar_list(currentBar)\chord()) = 1
      InitMySprite_lv3("container"+Str(chordCount), "graphics/"+Str(chord+1)+".png", 920, Lv2_contY, 2)
      *p2.mySprite = bar_list(currentBar)\chord()
      *p2\num = tone+1
      
      ;showCurrentBar()
      *b.mySprite = FindSprite("bar_active_c"+Str(currentBar*2+1))
      *b\active = 0
      
      *b.mySprite = FindSprite("bar_c"+Str(currentBar*2+1))
      *b\active = 1
      
      InitMySprite_lv3("bar_active_c"+Str(currentBar*2+2), "graphics/"+Str(chord+1)+"_active.png", 70+80*(currentBar*2+2-1), 30, 0)
      InitMySprite_lv3("bar_c"+Str(currentBar*2+2), "graphics/"+Str(chord+1)+"s.png", 70+80*(currentBar*2+2-1), 30, 0, 0)
      
      InitMyPosition(*p2, 10, 0, 1120, 0, 20)
      *p\x = 850
      InitMyPosition(*p, 10, 0, 1050, 0, 20)
      MoveAnt_Lv3()
      *p\active = 0
           
      *p.mySprite = FindSprite("ant")
      *p\active = 1
      
      chordFlag = 1 ;;;;;;
      
      If editMode = 1
        editMode = 0
        Debug "수정 끝"
      EndIf
  
    ;화면 전환 후 첫번째 마디
    Else
      
      If editMode = 0
        ;currentBar = currentBar + 1
        
        *p1.mySprite = FindSprite("ant")
        *p1\active = 0
        *p1.mySprite = FindSprite("ant2")
        *p1\active = 0
        
        ;전에 그린 화음 지우기
        For i=0 To 3 
          ForEach bar_list(i)\chord()
            bar_list(i)\chord()\active = 0
          Next
        Next
        
        DrawNote(currentBar)
        
      EndIf
      
      ;현재 입력한 화음만 활성화
      InitMySprite_lv3("container"+Str(chordCount), "graphics/"+Str(chord+1)+".png", Lv2_contX, Lv2_contY, 2)
      *p3.mySprite = bar_list(currentBar)\chord()
      *p3\active = 1
      *p3\num = tone+1
      
      ;showCurrentBar()
      *b.mySprite = FindSprite("bar_active_c"+Str((currentBar-1)*2+2))
      *b\active = 0
      
      *b.mySprite = FindSprite("bar_c"+Str((currentBar-1)*2+2))
      *b\active = 1
      
      
      InitMySprite_lv3("bar_active_c"+Str(currentBar*2+1), "graphics/"+Str(chord+1)+"_active.png", 70+80*(currentBar*2), 30, 0)
      InitMySprite_lv3("bar_c"+Str(currentBar*2+1), "graphics/"+Str(chord+1)+"s.png", 70+80*(currentBar*2), 30, 0, 0)
      
      InitMyPosition(*p3, 10, 0, Lv2_antX+60, 0, 20)
      
      InitMyPosition(*p, 10, 0, Lv2_antX, 0, 20)
      MoveAnt_Lv3()
      *p\active = 0
      ;InitMySprite_lv3("ant2"+Str(currentBar), "graphics/ant.png", Lv2_antX, Lv2_antY,0)

      *p.mySprite = FindSprite("ant2")
      *p\active = 1
      
    EndIf
    
  EndIf
  
EndProcedure


Procedure CalcBoxs_lv3()
  ptLeft = 0
  ptTop = 0
  ptRight = 0
  ptBottom = 0
  ptLength = 0
  direction = 0
  
  
  If inputMode = 0
    a = 7 ;음 입력
  Else
    a = 6 ;화음 입력
  EndIf
  
  
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
    ptLength = (ptRight-ptLeft)/a
    direction = 0
    top = (ptTop + ptBottom)/2 - 100
    bottom = (ptTop + ptBottom)/2 + 100
    If bottom > 480
      bottom = 480
    EndIf 
  Else
    ptLength = (ptBottom-ptTop)/a
    direction = 1
    left = (ptLeft + ptRight)/2 - 100
    right = (ptLeft + ptRight)/2 + 100
    If left < 0
      left = 0
    ElseIf right > 640
      right = 640
    EndIf       
  EndIf
  
  count = 0
  Repeat
    If direction = 1 ;세로
      bottom = ptBottom - count*ptLength
      top = ptBottom - (count+1)*ptLength      
    Else
      left = ptLeft + count*ptLength
      right = ptLeft + (count+1)*ptLength
    EndIf
    
    If left < 0
      left = 0
    EndIf
    If top < 0
      top = 0
    EndIf
    If right < 0
      right = 0
    EndIf
    If bottom < 0
      bottom = 0
    EndIf
    
    ptBox(count, 0)\x = left
    ptBox(count, 0)\y = top
    ptBox(count, 2)\x = right
    ptBox(count, 2)\y = bottom
    
    count+1
  Until count >= a
  
EndProcedure


Procedure DrawBoxs(*image)  
  ; 박스 0-6이 있고 각 꼭짓점을 4개 만듦, 현재는 0과 2만 씀(좌상단과 우하단) 타입은 CvPoint
  cvSetZero(*rectimg)
  
  ; 그리기 상태일 때 박스들의 좌표값을 계산한다.
  If markerState = 0
    CalcBoxs_lv3()
  EndIf
  
  ;멜로디 입력모드 
  If inputMode = 0
    ; 7개의 박스를 그린다
    count = 0
    Repeat
      cvRectangle(*rectimg, ptBox(count, 0)\x, ptBox(count, 0)\y, ptBox(count, 2)\x, ptBox(count, 2)\y, keyColor(count)\b, keyColor(count)\g, keyColor(count)\r, 0, -1, #CV_AA, #Null)
      count+1
    Until count >= 7
    
    cvAddWeighted(*image, 1, *rectimg, 0.5, 0, *image)
    cvResetImageROI(*image)
    
  ;화음 입력모드  
  Else
    If direction = 0   
      width = ptBox(5, 2)\x - ptBox(0, 0)\x
      height = ptBox(0, 2)\y - ptBox(0, 0)\y
    Else
      width = ptBox(0, 2)\x - ptBox(0, 0)\x
      height = ptBox(0, 2)\y - ptBox(5, 0)\y
    EndIf
    
    If height < 10 Or width < 10
      ProcedureReturn
    EndIf 
    
    
    ;Debug Str(ptBox(5,0)\x) + "    " + Str(ptBox(5,0)\y)
    ;Debug "width: " + Str(width) + "    height: " + Str(height)
    *boximg.IplImage = cvCreateImage(width, height, #IPL_DEPTH_8U, 3)
    
    If direction = 0
      cvResize(*loadbox1, *boximg, #CV_INTER_LINEAR)
      cvSetImageROI(*image, ptBox(0, 0)\x, ptBox(0, 0)\y, width, height)
    Else
      cvResize(*loadbox2, *boximg, #CV_INTER_LINEAR)
      cvSetImageROI(*image, ptBox(5, 0)\x, ptBox(5, 0)\y, width, height)
    EndIf
    
    cvAddWeighted(*image, 0.5, *boximg, 0.5, 0, *image)
    cvResetImageROI(*image)
    ;cvReleaseImage(*boximg)
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


Procedure GetChord(chord)
  Select chord
    Case #CHORD_C ;1번 코드
      note(0) = 1:      note(1) = 3:      note(2) = 5
    Case #CHORD_Dm
      note(0) = 2:      note(1) = 4:      note(2) = 6
    Case #CHORD_Em
      note(0) = 3:      note(1) = 5:      note(2) = 7
    Case #CHORD_F
      note(0) = 4:      note(1) = 6:      note(2) = 1
    Case #CHORD_G
      note(0) = 5:      note(1) = 7:      note(2) = 2
    Case #CHORD_Am
      note(0) = 6:      note(1) = 1:      note(2) = 3
      
  EndSelect
EndProcedure



Procedure PlayPianoSound(note)
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note) << 8 | 127 << 16 )
  ;Delay(150) ;박자 별로 딜레이 수정하기
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note) << 8 | 0 << 16)
EndProcedure


Procedure PlayChordSound()
  
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note(0)) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note(1)) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note(2)) << 8 | 127 << 16 )
  ;Delay(1000)
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note(0)) << 8 | 0 << 16)
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note(1)) << 8 | 0 << 16)
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note(2)) << 8 | 0 << 16)
  
EndProcedure




Procedure CalcArea_lv3(x, y)
  tone = -1
  i = 0
  a = 7
  
  If inputMode = 0
    a = 7
  Else
    a = 6
  EndIf
  
  Repeat
    If (ptBox(i, 0)\x < x) And (ptBox(i, 2)\x > x)
      If (ptBox(i, 0)\y < y) And (ptBox(i, 2)\y > y)
        tone = i
        Break
      EndIf
    EndIf
    i + 1
  Until i >= a
  
  ProcedureReturn tone ; 음을 반환
EndProcedure




Procedure CheckArea(key)
  If(key = #PB_Key_2)
    ;    Debug("GREEN : " + Str(marker2X) + ", " + Str(marker2Y))
    tone = CalcArea_lv3(marker2X, marker2Y)
  ElseIf(key = #PB_Key_1)
    ;    Debug("RED : " + Str(marker1X) + ", " + Str(marker1Y))
    tone = CalcArea_lv3(marker1X, marker1Y)
  EndIf
  

  ; 음 입력모드인 경우 + 음이 도-시 사이인 경우만 출력
  If tone > -1 And tone < 7 And inputMode = 0
    ;이전 음 소리 제거
    If inputCount <> -1
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(bar_list(currentBar)\note()\num) << 8 | 0 << 16)
    EndIf 
    
    intervalEnd = intervalStart
    intervalStart = GetTickCount_()
    
    inputTone = tone
    
    AddNote()
 
    If barCount < 4
      PlayPianoSound(tone+1)
      ;answerTone = tone
      inputCount = inputCount + 1
      
    EndIf
    
     
  ; 화음 입력모드
  ElseIf inputMode = 1 And tone > -1 And tone < 6 And chordFlag = 0
    GetChord(tone+1)
    PlayChordSound()
    AddChord(tone)
    If editMode = 0
      chordCount = chordCount + 1
    EndIf
    
  EndIf
    
EndProcedure


Procedure ClearNote()
  
  For i=0 To 3 
    ForEach bar_list(i)\note()
      bar_list(i)\note()\active = 0
    Next
    
    ForEach bar_list(i)\chord()
      bar_list(i)\chord()\active = 0
    Next
  Next
  
  
  ForEach sprite_list()
    FrameManager(sprite_list()) 
  Next
  
  
  For i=0 To 3
    currentTime = GetTickCount_()
    ForEach bar_list(i)\note()
      FrameManager(bar_list(i)\note())
    Next
    
    currentTime = GetTickCount_()
    ForEach bar_list(i)\chord()
      FrameManager(bar_list(i)\chord())
    Next
  Next
  
  
  ClearScreen(RGB(255, 255, 255))
  
  ForEach sprite_list()
    DrawMySprite(sprite_list())
  Next
  
  
  For i=0 To 3 
    ForEach bar_list(i)\note()
      DrawMySprite(bar_list(i)\note())
    Next
    
    ForEach bar_list(i)\chord()
      DrawMySprite(bar_list(i)\chord())
    Next
    
  Next
EndProcedure


;전체 재생해주는 함수
Procedure PlayAll()
  
  Repeat
 
    ClearNote()

    ForEach bar_list(i)\note()
 
      note = bar_list(i)\note()\num
      beat = bar_list(i)\note()\beat
      
      bar_list(i)\note()\active = 1
      currentTime = GetTickCount_()
      FrameManager(bar_list(i)\note())
      DrawMySprite(bar_list(i)\note())
  
      If bar_list(i)\note()\x = 800
        *p.mySprite = FirstElement(bar_list(i)\chord())
        chord = *p\num
        *p\active = 1
        GetChord(chord)
        PlayChordSound()
        
        ;Debug("2*i+1 = "+ Str(2*i+1))
        
        
;         If i <> 0
;           *b.mySprite = FindSprite("bar_active_c"+Str(2*i))
;           *b\active = 0
;           *b.mySprite = FindSprite("bar_c"+Str(2*i))
;           *b\active = 1
;         EndIf
;         *b.mySprite = FindSprite("bar_c"+Str(2*i+1))
;         *b\active = 0
        *b.mySprite = FindSprite("bar_active_c"+Str(2*i+1))
        *b\active = 1
        

      ElseIf bar_list(i)\note()\x = 1160
        *p.mySprite = LastElement(bar_list(i)\chord())
        chord = *p\num
        *p\active = 1
        GetChord(chord)
        PlayChordSound()
        
        ;Debug("2*i+2 = "+ Str(2*i+2))
;         If i*2+1 <> 0
;         *b.mySprite = FindSprite("bar_active_c"+Str(2*i+1))
;         *b\active = 0
;         *b.mySprite = FindSprite("bar_c"+Str(2*i+1))
;         *b\active = 1
;         EndIf
;         
;         *b.mySprite = FindSprite("bar_c"+Str(2*i+1))
;*b\active = 0
     
        
        *b.mySprite = FindSprite("bar_active_c"+Str(2*i+2))
        *b\active = 1
        
      EndIf  
      
      currentTime = GetTickCount_()
      FrameManager(sprite_list())
      FrameManager(bar_list(i)\chord())
      
      DrawMySprite(sprite_list())
      DrawMySprite(bar_list(i)\chord())
      
  
      midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(note) << 8 | 127 << 16 )
      Delay(beat)
      midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(note) << 8 | 0 << 16)
      
      FlipBuffers()
      
    Next

  i = i + 1
  Until i = 4
  
EndProcedure


Procedure Scoring()
  
  ;===========================멜로디-코드 매칭 채점==================================
  
  Dim checkNote.Bar(7)
  
  For i=0 To 3
    ForEach bar_list(i)\note()
      *p.mySprite = bar_list(i)\note()
      ;강박인 음을 기준으로 채점(마디 첫음 혹은 길이가 긴 음)
      If *p\x = 800
        *n.mySprite = AddElement(checkNote(2*i)\note())
        *n\num =*p\num
      ElseIf *p\x = 1160
        *n.mySprite = AddElement(checkNote(2*i+1)\note())
        *n\num =*p\num
      ElseIf *p\beat = 600
        If *p\x < 1160
          *n.mySprite = AddElement(checkNote(2*i)\note())
          *n\num =*p\num
        Else
          *n.mySprite = AddElement(checkNote(2*i+1)\note())
          *n\num =*p\num
        EndIf
      EndIf
    Next


    *p.mySprite = FirstElement(bar_list(i)\chord())
    *n.mySprite = AddElement(checkNote(2*i)\chord())
    *n\num =*p\num
    *p.mySprite = LastElement(bar_list(i)\chord())
    *n.mySprite = AddElement(checkNote(2*i+1)\chord())
    *n\num =*p\num
  
  Next
  
  ;flag = 1 (틀림), flag = 0 (맞음)
  For i=0 To 7
    flag = 1
    *p = FirstElement(checkNote(i)\chord())
    n = *p\num
    GetChord(n)
    ForEach checkNote(i)\note()
      m = checkNote(i)\note()\num
      If m= note(0) Or m = note(1) Or m = note(2)
        flag = 0
      EndIf
;       Debug("기준음 " + Str(m))
;       Debug("note 0 " + Str(note(0)))
;       Debug("note 1 " + Str(note(1)))
;       Debug("note 2 " + Str(note(2)))
;       Debug("flag " + Str(flag))
    Next
    If flag = 1
        score(i) = 1
    Else
        score(i) = 0
    EndIf
  Next
  
  
  ;===========================코드 진행 체크==================================
  
  *p.mySprite = FirstElement(bar_list(0)\chord())
  For i=0 To 3     
    ForEach bar_list(i)\chord()
      *q.mySprite = bar_list(i)\chord()
 
      ;G코드(5도) -> Dm(2도) or F(4도)
      If *p\num = 5 And (*q\num = 2 Or *q\num = 4)
        Debug("잘못된 코드진행")
      EndIf
      *p = *q
    Next
    
  Next
  
  
  
EndProcedure



markerState = 0 ; 마커 입력 상태

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

;InitProblem()


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
  *rectimg = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *loadbox1 = cvLoadImage("graphics/chord_box.png", 1)
  *loadbox2 = cvLoadImage("graphics/chord_box2.png", 1)
  
  
  ;전체화면으로 실행
  If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
    
    OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; 웹캠용 윈도우
    ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
    StickyWindow(1, #True) ; 항상 위에 고정
    SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(1), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; 윈도우 타이틀 바 제거
    
    InitSprite()
    InitKeyboard()
    
    ;Screen과 Sprite 생성
    Screen_0 = OpenWindowedScreen(WindowID(Window_0), 0, 0, WindowWidth(0), WindowHeight(0))
    
    UsePNGImageDecoder()
    
    TransparentSpriteColor(#PB_Default, RGB(255, 0, 255))
    
    InitMySprite_lv3("background", "graphics/background.png", 0, 0, 0)
    InitMySprite_lv3("background2", "graphics/background2.png", 0, 0, 0, 0)
    InitMySprite_lv3("leaf1", "graphics/leaf.png", 1120, 165, 0)
    InitMySprite_lv3("leaf2", "graphics/leaf.png", 1480, 170, 0)
    InitMySprite_lv3("note1", "graphics/do.png", 0, 650, 0, 0)
    InitMySprite_lv3("note2", "graphics/re.png", 0, 650, 0, 0)
    InitMySprite_lv3("note3", "graphics/mi.png", 0, 650, 0, 0)
    InitMySprite_lv3("note4", "graphics/fa.png", 0, 650, 0, 0)
    InitMySprite_lv3("note5", "graphics/so.png", 0, 650, 0, 0)
    InitMySprite_lv3("note6", "graphics/la.png", 0, 650, 0, 0)
    InitMySprite_lv3("note7", "graphics/ti.png", 0, 650, 0, 0)
    
    InitMySprite_lv3("ant", "graphics/ant.png", 1050, Lv2_antY,0,0)
    InitMySprite_lv3("ant2", "graphics/ant.png", Lv2_antX, Lv2_antY,0,0)

    
    ;숫자 마디
    InitMySprite_lv3("bar1", "graphics/bar1.png", 70, 30, 0, 1)
    InitMySprite_lv3("bar2", "graphics/bar2.png", 150, 30, 0, 1)
    InitMySprite_lv3("bar3", "graphics/bar3.png", 230, 30, 0, 1)
    InitMySprite_lv3("bar4", "graphics/bar4.png", 310, 30, 0, 1)
    InitMySprite_lv3("bar5", "graphics/bar5.png", 390, 30, 0, 1)
    InitMySprite_lv3("bar6", "graphics/bar6.png", 470, 30, 0, 1)
    InitMySprite_lv3("bar7", "graphics/bar7.png", 550, 30, 0, 1)
    InitMySprite_lv3("bar8", "graphics/bar8.png", 630, 30, 0, 1)
    
    InitMySprite_lv3("bar1_a", "graphics/bar1_active.png", 70, 30, 0, 1)    
    InitMySprite_lv3("bar2_a", "graphics/bar2_active.png", 150, 30, 0, 0)  
    InitMySprite_lv3("bar3_a", "graphics/bar3_active.png", 230, 30, 0, 0)     
    InitMySprite_lv3("bar4_a", "graphics/bar4_active.png", 310, 30, 0, 0)    
    InitMySprite_lv3("bar5_a", "graphics/bar5_active.png", 390, 30, 0, 0)  
    InitMySprite_lv3("bar6_a", "graphics/bar6_active.png", 470, 30, 0, 0)    
    InitMySprite_lv3("bar7_a", "graphics/bar7_active.png", 550, 30, 0, 0)
    InitMySprite_lv3("bar8_a", "graphics/bar8_active.png", 630, 30, 0, 0)
    
    ;화음 마디
    InitMySprite_lv3("c1", "graphics/container_s.png", 70, 30, 0, 0)
    InitMySprite_lv3("c2", "graphics/container_s.png", 150, 30, 0, 0)
    InitMySprite_lv3("c3", "graphics/container_s.png", 230, 30, 0, 0)
    InitMySprite_lv3("c4", "graphics/container_s.png", 310, 30, 0, 0)
    InitMySprite_lv3("c5", "graphics/container_s.png", 390, 30, 0, 0)
    InitMySprite_lv3("c6", "graphics/container_s.png", 470, 30, 0, 0)
    InitMySprite_lv3("c7", "graphics/container_s.png", 550, 30, 0, 0)
    InitMySprite_lv3("c8", "graphics/container_s.png", 630, 30, 0, 0)

    x_note1 = 800
    x_note2 = 840
    y_note1 = 610
   
    ClearScreen(RGB(255, 255, 255))
    
    Repeat
      *image = cvQueryFrame(*capture)
      ;*image = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
      
      If *image
        cvFlip(*image, #Null, 1)
        
        currentTime = GetTickCount_()
        
                ForEach sprite_list()
          FrameManager(sprite_list()) ;active 상태인 것들만 다음 프레임으로
        Next
        
        
        For i=0 To 3
          currentTime = GetTickCount_()
          ForEach bar_list(i)\note()
            FrameManager(bar_list(i)\note())
          Next
          
          currentTime = GetTickCount_()
          ForEach bar_list(i)\chord()
            FrameManager(bar_list(i)\chord())
          Next
        Next
       
        
        ClearScreen(RGB(255, 255, 255))
        
        ForEach sprite_list()
          DrawMySprite(sprite_list())
        Next
        
        
        For i=0 To 3 
          ForEach bar_list(i)\note()
            DrawMySprite(bar_list(i)\note())
          Next
          
          ForEach bar_list(i)\chord()
            DrawMySprite(bar_list(i)\chord())
          Next
          
        Next


        ;- 키보드 이벤트
        ExamineKeyboard()
        
        If KeyboardReleased(#PB_Key_1)
          keyInput = #PB_Key_1
          GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
          marker1X = mouse_x
          marker1Y = mouse_y - (WindowHeight(0)/2 - 200)
          ;marker1Y = mouse_y - (WindowHeight(0)- FrameHeight + 20)
          If (markerState = 1)
            CheckArea(keyInput)
          EndIf
        EndIf
        
        If KeyboardReleased(#PB_Key_2)
          keyInput = #PB_Key_2
          GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
          marker2X = mouse_x
          marker2Y = mouse_y - (WindowHeight(0)/2 - 200)
          ;marker2Y = mouse_y - (WindowHeight(0)- FrameHeight + 20)
          If (markerState = 1)
            CheckArea(keyInput)
          EndIf
        EndIf
        
        If KeyboardReleased(#PB_Key_Space)
          markerState = 1
        EndIf
        
        ;입력 모드 변경_ 0이면 음 입력, 1이면 화음 입력
        If KeyboardReleased(#PB_Key_3)
          ;화음입력
          If inputMode = 0
            inputMode = 1
            currentBar = 0
            DrawNote(currentBar)
            ;숫자 마디 비활성화
            For i=1 To 8
              *p.mySprite = FindSprite("bar"+Str(i))
              *p\active = 0
              *p.mySprite = FindSprite("bar"+Str(i)+"_a")
              *p\active = 0
            Next
            
            ;화음 마디 활성화
            For i=1 To 8
              *p.mySprite = FindSprite("c"+Str(i))
              *p\active = 1
            Next
            
            ;첫번째 배경으로 변경
            *b.mySprite = FindSprite("background")
            *b\active = 1
            *b.mySprite = FindSprite("background2")
            *b\active = 0
            
          ;음 입력  
          Else
            inputMode = 0
            
          EndIf
        EndIf
        
        
        ;입력모드 <-> 수정모드
        If KeyboardReleased(#PB_Key_4)
          If editMode = 0
            Debug "수정모드"
            editMode = 1
            inputCount = -1 ;멜로디 수정 시에만
            If inputMode = 1 And chordFlag = 1
              chordFlag = 0
            EndIf
          Else
            editMode = 0
            Debug "입력모드"
          EndIf
        EndIf
        
        
        ;앞의 마디로 이동
        If KeyboardReleased(#PB_Key_Left)
          If currentBar > 0
            ;Debug currentBar-1
            currentBar = currentBar-1 
            
            ;멜로디 모드일 때 숫자마디
            If inputMode = 0
              For i=1 To 8
                *p.mySprite = FindSprite("bar"+Str(i)+"_a")
                *p\active = 0
              Next
              
              *p.mySprite = FindSprite("bar"+Str(currentBar*2+1)+"_a")
              *p\active = 1
              
              *p.mySprite = FindSprite("bar"+Str(currentBar*2+2)+"_a")
              *p\active = 1
              
            ;화음 모드일 때 화음마디  
            ElseIf inputMode = 1
              For i=1 To 8
                
                If (i=currentBar*2+1) Or (i=currentBar*2+2)
                  *p.mySprite = FindSprite("bar_active_c"+Str(i))
                  *p\active = 1
                  *p.mySprite = FindSprite("bar_c"+Str(i))
                  *p\active = 0
                Else
                  *p.mySprite = FindSprite("bar_c"+Str(i))
                  *p\active = 1
                EndIf
              Next
            EndIf
            
            DrawNote(currentBar)

          EndIf
        EndIf
        
        ;뒤의 마디로 이동
        If KeyboardReleased(#PB_Key_Right)
          
          If currentBar < 3 And barCount > currentBar 
             currentBar = currentBar+1
                     ;멜로디 모드일 때 숫자마디
            If inputMode = 0
              For i=1 To 8
                *p.mySprite = FindSprite("bar"+Str(i)+"_a")
                *p\active = 0
              Next
              
              *p.mySprite = FindSprite("bar"+Str(currentBar*2+1)+"_a")
              *p\active = 1
              
              *p.mySprite = FindSprite("bar"+Str(currentBar*2+2)+"_a")
              *p\active = 1
              
            ;화음 모드일 때 화음마디  
            ElseIf inputMode = 1 And chordFlag = 0
              For i=1 To 8
                               
                If (i=currentBar*2+1) Or (i=currentBar*2+2)
                  *p.mySprite = FindSprite("bar_active_c"+Str(i))
                  *p\active = 1
                  *p.mySprite = FindSprite("bar_c"+Str(i))
                  *p\active = 0
                Else
                  *p.mySprite = FindSprite("bar_c"+Str(i))
                  *p\active = 1
                EndIf           
              Next
              
            EndIf
            
            ;화음 입력 안끝났을 때(입력하는 도중)
            If chordFlag = 1
              chordFlag = 0
              
              *b.mySprite = FindSprite("background")
              *b\active = 0
              
              *b.mySprite = FindSprite("background2")
              *b\active = 1
              
              
              *p1.mySprite = FindSprite("ant")
              *p1\active = 0
              *p1.mySprite = FindSprite("ant2")
              *p1\active = 0
              
            EndIf
            
            DrawNote(currentBar)
              
          EndIf
        EndIf
        
        
        ;전체 재생
        If KeyboardReleased(#PB_Key_0)
          For i=1 To 8   
            *p.mySprite = FindSprite("bar_active_c"+Str(i))
            *p\active = 0
            *p.mySprite = FindSprite("bar_c"+Str(i))
            *p\active = 0        
          Next  
          
          PlayAll()
          
          currentBar = 3
        EndIf
        
        ;--채점
        If KeyboardReleased(#PB_Key_9)
          ;1. 코드 진행 체크
          
          ;2. 멜로디x코드 올바른지 체크
          Scoring()
          
          For i=0 To 7
            If score(i) = 0
              ;InitSprite 녹색 동그라미
              InitMySprite_lv3("result"+Str(i), "graphics/result_o.png", 70+80*i, 30, 0, 1)
              
            Else
              ;InitSprite 빨간 동그라미
              InitMySprite_lv3("result"+Str(i), "graphics/result_x.png", 70+80*i, 30, 0, 1)
            EndIf
          Next
          
          ;InitMySprite_lv3("o", "graphics/result_o.png", 70, 30, 0, 0)
          ;InitMySprite_lv3("x", "graphics/result_x.png", 230, 30, 0, 0)
          ;InitMySprite_lv3("c1", "graphics/container_s.png", 70, 30, 0, 0)
              
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
  FreeImage(pbImage)
  cvReleaseCapture(@*capture)
  
  
  midiOutReset_(hMidiOut)
  midiOutClose_(hMidiOut)
  
  ForEach sprite_list()
    FreeStructure(sprite_list())
  Next
  
  For i=0 To 3 
    ForEach bar_list(i)\note()
      FreeStructure(bar_list(i)\note())
    Next
    
    ForEach bar_list(i)\chord()
      FreeStructure(bar_list(i)\chord())
    Next
    
  Next

  
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 1572
; FirstLine = 1533
; Folding = ----
; EnableXP
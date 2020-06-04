;IncludeFile "includes/cv_functions.pbi"

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력
; 키보드3 : 멜로디 입력 <-> 코드 입력 전환 (기본 상태는 멜로디 입력, 처음 누르면 코드 입력으로 전환)
; 키보드4 : 입력 <-> 수정 전환 (기본 상태는 입력, 처음 누르면 수정모드로 전환)

Structure mySprite_lv3
  sprite_id.i
  sprite_name.s
  filename.s
  
  num.i ; 몇 번 음(또는 화음)인지 저장
  beat.i; 음표 스프라이트만 박자 저장
  
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


;-Structure Bar_lv3
Structure Bar_lv3
  List note_lv3.mySprite_lv3()
  List chord.mySprite_lv3()
EndStructure


Structure myPosition_lv3
  *sprite.mySprite_lv3
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


Structure Problem_lv3
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
Global NewList sprite_list_lv3.mySprite_lv3()
Global Dim bar_list_lv3.Bar_lv3(3)
Global NewList position_list_lv3.myPosition_lv3()
Global complete = 0 ;입력완료 flag
Global x_lv3 = 800
Global barCount = 0, currentBar.i ;마디 수 측정
Global inputMode = 0              ;입력모드(화음 or 음 입력)
Global editMode = 0               ;편집모드
Global Dim note_lv3(2)
Global Lv2_antX = 700
Global Lv2_antY = 630
Global Lv2_noteY = 610
Global Lv2_contX = 560
Global Lv2_contY = 600
Global chordCount = 0
Global check = 0
Global chordFlag = 0
Global Dim score(7)
Global Tutorial_Num_Lv3 = 1
Global Tutorial_lock_Lv3 = #True
Global Dim keyColor.color(6)



Procedure DrawMySprite_lv3(*this.mySprite_lv3)
  If *this\active = 1
    ; 일반 스프라이트
    DisplayTransparentSprite(*this\sprite_id, *this\x, *this\y)
  EndIf
  
EndProcedure

;이미지 프레임 넘기는 함수
Procedure FrameManager_lv3(*this.mySprite_lv3)
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
    *newsprite.mySprite_lv3 = AddElement(sprite_list_lv3())
  ElseIf type = 1 ;음표(과일) 스프라이트
    *newsprite.mySprite_lv3 = AddElement(bar_list_lv3(currentBar)\note_lv3())   ;beat, bar 따로 저장
  ElseIf type = 2                                                               ;화음 스프라이트
    *newsprite.mySprite_lv3 = AddElement(bar_list_lv3(currentBar)\chord())
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
Procedure SetMySprite_lv3(*sprite.mySprite_lv3, x.i, y.i, active.i)
  *sprite\x = x
  *sprite\y = y
  *sprite\active = active
EndProcedure

;myPosition_lv3 초기화
Procedure InitMyPosition_lv3(*sprite.mySprite_lv3, xmove.i, ymove.i, xmax.i, ymax.i, startdelay.i)
  *this.myPosition_lv3 = AddElement(position_list_lv3())
  
  *this\sprite = *sprite
  *this\xmove = xmove
  *this\ymove = ymove
  *this\xmax = xmax
  *this\ymax = ymax
  *this\startdelay = startdelay
EndProcedure

; sprite_list_lv3 에서 이름으로 구조체 찾기. 퓨베 특성상 current element 이슈 때문에 도중에 일치해도 끝까지 루프를 돌아야함
Procedure FindSprite_lv3(name.s)
  *returnStructure.mySprite_lv3
  
  ForEach sprite_list_lv3()
    If sprite_list_lv3()\sprite_name = name
      returnStructrue = sprite_list_lv3()
    EndIf 
  Next
  
  ProcedureReturn returnStructrue
EndProcedure




; 좌표값 옮겨주는 함수
Procedure ChangePos_lv3(*this.myPosition_lv3)
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
    DeleteElement(position_list_lv3())
  EndIf 
  
  
EndProcedure




Procedure MoveAnt_Lv3()
  Repeat
    currentTime = GetTickCount_()
    ForEach position_list_lv3()
      ChangePos_lv3(position_list_lv3())
    Next
    
    currentTime = GetTickCount_()
    ;For i=0 To 3 
    ForEach bar_list_lv3(currentBar)\note_lv3()
      FrameManager_lv3(bar_list_lv3(currentBar)\note_lv3())
    Next
    
    currentTime = GetTickCount_()
    ForEach bar_list_lv3(currentBar)\chord()
      FrameManager_lv3(bar_list_lv3(currentBar)\chord())
    Next
    ;Next
    
    currentTime = GetTickCount_()
    ForEach sprite_list_lv3()
      FrameManager_lv3(sprite_list_lv3()) ;active 상태인 것들만 다음 프레임으로
    Next
    
    
    ForEach sprite_list_lv3()
      DrawMySprite_lv3(sprite_list_lv3())
    Next
    
    ;For i=0 To 3 
    ForEach bar_list_lv3(currentBar)\note_lv3()
      DrawMySprite_lv3(bar_list_lv3(currentBar)\note_lv3())
    Next
    
    ForEach bar_list_lv3(currentBar)\chord()
      DrawMySprite_lv3(bar_list_lv3(currentBar)\chord())
    Next
    ;Next
    
    FlipBuffers()
  Until ListSize(position_list_lv3()) = 0
  
EndProcedure





;음 길이 계산하는 함수, 여기서 음 길이는 현재 입력 음이 아닌 바로 앞의 음에 해당(음 두 개의 간격으로 계산하므로)
Procedure CalcBeat_lv3()
  
  interval = intervalStart - intervalEnd ;현재 음 입력시간 - 이전 음 입력시간
  
  ; Debug Interval
  
  If Interval >=1000 And Interval <5000
    dist = 160
    beat = 800 ;두 박자(2분 음표), x좌표 간격 160으로 
  ElseIf Interval >=500 And Interval <1000
    dist = 80
    beat = 400  ;한 박자(4분 음표), x좌표 간격 80으로 
  ElseIf Interval < 500
    dist = 40
    beat = 200  ;반 박자(8분 음표), x좌표 간격 40으로
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
Procedure DrawNote_lv3(b)
  
  ; 전체 음 다 지우기
  For i=0 To 3 
    ForEach bar_list_lv3(i)\note_lv3()
      bar_list_lv3(i)\note_lv3()\active = 0
    Next
    
    ForEach bar_list_lv3(i)\chord()
      bar_list_lv3(i)\chord()\active = 0
    Next
    
  Next
  
  ;Debug "b" + Str(b)
  ; 현재 화면의 음만 그려주기
  ForEach bar_list_lv3(b)\note_lv3()
    bar_list_lv3(b)\note_lv3()\active= 1
  Next
  
  
  ForEach bar_list_lv3(b)\chord()
    bar_list_lv3(b)\chord()\active= 1
  Next
  
  
  
EndProcedure


;음 입력하면 과일 그려주는 함수
Procedure AddNote_lv3()
  
  CalcBeat_lv3()
  
  y = 160
  xx = x_lv3
  x_lv3 = xx + dist
  
  ;수정모드
  If editMode = 1 And inputCount = -1
    ClearList(bar_list_lv3(currentBar)\note_lv3())  
    x_lv3 = 800
    barCount = currentBar
    beatSum = 0
  EndIf
  
  ;현재 화면 밖으로 벗어나는 경우
  If x_lv3 > 1440
    ;If beatSum = 8  
    barCount = barCount + 1 ; 여기가 문제!!!!!!!!
    
    ;마디 수 체크
    If barCount > 3 And editMode = 0
      ;Debug "입력 끝"
      complete = 1
      barCount = 3
      ;--맨 마지막 음 박자 계산! 나중에는 마지막 마디 입력 끝나면 저장하는걸로 바꾸기!!
      *p.mySprite_lv3 = LastElement(bar_list_lv3(3)\note_lv3())
      diff_lv3 = 1480 - *p\x
      If diff_lv3 = 160
        *p\beat = 800 ;두박자
      ElseIf diff_lv3 = 80
        *p\beat = 400 ;한박자
      ElseIf diff_lv3 = 40
        *p\beat = 200 ;반박자
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
        ForEach bar_list_lv3(i)\note_lv3()
          bar_list_lv3(i)\note_lv3()\active = 0
        Next
      Next
      
      ;Debug "화면 전환"
      currentBar = barCount
      
      *b.mySprite_lv3 = FindSprite_lv3("background")
      *b\active = 0
      
      *b.mySprite_lv3 = FindSprite_lv3("background2")
      *b\active = 1
      
      ;숫자 마디 (비)활성화 
      For i=1 To 8
        *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i)+"_a")
        *p\active = 0
      Next
      
      *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+1)+"_a")
      *p\active = 1
      
      
      x_lv3 = 800 ;초기화, 첫 위치부터 다시 그림
      InitMySprite_lv3("note_lv3"+Str(inputTone+1), "graphics/graphics_lv3/lines"+Str(inputTone+1)+".png", x_lv3, y, 1, 1)
      bar_list_lv3(currentBar)\note_lv3()\num = inputTone+1
      *p.mySprite_lv3 = LastElement(bar_list_lv3(currentBar-1)\note_lv3())
      diff_lv3 = 1480 - *p\x
      If diff_lv3 = 160
        *p\beat = 600 ;두박자
      ElseIf diff_lv3 = 80
        *p\beat = 450 ;한박자
      ElseIf diff_lv3 = 40
        *p\beat =300 ;반박자
      EndIf
      
      ;Debug "currentBar" + Str(currentBar)
      ;Debug "이전 음 beat" + Str(*p\beat) + "이전 음 x" + Str(*p\x)
      ;Debug "이전 음 x" + Str(*p\x)
      ;bar_list_lv3(currentBar)\note_lv3()\beat = beat
      
      
      beatSum = 0
    EndIf
    
    ;화면상에서 두번째 마디 시작
  ElseIf beatSum = 320
    
    currentBar = barCount
    
    ;숫자 마디 (비)활성화 
    For i=1 To 8
      *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i)+"_a")
      *p\active = 0
    Next
    
    *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+2)+"_a")
    *p\active = 1
    
    
    
    x_lv3 = 1160 ;두번째 마디 시작점
    
    InitMySprite_lv3("note_lv3"+Str(inputTone+1), "graphics/graphics_lv3/lines"+Str(inputTone+1)+".png", x_lv3, y, 1, 1)
    bar_list_lv3(currentBar)\note_lv3()\num = inputTone+1
    ;bar_list_lv3(currentBar)\note_lv3()\beat = beat
    *p.mySprite_lv3 = PreviousElement(bar_list_lv3(currentBar)\note_lv3())
    diff_lv3 = 1160 - *p\x
    If diff_lv3 = 200
      *p\beat = 600 ;두박자
    ElseIf diff_lv3 = 120
      *p\beat = 450 ;한박자
    ElseIf diff_lv3 = 80
      *p\beat = 300 ;반박자
    EndIf
    ;Debug "이전 음 beat" + Str(*p\beat)
    
  Else
    ;Debug "어디야"
    currentBar = barCount
    InitMySprite_lv3("note_lv3"+Str(inputTone+1), "graphics/graphics_lv3/lines"+Str(inputTone+1)+".png", x_lv3, y, 1, 1)
    bar_list_lv3(currentBar)\note_lv3()\num = inputTone+1
    If x_lv3<>800
      *p.mySprite_lv3 = PreviousElement(bar_list_lv3(currentBar)\note_lv3())
      *p\beat = beat
    EndIf
    
    If x_lv3 = 800
      ;숫자 마디 (비)활성화 
      For i=1 To 8
        *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i)+"_a")
        *p\active = 0
      Next
      *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+1)+"_a")
      *p\active = 1
      
    ElseIf x_lv3 = 1160
      ;숫자 마디 (비)활성화 
      For i=1 To 8
        *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i)+"_a")
        *p\active = 0
      Next
      
      *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+2)+"_a")
      *p\active = 1
    EndIf
    ;Debug "currentBar" + Str(currentBar)
    
  EndIf
  
  ;Debug bar_list_lv3(currentBar)\note_lv3()\beat
  ;Debug bar_list_lv3(currentBar)\note_lv3()\num 
EndProcedure

;화음 입력하면 개미랑 비료 그려주는 함수
Procedure AddChord(tone)
  
  chord = tone
  
  If chordCount < 8 Or editMode = 1
    
    ;수정모드
    If editMode = 1
      If check = 0
        check = check + 1
        ClearList(bar_list_lv3(currentBar)\chord())
        
        *p.mySprite_lv3 = FindSprite_lv3("ant")
        *p\active = 0
        *p.mySprite_lv3 = FindSprite_lv3("ant2")
        *p\active = 0
      Else
        check = 0
      EndIf 
      ;Debug "currentBar : " + Str(currentBar)
      ;Debug "listSize : " + Str(ListSize(bar_list_lv3(currentBar)\chord()))
      
    EndIf
    
    InitMySprite_lv3("antmove"+Str(currentBar), "graphics/graphics_lv3/antmove.png", Lv2_antX-200, Lv2_antY, 0)
    *p.mySprite_lv3 = FindSprite_lv3("antmove"+Str(currentBar))
    *p\f_horizontal = 4
    *p\f_width = 98
    *p\f_height = 112
    
    ;첫번째 화면의 첫번째 화음
    If ListSize(bar_list_lv3(currentBar)\chord()) = 0 And currentBar = 0
      InitMySprite_lv3("container"+Str(chordCount), "graphics/graphics_lv3/"+Str(chord+1)+".png", Lv2_contX, Lv2_contY, 2)
      
      *p2.mySprite_lv3 = bar_list_lv3(currentBar)\chord()
      *p2\num = tone+1
      
      
      InitMySprite_lv3("bar_active_c"+Str(currentBar*2+1), "graphics/graphics_lv3/"+Str(chord+1)+"_active.png", 70, 30, 0)
      InitMySprite_lv3("bar_c"+Str(currentBar*2+1), "graphics/graphics_lv3/"+Str(chord+1)+"s.png", 70+80*(currentBar*2), 30, 0,0)
      
      InitMyPosition_lv3(*p2, 10, 0, Lv2_antX+60, 0, 20)
      ;*p2\active = 1
      
      InitMyPosition_lv3(*p, 10, 0, Lv2_antX, 0, 20)
      MoveAnt_Lv3()
      *p\active = 0
      *p.mySprite_lv3 = FindSprite_lv3("ant2")
      *p\active = 1
      
      
      ;Debug "currentBar : " + Str(currentBar)
      ;Debug "listSize : " + Str(ListSize(bar_list_lv3(currentBar)\chord()))
      
      ;한 화면에서 두번째 마디  
    ElseIf ListSize(bar_list_lv3(currentBar)\chord()) = 1
      InitMySprite_lv3("container"+Str(chordCount), "graphics/graphics_lv3/"+Str(chord+1)+".png", 920, Lv2_contY, 2)
      *p2.mySprite_lv3 = bar_list_lv3(currentBar)\chord()
      *p2\num = tone+1
      
      ;showCurrentBar()
      *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(currentBar*2+1))
      *b\active = 0
      
      *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(currentBar*2+1))
      *b\active = 1
      
      InitMySprite_lv3("bar_active_c"+Str(currentBar*2+2), "graphics/graphics_lv3/"+Str(chord+1)+"_active.png", 70+80*(currentBar*2+2-1), 30, 0)
      InitMySprite_lv3("bar_c"+Str(currentBar*2+2), "graphics/graphics_lv3/"+Str(chord+1)+"s.png", 70+80*(currentBar*2+2-1), 30, 0, 0)
      
      InitMyPosition_lv3(*p2, 10, 0, 1120, 0, 20)
      *p\x = 850
      InitMyPosition_lv3(*p, 10, 0, 1050, 0, 20)
      MoveAnt_Lv3()
      *p\active = 0
      
      *p.mySprite_lv3 = FindSprite_lv3("ant")
      *p\active = 1
      
     ; chordFlag = 1 ;;;;;;
      
            If currentBar <> 3
        chordFlag = 1 ;;;;;;
      EndIf
      
      
      If editMode = 1
        editMode = 0
        Debug "수정 끝"
        chordFlag = 0
      EndIf
      
      ;화면 전환 후 첫번째 마디
    Else
      
      If editMode = 0
        ;currentBar = currentBar + 1
        
        *p1.mySprite_lv3 = FindSprite_lv3("ant")
        *p1\active = 0
        *p1.mySprite_lv3 = FindSprite_lv3("ant2")
        *p1\active = 0
        
        ;전에 그린 화음 지우기
        For i=0 To 3 
          ForEach bar_list_lv3(i)\chord()
            bar_list_lv3(i)\chord()\active = 0
          Next
        Next
        
        DrawNote_lv3(currentBar)
        
      EndIf
      
      ;현재 입력한 화음만 활성화
      InitMySprite_lv3("container"+Str(chordCount), "graphics/graphics_lv3/"+Str(chord+1)+".png", Lv2_contX, Lv2_contY, 2)
      *p3.mySprite_lv3 = bar_list_lv3(currentBar)\chord()
      *p3\active = 1
      *p3\num = tone+1
      
      ;showCurrentBar()
      *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str((currentBar-1)*2+2))
      *b\active = 0
      
      *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str((currentBar-1)*2+2))
      *b\active = 1
      
      
      InitMySprite_lv3("bar_active_c"+Str(currentBar*2+1), "graphics/graphics_lv3/"+Str(chord+1)+"_active.png", 70+80*(currentBar*2), 30, 0)
      InitMySprite_lv3("bar_c"+Str(currentBar*2+1), "graphics/graphics_lv3/"+Str(chord+1)+"s.png", 70+80*(currentBar*2), 30, 0, 0)
      
      InitMyPosition_lv3(*p3, 10, 0, Lv2_antX+60, 0, 20)
      
      InitMyPosition_lv3(*p, 10, 0, Lv2_antX, 0, 20)
      MoveAnt_Lv3()
      *p\active = 0
      ;InitMySprite_lv3("ant2"+Str(currentBar), "graphics/graphics_lv3/ant.png", Lv2_antX, Lv2_antY,0)
      
      *p.mySprite_lv3 = FindSprite_lv3("ant2")
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


Procedure DrawBoxs_lv3(*image)  
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


Procedure GetNote_lv3(note_lv3)
  result.i
  Select note_lv3
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
      note_lv3(0) = 1:      note_lv3(1) = 3:      note_lv3(2) = 5
    Case #CHORD_Dm
      note_lv3(0) = 2:      note_lv3(1) = 4:      note_lv3(2) = 6
    Case #CHORD_Em
      note_lv3(0) = 3:      note_lv3(1) = 5:      note_lv3(2) = 7
    Case #CHORD_F
      note_lv3(0) = 4:      note_lv3(1) = 6:      note_lv3(2) = 1
    Case #CHORD_G
      note_lv3(0) = 5:      note_lv3(1) = 7:      note_lv3(2) = 2
    Case #CHORD_Am
      note_lv3(0) = 6:      note_lv3(1) = 1:      note_lv3(2) = 3
      
  EndSelect
EndProcedure



Procedure PlayPianoSound_lv3(note_lv3)
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_lv3(note_lv3) << 8 | 127 << 16 )
  ;Delay(150) ;박자 별로 딜레이 수정하기
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_lv3(note_lv3) << 8 | 0 << 16)
EndProcedure


Procedure PlayChordSound_lv3()
  
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_lv3(note_lv3(0)) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_lv3(note_lv3(1)) << 8 | 127 << 16 )
  midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_lv3(note_lv3(2)) << 8 | 127 << 16 )
  ;Delay(1000)
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_lv3(note_lv3(0)) << 8 | 0 << 16)
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_lv3(note_lv3(1)) << 8 | 0 << 16)
  ;midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_lv3(note_lv3(2)) << 8 | 0 << 16)
  
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

Procedure CheckArea_lv3(key)
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
      midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_lv3(bar_list_lv3(currentBar)\note_lv3()\num) << 8 | 0 << 16)
    EndIf 
    
    intervalEnd = intervalStart
    intervalStart = GetTickCount_()
    
    inputTone = tone
    
    AddNote_lv3()
    
    If barCount < 4
      PlayPianoSound_lv3(tone+1)
      ;answerTone = tone
      inputCount = inputCount + 1
      
    EndIf
    
    
    ; 화음 입력모드
  ElseIf inputMode = 1 And tone > -1 And tone < 6 And chordFlag = 0
    GetChord(tone+1)
    PlayChordSound_lv3()
    AddChord(tone)
    If editMode = 0
      chordCount = chordCount + 1
    EndIf
    
  EndIf
  
EndProcedure

Procedure ant_saying_lv3(script.s, pos_x, pos_y)
  
  *p = FindSprite_lv3("ant_say")
  SetMySprite_lv3(*p, 900, 500, 1)  
  StartDrawing(ScreenOutput())  
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(Font15))
  DrawTextEx(pos_x, pos_y, script)
  StopDrawing()
  
EndProcedure


Procedure LEVEL3_Tutorial(x, Tutorial_Num_Lv3)
  
  pos_x = 1000
  pos_y = 530
  ;x + 1
 ; Debug  Tutorial_Num_Lv2
  
  
  Select Tutorial_Num_Lv3
      
    Case 1     
      *p = FindSprite_lv3("ant_tuto")   
      SetMySprite_lv3(*p, 800, 630, 1)
      
      ant_saying_lv3("여기까지 잘 따라와주었구나!"+#CRLF$+"이제 마지막 3단계에서는"+#CRLF$+"직접 작곡을 해 볼 차례야", pos_x, pos_y)
      
    Case 2
      ant_saying_lv3("먼저 생각나는 멜로디를 한 번 입력해봐!"+#CRLF$+"1단계에서 했던 것처럼 원하는 과일을"+#CRLF$+"마커로 입력하면 가지에 과일이 생길거야", pos_x, pos_y) 
      
    Case 3 
      
      ant_saying_lv3("다른 마디로 이동하고 싶을 땐"+#CRLF$+"<오른쪽 마커의 왼쪽, 오른쪽 제스처>를 이용해봐!", pos_x, pos_y)
      
    Case 4
      
      ant_saying_lv3("혹시 입력한 멜로디가 마음에 들지 않으면"+#CRLF$+"OO제스처를 이용해서 수정할 수 있으니 걱정마!"+#CRLF$+"수정은 한 번에 두 마디씩 할 수 있어", pos_x, pos_y)
      
    Case 5
      ant_saying_lv3("멜로디를 다 입력했으면 이제 화음을 넣어보자!", pos_x, pos_y)
      
    Case 6       
      ant_saying_lv3("OO제스처를 사용하면 화음을 입력할 수 있는 상태가 될거야."+#CRLF$+"혹시 화음을 입력하다가 다시 멜로디를 수정하고 싶을 때도"+#CRLF$+"이 제스처를 사용하면 음을 입력할 수 있어", pos_x, pos_y)

    Case 7
      ant_saying_lv3("멜로디에 있는 과일과 비슷한 과일로"+#CRLF$+"이루어진 화음을 고르면 잘 어울릴거야."+#CRLF$+"2단계에서도 해봤으니 잘 할 수 있겠지?", pos_x, pos_y)     
    Case 8       
      ant_saying_lv3("화음을 넣을 때도 OO제스처로 원하는 마디로 이동할 수 있어."+#CRLF$+"두 마디에 화음을 다 입력하면"+#CRLF$+"오른쪽 제스처로 다음 마디로 넘겨봐!", pos_x, pos_y)         
    Case 9
     
      
      ant_saying_lv3("잘못 입력했을 때도 OO 제스처로 다시 입력할 수 있어", pos_x, pos_y)
      
    Case 10
      ant_saying_lv3("화음까지 다 입력했다면,"+#CRLF$+"입력한 화음이 멜로디랑 같이 어떤 소리를 낼지 궁금할거야", pos_x, pos_y) 
      
    Case 11
      ant_saying_lv3("OO제스처를 통해 우리가 만든 곡을 한번 들어봐", pos_x, pos_y)   
      
    Case 12
      ant_saying_lv3("혹시 마음에 들지 않는다면"+#CRLF$+"OO제스처로 화음이나 음 입력 모드로 돌아가서"+#CRLF$+"OO제스처로 수정한 다음에 다시 들어볼 수 있어", pos_x, pos_y)   
      
    Case  13  
      ant_saying_lv3("마음에 든다면 OO제스처로 곡을 완성해줘!"+#CRLF$+"그러면 1, 2단계에서 배운 내용을 잘 적용했는지 확인할 수 있을거야", pos_x, pos_y)   
     Case 14
      
       ant_saying_lv3("그러면 게임 시작!", pos_x, pos_y)
    Case 15    
      *p = FindSprite_lv3("ant_say")
      SetMySprite_lv3(*p, 900, 500, 0)
       *p = FindSprite_lv3("ant_tuto")   
      SetMySprite_lv3(*p, 900, 500, 0)
      Tutorial_lock_Lv3 = #False  
      
  EndSelect
  
    If Tutorial_Num_Lv3 = 1
    StartDrawing(ScreenOutput())  
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Font15))
    DrawText(1430+2*Sin(x), 680, "다음" , RGB(0,0,0))
    ;  DrawText(100-2*Sin(x), 150, "이전" , RGB(255,255,255))
    StopDrawing()
  ElseIf Tutorial_Num_Lv3 = 15
    StartDrawing(ScreenOutput())  
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Font15))
    ;  DrawText(1300+2*Sin(x), 150, "다음" , RGB(0,255,255))
    DrawText(1000-2*Sin(x), 680, "이전" , RGB(0,0,0))
    StopDrawing()
  Else
    StartDrawing(ScreenOutput())  
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Font15))
    DrawText(1430+2*Sin(x), 680, "다음" , RGB(0,0,0))
    DrawText(1000-2*Sin(x), 680, "이전" , RGB(0,0,0))
    StopDrawing()
  EndIf  
  
  
EndProcedure





Procedure ClearNote_lv3()
  
  For i=0 To 3 
    ForEach bar_list_lv3(i)\note_lv3()
      bar_list_lv3(i)\note_lv3()\active = 0
    Next
    
    ForEach bar_list_lv3(i)\chord()
      bar_list_lv3(i)\chord()\active = 0
    Next
  Next
  
  
  ForEach sprite_list_lv3()
    FrameManager_lv3(sprite_list_lv3()) 
  Next
  
  
  For i=0 To 3
    currentTime = GetTickCount_()
    ForEach bar_list_lv3(i)\note_lv3()
      FrameManager_lv3(bar_list_lv3(i)\note_lv3())
    Next
    
    currentTime = GetTickCount_()
    ForEach bar_list_lv3(i)\chord()
      FrameManager_lv3(bar_list_lv3(i)\chord())
    Next
  Next
  
  
  ClearScreen(RGB(255, 255, 255))
  
  ForEach sprite_list_lv3()
    DrawMySprite_lv3(sprite_list_lv3())
  Next
  
  
  For i=0 To 3 
    ForEach bar_list_lv3(i)\note_lv3()
      DrawMySprite_lv3(bar_list_lv3(i)\note_lv3())
    Next
    
    ForEach bar_list_lv3(i)\chord()
      DrawMySprite_lv3(bar_list_lv3(i)\chord())
    Next
    
  Next
EndProcedure


;전체 재생해주는 함수
Procedure PlayAll_lv3()
  
  Repeat
    
    ClearNote_lv3()
    
    ForEach bar_list_lv3(i)\note_lv3()
      
      note_lv3 = bar_list_lv3(i)\note_lv3()\num
      beat = bar_list_lv3(i)\note_lv3()\beat
      
      bar_list_lv3(i)\note_lv3()\active = 1
      currentTime = GetTickCount_()
      FrameManager_lv3(bar_list_lv3(i)\note_lv3())
      DrawMySprite_lv3(bar_list_lv3(i)\note_lv3())
      
      If bar_list_lv3(i)\note_lv3()\x = 800
        *p.mySprite_lv3 = FirstElement(bar_list_lv3(i)\chord())
        chord = *p\num
        *p\active = 1
        GetChord(chord)
        PlayChordSound_lv3()
        
        ;Debug("2*i+1 = "+ Str(2*i+1))
        
        
        ;         If i <> 0
        ;           *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*i))
        ;           *b\active = 0
        ;           *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(2*i))
        ;           *b\active = 1
        ;         EndIf
        ;         *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(2*i+1))
        ;         *b\active = 0
      ;  *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*i+1))
       ; *b\active = 1
        
        
         If i<3
          *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*i+1)) ;==============================================
          *b\active = 0
          *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(2*i+1))            ;==============================================
          *b\active = 1
          
          *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*(i+1)+1)) ;==============================================
          *b\active = 1                                           ;==============================================
        EndIf
        
        
      ElseIf bar_list_lv3(i)\note_lv3()\x = 1160
        *p.mySprite_lv3 = LastElement(bar_list_lv3(i)\chord())
        chord = *p\num
        *p\active = 1
        GetChord(chord)
        PlayChordSound_lv3()
        
        ;Debug("2*i+2 = "+ Str(2*i+2))
        ;         If i*2+1 <> 0
        ;         *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*i+1))
        ;         *b\active = 0
        ;         *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(2*i+1))
        ;         *b\active = 1
        ;         EndIf
        ;         
        ;         *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(2*i+1))
        ;*b\active = 0
        
        
    ;    *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*i+2))
    ;    *b\active = 1
        
        
         If i<3
          *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*i+2)) ;==============================================
          *b\active = 0
          *b.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(2*i+2))            ;==============================================
          *b\active = 1
          
          *b.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2*(i+1)+2)) ;==============================================
          *b\active = 1                                           ;==============================================
        EndIf

      EndIf  
      
      currentTime = GetTickCount_()
      FrameManager_lv3(sprite_list_lv3())
      FrameManager_lv3(bar_list_lv3(i)\chord())
      
      DrawMySprite_lv3(sprite_list_lv3())
      DrawMySprite_lv3(bar_list_lv3(i)\chord())
      
      
      midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_lv3(note_lv3) << 8 | 127 << 16 )
      Delay(beat)
      midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_lv3(note_lv3) << 8 | 0 << 16)
      
      FlipBuffers()
      
    Next
    
    i = i + 1
  Until i = 4
  
EndProcedure


Procedure Scoring_lv3()
  
  ;===========================멜로디-코드 매칭 채점==================================
  
  Dim checkNote.Bar_lv3(7)
  
  For i=0 To 3
    ForEach bar_list_lv3(i)\note_lv3()
      *p.mySprite_lv3 = bar_list_lv3(i)\note_lv3()
      ;강박인 음을 기준으로 채점(마디 첫음 혹은 길이가 긴 음)
      If *p\x = 800
        *n.mySprite_lv3 = AddElement(checkNote(2*i)\note_lv3())
        *n\num =*p\num
      ElseIf *p\x = 1160
        *n.mySprite_lv3 = AddElement(checkNote(2*i+1)\note_lv3())
        *n\num =*p\num
      ElseIf *p\beat = 600
        If *p\x < 1160
          *n.mySprite_lv3 = AddElement(checkNote(2*i)\note_lv3())
          *n\num =*p\num
        Else
          *n.mySprite_lv3 = AddElement(checkNote(2*i+1)\note_lv3())
          *n\num =*p\num
        EndIf
      EndIf
    Next
    
    
    *p.mySprite_lv3 = FirstElement(bar_list_lv3(i)\chord())
    *n.mySprite_lv3 = AddElement(checkNote(2*i)\chord())
    *n\num =*p\num
    *p.mySprite_lv3 = LastElement(bar_list_lv3(i)\chord())
    *n.mySprite_lv3 = AddElement(checkNote(2*i+1)\chord())
    *n\num =*p\num
    
  Next
  
  ;flag = 1 (틀림), flag = 0 (맞음)
  For i=0 To 7
    flag = 1
    *p = FirstElement(checkNote(i)\chord())
    n = *p\num
    GetChord(n)
    ForEach checkNote(i)\note_lv3()
      m = checkNote(i)\note_lv3()\num
      If m= note_lv3(0) Or m = note_lv3(1) Or m = note_lv3(2)
        flag = 0
      EndIf
      ;       Debug("기준음 " + Str(m))
      ;       Debug("note_lv3 0 " + Str(note_lv3(0)))
      ;       Debug("note_lv3 1 " + Str(note_lv3(1)))
      ;       Debug("note_lv3 2 " + Str(note_lv3(2)))
      ;       Debug("flag " + Str(flag))
    Next
    If flag = 1
      score(i) = 1
    Else
      score(i) = 0
    EndIf
  Next
  
  
  ;===========================코드 진행 체크==================================
  
  *p.mySprite_lv3 = FirstElement(bar_list_lv3(0)\chord())
  For i=0 To 3     
    ForEach bar_list_lv3(i)\chord()
      *q.mySprite_lv3 = bar_list_lv3(i)\chord()
      
      ;G코드(5도) -> Dm(2도) or F(4도)
      If *p\num = 5 And (*q\num = 2 Or *q\num = 4)
        Debug("잘못된 코드진행")
      EndIf
      *p = *q
    Next
    
  Next
  
  
  
EndProcedure

Procedure CreateLEVEL3()
  
  Shared MainWindow
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
    *loadbox1 = cvLoadImage("graphics/graphics_lv3/chord_box.png", 1)
    *loadbox2 = cvLoadImage("graphics/graphics_lv3/chord_box2.png", 1)
    
    
    ;전체화면으로 실행
    ; If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
    If   MainWindow
      OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; 웹캠용 윈도우
      ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
      StickyWindow(1, #True) ; 항상 위에 고정
      SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(1), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; 윈도우 타이틀 바 제거
      SetForegroundWindow_(WindowID(0))                                                                                       ; 윈도우 포커스 이동
      InitSprite()
      InitKeyboard()
      
      ;Screen과 Sprite 생성
  ;    Screen_0 = OpenWindowedScreen(WindowID(Window_0), 0, 0, WindowWidth(0), WindowHeight(0))
      
      UsePNGImageDecoder()
      
      TransparentSpriteColor(#PB_Default, RGB(255, 0, 255))
      
      InitMySprite_lv3("background", "graphics/graphics_lv3/background.png", 0, 0, 0)
      InitMySprite_lv3("background2", "graphics/graphics_lv3/background2.png", 0, 0, 0, 0)
      InitMySprite_lv3("leaf1", "graphics/graphics_lv3/leaf.png", 1120, 165, 0)
      InitMySprite_lv3("leaf2", "graphics/graphics_lv3/leaf.png", 1480, 170, 0)
      InitMySprite_lv3("note1", "graphics/graphics_lv3/do.png", 0, 650, 0, 0)
      InitMySprite_lv3("note2", "graphics/graphics_lv3/re.png", 0, 650, 0, 0)
      InitMySprite_lv3("note3", "graphics/graphics_lv3/mi.png", 0, 650, 0, 0)
      InitMySprite_lv3("note4", "graphics/graphics_lv3/fa.png", 0, 650, 0, 0)
      InitMySprite_lv3("note5", "graphics/graphics_lv3/so.png", 0, 650, 0, 0)
      InitMySprite_lv3("note6", "graphics/graphics_lv3/la.png", 0, 650, 0, 0)
      InitMySprite_lv3("note7", "graphics/graphics_lv3/ti.png", 0, 650, 0, 0)
      
      InitMySprite_lv3("ant", "graphics/graphics_lv3/ant.png", 1050, Lv2_antY,0,0)
      InitMySprite_lv3("ant2", "graphics/graphics_lv3/ant.png", Lv2_antX, Lv2_antY,0,0)
      
      
      ;숫자 마디
      InitMySprite_lv3("bar1", "graphics/graphics_lv3/bar1.png", 70, 30, 0, 1)
      InitMySprite_lv3("bar2", "graphics/graphics_lv3/bar2.png", 150, 30, 0, 1)
      InitMySprite_lv3("bar3", "graphics/graphics_lv3/bar3.png", 230, 30, 0, 1)
      InitMySprite_lv3("bar4", "graphics/graphics_lv3/bar4.png", 310, 30, 0, 1)
      InitMySprite_lv3("bar5", "graphics/graphics_lv3/bar5.png", 390, 30, 0, 1)
      InitMySprite_lv3("bar6", "graphics/graphics_lv3/bar6.png", 470, 30, 0, 1)
      InitMySprite_lv3("bar7", "graphics/graphics_lv3/bar7.png", 550, 30, 0, 1)
      InitMySprite_lv3("bar8", "graphics/graphics_lv3/bar8.png", 630, 30, 0, 1)
      
      InitMySprite_lv3("bar1_a", "graphics/graphics_lv3/bar1_active.png", 70, 30, 0, 1)    
      InitMySprite_lv3("bar2_a", "graphics/graphics_lv3/bar2_active.png", 150, 30, 0, 0)  
      InitMySprite_lv3("bar3_a", "graphics/graphics_lv3/bar3_active.png", 230, 30, 0, 0)     
      InitMySprite_lv3("bar4_a", "graphics/graphics_lv3/bar4_active.png", 310, 30, 0, 0)    
      InitMySprite_lv3("bar5_a", "graphics/graphics_lv3/bar5_active.png", 390, 30, 0, 0)  
      InitMySprite_lv3("bar6_a", "graphics/graphics_lv3/bar6_active.png", 470, 30, 0, 0)    
      InitMySprite_lv3("bar7_a", "graphics/graphics_lv3/bar7_active.png", 550, 30, 0, 0)
      InitMySprite_lv3("bar8_a", "graphics/graphics_lv3/bar8_active.png", 630, 30, 0, 0)
      
      ;화음 마디
      InitMySprite_lv3("c1", "graphics/graphics_lv3/container_s.png", 70, 30, 0, 0)
      InitMySprite_lv3("c2", "graphics/graphics_lv3/container_s.png", 150, 30, 0, 0)
      InitMySprite_lv3("c3", "graphics/graphics_lv3/container_s.png", 230, 30, 0, 0)
      InitMySprite_lv3("c4", "graphics/graphics_lv3/container_s.png", 310, 30, 0, 0)
      InitMySprite_lv3("c5", "graphics/graphics_lv3/container_s.png", 390, 30, 0, 0)
      InitMySprite_lv3("c6", "graphics/graphics_lv3/container_s.png", 470, 30, 0, 0)
      InitMySprite_lv3("c7", "graphics/graphics_lv3/container_s.png", 550, 30, 0, 0)
      InitMySprite_lv3("c8", "graphics/graphics_lv3/container_s.png", 630, 30, 0, 0)
      
      
      ;튜토리얼 개미
      InitMySprite_lv3("ant_tuto", "graphics/ant.png", 800, 630, 0)
      InitMySprite_lv3("ant_say", "graphics/ant_say.png", 500,500,0)   
      
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
          
          ForEach sprite_list_lv3()
            FrameManager_lv3(sprite_list_lv3()) ;active 상태인 것들만 다음 프레임으로
          Next
          
          
          For i=0 To 3
            currentTime = GetTickCount_()
            ForEach bar_list_lv3(i)\note_lv3()
              FrameManager_lv3(bar_list_lv3(i)\note_lv3())
            Next
            
            currentTime = GetTickCount_()
            ForEach bar_list_lv3(i)\chord()
              FrameManager_lv3(bar_list_lv3(i)\chord())
            Next
          Next
          
          
          ClearScreen(RGB(255, 255, 255))
          
          ForEach sprite_list_lv3()
            DrawMySprite_lv3(sprite_list_lv3())
          Next
          
          
          For i=0 To 3 
            ForEach bar_list_lv3(i)\note_lv3()
              DrawMySprite_lv3(bar_list_lv3(i)\note_lv3())
            Next
            
            ForEach bar_list_lv3(i)\chord()
              DrawMySprite_lv3(bar_list_lv3(i)\chord())
            Next
            
          Next
          
          
            ; 처음 Tutorial_lock 걸려있는 동안은 tutorial 재생 
            If   Tutorial_lock_Lv3
              LEVEL3_Tutorial( inc_x , Tutorial_Num_Lv3)
              inc_x+1
              
            EndIf
          
          
          
          
          ;- 키보드 이벤트
          ExamineKeyboard()
          
          If KeyboardReleased(#PB_Key_1)
            keyInput = #PB_Key_1
            GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
            marker1X = mouse_x
            marker1Y = mouse_y - (WindowHeight(0)/2 - 200)
            ;marker1Y = mouse_y - (WindowHeight(0)- FrameHeight + 20)
            If (markerState = 1)
              CheckArea_lv3(keyInput)
            EndIf
          EndIf
          
          If KeyboardReleased(#PB_Key_2)
            keyInput = #PB_Key_2
            GetCursorPos_(mouse.POINT) : mouse_x=mouse\x : mouse_y=mouse\y
            marker2X = mouse_x
            marker2Y = mouse_y - (WindowHeight(0)/2 - 200)
            ;marker2Y = mouse_y - (WindowHeight(0)- FrameHeight + 20)
            If (markerState = 1)
              CheckArea_lv3(keyInput)
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
              DrawNote_lv3(currentBar)
              ;숫자 마디 비활성화
              For i=1 To 8
                *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i))
                *p\active = 0
                *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i)+"_a")
                *p\active = 0
              Next
              
              ;화음 마디 활성화
              For i=1 To 8
                *p.mySprite_lv3 = FindSprite_lv3("c"+Str(i))
                *p\active = 1
              Next
              
              ;첫번째 배경으로 변경
              *b.mySprite_lv3 = FindSprite_lv3("background")
              *b\active = 1
              *b.mySprite_lv3 = FindSprite_lv3("background2")
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
                  *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i)+"_a")
                  *p\active = 0
                Next
                
                *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+1)+"_a")
                *p\active = 1
                
                *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+2)+"_a")
                *p\active = 1
                
                ;화음 모드일 때 화음마디  
              ElseIf inputMode = 1
                For i=1 To 8
                  
                  If (i=currentBar*2+1) Or (i=currentBar*2+2)
                    *p.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(i))
                    *p\active = 1
                    *p.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(i))
                    *p\active = 0
                  Else
                    *p.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(i))
                    *p\active = 1
                  EndIf
                Next
              EndIf
              
              DrawNote_lv3(currentBar)
              
            EndIf
          EndIf
          
          
          
          If KeyboardReleased(#PB_Key_B)
            
            Tutorial_Num_Lv3 + 1
            
            
          EndIf
          
          
         If KeyboardReleased(#PB_Key_V)
            
            Tutorial_Num_Lv3 -1

          EndIf

          ;뒤의 마디로 이동
          If KeyboardReleased(#PB_Key_Right)
            
            If currentBar < 3 And barCount > currentBar 
              currentBar = currentBar+1
              ;멜로디 모드일 때 숫자마디
              If inputMode = 0
                For i=1 To 8
                  *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(i)+"_a")
                  *p\active = 0
                Next
                
                *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+1)+"_a")
                *p\active = 1
                
                *p.mySprite_lv3 = FindSprite_lv3("bar"+Str(currentBar*2+2)+"_a")
                *p\active = 1
                
                ;화음 모드일 때 화음마디  
              ElseIf inputMode = 1 And chordFlag = 0
                For i=1 To 8
                  
                  If (i=currentBar*2+1) Or (i=currentBar*2+2)
                    *p.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(i))
                    *p\active = 1
                    *p.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(i))
                    *p\active = 0
                  Else
                    *p.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(i))
                    *p\active = 1
                  EndIf           
                Next
                
              EndIf
              
              ;화음 입력 안끝났을 때(입력하는 도중)
              If chordFlag = 1
                chordFlag = 0
                
                *b.mySprite_lv3 = FindSprite_lv3("background")
                *b\active = 0
                
                *b.mySprite_lv3 = FindSprite_lv3("background2")
                *b\active = 1
                
                
                *p1.mySprite_lv3 = FindSprite_lv3("ant")
                *p1\active = 0
                *p1.mySprite_lv3 = FindSprite_lv3("ant2")
                *p1\active = 0
                
              EndIf
              
              DrawNote_lv3(currentBar)
              
            EndIf
          EndIf
          
          
          ;전체 재생
          If KeyboardReleased(#PB_Key_0)
            For i=1 To 8   
              *p.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(i))
              *p\active = 0
              *p.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(i))
              *p\active = 0        
            Next  
            
             *p.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(1))
          *p\active = 1
          *p.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(2))
          *p\active = 1
            
            
            PlayAll_lv3()
            
            ;    currentBar = 3
            
          Delay(500)
          
          ;종료하면 첫째마디로 이동
          currentBar = 0
          For i=1 To 8         
            If (i=currentBar*2+1) Or (i=currentBar*2+2)
              *p.mySprite_lv3 = FindSprite_lv3("bar_active_c"+Str(i))
              *p\active = 1
              *p.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(i))
              *p\active = 0
            Else
              *p.mySprite_lv3 = FindSprite_lv3("bar_c"+Str(i))
              *p\active = 1
            EndIf
          Next
        ;EndIf
        
        DrawNote_lv3(currentBar)
            
            
            
          EndIf
          
          ;--채점
          If KeyboardReleased(#PB_Key_9)
            ;1. 코드 진행 체크
            
            ;2. 멜로디x코드 올바른지 체크
            Scoring_lv3()
            
            For i=0 To 7
              If score(i) = 0
                ;녹색 동그라미
                InitMySprite_lv3("result"+Str(i), "graphics/graphics_lv3/result_o.png", 70+80*i, 30, 0, 1)
                
              Else
                ;빨간 동그라미
                InitMySprite_lv3("result"+Str(i), "graphics/graphics_lv3/result_x.png", 70+80*i, 30, 0, 1)
              EndIf
            Next
            
          EndIf
          
        EndIf
        
        DrawBoxs_lv3(*image)
        
        *mat.CvMat = cvEncodeImage(".bmp", *image, 0)     
        Result = CatchImage(1, *mat\ptr)
        SetGadgetState(0, ImageID(1))     
        cvReleaseMat(@*mat)  
        
        FlipBuffers()
        
        
        If  KeyboardPushed(#PB_Key_8)
          
          FreeImage(pbImage)
          cvReleaseCapture(@*capture)
          midiOutReset_(hMidiOut)
          midiOutClose_(hMidiOut)
          CloseWindow(1)
          
          Break 
          
        EndIf 
        
        
      Until WindowEvent() = #PB_Event_CloseWindow Or KeyboardReleased(#PB_Key_8)
    EndIf
    ; FreeImage(pbImage)
    ; cvReleaseCapture(@*capture)
    
    
    ; midiOutReset_(hMidiOut)
    ; midiOutClose_(hMidiOut)
    
    ;  ForEach sprite_list_lv3()
    ;    FreeStructure(sprite_list_lv3())
    ;  Next
    
    ;For i=0 To 3 
    ;  ForEach bar_list_lv3(i)\note_lv3()
    ;    FreeStructure(bar_list_lv3(i)\note_lv3())
    ;  Next
    
    ;  ForEach bar_list_lv3(i)\chord()
    ;    FreeStructure(bar_list_lv3(i)\chord())
    ;  Next
    
    ; Next
    
    
  Else
    MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
  EndIf
  
  
  
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 1011
; FirstLine = 245
; Folding = IAAM9
; EnableXP
; DisableDebugger
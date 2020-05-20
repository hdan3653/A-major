
IncludeFile "includes/cv_functions.pbi"
;EnableExplicit

Enumeration
  #MainForm
EndEnumeration

;Enumeration Status
;  #Status_GameBeforeFirstStart
;  #Status_GameInPlay
;  #Status_GameEndingAnimation
;  #Status_GameRestartReady
;  #Status_GameInPause
;EndEnumeration

Enumeration Sound
  #Sound_Logo
  #Sound_GameInPause
  #Sound_GameInPlay
  #Sound_FindTarget
EndEnumeration

Enumeration Image
  #Image_Background
EndEnumeration


Global Event
Global Font15, Font20, font25, font40
Global ScreenDefaultColor, GameDefaultColor, GameColor, TextColor, LineColor, GameOpacity
Global Text.s 

Global EffectX, EffectY, EffectW, EffectH
Global LayerEffectFG    ;Forground layer Effect
Global LayerEffectBG    ;Background layer Effect
Global LayerMessage     ;Message layer

;Game Sprite
Global Game

;Message
Global TextPause.s = "Pause"


Declare LayerEffectReset(Color = #PB_Ignore)

;Engine Init
InitSprite()
InitSound()
InitKeyboard()

;Setup Font
Font15 = LoadFont(#PB_Any, "System", 15)
Font20 = LoadFont(#PB_Any, "System", 20)
Font25 = LoadFont(#PB_Any, "System", 23)
Font40 = LoadFont(#PB_Any, "System", 40,#PB_Font_Bold)

;Setup Screen Color
ScreenDefaultColor    = RGB(215, 73, 11)
TextColor             = RGB(0, 0, 0)

;Setup Sound


;Setup Sprite
UsePNGImageDecoder()
LoadImage(#Image_Background, "MAIN.png")



;Screen
;OpenWindow(#MainForm, 0, 0, 600, 600, "Crazy Snake", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
;OpenWindowedScreen(WindowID(0), 0, 0, 600, 600)



;PlaySound(#Sound_Logo, #PB_Sound_MultiChannel, 50)
;PlaySound(#Sound_GameInPause, #PB_Sound_Loop , 50)





;###########################################################################################





;EnableExplicit
;Global Event
Global SceneNumber
Global GameState
;Message
Global TextPause.s = "Pause"


Enumeration
  #MainForm
EndEnumeration

Enumeration Scene
  #StartScene
  #SceneLevel1
  #SceneLevel2
  #SceneLevel3
EndEnumeration

Enumeration Status
  #Status_GameBeforeFirstStart
  #Status_GameInPlay
  #Status_GameEndingAnimation
  #Status_GameRestartReady
  #Status_GameInPause
EndEnumeration

;Enumeration Sound
 ; #Sound_Logo
 ; #Sound_GameInPause
 ; #Sound_GameInPlay
 ; #Sound_FindTarget
;EndEnumeration

;----------------------------
;UB2D----------------------------
Enumeration
	#Window
	#Gadget_Button
	#Gadget_DisabledButton
	#Gadget_ListView
	#Gadget_StringInput
	#Gadget_CheckBox
	#Gadget_Progessbar
	#Gadget_Slider
	#Gadget_Spin
EndEnumeration
;---------------------------------
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Stage 1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력, 키보드 3으로 정답 화음 재생

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


Global Window_0, Screen_0, Window_1
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, answerTone, threadStatus, currentThread, currentTime, currentProblem.i
Global Dim ptBox.CvPoint(7, 4)
Global NewList sprite_list.mySprite()
Global NewList position_list.myPosition()
Global Dim problem_list.Problem(2)

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
  problem_list(1)\note1 = 1
  problem_list(1)\note2 = 4
  problem_list(1)\answer = 6
  problem_list(2)\note1 = 2
  problem_list(2)\note2 = 5
  problem_list(2)\answer = 7
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
  *q\x = 730
  *q\active = 1
  *q = FindSprite("antmove")
  *q\x = 730
  *q\active = 0
  *q\present = -1
  *q = FindSprite("container")
  *q\x = 790
  *q = FindSprite("note" + Str(problem_list(currentProblem)\note1))
  *q\x = 800
  *q = FindSprite("note" + Str(problem_list(currentProblem)\note2))
  *q\x = 840
EndProcedure 

; 콘솔에 정답 여부 출력
Procedure AnswerCheck()
  
  If problem_list(currentProblem)\answer = answerTone+1
    PrintN("Correct")
  Else
    PrintN("Wrong")
  EndIf 
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
  
  SortArray(note(), #PB_Sort_Ascending)
  
  second = note(1) - note(0) - 1
  third = note(2) - note(1) - 1
  
  Select note(0)
    Case 1
      first = 1
      second = 6*second - second*(second+1)/2
    Case 2
      first = 16
      second = 5*second - second*(second+1)/2
    Case 3
      first = 26
      second = 3*(second-1)
    Case 4
      first = 32
    Case 5
      first = 35
  EndSelect
  
  chord = first + second + third
  
  PlaySound(chord+6)
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

; 음 클릭 시 동작하는 애니메이션과 사운드 재생
Procedure DropNote()  
  
  y = 200
  x = 820 + answerTone*80
  
  *p.mySprite = FindSprite("line"+Str(answerTone+1))
  *p\active = 0
  *p = FindSprite("lineclipped")
  *p\active = 1
  *p\x = x+35
  *p = FindSprite("scissors")
  *p\x = x
  *p\active = 1
  *p = FindSprite("note"+Str(answerTone+1))
  
  *answer.mySprite = AddElement(sprite_list())
  *answer\sprite_id = CopySprite(*p\sprite_id, #PB_Any)
  *answer\sprite_name = "answer1"
  SetMySprite(*answer, x + 20, 500, 1)
  
  *ant.mySprite = FindSprite("ant")
  *ant\active = 0
  *antmove.mySprite = FindSprite("antmove")
  *antmove\active = 1
  *container.mySprite = FindSprite("container")
  *note1.mySprite = FindSprite("note" + Str(problem_list(currentProblem)\note1))
  *note2.mySprite = FindSprite("note" + Str(problem_list(currentProblem)\note2))
  
  InitMyPosition(*answer, 0, 10, 0, 650, 0)
  InitMyPosition(*antmove, 10, 0, 760 + answerTone*80, 0, 20)
  InitMyPosition(*container, 10, 0, 820 + answerTone*80, 0, 20)
  InitMyPosition(*note1, 10, 0, 830 + answerTone*80, 0, 20)
  InitMyPosition(*note2, 10, 0, 870 + answerTone*80, 0, 20)
  
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
  PlayChordSound(1)
  Delay(500)
  AnswerCheck()
  Delay(500)
  
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
    PlayPianoSound(tone)
    answerTone = tone
    DropNote()
  EndIf
  
EndProcedure

OpenConsole()
markerState = 0 ; 마커 입력 상태

InitProblem()

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

; 화음 wav파일 불러오기
For i = 1 To 35
  file$ = "chord/"+Str(i)+".wav"
  result = LoadSound(6+i, file$)
Next

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



;@@@@@@@@@@@@@@@@@@@@@@@@Stage 2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


;-- TODO
; 소리 출력
; 세세한 이미지 좌표 조정
; 정답 체크
; 문제 데이터에서 읽기


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
Global Dim problem_list2.Problem_Lv2(1)

Global currentBar.i
Global MaxBar = 8 ; 최대 8마디
Global Lv2_antX = 730
Global Lv2_antY = 630
Global Lv2_noteY = 610
Global Lv2_contX = 590
Global Lv2_contY = 600




Procedure InitProblem2()
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
  
  problem_list2(0) = problem
  problem_list2(1) = problem
  
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
  
  problem.Problem_Lv2 = problem_list2(currentProblem)
  
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

InitProblem2()

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

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


Enumeration  
  #mainform                 
  #background
  #ground
    
  #bird       
  
  #soundforest
EndEnumeration

Global Event          

;Structure type d'un sprite
;Les informations obligatoires sont pr??? d'un *
Structure Sprite 
  Actif.b              ; Actif
  
  x.i                  ; * Position en X du sprite
  y.i                  ; * Position en Y du sprite
    
  Animation.i          ; * Animation en cours
  CurrentFrame.i       ; Indique quelle image de l'animation est actuellement en cours 
  
  FrameWidth.i         ; * Largeur de chaque image de l'animation
  FrameHeight.i        ; * hauteur de chaque image de l'animation
  FrameMax.i           ; * Nombre d'image maximum pour une animation
  
  FrameRate.i          ; * Transition entre deux images (Ms)
  FrameTimeLife.i      ; Indique la dur? d'affichage de l'image en cours
    
  VelocityX.i          ; Vitesse d?lacement en X
  VelocityY.i          ; Vitesse d?lacement en Y
    
  SpriteWidth.i        ; * Largeur du sprite 
  SpriteHeight.i       ; * Hauteur du sprite 
  
  Life.i               ; Nombre de vie d'un sprite (Aucune utilit?dans ce code)            
  
  Opacity.i            ; * Opacit?(0 ?255)
  
EndStructure 

;D
Global bird.Sprite

;D?inition de l'animation
;Chaque variable d?ermine le num?o de la rang? de l'image qui sera pris en compte pour l'animation
;0 Sera la premiere rang?.

Global AnimationLeft  = 0 ;1er rang? de l'image
Global AnimationRight = 1 ;2eme rang? de l'image 
Global AnimationFace  = 3 ;4eme rang?e de l'image

;Une rang? sera multipli? par la hauteur d'une image frame pour determiner ou commence la rang? suivante.

Procedure Init()
  Protected cr.b = #True
  
  UseJPEGImageDecoder()
  UsePNGImageDecoder()
  
  If InitSprite() = 0 Or InitKeyboard() = 0 Or InitMouse() = 0 And InitSound() = 0
    MessageRequester("Error", "Sprite system can't be initialized", 0)
    cr=#False
  EndIf
  
  ProcedureReturn cr
EndProcedure

;Mise ?jour du jeu
Procedure GameUpdate()
  
  DisplaySprite(#background, 0, 0)
  DisplaySprite(#ground, 0, 500) 
  
  ;Mise ?jour de l'oiseau 
  If ElapsedMilliseconds() - bird\FrameTimeLife > bird\FrameRate
    bird\FrameTimeLife = ElapsedMilliseconds()
           
    If bird\CurrentFrame < bird\FrameMax-1
      bird\CurrentFrame+1  
    Else
      bird\CurrentFrame=0  
    EndIf  
  EndIf
 
  ClipSprite(#bird, bird\CurrentFrame * bird\FrameWidth, bird\Animation * bird\FrameHeight, bird\FrameWidth ,bird\FrameHeight)
  ZoomSprite(#bird, bird\SpriteWidth, bird\SpriteHeight)
  DisplayTransparentSprite(#bird, bird\x, bird\y, bird\Opacity)  
 
  
  ;A gauche
  If KeyboardPushed(#PB_Key_Left)
    bird\Animation = AnimationLeft ;L'animation change
    bird\x - bird\VelocityX ;La position x change 
  EndIf
    
  ;A droite:
  If KeyboardPushed(#PB_Key_Right)
    bird\Animation = AnimationRight ;L'animation change
    bird\x + bird\VelocityX ;La position x change 
  EndIf
  
  
  ;Si on relache une des deux touches Left or Right
  If KeyboardReleased(#PB_Key_Left) Or KeyboardReleased(#PB_Key_Right)
    bird\Animation = AnimationFace
  EndIf
  
    
EndProcedure

Procedure GameStart()
  
      ;Ambience foret
      LoadSound(#soundforest, "data/sounds/ambientforest.wav")
      PlaySound(#soundforest, #PB_Sound_Loop) 
            
      ;Image de fond et sol
      LoadSprite(#background, "data/images/background.jpg")
      LoadSprite(#ground, "data/images/ground.jpg")
            
      ;L'oiseau
      LoadSprite(#bird, "data/images/bird.png", #PB_Sprite_AlphaBlending)
      
      ;Caract?istique de l'animation
      ;Chaque image fait 64x64 pixels et il y a 4 images par ligne
      bird\FrameWidth = 64
      bird\FrameHeight = 64
      bird\FrameMax = 4
      bird\FrameRate = 130
      
      ;Animation au depart du jeu
      bird\Animation = AnimationFace
      
      ;V?ocit?du sprite 
      bird\VelocityX = 5
      
      ;Coordonn?s x,y et taille du sprite
      bird\x = 400
      bird\y = 200 
      bird\SpriteWidth = 80
      bird\SpriteHeight = 80
      
      bird\Opacity = 255
      
      ;-Boucle evenementielle
      Repeat  
        Repeat
          event = WindowEvent()
          Select event  
            Case #PB_Event_CloseWindow
            End
          EndSelect  
        Until event=0
    
        FlipBuffers()
        ClearScreen(RGB(0,0,0))
                
        ExamineKeyboard()
        ExamineMouse()
        GameUpdate()

        ;  Until KeyboardPushed(#PB_Key_Escape) 
        If KeyboardPushed(#PB_Key_0)
          SceneNumber = #StartScene
          EndIf
        
        Until KeyboardPushed(#PB_Key_0) 
  
EndProcedure




;Engine Init
InitSprite()
InitSound()
InitKeyboard()

;Setup Sprite
UsePNGImageDecoder()


;Screen
; 여기서 FrameWidth 랑 FrameHeight로 윈도우 크기 정하는게 아니라 #PB_Window_Maximize 이거 떄문인데 FrameHeight...?
; 여기말고 저기 아래서 사용한 Framewidth랑 Frameheight는 cam 크기인듯?? 요기 
; 화면 크기야 조절하면 되니까... 일단 보류
OpenWindow(0, 0, 0, 1000, 1000, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
;OpenWindow(#MainForm, 0, 0, 600, 600, "Scene Manage Test", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, 1000, 1000)

;###########################################################################################




;-Event Loop
Repeat
  
 ; WX = WindowX(#MainForm, #PB_Window_FrameCoordinate)
 ; WY= WindowY(#MainForm, #PB_Window_FrameCoordinate)  
  
  Repeat
    Event = WindowEvent()
    
    Select Event   
      Case #PB_Event_CloseWindow
        End
    EndSelect 
  Until Event=0
  
  FlipBuffers()
  ClearScreen(RGB(0, 0, 0))
  
  If ExamineKeyboard() = 0 And GameState = #Status_GameInPlay ;Lost focus
    GameState = #Status_GameInPause 
    PauseSound(#Sound_GameInPlay)
  EndIf
    
  If GameState = #Status_GameRestartReady Or GameState = #Status_GameBeforeFirstStart
    
    If KeyboardReleased(#PB_Key_Up)
      
      GameState = #Status_GameInPlay 
  

      GameColor = GameDefaultColor
      GameOpacity = 255
      
      LayerEffectReset()
    EndIf
  EndIf
  
  If GameState = #Status_GameInPlay Or GameState = #Status_GameInPause 
    
    ;-Keyboard events
    If KeyboardPushed(#PB_Key_Left) And KLR = #True
      dir.s = "G"
    ElseIf KeyboardPushed(#PB_Key_Right) And KLR = #True
      dir.s = "D"
    ElseIf KeyboardPushed(#PB_Key_Up) And KUD = #True
      dir.s = "H"
    ElseIf KeyboardPushed(#PB_Key_Down) And KUD = #True
      dir.s = "B"
    ElseIf KeyboardReleased(#PB_Key_Space)
      If GameState = #Status_GameInPause 
        GameState = #Status_GameInPlay
        ResumeSound(#Sound_GameInPlay)
      Else
        GameState = #Status_GameInPause 
      EndIf
    EndIf
    
    If GameState = #Status_GameInPause
        StartDrawing(ImageOutput(LayerMessage))
        DrawingMode(#PB_2DDrawing_AllChannels)
        Box(0, 0, 400, 400, RGBA(255, 255, 255, 50))    
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawingFont(FontID(Font40))
        
        DrawRotatedText((400-TextWidth(TextPause))/2, (400-TextHeight(TextPause))/2, TextPause, 0, RGBA(255, 255, 255, 120))
        StopDrawing()
    EndIf      

    ;- Updates the position of the snake
   

  EndIf
  
  ;- Drawing Game
  
  ;0 - Draw Score 
  StartDrawing(ScreenOutput())
  ;Box(0, 0, 600, 600, ScreenDefaultColor)
  DrawImage(ImageID(#Image_Background), 0, 0, 1000 , 1000)  
 
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(Font20))
  DrawText(20, 15, "A-MAJOR", TextColor)
  DrawText(20, 50, "USER NAME", TextColor)

  StopDrawing()
  

  
    
  ;- Display game
  If GameState <> #Status_GameRestartReady And GameState <> #Status_GameBeforeFirstStart
   
  EndIf

  ;- Game effect
  If GameState = #Status_GameInPlay 
  
    If SceneNumber = #StartScene
      
     
      Repeat
      FlipBuffers()

     

  If ExamineKeyboard() = 0  ;ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ
  EndIf
  
    If KeyboardPushed(#PB_Key_Left)
      SceneNumber = #SceneLevel1
    ElseIf   KeyboardPushed(#PB_Key_Right)
      SceneNumber = #SceneLevel3
    ElseIf KeyboardPushed(#PB_Key_Up)
      SceneNumber = #SceneLevel2
    ElseIf KeyboardPushed(#PB_Key_Space)
      GameState = #Status_GameInPause
    EndIf
  ;Scene Level 1
  If SceneNumber = #SceneLevel1
    If Init()
    GameStart()
    Else
     MessageRequester("Oops !", "Impossible d'intialiser l'environnement 2D")
      EndIf
  ;Scene Level 2  
    ElseIf SceneNumber = #SceneLevel2
      
  Repeat
  nCreate + 1
  *capture.CvCapture = cvCreateCameraCapture(0)
  Until nCreate = 5 Or *capture
  nCreate = 0    
      
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
    
    InitMySprite("background", "graphics/background.png", 0, 0)
    InitMySprite("line1", "graphics/line1.png", 820, 160)
    InitMySprite("line2", "graphics/line2.png", 900, 160)
    InitMySprite("line3", "graphics/line3.png", 980, 160)
    InitMySprite("line4", "graphics/line4.png", 1060, 160)
    InitMySprite("line5", "graphics/line5.png", 1140, 160)
    InitMySprite("line6", "graphics/line6.png", 1220, 160)
    InitMySprite("line7", "graphics/line7.png", 1300, 160)
    InitMySprite("lineclipped", "graphics/line_clipped.png", 0, 160, 0)
    InitMySprite("scissors", "graphics/cut.png", 0, 200, 0)
    InitMySprite("container", "graphics/container.png", 790, 600)
    InitMySprite("note1", "graphics/do.png", 0, 650, 0)
    InitMySprite("note2", "graphics/re.png", 0, 650, 0)
    InitMySprite("note3", "graphics/mi.png", 0, 650, 0)
    InitMySprite("note4", "graphics/fa.png", 0, 650, 0)
    InitMySprite("note5", "graphics/so.png", 0, 650, 0)
    InitMySprite("note6", "graphics/la.png", 0, 650, 0)
    InitMySprite("note7", "graphics/ti.png", 0, 650, 0)
    InitMySprite("ant", "graphics/ant.png", 730, 630)
    InitMySprite("antmove", "graphics/antmove.png", 730, 630, 0)
    
    x_note1 = 800
    x_note2 = 840
    y_note1 = 610
    
    currentProblem = Random(2) ; 문제 랜덤 선택
    
    *p.mySprite =  FindSprite("note" + Str(problem_list(currentProblem)\note1))
    SetMySprite(*p, x_note1, y_note1, 1)
    *p = FindSprite("note" + Str(problem_list(currentProblem)\note2))
    SetMySprite(*p, x_note2, y_note1, 1)
    *p = FindSprite("antmove")
    *p\f_horizontal = 4
    *p\f_width = 65
    *p\f_height = 69
    
    ClearScreen(RGB(255, 255, 255))
    
    Repeat
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
      ;  ExamineKeyboard()
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
      
              ;  Until KeyboardPushed(#PB_Key_Escape) 
        If KeyboardPushed(#PB_Key_0)
          SceneNumber = #StartScene
          cvReleaseCapture(@*capture)
            FreeImage(pbImage)
            ; cvReleaseCapture(@*capture)
                 CloseWindow(1)
          
       ;    ForEach sprite_list()
     ;    FreeStructure(sprite_list())
      ;     Next       
          EndIf
      
    Until WindowEvent() = #PB_Event_CloseWindow Or KeyboardPushed(#PB_Key_0) 

      
  EndIf
  
 ; FreeImage(pbImage)
 ; cvReleaseCapture(@*capture)
 ; ForEach sprite_list()
 ;   FreeStructure(sprite_list())
 ; Next  
  
 
  

Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf
      
      
  ;Scene Level 3
  ElseIf SceneNumber = #SceneLevel3 
    
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
      ;Until KeyboardPushed(#PB_Key_Escape) 
      
        If KeyboardPushed(#PB_Key_0)
          SceneNumber = #StartScene
          cvReleaseCapture(@*capture)
          CloseWindow(1)
          EndIf
      
    Until WindowEvent() = #PB_Event_CloseWindow Or KeyboardPushed(#PB_Key_0) 
  
  EndIf
  
;  FreeImage(pbImage)
;  cvReleaseCapture(@*capture)
  
 ; ForEach sprite_list()
 ;   FreeStructure(sprite_list())
 ; Next
  
 ; FreeStructure(position_list())
  ;FreeStructure(problem_list2())
  
 ; cvReleaseCapture(@*capture)
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf
    
  EndIf  
 
  
Until KeyboardPushed(#PB_Key_Escape)



EndIf 
  EndIf
  
  ;Out of bound or Game over
  If GameState = #Status_GameInPlay

    
  EndIf
  
  If GameState = #Status_GameEndingAnimation
  ;  If SpriteWidth(Game) <> 10
  ;    
  ;  Else
  ;    GameState = #Status_GameRestartReady 
  ;  EndIf
  EndIf
  
  
  ;- Game Over
  If GameState = #Status_GameRestartReady Or GameState = #Status_GameBeforeFirstStart
    
    If Score > BestScore
      BestScore = Score
    EndIf
    
    StartDrawing(ScreenOutput())
    
    DrawingMode(#PB_2DDrawing_Transparent)
    
    If GameState = #Status_GameBeforeFirstStart
      DrawingFont(FontID(Font25))
      Text = "MAIN DISPLAY"
      DrawText((600 - TextWidth(Text))/2, 130, Text, TextColor)   
    Else
      
      ;#Status_GameRestartReady
      
    EndIf
    
    Text = "Press UP Arrow Key"
    
    
    
    DrawingFont(FontID(Font20))
    DrawText((600 - TextWidth(Text))/2, 400 , Text, TextColor )
    
    StopDrawing()
  EndIf
  
Until KeyboardPushed(#PB_Key_Escape)

Procedure LayerEffectReset(Color = #PB_Ignore)
  If Color = #PB_Ignore
    GameColor = GameDefaultColor
  Else
    GameColor = Color
  EndIf
  
  StartDrawing(ImageOutput(LayerEffectFG))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Box(0, 0, 400, 400, RGBA(0, 0, 0, 0))
  StopDrawing()
  
  StartDrawing(ImageOutput(LayerEffectBG))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Box(0, 0, 400, 400, RGBA(0, 0, 0, 0))
  StopDrawing()
  
EndProcedure

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 14
; Folding = -----
; Markers = 1181,1239,1575
; EnableXP
; Executable = CrazySnake.exe
; IncludeVersionInfo
; VersionField0 = 0,0,0,0
; VersionField1 = 0.0.0.0
; VersionField2 = falsam
; VersionField3 = Crazy Snake
; VersionField4 = 1.0
; VersionField5 = 1.0
; VersionField9 = falsam
; VersionField12 = Make with PureBasic
; VersionField13 = falsam@falsam.com
; VersionField14 = falsam.com
; Watchlist = GameState
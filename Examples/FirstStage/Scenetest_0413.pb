IncludeFile "../OpenCV_32/includes/cv_functions.pbi"
IncludeFile "LEVEL1.pb"

;EnableExplicit
Global Event
Global SceneNumber
Global GameState
;Message
Global TextPause.s = "Pause"


Enumeration
  #MainForm
EndEnumeration

Enumeration Scene
  #StartScene
  #MenuSelect
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

Enumeration Image
  #Image_MAIN
  #Image_MENU
EndEnumeration

Enumeration Sound
  #Sound_Logo
  #Sound_GameInPause
  #Sound_GameInPlay
  #Sound_FindTarget
EndEnumeration


Enumeration  
  #mainform                 
  #background
  #ground
  #bird       
  #soundforest
EndEnumeration

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
LoadImage(#Image_MAIN, "MAIN.png")
LoadImage(#Image_MENU, "MENU.png")
Global Event          





; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력, 키보드 3으로 정답 화음 재생


Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, answerTone.i, currentTime, currentProblem.i, spriteinitial.i
Global.l hMidiOut

spriteinitial = 1

; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@LEVEL 1 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


Global Dim ptBox.CvPoint(7, 4)
Global NewList sprite_list.mySprite()
Global NewList position_list.myPosition()
Global Dim problem_list.Problem(17)
Global Dim PosLine(6)

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

OutDev.l
result = midiOutOpen_(@hMidiOut, OutDev, 0, 0, 0)
PrintN(Str(result))


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


;@@@@@@@@@@@@@@@@@LEVEL 2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


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
Global NewList sprite_list2.mySprite()
Global NewList position_list2.myPosition()
Global Dim problem_list2.Problem_Lv2(1)

Global currentBar.i
Global MaxBar = 8 ; 최대 8마디
Global Lv2_antX = 730
Global Lv2_antY = 630
Global Lv2_noteY = 610
Global Lv2_contX = 590
Global Lv2_contY = 600




Procedure InitMySprite2(name.s, filename.s, x.i, y.i, active.i = 1) ;active는 옵션
                                                                   ; 스프라이트 구조체 초기화
  CreateSprite(#PB_Any, width, height)
  mysprite = LoadSprite(#PB_Any, filename.s)
  *newsprite.mySprite = AddElement(sprite_list2())
  
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


;myPosition 초기화
Procedure InitMyPosition2(*sprite.mySprite, xmove.i, ymove.i, xmax.i, ymax.i, startdelay.i)
  *this.myPosition = AddElement(position_list2())
  
  *this\sprite = *sprite
  *this\xmove = xmove
  *this\ymove = ymove
  *this\xmax = xmax
  *this\ymax = ymax
  *this\startdelay = startdelay
EndProcedure

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

; sprite_list2 에서 이름으로 구조체 찾기. 퓨베 특성상 current element 이슈 때문에 도중에 일치해도 끝까지 루프를 돌아야함
Procedure FindSprite2(name.s)
  *returnStructure.mySprite
  
  ForEach sprite_list2()
    If sprite_list2()\sprite_name = name
      returnStructrue = sprite_list2()
    EndIf 
  Next
  
  ProcedureReturn returnStructrue
EndProcedure

;초기 화면구성으로 재설정하는 함수
Procedure InitialSetting2()
  
  ;   *p.mySprite = LastElement(sprite_list2()) ;answer sprite
  ;   DeleteElement(sprite_list2())
  ;   
  ;   *q.mySprite = FindSprite2("line"+Str(answerTone+1))
  ;   *q\active = 1
  ;   *q = FindSprite2("lineclipped")
  ;   *q\active = 0
  ;   *q = FindSprite2("scissors")
  ;   *q\active = 0
  ;   *q = FindSprite2("ant")
  ;   *q\x = 730
  ;   *q\active = 1
  ;   *q = FindSprite2("antmove")
  ;   *q\x = 730
  ;   *q\active = 0
  ;   *q\present = -1
  ;   *q = FindSprite2("container")
  ;   *q\x = 790
  ; ;   *q = FindSprite2("note" + Str(problem_list2(currentProblem)\note1))
  ; ;   *q\x = 800
  ; ;   *q = FindSprite2("note" + Str(problem_list2(currentProblem)\note2))
  ; ;   *q\x = 840
EndProcedure 

Procedure AnswerCheck2()
  ;   OpenConsole()
  ;   If problem_list2(currentProblem)\answer = answerTone+1
  ;     PrintN("correct")
  ;   Else
  ;     PrintN("Wrong")
  ;   EndIf 
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


Procedure PlayPianoSound2(sound.a)
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



; 좌표값 옮겨주는 함수
Procedure ChangePos2(*this.myPosition)
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
    
    DeleteElement(position_list2())
  EndIf 
  
  
EndProcedure

Procedure MoveAnt()
  Repeat
    currentTime = GetTickCount_()
    ForEach position_list2()
      ChangePos2(position_list2())
    Next
    currentTime = GetTickCount_()
    ForEach sprite_list2()
      FrameManager(sprite_list2()) ;active 상태인 것들만 다음 프레임으로
    Next
    ForEach sprite_list2()
      ;--
      PrintN(sprite_list2()\sprite_name)
      
      DrawMySprite(sprite_list2())
    Next
    FlipBuffers()
  Until ListSize(position_list2()) = 0
  
  ;answer check
  Delay(500)
  AnswerCheck()
  Delay(500)
  
EndProcedure

Procedure MakeAnt(code.i)
  
  ;-- Null pointer 체크를 하고 싶은데 어떻게 하는지 몰라
  ;   *temp.mySprite = FindSprite2("note"+Str(currentBar)+"\0")
  ;   SetMySprite(*temp, 0, 0, 0)
  
  InitMySprite2("antmove"+Str(currentBar), "../graphics/antmove.png", Lv2_antX-200, Lv2_antY)
  *p.mySprite = FindSprite2("antmove"+Str(currentBar))
  *p\f_horizontal = 4
  *p\f_width = 65
  *p\f_height = 69
  
  InitMySprite2("container"+Str(currentBar), "../graphics/container.png", Lv2_contX, Lv2_contY)
  *p2.mySprite = FindSprite2("container"+Str(currentBar))
  
  InitMyPosition2(*p, 10, 0, Lv2_antX, 0, 20)
  InitMyPosition2(*p2, 10, 0, Lv2_antX+60, 0, 20)
  
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
  
  InitMySprite2("note"+Str(currentBar)+"\0", "../graphics/"+note0+".png", note0X, note0Y)
  InitMySprite2("note"+Str(currentBar)+"\1", "../graphics/"+note1+".png", note1X, note1Y)
  InitMySprite2("note"+Str(currentBar)+"\2", "../graphics/"+note2+".png", note2X, note2Y)
  
  *n0 = FindSprite2("note"+Str(currentBar)+"\0")
  *n1 = FindSprite2("note"+Str(currentBar)+"\1")
  *n2 = FindSprite2("note"+Str(currentBar)+"\2")
  
  InitMyPosition2(*n0, 10, 0, Lv2_antX+70, 0, 20)
  InitMyPosition2(*n1, 10, 0, Lv2_antX+110, 0, 20)
  InitMyPosition2(*n2, 10, 0, Lv2_antX+90, 0, 20)
  
  MoveAnt()
  
  *p\active = 0
  *p.mySprite = InitMySprite2("ant"+Str(currentBar), "../graphics/ant.png", Lv2_antX, Lv2_antY)
  
EndProcedure



Procedure DrawBarMarker()
  posX = 100
  posY = 30
  For i=MaxBar-1 To 0 Step -1
    If i = currentBar
      InitMySprite2("barMarker"+Str(i), "../graphics/re.png", posX+i*40, posY)
      ;       *p.mySprite = FindSprite2("barMarker"+Str(i))
    Else
      InitMySprite2("barMarker"+Str(i), "../graphics/fa.png", posX+i*40, posY)
    EndIf
  Next
  
EndProcedure





; LEVEL2 
Procedure DrawNotes()
  
  problem.Problem_Lv2 = problem_list2(currentProblem)
  
  weight.f = 0.0
  distance.i = Lv2_antX
  current_bar.i = 0
  
  ; 배경 그려주기
  InitMySprite2("background_clip", "../graphics/background_clip.png", Lv2_antX-100, 0)
  
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
      InitMySprite2("background_clip", "../graphics/background_clip.png", Lv2_antX+450, 0)
      posX+160
      
    EndIf
    
    ; 음표 그리기 ; line0/2 : 0번째 마디의 3번째 음표
    spriteName.s = "line" + Str(note\posBar) + "/" + Str(note\posNote)
    PrintN(Str(i) + " : " + Str(posX) + ", " + Str(posY) + " and " + Str(weight))
    InitMySprite2(spriteName, "../graphics/line"+line_num+".png", posX, posY)
    
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


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








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
MainWindow= OpenWindow(0, 0, 0, 1920, 1080, "Main Window", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, 1920, 1080)


If SceneNumber = #StartScene
  
    StartDrawing(ScreenOutput())
  ;Box(0, 0, 600, 600, ScreenDefaultColor)
  DrawImage(ImageID(#Image_MAIN), 0, 0, 1920, 1080)  
 
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(Font20))
  DrawText(20, 15, "A-MAJOR", TextColor)
  DrawText(20, 50, "USER NAME", TextColor)

  StopDrawing()
  
  
  Repeat
  FlipBuffers()
  ;ClearScreen(RGB(0, 0, 0))
  
  
   ExamineKeyboard()
    
   
     If  ExamineKeyboard()
    If KeyboardPushed(#PB_Key_Left)
      SceneNumber = #SceneLevel2
    ElseIf   KeyboardPushed(#PB_Key_Right)
      SceneNumber = #SceneLevel1
    ElseIf KeyboardPushed(#PB_Key_Up)
      SceneNumber = #SceneLevel3
    ElseIf KeyboardPushed(#PB_Key_Space)
      GameState = #Status_GameInPause
     ElseIf KeyboardPushed(#PB_Key_Escape)
       CloseWindow(0)
       CloseConsole()
    EndIf
   EndIf 
   
   
   
  ;윈도우 해상도 별로 이미지선택하도록 해야할듯.
  If SceneNumber = #StartScene

    If KeyboardPushed(#PB_Key_All)
      ClearScreen(RGB(0, 0, 0))
      SceneNumber = #MenuSelect
    EndIf 
    
    
    
    
  ElseIf SceneNumber = #MenuSelect
    
   
  ClearScreen(RGB(0, 0, 0))
  StartDrawing(ScreenOutput())
  ;Box(0, 0, 600, 600, ScreenDefaultColor)
  DrawImage(ImageID(#Image_MENU), 0, 0, 1920, 1080)  
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(Font20))
  DrawText(20, 15, "A-MAJOR", TextColor)
  DrawText(20, 50, "USER NAME", TextColor)
  StopDrawing()    
    
    
  ElseIf SceneNumber = #SceneLevel1
    If Init()
    GameStart()
    Else
     MessageRequester("Oops !", "Impossible d'intialiser l'environnement 2D")
      EndIf
  ;Scene Level 2  
  ElseIf SceneNumber = #SceneLevel2
    CreateLevel1()
    SceneNumber = #MenuSelect
  ;Scene Level 3
  ElseIf SceneNumber = #SceneLevel3 
    CreateLevel1()
    SceneNumber = #MenuSelect
  EndIf 
  
 
  Until KeyboardPushed(#PB_Key_Escape)

EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 819
; FirstLine = 793
; Folding = ---
; EnableXP
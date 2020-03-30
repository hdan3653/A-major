IncludeFile "includes/cv_functions.pbi"

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
    Until WindowEvent() = #PB_Event_CloseWindow
  EndIf
  FreeImage(pbImage)
  cvReleaseCapture(@*capture)
  ForEach sprite_list()
    FreeStructure(sprite_list())
  Next
Else
  MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 11
; Folding = ---
; EnableXP
; DisableDebugger
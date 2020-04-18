IncludeFile "includes/cv_functions.pbi"


; microbit 사용 버전

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

Global *imgTracking.IplImage,*imgTracking2.IplImage
Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global.i keyInput, answerTone, currentTime, stageNum, answerNum
Global.l hMidiOut
Global Dim ptBox.CvPoint(7, 4)
Global NewList sprite_list.mySprite()
Global NewList position_list.myPosition()
Global Dim chord_list(5, 2)
Global Dim currentProblem(3)
Global Dim answer(2)
Global Dim line_position(6)
Global Dim elements(2) ; container 안에 3개 element spirte 구조체 포인터 저장

ProcedureC TrackRed(*imgHSV.IplImage)
  *imgThresh.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  cvInRangeS(*imgHSV, 160, 140, 40, 0, 179, 255, 255, 0, *imgThresh)
  moments.CvMoments
  cvMoments(*imgThresh, @moments, 1)
  moment10.d = moments\m10
  moment01.d = moments\m01
  area.d = moments\m00
  
  If area > 1000
    posX = moment10 / area
    posY = moment01 / area
    
    If posX >= 0 And posY >= 0 
      ;cvCircle(*imgTracking, posX, posY, 10, 0, 0, 255, 0, 2, #CV_AA, #Null)
      marker1X = posX
      marker1Y = posY
      
    EndIf
  EndIf
  
EndProcedure

ProcedureC TrackGreen(*imgHSV.IplImage)
  
  *imgThresh2.IplImage = cvCreateImage(*imgHSV\width, *imgHSV\height, #IPL_DEPTH_8U, 1)
  cvInRangeS(*imgHSV, 65 , 60, 60, 0, 80, 255, 255, 0, *imgThresh2)
  moments.CvMoments
  cvMoments(*imgThresh2, @moments, 1)
  moment10.d = moments\m10
  moment01.d = moments\m01
  area.d = moments\m00
  
  If area > 1000
    posX = moment10 / area
    posY = moment01 / area
    
    If posX >= 0 And posY >= 0
      ;cvCircle(*imgTracking, posX, posY, 10, 0, 255, 0, 0, 2, #CV_AA, #Null)
      marker2X = posX
      marker2Y = posY
    EndIf
  EndIf
EndProcedure

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
Procedure InitChords()
  chord_list(0, 0) = 1
  chord_list(0, 1) = 3
  chord_list(0, 2) = 5
  chord_list(1, 0) = 2
  chord_list(1, 1) = 4
  chord_list(1, 2) = 6
  chord_list(2, 0) = 3
  chord_list(2, 1) = 5
  chord_list(2, 2) = 7
  chord_list(3, 0) = 1
  chord_list(3, 1) = 4
  chord_list(3, 2) = 6
  chord_list(4, 0) = 2
  chord_list(4, 1) = 5
  chord_list(4, 2) = 7
  chord_list(5, 0) = 1
  chord_list(5, 1) = 3
  chord_list(5, 2) = 6
  
EndProcedure

Procedure InitProblem()
  currentProblem(0) = Random(5) ; 코드 종류
  Dim shuffle(5, 2)
  shuffle(0, 0) = 0
  shuffle(0, 1) = 1
  shuffle(0, 2) = 2
  shuffle(1, 0) = 0
  shuffle(1, 1) = 2
  shuffle(1, 2) = 1
  shuffle(2, 0) = 1
  shuffle(2, 1) = 0
  shuffle(2, 2) = 2
  shuffle(3, 0) = 1
  shuffle(3, 1) = 2
  shuffle(3, 2) = 0
  shuffle(4, 0) = 2
  shuffle(4, 1) = 0
  shuffle(4, 2) = 1
  shuffle(5, 0) = 2
  shuffle(5, 1) = 1
  shuffle(5, 2) = 0
  
  choose.i = Random(5)
  currentProblem(1) = shuffle(choose, 0)
  currentProblem(2) = shuffle(choose, 1)
  currentProblem(3) = shuffle(choose, 2)
  
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
  
  ; element 스프라이트 삭제
  If answerNum = stageNum
    For k = 0 To stageNum - 1
      LastElement(sprite_list()) ;answer sprite
      DeleteElement(sprite_list())
    Next
    answerNum = 0
  EndIf 
  
  If stageNum = 1
    *q = elements(0)
    *q\x = 780
    *q\y = 620
    *q = elements(1)
    *q\x = 830
    *q\y = 620
  ElseIf stageNum = 2
    *q = elements(0)
    *q\x = 780
    *q\y = 620
    If answerNum = 1
      *q = elements(1)
      *q\x = 830
      *q\y = 620
    EndIf 
  ElseIf stageNum = 3
    If answerNum = 1
      *q = elements(0)
      *q\x = 780
      *q\y = 620
    ElseIf answerNum = 2
      *q = elements(0)
      *q\x = 780
      *q\y = 620
      *q = elements(1)
      *q\x = 830
      *q\y = 620
    EndIf
  EndIf 
  
EndProcedure 

Procedure ChangeProblem()
  InitProblem()
  
  x_note1 = 780
  x_note2 = 830
  y_note1 = 620
  
  ; 문제 스프라이트 세팅
  If stageNum = 1
    *p.mySprite = elements(0)
    *p\active = 0
    *p = elements(1)
    *p\active = 0
    *p = FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
    SetMySprite(*p, x_note1, y_note1, 1)
    elements(0) = *p
    *p = FindSprite("bubble" + chord_list(currentProblem(0), currentProblem(2)))
    SetMySprite(*p, x_note2, y_note1, 1)
    elements(1) = *p
  ElseIf stageNum = 2
    *p.mySprite =  elements(0)
    *p\active = 0
    *p = FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
    SetMySprite(*p, x_note1, y_note1, 1)
    elements(0) = *p
  EndIf
EndProcedure

; 정답 체크
Procedure AnswerCheck()
  isCorrect = #True
  
  Dim correctAns(2)
  correctAns(0) = -1
  correctAns(1) = -1
  correctAns(2) = -1
  For k = 0 To stageNum - 1
    correctAns(k) = chord_list(currentProblem(0), currentProblem(3 - k))
  Next
  
  SortArray(correctAns(), #PB_Sort_Descending)
  SortArray(answer(), #PB_Sort_Descending)
  For k = 0 To stageNum - 1
    If correctAns(k) <> answer(k)
      isCorrect = #False
    EndIf
  Next
  
  If isCorrect = #True
    PrintN("Correct")
    *q.mySprite = elements(2)
    *q\active = 1
  Else
    PrintN("Wrong")
    *q.mySprite = FindSprite("container")
    *q\active = 0
    *q = FindSprite("failed")
    SetMySprite(*q, line_position(answerTone), 660, 1)
    *q = elements(0)
    SetMySprite(*q, *q\x, 650, 1)
    *q = elements(1)
    SetMySprite(*q, *q\x + 20, 650, 1)
    *q = elements(2)
    SetMySprite(*q, *q\x + 100, 650, 1)
  EndIf
  
  DeleteSprite("fruit1")
  ForEach sprite_list()
    DrawMySprite(sprite_list())
  Next
  FlipBuffers()
  
  ProcedureReturn isCorrect
EndProcedure

; 답안 삭제
Procedure RemoveAnswer()
  If answerNum = 0
    ProcedureReturn
  EndIf 
  
  If stageNum = 2
    *p.mySprite = elements(answerNum)
  ElseIf stageNum = 3
    *p.mySprite = elements(answerNum-1)
  EndIf 
  DeleteSprite(*p\sprite_name)
  answerNum = answerNum - 1
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
    *this\frameTime = GetTickCount_() + 50
    *this\startdelay = -1
  ElseIf  *this\startdelay = -1     
    If *this\frameTime <= currentTime
      *this\sprite\x = *this\sprite\x + *this\xmove
      *this\sprite\y = *this\sprite\y + *this\ymove
      *this\frameTime = currentTime + 50
    EndIf 
  EndIf
  
  ; 좌표 이동 끝나면 리스트에서 제거
  If *this\sprite\x = *this\xmax Or *this\sprite\y = *this\ymax
    DeleteElement(position_list())
  EndIf 
  
  
EndProcedure

; midi에 넘겨줄 음 값 계산
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
  NewList chord.i()
  
  ;flag = 0 (default)일 때 정답 화음 / 그 외엔 사용자 입력 화음 재생
  If flag = 0
    AddElement(chord())
    chord() = chord_list(currentProblem(0), 0)
    AddElement(chord())
    chord() = chord_list(currentProblem(0), 1)
    AddElement(chord())
    chord() = chord_list(currentProblem(0), 2)
  Else
    i = 3 - stageNum
    j = 1
    While i > 0
      AddElement(chord())
      chord() = chord_list(currentProblem(0), currentProblem(j))
      j = j + 1
      i = i - 1
    Wend  
    i = answerNum
    j = 0
    While i > 0
      AddElement(chord())
      chord() = answer(j)
      j = j + 1
      i = i - 1
    Wend      
  EndIf 
  
  ForEach chord()  
    midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote(chord()) << 8 | 127 << 16 )
    PrintN(Str(chord()))
  Next
  Delay(1000)
  ForEach chord()  
    midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote(chord()) << 8 | 0 << 16)
  Next
  
EndProcedure

; 음 클릭 시 동작하는 애니메이션과 사운드 재생
Procedure DropNote()  
  
  y = 200
  x = line_position(AnswerTone)
  
  *p.mySprite = FindSprite("line"+Str(answerTone+1))
  *p\active = 0
  *p = FindSprite("lineclipped")
  *p\active = 1
  *p\x = x+35
  *p = FindSprite("scissors")
  *p\x = x
  *p\active = 1
  
  ; 새 element 스프라이트 생성
  *p = FindSprite("bubble" + Str(answerTone+1))
  *bubble.mySprite = AddElement(sprite_list())
  *bubble\sprite_id = CopySprite(*p\sprite_id, #PB_Any)
  *bubble\sprite_name = "answer" + Str(answerNum)
  SetMySprite(*bubble, x + 20, 670, 0)
  
  ; 떨어지는 과일 스프라이트 생성
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
  InitMyPosition(*answer, 0, 10, 0, 650, 0)
  InitMyPosition(*antmove, 10, 0, line_position(answerTone) - 80, 0, 20)
  InitMyPosition(*container, 10, 0, line_position(answerTone) - 20, 0, 20)
  
  If stageNum = 1  
    *note1.mySprite = elements(0);FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
    *note2.mySprite = elements(1);FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(2)))) 
    InitMyPosition(*note1, 10, 0, line_position(answerTone), 0, 20)
    InitMyPosition(*note2, 10, 0, line_position(answerTone) + 50, 0, 20)
    elements(2) = *bubble
  ElseIf stageNum = 2
    *note1.mySprite = elements(0);FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
    InitMyPosition(*note1, 10, 0, line_position(answerTone), 0, 20)
    If answerNum = 1
      elements(1) = *bubble
    ElseIf answerNum = 2
      *note2.mySprite = elements(1);FindSprite("answer1")
      InitMyPosition(*note2, 10, 0, line_position(answerTone) + 50, 0, 20)
      elements(2) = *bubble
    EndIf 
  ElseIf stageNum = 3
    If answerNum = 1
      elements(0) = *bubble
    ElseIf answerNum = 2
      *note1.mySprite = elements(0);FindSprite("answer1")
      InitMyPosition(*note1, 10, 0, line_position(answerTone), 0, 20)
      elements(1) = *bubble
    ElseIf answerNum = 3
      *note1.mySprite = elements(0);FindSprite("answer1")
      InitMyPosition(*note1, 10, 0, line_position(answerTone), 0, 20)
      *note2.mySprite = elements(1);FindSprite("answer2")
      InitMyPosition(*note2, 10, 0, line_position(answerTone) + 50, 0, 20)
      elements(2) = *bubble
    EndIf 
  EndIf 
  
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
  isCorrect.i
  PlayChordSound(1)
  If answerNum = stageNum
    isCorrect = AnswerCheck()
    Delay(2000)
  Else ; 정답체크 안 하고 element만 추가
    *bubble\active = 1
    DeleteSprite("fruit1")
    ForEach sprite_list()
      DrawMySprite(sprite_list())
    Next
    FlipBuffers()
  EndIf
  
  If isCorrect = #True
    ChangeProblem()
  EndIf 
  InitialSetting()
  
EndProcedure


Procedure CheckArea(bit$)
  If(bit$ = "1")
    ;    Debug("GREEN : " + Str(marker2X) + ", " + Str(marker2Y))
    tone = CalcArea(marker2X, marker2Y)
  ElseIf(bit$ = "0")
    ;    Debug("RED : " + Str(marker1X) + ", " + Str(marker1Y))
    tone = CalcArea(marker1X, marker1Y)
  EndIf
  
  ; 음이 도-시 사이인 경우만 출력
  If tone > -1 And tone < 7
    PlayPianoSound(tone+1)
    If bit$ = "1"
      ;PlayPianoSound(tone+1)
      ProcedureReturn
    EndIf 
    answerTone = tone
    answer(answerNum) = answerTone + 1
    answerNum = answerNum + 1
    DropNote()
  EndIf
  
EndProcedure

Com = OpenSerialPort(#PB_Any, "COM3", 115200, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 64, 64)

OpenConsole()
markerState = 0 ; 마커 입력 상태
answerNum = 0
answer(0) = -1
answer(1) = -1
answer(2) = -1

InitChords()
stageNum = 3
InitProblem()

;사운드 시스템 초기화, 점검
If InitSound() = 0 
  MessageRequester("Error", "Sound system is not available",  0)
  End
EndIf

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
  *imgTracking = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *imgTracking2 = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *imgHSV.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  *imgHSV2.IplImage = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
  cvSetZero(*imgTracking)
  cvSetZero(*imgTracking2)
  
  If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
    
    OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; 웹캠용 윈도우
    ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
    StickyWindow(1, #True) ; 항상 위에 고정
    SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(1), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; 윈도우 타이틀 바 제거
    
    InitSprite()
    InitKeyboard()
    
    ;Screen과 Sprite 생성
    OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0), WindowHeight(0))
    
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
    If stageNum = 1
      *p.mySprite =  FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
      SetMySprite(*p, x_note1, y_note1, 1)
      elements(0) = *p
      *p = FindSprite("bubble" + chord_list(currentProblem(0), currentProblem(2)))
      SetMySprite(*p, x_note2, y_note1, 1)
      elements(1) = *p
    ElseIf stageNum = 2
      *p.mySprite =  FindSprite("bubble" + Str(chord_list(currentProblem(0), currentProblem(1))))
      SetMySprite(*p, x_note1, y_note1, 1)
      elements(0) = *p
    EndIf
    
    ; 애니메이션 스프라이트 세팅
    *p = FindSprite("antmove")
    *p\f_horizontal = 4
    *p\f_width = *p\width / 4
    *p\f_height = *p\height
    *p = FindSprite("scissors")
    *p\f_horizontal = 2
    *p\f_width = *p\width / 2
    *p\f_height = *p\height
    
    ClearScreen(RGB(255, 255, 255))
    
    
    Repeat
      *image = cvQueryFrame(*capture)
      ;*image = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
      
      If *image
        cvFlip(*image, #Null, 1)
        cvSmooth(*image, *image, #CV_GAUSSIAN, 3, 3, 0, 0)
        cvCvtColor(*image, *imgHSV, #CV_BGR2HSV, 1)
        cvSmooth(*imgThresh, *imgThresh, #CV_GAUSSIAN, 3, 3, 0, 0)
        cvSmooth(*imgThresh2, *imgThresh2, #CV_GAUSSIAN, 3, 3, 0, 0)
        
        ; 프레임 넘기기
        currentTime = GetTickCount_()
        ForEach sprite_list()
          FrameManager(sprite_list()) ;active 상태인 것들만 다음 프레임으로
        Next
        
        ; 렌더링
        ForEach sprite_list()
          DrawMySprite(sprite_list())
        Next
        
        If IsSerialPort(Com) <> 0
          If AvailableSerialPortInput(Com) > 0 
            ;마이크로비트 포트 값
            If ReadSerialPortData(Com, @Buffer, 1)
              micbit$ = Chr(Buffer)
              If (Asc(micbit$) < 50)
                If(micbit$ = "0")
                  ;            Debug "this is from Blue"
                  TrackRed(*imgHSV)
                  debugStr$ = "micBlue:" + Str(marker1X) + ", " + Str(marker1Y)
                ElseIf(micbit$ = "1")
                  ;            Debug "this is from Yellow"
                  TrackGreen(*imgHSV)
                   debugStr$ = "micYellow:" + Str(marker2X) + ", " + Str(marker2Y)
                 EndIf
                 PrintN(debugStr$)
                ;상태가 음 출력 상태이면 음을 출력한다
                If markerState = 1
                  CheckArea(micbit$)
                EndIf
              Else
                If(micbit$ = "2")
                  markerState = 1
                ElseIf(micbit$ = "4")
                  PlayChordSound()
                ElseIf(micbit$ = "6")
                  RemoveAnswer()
                EndIf 
                
              EndIf
            EndIf
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
    FreeImage(pbImage)
    cvReleaseCapture(@*capture)
    ForEach sprite_list()
      FreeStructure(sprite_list())
    Next
    midiOutReset_(hMidiOut)
    midiOutClose_(hMidiOut)
    
  Else
    MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
  EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 3
; Folding = -----
; EnableXP
; DisableDebugger
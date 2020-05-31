; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 1: 가입력 2: 입력 3: 악보 재생하기
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력
 
;IncludeFile "../OpenCV_32/includes/cv_functions.pbi"
IncludeFile "ReadCSV.pb"


Global LEVEL2_State

Enumeration InGameStatus
  #Stage_Tutorial
  #Status2_Intro
  #Status2_GameInPlay
  #Status2_GameInPause
  #Status2_GameEnd
EndEnumeration

 
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
 Array fixed.i(8)
 Array answers.i(8)
EndStructure
 
Global Window_0, Screen_0, Window_1
Global *rectimg.IplImage, *loadbox1.IplImage, *loadbox2.IplImage
Global markerState, marker1X, marker1Y, marker2X, marker2Y, direction
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
 
Global Tutorial_Num_Lv2 =1
Global Tutorial_lock_Lv2 = #True
 
; ################## LEVEL 2 ##################
; 좌표값 옮겨주는 함수
Procedure ChangePos_Lv2(*this.myPosition)
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
  If (*this\xmove < 0 And *this\sprite\x <= *this\xmax) Or (*this\xmove > 0 And *this\sprite\x >= *this\xmax)
   DeleteElement(position_list())
 EndIf
 If (*this\ymove < 0 And *this\sprite\y <= *this\ymax) Or (*this\ymove > 0 And *this\sprite\y >= *this\ymax)
   DeleteElement(position_list())
 EndIf
EndProcedure
 
Procedure InitProblem_Lv2()
  NewList entry.CSVEntry()
 ReadCSVFile("problems.csv", ',', entry.CSVEntry(), #CSV_WithDoubleQuotes)
  Define cnt_i.i = 0  ; i
 Define cnt_j.i = 0  ; j
 Define prob.i = 0   ; 문제 번호
  ForEach entry()
  
   If (cnt_i+1)%10 = 9 And cnt_i <> 9
     count.i = 0
     ForEach entry()\Item()
       If entry()\Item() = ""
         Break
       EndIf
      
       problem_list(prob)\answers(count) = ValD(entry()\Item())
       count+1
     Next
    
   ElseIf (cnt_i+1)%10 = 0 And cnt_i <> 0
     count.i = 0
     ForEach entry()\Item()
       If entry()\Item() = ""
         Break
       EndIf
      
       problem_list(prob)\fixed(count) = ValD(entry()\Item())
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
         problem_list(prob)\bars(cnt_i%10)\noteCount = count
       ElseIf cnt_j%2 = 1
         newnote.i = ValD(entry()\Item())
         problem_list(prob)\bars(cnt_i%10)\note(cnt_k)\note.i = newnote.i
       ElseIf cnt_j%2 = 0
         newlength.f = ValF(entry()\Item())
         problem_list(prob)\bars(cnt_i%10)\note(cnt_k)\length.f = newlength.f
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
 ptLeft = 0    : ptRight = 0
 ptTop = 0     : ptBottom = 0
 ptLength = 0  : direction = 0
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
   top = (ptTop + ptBottom)/2 - 100
   bottom = (ptTop + ptBottom)/2 + 100
   If bottom > 480
     bottom = 480
   EndIf 
 Else
   ptLength = (ptBottom-ptTop)/6
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
                    ;left = (ptLeft + ptRight)/2 - 100
     bottom = ptBottom - count*ptLength
     ;right = (ptLeft + ptRight)/2 + 100
     top = ptBottom - (count+1)*ptLength      
   Else
     left = ptLeft + count*ptLength
     ;top = (ptTop + ptBottom)/2 - 100
     right = ptLeft + (count+1)*ptLength
     ;bottom = (ptTop + ptBottom)/2 + 100
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
 Until count >= 6
 EndProcedure
 
Procedure DrawBoxs_Lv2(*image)
  If markerState = 0
   CalcCodeBoxs_Lv2()
 EndIf
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
  ;   Debug Str(ptBox(5,0)\x) + "    " + Str(ptBox(5,0)\y)
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
 
Procedure StaticAnt_Lv2(bar.i, code, distance.i)
  ; 비료
 InitMySprite("container"+Str(bar), "../graphics/container.png", distance-30, Lv2_contY)
  note0X = distance-5
 note0Y = Lv2_noteY+20
 note1X = distance+35
 note1Y = Lv2_noteY+20
 note2X = distance+15
 note2Y = Lv2_noteY+60
 note.Code
  GetCode(code, @note)
  InitMySprite("note"+Str(bar)+"\0", "../graphics/bubble"+Str(note\note0)+".png", note0X, note0Y)
 InitMySprite("note"+Str(bar)+"\1", "../graphics/bubble"+Str(note\note1)+".png", note1X, note1Y)
 InitMySprite("note"+Str(bar)+"\2", "../graphics/bubble"+Str(note\note2)+".png", note2X, note2Y)
  *n0 = FindSprite("note"+Str(bar)+"\0")
 *n1 = FindSprite("note"+Str(bar)+"\1")
 *n2 = FindSprite("note"+Str(bar)+"\2")
  *p.mySprite = InitMySprite("ant"+Str(bar), "../graphics/ant.png", distance-90, Lv2_antY)
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
     ChangePos_Lv2(position_list())
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
  If problem_list(currentProblem)\fixed(currentBar) = 1
   ProcedureReturn
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
 ForEach sprite_list()
   DeleteElement(sprite_list())
 Next
  problem.Problem_Lv2 = problem_list(currentProblem)
  weight.f = 0.0
 distance.i = 790
  ; 배경 그려주기
 InitMySprite("background", "../graphics/background.png", 0, 0)
  DrawBarMarker_Lv2()
  posX.i = distance
 posY.i = 160
  For b=currentBar To MaxBar-1
  
   bar.Bar = problem\bars(b)
  
   ;     If posX > WindowWidth(0)
   ;       ; 화면에 넘치게 그려지면 더이상 그리지 않음
   ;       Break
   ;     EndIf
  
   ; 사용자가 입력한 화음
   If userAnswers(b) <> -1
     StaticAnt_Lv2(b, userAnswers(b), posX)
   EndIf
  
   ; 고정된 화음 1:고정, 0:입력
   If problem\fixed(b) = 1
     StaticAnt_Lv2(b, problem\answers(b), posX)
   EndIf
  
   For i=0 To bar\noteCount-1
     note.Note = bar\note(i)
    
     spriteName.s = "line" + Str(b) + "/" + Str(i)
     InitMySprite(spriteName, "../graphics/line"+note\note+".png", posX, posY)
    
     ; 다음 음표를 위한 거리 가중치 (간격을 맞춰주기 위해)
     weight.f = note\length
     posX + Int(80*weight)
   Next
  
   If b <> MaxBar-1
     posX + 80
     InitMySprite("separator"+Str(b), "../graphics/leaf.png", posX, posY)
     posX + 80
   EndIf
  
 Next
 EndProcedure
 
Procedure AnswerCheck_Lv2()
 For i=0 To MaxBar-1
   If problem_list(currentProblem)\fixed(i)
     ; 주어진 답은 비교하지 않음
     Continue
   EndIf
   answer = problem_list(currentProblem)\answers(i)
   input = userAnswers(i)
   If answer = input
     PrintN(Str(i+1) + "번째 마디 정답 / 입력 : " + Str(userAnswers(i)) + "/ 실제 답 : " + Str(answer))
     ; InitMySprite("small_correct"+i, "graphics/small_correct.png", 40*i, 10,1)
       *p = FindSprite("small_correct"+i)
       SetMySprite(*p, 40*i , 30, 1)
       *p = FindSprite("small_incorrect"+i)
       SetMySprite(*p, 40*i , 30, 0)  
   Else
     PrintN(Str(i+1) + "번째 마디 오답 / 입력 : " + Str(userAnswers(i)) + "/ 실제 답 : " + Str(answer))
     Debug "initmysprite" + i
     ;   InitMySprite("small_incorrect"+i, "graphics/small_incorrect.png", 40*i, 10,1) 
            *p = FindSprite("small_correct"+i)
       SetMySprite(*p, 40*i , 30, 0)
        *p = FindSprite("small_incorrect"+i)
        SetMySprite(*p, 40*i , 30, 1)  
   EndIf
 Next
 
EndProcedure
 
Procedure MoveNotes(distance.i)
 For i=0 To 7
   noteCount = problem_list(currentProblem)\bars(i)\noteCount
   For j=0 To noteCount-1
     *this.mySprite = FindSprite("line" + Str(i) + "/" + Str(j))
     *this\x = *this\x+distance
   Next
  
   *leaf.mySprite = FindSprite("separator" + Str(i))
   If *leaf <> #Null
     *leaf\x = *leaf\x+distance
   EndIf
  
   *ant.mySprite = FindSprite("ant" + Str(i))
   If *ant <> #Null
     *ant\x = *ant\x+distance
   EndIf
  
   *container.mySprite = FindSprite("container" + Str(i))
   If *container <> #Null
     *container\x = *container\x+distance
   EndIf
   *note0.mySprite = FindSprite("note" + Str(i) + "\0")
   If *note0 <> #Null
     *note0\x = *note0\x+distance
   EndIf
   *note1.mySprite = FindSprite("note" + Str(i) + "\1")
   If *note1 <> #Null
     *note1\x = *note1\x+distance
   EndIf
   *note2.mySprite = FindSprite("note" + Str(i) + "\2")
   If *note2 <> #Null
     *note2\x = *note2\x+distance
   EndIf
 Next
EndProcedure
 
Procedure PlayNotes(parameter)
  currentBar = 0
 DrawNotes_Lv2()
  beat.i = 500
 posX.i = 790
 weight.f = 0
  ; 전체 재생하면 화면 멈춰버리는 증상
 For i=0 To 7
   noteCount = problem_list(currentProblem)\bars(i)\noteCount
  
   For j=0 To noteCount-1
     note.i = problem_list(currentProblem)\bars(i)\note(j)\note
     length.f = problem_list(currentProblem)\bars(i)\note(j)\length
    
     ; 사용자 입력 화음
     code.Code : code\note0 = -1 : code\note1 = -1 : code\note2 = -1
     If userAnswers(i) > -1 And userAnswers(i) < 6 And j = 0
       GetCode(userAnswers(i), @code)
      
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note0) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note1) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note2) << 8 | 127 << 16 )
     EndIf
    
     ; 고정된 화음
     If problem_list(currentProblem)\fixed(i) = 1 And j = 0
       GetCode(problem_list(currentProblem)\answers(i), @code)
      
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note0) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note1) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note2) << 8 | 127 << 16 )
     EndIf
     ; 화음과 겹치는 음은 빼고
     If note <> note0 And note <> note1 And note <> note2
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note) << 8 | 127 << 16 )
     EndIf
    
     ; 위치 변경
     dist.f = -80*weight.f
     If j=0 And i<>0 ; 첫 음이면서 첫 마디가 아님
                     ; separator 만큼 더 움직여야 함
       dist.f + (-80*2)
     EndIf
    
     MoveNotes(dist)
     ForEach sprite_list()
       FrameManager(sprite_list()) ;active 상태인 것들만 다음 프레임으로
     Next
     ForEach sprite_list()
       DrawMySprite(sprite_list())
     Next
     FlipBuffers()
    
     temp.i = Int(length*beat)
     Delay(temp)
    
     If note <> note0 And note <> note1 And note <> note2
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note) << 8 | 0 << 16 )   
     EndIf
    
     ; 사용자 입력 화음
     If userAnswers(i) > -1 And userAnswers(i) < 6 And j = 0
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note0) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note1) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note2) << 8 | 0 << 16 )
     EndIf
    
     ; 고정된 화음
     If problem_list(currentProblem)\fixed(i) = 1 And j = 0
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note0) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note1) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note2) << 8 | 0 << 16 )
     EndIf
    
     weight = length ; weight update
   Next
 Next
  ; 정답 체크
 AnswerCheck_Lv2()
  currentBar = 0
 DrawNotes_Lv2()
 EndProcedure
 
 ; ==================================================PAUSE ====================================================

Procedure GamePause_Lv2()
  
  UsePNGImageDecoder()
   Font40 = LoadFont(#PB_Any, "Impact", 100)
  StartDrawing(ScreenOutput())
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(Font40))
  DrawText(640, 400, "PAUSED", RGB(255,255,255))

  StopDrawing()
  ExamineKeyboard()
  If KeyboardPushed(#PB_Key_5)
      LEVEL2_State = #Status2_GameInPlay         
  EndIf  
              
FlipBuffers() 

EndProcedure

;==================================================PAUSE =========================================================
 



Procedure LEVEL2_Tutorial()
  
  pos_x = 1000
  pos_y = 600
  x + 1
  Debug  Tutorial_Num_Lv2
  
  
  Select Tutorial_Num_Lv2
      
     Case 1     
       ant_saying("안녕 LEVEL2에 온 걸 환영해", pos_x, pos_y)
       
     Case 2
      ant_saying("LEVEL2에 관해 간단히 설명해줄게", pos_x, pos_y) 
      
    Case 3 
  
       ant_saying("LEVEL2는 주어진 멜로디에 알맞은 경단, "+#CRLF$+" 즉 화음을 넣는 단계야", pos_x, pos_y)
       
     Case 4
       
       ant_saying("멜로디는 '마디'로 구분되는데, "+#CRLF$+" 작은 나뭇잎 보이지? "+#CRLF$+"저걸로 마디를 구분해", pos_x, pos_y)
       
        *p = FindSprite("leaf_highlight")
        SetMySprite(*p, 1170 , 140 , 1)
       
      Case 5
        *p = FindSprite("madi_highlight")
        SetMySprite(*p, 800 , 440 , 1)
        ant_saying("작은 나뭇잎 까지, "+#CRLF$+"즉, 표시한 부분이 한 마디가 되는거야!", pos_x, pos_y)
              
      Case 6       
       ant_saying("LEVEL2의 멜로디는 총 8마디야!", pos_x, pos_y)
        *p = FindSprite("leaf_highlight")
        SetMySprite(*p, 1170 , 140 , 0)
        *p = FindSprite("madi_highlight")
        SetMySprite(*p, 800 , 440 , 0)
        
     Case 7
       ant_saying("왼쪽오른쪽 제스쳐를 통해서 마디를 이동할 수 있지", pos_x, pos_y)
       
     Case 8       
        *p = FindSprite("madis_highlight")
        SetMySprite(*p, 50 , 40 , 1)
       
       ant_saying("마디 정보는 왼쪽 위에서 확인할 수 있어!", pos_x, pos_y)     
       
     Case 9
       
        *p = FindSprite("madis_highlight")
        SetMySprite(*p, 50 , 40 , 0)
       
       ant_saying("멜로디의 음에 따라서 "+#CRLF$+"알맞음 화음을 붙이는 방법을 알려줄게", pos_x, pos_y)
                                             
     Case 10
       ant_saying("어쩌고 저쩌고", pos_x, pos_y) 
       
     Case 11
       ant_saying("제스쳐를 이용해서 마디를 이동하고,"+#CRLF$+" 비어있는 곳에 마커를 이용해서 알맞은 화음을 넣으면 돼!", pos_x, pos_y)   
       
     Case 12
        ant_saying("OO을 제스쳐로 음악을 재생하고 정답을 체크 할 수있지", pos_x, pos_y)   
       
     Case 13
      *p = FindSprite("ant_say")
       SetMySprite(*p, 900, 500, 0)
     Tutorial_lock_Lv2 = #False  

  EndSelect
  
EndProcedure



Procedure Gamestage_Lv2()
  UsePNGImageDecoder()
  LoadImage(#Image_Lv2_Stage, "./graphics/Lv2_stage.png")
  InitMySprite("ant_say", "graphics/ant_say.png", 500,500,0)   
  Font202 = LoadFont(#PB_Any, "System", 20)
  ProbSelect = 1
  Debug ProbSelect
  InitSprite()
  
  StageNodeX_Lv2 = 600
  StageNodeY_Lv2 = 150
  
  Repeat  
    
   ClearScreen(RGB(255,255,255))
    
   StartDrawing(ScreenOutput())
   ; 똑같은건데 #Image_MENU는 오류나고 #Image_MENU2는 괜찮음. 어디서 이름이 겹치나..? 그래서 그냥 #Image_MENU2 로 합니다.
   DrawImage(ImageID(#Image_MENU2), 0, 0, BackgroundX, BackgroundY)  
   DrawingMode(#PB_2DDrawing_Transparent)
   
   DrawingFont(FontID(Font202))  
   DrawImage(ImageID(#Image_Lv2_Stage), 470, 350- (3*Sin(node1_pos)),StageNodeX_Lv2, StageNodeY_Lv2)  
   DrawImage(ImageID(#Image_Lv2_Stage), 470, 550 -(3*Sin(node2_pos)),StageNodeX_Lv2, StageNodeY_Lv2) 
   DrawText(500, 450- (3*Sin(node1_pos)), "비행기", TextColor)
   DrawText(500, 650 -(3*Sin(node2_pos)), "학교 종", TextColor)
   DrawingMode(#PB_2DDrawing_Transparent)  
   StopDrawing()    
   
   If ProbSelect = 0 ;비행기
     node1_pos +1     
   ElseIf ProbSelect = 1 ;학교종
     node2_pos +1
   EndIf  
   
    ; 좌우로 눌러서 메뉴 선택 , 4로 확인
    If  ExamineKeyboard()
    If KeyboardReleased(#PB_Key_Left)
        If  ProbSelect > 0
        ProbSelect - 1
        EndIf 
    ElseIf   KeyboardReleased(#PB_Key_Right) 
      
      If ProbSelect < 1
        ProbSelect + 1
      EndIf  
      
    EndIf
   EndIf 
    
       FlipBuffers()
 Until KeyboardReleased(#PB_Key_4)
 

ProcedureReturn ProbSelect
  

EndProcedure


 Procedure CreateLEVEL2 ()

   Shared MainWindow
   OpenConsole("Test Console")
 
markerState = 0 ; 마커 입력 상태
threadStatus = 0; thread 상태. 0-실행안함, 1-실행중


    LEVEL2_State = #Status2_Intro
    If  LEVEL2_State = #Status2_Intro
    currentProblem = Gamestage_Lv2()
    LEVEL2_State = #Status2_GameInPlay
   EndIf 
   
   ;-- TODO random
   ;currentProblem = Random(1)
   PrintN("Problem Count is " + Str(problem_count))
   PrintN("Current Problem Number is " + Str(currentProblem)) 
   
; @@
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
 ;*image.IplImage :
  pbImage = CreateImage(#PB_Any, 640, 480)
 *rectimg = cvCreateImage(FrameWidth, FrameHeight, #IPL_DEPTH_8U, 3)
 *loadbox1 = cvLoadImage("../graphics/chord_box.png", 1)
 *loadbox2 = cvLoadImage("../graphics/chord_box2.png", 1)
  ;If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
  If  MainWindow
   Window_1=OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; 웹캠용 윈도우
   ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
   StickyWindow(1, #True) ; 항상 위에 고정
   SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(0), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; 윈도우 타이틀 바 제거
   SetForegroundWindow_(WindowID(0))
   InitSprite()
   InitKeyboard()
  
   ;Screen과 Sprite 생성
   ;Screen_0 = OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0), WindowHeight(0))
  
   UsePNGImageDecoder()
   TransparentSpriteColor(#PB_Default, RGB(255, 0, 255))
  
   InitMySprite("background", "graphics/background.png", 0, 0)
   
   currentBar = 0
   For i=0 To MaxBar-1
     userAnswers(i) = -1
   Next
  
   DrawBarMarker_Lv2()
   DrawNotes_Lv2()
  
   ClearScreen(RGB(255, 255, 255))
   
         InitMySprite("ant_say", "graphics/ant_say.png", 500,500,0) 
         InitMySprite("leaf_highlight", "graphics/leaf_highlight.png", 500,500,0) 
         InitMySprite("madi_highlight", "graphics/madi_highlight.png", 500,500,0) 
         InitMySprite("madis_highlight", "graphics/madis_highlight.png", 500,500,0)  

   Repeat
     
        ; ㄱ- 이거 위치 리핏밖으로 꺼내면 왜 안되는건지 모르겟음
         InitMySprite("small_incorrect0", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_incorrect1", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_incorrect2", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_incorrect3", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_incorrect4", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_incorrect5", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_incorrect6", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_incorrect7", "graphics/small_incorrect.png", 40, 10,0)
         InitMySprite("small_correct0", "graphics/small_correct.png", 500,500,0)
         InitMySprite("small_correct1", "graphics/small_correct.png", 500,500,0)
         InitMySprite("small_correct2", "graphics/small_correct.png", 500,500,0)
         InitMySprite("small_correct3", "graphics/small_correct.png", 500,500,0)
         InitMySprite("small_correct4", "graphics/small_correct.png", 500,500,0)
         InitMySprite("small_correct5", "graphics/small_correct.png", 500,500,0)
         InitMySprite("small_correct6", "graphics/small_correct.png", 500,500,0)
         InitMySprite("small_correct7", "graphics/small_correct.png", 500,500,0)
     
     
     
     If  LEVEL2_State = #Status2_GameInPlay

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
       
     
    

       ; Tutorial
       If   Tutorial_lock_Lv2
         
          LEVEL2_Tutorial()
          
      Font40 = LoadFont(#PB_Any, "Impact", 15)     
     If Tutorial_Num_Lv2 = 1
     StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
     DrawText(1450+2*Sin(x), 680, "다음" , RGB(0,0,0))
   ;  DrawText(100-2*Sin(x), 150, "이전" , RGB(255,255,255))
     StopDrawing()
     ElseIf Tutorial_Num_Lv2 = 12
          StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
   ;  DrawText(1300+2*Sin(x), 150, "다음" , RGB(0,255,255))
     DrawText(1000-2*Sin(x), 680, "이전" , RGB(0,0,0))
     StopDrawing()
     Else
               StartDrawing(ScreenOutput())  
     DrawingMode(#PB_2DDrawing_Transparent)
     DrawingFont(FontID(Font40))
     DrawText(1450+2*Sin(x), 680, "다음" , RGB(0,0,0))
     DrawText(1000-2*Sin(x), 680, "이전" , RGB(0,0,0))
     StopDrawing()
     EndIf  
     
     x+1  
        EndIf 
       
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
         If (markerState = 1) And problem_list(currentProblem)\fixed(currentBar) = 0
           CheckArea_Lv2(keyInput)
         EndIf
       EndIf
      
       If KeyboardReleased(#PB_Key_3)
         ; multi-thread
         ;           CreateThread(@PlayNotes(), 0)
         PlayNotes(0)
       EndIf
      
       If KeyboardReleased(#PB_Key_Space)
         markerState = 1
       EndIf
       
       
       
       If  Tutorial_lock_Lv2
       
       
      If  KeyboardReleased(#PB_Key_Right) And Tutorial_Num_Lv2 <20
          
          Tutorial_Num_Lv2 + 1
          
        EndIf 
        
       If  KeyboardReleased(#PB_Key_Left) And Tutorial_Num_Lv2 > 1
          
          Tutorial_Num_Lv2 -1
          
        EndIf
       
     Else
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
       
       If KeyboardPushed(#PB_Key_A) ; ANSWER CHECK <- 이거 겁나 연타하면 멈춤 ㄱ- ㅋㅋ
         
         AnswerCheck_Lv2()
         EndIf  
       
       
       
          If KeyboardPushed(#PB_Key_P) ; PAUSE
        LEVEL2_State = #Status2_GameInPause  
               
            
          EndIf 
    
     DrawBoxs_Lv2(*image)
    
     *mat.CvMat = cvEncodeImage(".bmp", *image, 0)
     Result = CatchImage(1, *mat\ptr)
     SetGadgetState(0, ImageID(1))
     cvReleaseMat(@*mat) 
    
     FlipBuffers()
     
     ; free memory
     If  KeyboardPushed(#PB_Key_0) And LEVEL2_State = #Status2_GameInPlay;Escape
     cvReleaseCapture(@*capture)
      ; FreeArray(problem_list()) 
     ; FreeArray(userAnswers()) 
     ; FreeArray(ptBox())
      ForEach sprite_list()
         DeleteElement(sprite_list())
      Next
      ForEach position_list()
          DeleteElement(position_list())
      Next
      FreeImage(pbImage)
       cvReleaseCapture(@*capture)
       midiOutReset_(hMidiOut)
       midiOutClose_(hMidiOut)
       CloseWindow(1)
       
       LEVEL2_State = #Status2_GameEnd
       
       EndIf

     EndIf
     
      ElseIf LEVEL2_State = #Status2_GameInPause 
      GamePause_Lv2()
     
     EndIf  

   Until WindowEvent() = #PB_Event_CloseWindow Or LEVEL2_State = #Status2_GameEnd
 EndIf

 
 Else
 MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf


ProcedureReturn  


EndProcedure


;CreateLEVEL2()

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 549
; FirstLine = 534
; Folding = ----
; EnableXP


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 1003
; FirstLine = 328
; Folding = AAA-
; EnableXP
; DisableDebugger
; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 1: ���Է� 2: �Է� 3: �Ǻ� ����ϱ�
; ó�� ���� ��, ���콺 Ŀ���� Ű���� 1(Ȥ�� 2)�� �ڽ� ���� ���� -> �����̽��ٷ� ���� ��ȯ -> ���콺 Ŀ���� Ű���� 1(Ȥ�� 2)�� �� ���
 
IncludeFile "../OpenCV_32/includes/cv_functions.pbi"
IncludeFile "ReadCSV.pb"
 
Structure mySprite
 sprite_id.i
 sprite_name.s
 filename.s
  x.i   ; ��ġ x
 y.i   ; ��ġ y
 width.i   ; ��ü ���� ������
 height.i  ; ��ü ���� ������
  present.i; ���� ������
 frametime.i
  f_width.i ; �� �������� ���� ������
 f_height.i; �� �������� ���� ������
 f_horizontal.i   ; ���� ������ ��
 f_vertical.i     ; ���� ������ ��
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
Global MaxBar = 8 ; �ִ� 8����
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
 
;�̹��� ������ �ѱ�� �Լ�
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
 
Procedure InitMySprite(name.s, filename.s, x.i, y.i, active.i = 1) ;active�� �ɼ�
                                                                  ; ��������Ʈ ����ü �ʱ�ȭ
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
 
;��������Ʈ ��ǥ��, Ȱ��ȭ���� ����
Procedure SetMySprite(*sprite.mySprite, x.i, y.i, active.i)
 *sprite\x = x
 *sprite\y = y
 *sprite\active = active
EndProcedure
 
;myPosition �ʱ�ȭ
Procedure InitMyPosition(*sprite.mySprite, xmove.i, ymove.i, xmax.i, ymax.i, startdelay.i)
 *this.myPosition = AddElement(position_list())
  *this\sprite = *sprite
 *this\xmove = xmove
 *this\ymove = ymove
 *this\xmax = xmax
 *this\ymax = ymax
 *this\startdelay = startdelay
EndProcedure
 
; sprite_list ���� �̸����� ����ü ã��. ǻ�� Ư���� current element �̽� ������ ���߿� ��ġ�ص� ������ ������ ���ƾ���
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
; ��ǥ�� �Ű��ִ� �Լ�
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
 Define prob.i = 0   ; ���� ��ȣ
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
   If direction = 1 ;����
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
 
Procedure DrawBoxs(*image)
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
  ProcedureReturn code ; �ڵ带 ��ȯ
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
  ; ���
 InitMySprite("container"+Str(bar), "graphics/container.png", distance-30, Lv2_contY)
  note0X = distance-5
 note0Y = Lv2_noteY+20
 note1X = distance+35
 note1Y = Lv2_noteY+20
 note2X = distance+15
 note2Y = Lv2_noteY+60
 note.Code
  GetCode(code, @note)
  InitMySprite("note"+Str(bar)+"\0", "graphics/bubble"+Str(note\note0)+".png", note0X, note0Y)
 InitMySprite("note"+Str(bar)+"\1", "graphics/bubble"+Str(note\note1)+".png", note1X, note1Y)
 InitMySprite("note"+Str(bar)+"\2", "graphics/bubble"+Str(note\note2)+".png", note2X, note2Y)
  *n0 = FindSprite("note"+Str(bar)+"\0")
 *n1 = FindSprite("note"+Str(bar)+"\1")
 *n2 = FindSprite("note"+Str(bar)+"\2")
  *p.mySprite = InitMySprite("ant"+Str(bar), "graphics/ant.png", distance-90, Lv2_antY)
 EndProcedure
 
Procedure MovingAnt_Lv2(code.i, bar.i)
  b = currentBar
 ; ���
 InitMySprite("container"+Str(b), "graphics/container.png", Lv2_contX, Lv2_contY)
 *p2.mySprite = FindSprite("container"+Str(b))
 InitMyPosition(*p2, 10, 0, Lv2_antX+60, 0, 20)
  InitMySprite("antmove"+Str(b), "graphics/antmove.png", Lv2_antX-200, Lv2_antY)
 *p.mySprite = FindSprite("antmove"+Str(b))
 *p\f_horizontal = 4
 *p\f_width = *p\width/4
 InitMyPosition(*p, 10, 0, Lv2_antX, 0, 20)
  ;����
 userAnswers(b) = code.i
  note0X = Lv2_antX-200+85
 note0Y = Lv2_noteY+20
 note1X = Lv2_antX-200+125
 note1Y = Lv2_noteY+20
 note2X = Lv2_antX-200+105
 note2Y = Lv2_noteY+60
  note.Code
 GetCode(code, @note)
  InitMySprite("note"+Str(currentBar)+"\0", "graphics/bubble"+Str(note\note0)+".png", note0X, note0Y)
 InitMySprite("note"+Str(currentBar)+"\1", "graphics/bubble"+Str(note\note1)+".png", note1X, note1Y)
 InitMySprite("note"+Str(currentBar)+"\2", "graphics/bubble"+Str(note\note2)+".png", note2X, note2Y)
  *n0 = FindSprite("note"+Str(currentBar)+"\0")
 *n1 = FindSprite("note"+Str(currentBar)+"\1")
 *n2 = FindSprite("note"+Str(currentBar)+"\2")
  InitMyPosition(*n0, 10, 0, Lv2_antX+85, 0, 20)
 InitMyPosition(*n1, 10, 0, Lv2_antX+125, 0, 20)
 InitMyPosition(*n2, 10, 0, Lv2_antX+105, 0, 20)
  ; �Ҹ� ���
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
     FrameManager(sprite_list()) ;active ������ �͵鸸 ���� ����������
   Next
   ForEach sprite_list()
     DrawMySprite(sprite_list())
   Next
   FlipBuffers()
 Until ListSize(position_list()) = 0
  ; ���� �� �����̸� ������
 midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note\note0) << 8 | 0 << 16 )
 midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note\note1) << 8 | 0 << 16 )
 midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(note\note2) << 8 | 0 << 16 )
  *p\active = 0
 ;����
 *p.mySprite = InitMySprite("ant"+Str(currentBar), "graphics/ant.png", Lv2_antX, Lv2_antY)
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
  ; ���� ��-�� ������ ��츸 ���
 If code >= #CODE_C And code <= #CODE_Em
   MovingAnt_Lv2(code, 0)
 EndIf
 EndProcedure
 
Procedure DrawBarMarker_Lv2()
 posX = 100
 posY = 30
 For i=MaxBar-1 To 0 Step -1
   If i = currentBar
     InitMySprite("barMarker"+Str(i), "graphics/bubble2.png", posX+i*40, posY)
   Else
     InitMySprite("barMarker"+Str(i), "graphics/bubble4.png", posX+i*40, posY)
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
  ; ��� �׷��ֱ�
 InitMySprite("background", "graphics/background.png", 0, 0)
  DrawBarMarker_Lv2()
  posX.i = distance
 posY.i = 160
  For b=currentBar To MaxBar-1
  
   bar.Bar = problem\bars(b)
  
   ;     If posX > WindowWidth(0)
   ;       ; ȭ�鿡 ��ġ�� �׷����� ���̻� �׸��� ����
   ;       Break
   ;     EndIf
  
   ; ����ڰ� �Է��� ȭ��
   If userAnswers(b) <> -1
     StaticAnt_Lv2(b, userAnswers(b), posX)
   EndIf
  
   ; ������ ȭ�� 1:����, 0:�Է�
   If problem\fixed(b) = 1
     StaticAnt_Lv2(b, problem\answers(b), posX)
   EndIf
  
   For i=0 To bar\noteCount-1
     note.Note = bar\note(i)
    
     spriteName.s = "line" + Str(b) + "/" + Str(i)
     InitMySprite(spriteName, "graphics/line"+note\note+".png", posX, posY)
    
     ; ���� ��ǥ�� ���� �Ÿ� ����ġ (������ �����ֱ� ����)
     weight.f = note\length
     posX + Int(80*weight)
   Next
  
   If b <> MaxBar-1
     posX + 80
     InitMySprite("separator"+Str(b), "graphics/leaf.png", posX, posY)
     posX + 80
   EndIf
  
 Next
 EndProcedure
 
Procedure AnswerCheck_Lv2()
 For i=0 To MaxBar-1
   If problem_list(currentProblem)\fixed(i)
     ; �־��� ���� ������ ����
     Continue
   EndIf
   answer = problem_list(currentProblem)\answers(i)
   input = userAnswers(i)
   If answer = input
     PrintN(Str(i+1) + "��° ���� ���� / �Է� : " + Str(userAnswers(i)) + "/ ���� �� : " + Str(answer))
   Else
     PrintN(Str(i+1) + "��° ���� ���� / �Է� : " + Str(userAnswers(i)) + "/ ���� �� : " + Str(answer))
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
  ; ��ü ����ϸ� ȭ�� ��������� ����
 For i=0 To 7
   noteCount = problem_list(currentProblem)\bars(i)\noteCount
  
   For j=0 To noteCount-1
     note.i = problem_list(currentProblem)\bars(i)\note(j)\note
     length.f = problem_list(currentProblem)\bars(i)\note(j)\length
    
     ; ����� �Է� ȭ��
     code.Code : code\note0 = -1 : code\note1 = -1 : code\note2 = -1
     If userAnswers(i) > -1 And userAnswers(i) < 6 And j = 0
       GetCode(userAnswers(i), @code)
      
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note0) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note1) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note2) << 8 | 127 << 16 )
     EndIf
    
     ; ������ ȭ��
     If problem_list(currentProblem)\fixed(i) = 1 And j = 0
       GetCode(problem_list(currentProblem)\answers(i), @code)
      
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note0) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note1) << 8 | 127 << 16 )
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(code\note2) << 8 | 127 << 16 )
     EndIf
     ; ȭ���� ��ġ�� ���� ����
     If note <> note0 And note <> note1 And note <> note2
       midiOutShortMsg_(hMidiOut, $90 | 0 | GetNote_Lv2(note) << 8 | 127 << 16 )
     EndIf
    
     ; ��ġ ����
     dist.f = -80*weight.f
     If j=0 And i<>0 ; ù ���̸鼭 ù ���� �ƴ�
                     ; separator ��ŭ �� �������� ��
       dist.f + (-80*2)
     EndIf
    
     MoveNotes(dist)
     ForEach sprite_list()
       FrameManager(sprite_list()) ;active ������ �͵鸸 ���� ����������
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
    
     ; ����� �Է� ȭ��
     If userAnswers(i) > -1 And userAnswers(i) < 6 And j = 0
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note0) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note1) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note2) << 8 | 0 << 16 )
     EndIf
    
     ; ������ ȭ��
     If problem_list(currentProblem)\fixed(i) = 1 And j = 0
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note0) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note1) << 8 | 0 << 16 )
       midiOutShortMsg_(hMidiOut, $80 | 0 | GetNote_Lv2(code\note2) << 8 | 0 << 16 )
     EndIf
    
     weight = length ; weight update
   Next
 Next
  ; ���� üũ
 AnswerCheck_Lv2()
  currentBar = 0
 DrawNotes_Lv2()
 EndProcedure
 
OpenConsole("Test Console")
 
markerState = 0 ; ��Ŀ �Է� ����
threadStatus = 0; thread ����. 0-�������, 1-������
 
; @@
InitProblem_Lv2()
 
;MIDI ����
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
  If OpenWindow(0, 0, 0, FrameWidth, FrameHeight, "PureBasic Interface to OpenCV", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered|#PB_Window_Maximize)
  
   Window_1=OpenWindow(1, 0, WindowHeight(0)/2 - 200, FrameWidth-5, FrameHeight-30, "title") ; ��ķ�� ������
   ImageGadget(0, 0, 0, FrameWidth, FrameHeight, ImageID(pbImage))
   StickyWindow(1, #True) ; �׻� ���� ����
   SetWindowLongPtr_(WindowID(1), #GWL_STYLE, GetWindowLongPtr_(WindowID(0), #GWL_STYLE)&~ #WS_THICKFRAME &~ #WS_DLGFRAME) ; ������ Ÿ��Ʋ �� ����
  
   InitSprite()
   InitKeyboard()
  
   ;Screen�� Sprite ����
   Screen_0 = OpenWindowedScreen(WindowID(Window_0), 0, 0, WindowWidth(0), WindowHeight(0))
  
   UsePNGImageDecoder()
   TransparentSpriteColor(#PB_Default, RGB(255, 0, 255))
  
   InitMySprite("background", "graphics/background.png", 0, 0)
  
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
         FrameManager(sprite_list()) ;active ������ �͵鸸 ���� ����������
       Next
      
       ForEach sprite_list()
         DrawMySprite(sprite_list())
       Next
      
       ;Ű���� �̺�Ʈ
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
      
       If KeyboardReleased(#PB_Key_Left)
         ; ���� ����� �̵�
         If currentBar > 0
           currentBar-1
           DrawNotes_Lv2()
         EndIf
        
       EndIf
      
       If KeyboardReleased(#PB_Key_Right)
         ; ���� ����� �̵�
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
 FreeArray(problem_list()) 
 FreeArray(userAnswers()) 
 FreeArray(ptBox())
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
 Else
 MessageRequester("PureBasic Interface to OpenCV", "Unable to connect to a webcam - operation cancelled.", #MB_ICONERROR)
EndIf
 
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 549
; FirstLine = 534
; Folding = ----
; EnableXP


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 856
; FirstLine = 816
; Folding = ----
; EnableXP
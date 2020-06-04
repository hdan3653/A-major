IncludeFile "./includes/cv_functions.pbi"

;Score 
Global LEVEL1_stage1_score =0, LEVEL1_stage2_score =0, LEVEL1_stage3_score =0
Enumeration Image
  #Image_MAIN
  #Image_MENU
  #Image_MENU2
  #Image_PAUSE2
  #Image_StageBackground    
  #Image_StageNode
  #Image_Stage_left
  #Image_Stage_right
  #Image_LEVELSelectBackground
  #Image_LEVEL1_Button
  #Image_LEVEL2_Button
  #Image_LEVEL3_Button
  #Image_Calibration_Button
  #Image_Score1
  #Image_Score2
  #Image_Score3
  #Image_Lv2_Stage
EndEnumeration

;Setup Sprite
UsePNGImageDecoder()
LoadImage(#Image_MAIN, "./graphics/MAIN.png")
LoadImage(#Image_MENU, "./graphics/MENU.png")
LoadImage(#Image_MENU2, "./graphics/MENU.png")
LoadImage(#Image_StageBackground, "./graphics/StageBackground.png")
LoadImage(#Image_StageNode, "./graphics/stage1.png")
LoadImage(#Image_LEVEL1_Button, "./graphics/LEVEL1.png")
LoadImage(#Image_LEVEL2_Button, "./graphics/LEVEL2.png")
LoadImage(#Image_LEVEL3_Button, "./graphics/LEVEL3.png")
LoadImage(#Image_Calibration_Button, "./graphics/CalibrationButton.png")
LoadImage(#Image_Lv2_Stage, "./graphics/Lv2_stage.png")

Global BackgroundX = 1536, BackgroundY = 897


;Setup Font
Global Impact20 = LoadFont(#PB_Any, "Impact", 20)
Global Impact25 = LoadFont(#PB_Any, "Impact", 25)
Global Impact30 = LoadFont(#PB_Any, "Impact", 30)
Global Impact50 = LoadFont(#PB_Any, "Impact", 50)
Global Impact100 = LoadFont(#PB_Any, "Impact", 100)
Global Font15 = LoadFont(#PB_Any, "a영고딕E", 15)
Global Font20 = LoadFont(#PB_Any, "a영고딕E", 20)
Global Font30 = LoadFont(#PB_Any, "a영고딕E", 30)
Global Font25 = LoadFont(#PB_Any, "a영고딕E", 25)
Global Font40 = LoadFont(#PB_Any, "a영고딕E", 40,#PB_Font_Bold)
Global Font50 = LoadFont(#PB_Any, "a영고딕E", 50)
Global Font100 = LoadFont(#PB_Any, "a영고딕E", 100)


Procedure DrawTextEx(X.i, Y.i, Text.s)
  Protected I.i, Max = CountString(Text, #CRLF$)+1
  Protected Line.s
  For I = 1 To Max
    Line = StringField(Text, I, #CRLF$)
    DrawText(X, Y, Line, RGB(0,0,0))
    Y + TextHeight(" ")
  Next
EndProcedure

Structure color
  r.i
  g.i
  b.i
EndStructure

;EnableExplicit
Global SceneNumber
Global GameState

Enumeration
  #MainForm
EndEnumeration

Enumeration Scene
  #StartScene
  #MenuSelect
  #CalibrationScene
  #Tutorial
  #StageSelect
  #SceneLevel1
  #SceneLevel2
  #SceneLevel3
  #Program_End
  #GameEnding
EndEnumeration

Enumeration Status
  #Status_GameBeforeFirstStart
  #Status_GameInPlay
  #Status_GameEndingAnimation
  #Status_GameRestartReady
  #Status_GameInPause
EndEnumeration


;Image Size
Global *image.IplImage
Global LevelNodeX = 300, LevelNodeY = 300
Global StageNodeX = 400, StageNodeY = 400
Global StageNodePosX = 548 ,StageNodePosY = 349
Global ScorePosX = 845, ScorePosY =349
Global ScoreWidth=200 , ScoreHeight=50
Global NodeTextX = StageNodePosX+90,NodeTextY = StageNodePosY+155


;Setup Screen Color
ScreenDefaultColor    = RGB(215, 73, 11)
TextColor             = RGB(200, 0, 0)

Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global.l hMidiOut

IncludeFile "LEVEL1.pb"
IncludeFile "LEVEL2.pb"
IncludeFile "LEVEL3.pb"
IncludeFile "TUTORIAL.pb"
IncludeFile "cv_colorcalibration.pb"


Procedure drawStageSelect(StageNum, LeftOrRight, LevelNum)
  
  If InitSprite() = 0 Or InitKeyboard() = 0
    MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf
  
  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "./graphics/MAIN.png")
  
  
  Repeat
    FlipBuffers()
    
    StartDrawing(ScreenOutput())
    
    DrawImage(ImageID(#Image_StageBackground), 0, 0,BackgroundX, BackgroundY) 
    DrawingMode(#PB_2DDrawing_Transparent)
    StopDrawing() 
    
    currentStageNum =StageNum
    AfterStage = currentStageNum+1
    BeforeStage = currentStageNum-1
    
    
    If LeftOrRight = 0
      
      StartDrawing(ScreenOutput())     
      DrawImage(ImageID(#Image_StageNode), StageNodePosX, StageNodePosY,StageNodeX, StageNodeY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Impact50))
      DrawText(NodeTextX, NodeTextY, "Stage"+AfterStage, TextColor)    
      StopDrawing()
      
      StartDrawing(ScreenOutput())
      
      DrawImage(ImageID(#Image_StageNode), StageNodePosX-var_x+z, StageNodePosY,StageNodeX, StageNodeY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Impact50))
      DrawText(NodeTextX -var_x+z, NodeTextY, "Stage"+StageNum, TextColor)    
      StopDrawing()
      
      var_x+20
      If var_x > 700
        Break  
      EndIf  
      
    ElseIf LeftOrRight = 1
      
      StartDrawing(ScreenOutput())     
      DrawImage(ImageID(#Image_StageNode), StageNodePosX, StageNodePosY,StageNodeX, StageNodeY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Impact50))
      DrawText(NodeTextX, NodeTextY, "Stage"+StageNum, TextColor)    
      StopDrawing()
      
      StartDrawing(ScreenOutput())
      DrawImage(ImageID(#Image_StageNode), StageNodePosX-var_x+z, StageNodePosY,StageNodeX, StageNodeY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Impact50))
      DrawText(NodeTextX-var_x+z, NodeTextY, "Stage"+BeforeStage, TextColor)    
      StopDrawing()
      
      y+20
      z = NodeTextX - y
      
      If y > NodeTextX
        Break  
      EndIf  
      
    EndIf  
    
    ExamineKeyboard()
  Until KeyboardPushed(#PB_Key_Escape)
  
  
  ProcedureReturn StageNum
  
  
  
EndProcedure

Procedure drawStageVibe(StageNum, LevelNum)
  
  
  
  If InitSprite() = 0 Or InitKeyboard() = 0
    MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf
  
  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "./graphics/MAIN.png")
  
  
  Repeat
    
    FlipBuffers()
    StartDrawing(ScreenOutput())
    DrawImage(ImageID(#Image_StageBackground), 0, 0,BackgroundX, BackgroundY) 
    DrawingMode(#PB_2DDrawing_Transparent)
    StopDrawing() 
    
    StartDrawing(ScreenOutput())
    DrawImage(ImageID(#Image_StageNode), StageNodePosX-20*Sin(var_x), StageNodePosY,StageNodeX, StageNodeY)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Impact50))
    DrawText(NodeTextX-20*Sin(var_x), NodeTextY, "Stage"+StageNum, TextColor)
    StopDrawing()
    var_x+20      
    ExamineKeyboard()
  Until KeyboardPushed(#PB_Key_Escape) Or var_x > 300
  
  
EndProcedure

Procedure StageSelectScene(LevelNum)
  
  
  If LevelNum = 1 
    StageMax =3 
    ;  ElseIf LevelNum =2
    ;     StageMax=2
  EndIf 
  
  
  
  If InitSprite() = 0 Or InitKeyboard() = 0
    MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf
  
  StageNum =1
  
  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "graphics/MAIN.png")
  
  Repeat
    
    FlipBuffers()
    
    
    
    If StageNum = 1         
      Score = LEVEL1_stage1_score         
    ElseIf StageNum = 2         
      Score = LEVEL1_stage2_score
    ElseIf  StageNum = 3         
      Score = LEVEL1_stage3_score         
    EndIf  
    
    StartDrawing(ScreenOutput())
    Box(0, 0, 600, 600, RGB(0,0,0))
    DrawImage(ImageID(#Image_StageBackground), 0, 0, BackgroundX, BackgroundY) 
    DrawingMode(#PB_2DDrawing_Transparent)
    StopDrawing() 
    
    ; TODO 위치 조정
    StartDrawing(ScreenOutput())
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawImage(ImageID (#Image_StageNode),StageNodePosX,StageNodePosY,StageNodeX,StageNodeY)
    DrawingFont(FontID(Impact50))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(NodeTextX, NodeTextY, "Stage"+StageNum, TextColor)
    DrawingFont(FontID(Impact25))
    If Score < 10 
      DrawText(StageNodePosX+20, StageNodePosY+10, "☆☆☆", TextColor)
    ElseIf Score < 50
      DrawText(StageNodePosX+20, StageNodePosY+10, "★☆☆", TextColor)
    ElseIf Score < 100
      DrawText(StageNodePosX+20, StageNodePosY+10, "★★☆", TextColor)
    ElseIf Score < 150
      DrawText(StageNodePosX+20, StageNodePosY+10, "★★★", TextColor)  
    EndIf  
    DrawingFont(FontID(Impact20))
    DrawText(StageNodePosX+245, StageNodePosY+20, "score : " + Str(Score), TextColor)
    StopDrawing()
    
    
    ExamineKeyboard()
    If KeyboardPushed(#PB_Key_Left)
      If  StageNum < StageMax      
        drawStageSelect(StageNum, 0, LevelNum) 
        StageNum + 1        
      Else
        drawStageVibe(StageNum, LevelNum)
      EndIf 
    ElseIf KeyboardPushed(#PB_Key_Right)
      
      If StageNum > 1
        
        drawStageSelect(StageNum, 1, LevelNum)
        StageNum - 1  
      Else
        drawStageVibe(StageNum, LevelNum)
      EndIf  
      
    EndIf 
    
    ExamineKeyboard()
    If KeyboardPushed(#PB_Key_Escape)
      ProcedureReturn StageNum 
    EndIf 
    
  Until KeyboardPushed(#PB_Key_Escape)
  
EndProcedure

Procedure MenuSelectScene() ;제스쳐로 선택하도록 LEVEL1 ,2,3,튜토, 캘리  확인 : 4, 종료 escape 
  
  MENUSelect = 1
  
  Repeat  
    
    StartDrawing(ScreenOutput())
    ; 똑같은건데 #Image_MENU는 오류나고 #Image_MENU2는 괜찮음. 어디서 이름이 겹치나..? 그래서 그냥 #Image_MENU2 로 합니다.
    DrawImage(ImageID(#Image_MENU2), 0, 0, BackgroundX, BackgroundY)  
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Font15))
    ;DrawText(20, 15, "MENU SCENE", TextColor)
    ;DrawText(20, 50, "USER NAME", TextColor)
    
    DrawImage(ImageID(#Image_LEVEL1_Button), 200, 350- (3*Sin(LEVEL1_pos)),LevelNodeX,LevelNodeY)  
    DrawImage(ImageID(#Image_LEVEL2_Button), 600, 350 -(3*Sin(LEVEL2_pos)),LevelNodeX,LevelNodeY) 
    DrawImage(ImageID(#Image_LEVEL3_Button), 1000, 350 -(3*Sin(LEVEL3_pos)),LevelNodeX,LevelNodeY) 
    DrawImage(ImageID(#Image_Calibration_Button), 50, 100-(3*Sin(CaliButton)), 200,50)
    DrawImage(ImageID(#Image_Calibration_Button), 1300, 100-(3*Sin(Tutorialbutton)), 200,50)
    DrawText(80, 115-(3*Sin(CaliButton)),"캘리브레이션", TextColor)
    DrawText(1350, 115-(3*Sin(Tutorialbutton)),"튜토리얼", TextColor)
    DrawingMode(#PB_2DDrawing_Transparent)
    
    StopDrawing()    
    
    
    If MENUSelect = 1 ;LEVEL1
      LEVEL1_pos +1     
    ElseIf MENUSelect = 2 ;LEVEL2
      LEVEL2_pos +1
    ElseIf MENUSelect = 3 ;LEVEL3
      LEVEL3_pos +1     
    ElseIf MENUSelect = 4 ; calibration 화면
      CaliButton + 1
    ElseIf MENUSelect =5 
      Tutorialbutton + 1
    EndIf  
    
    ; 좌우로 눌러서 메뉴 선택 , 4로 확인
    If  ExamineKeyboard()
      If KeyboardReleased(#PB_Key_Left)
        If  MENUSelect > 1
          MENUSelect - 1
        EndIf 
      ElseIf   KeyboardReleased(#PB_Key_Right) 
        
        If MENUSelect < 5
          MENUSelect + 1
        EndIf  
        
      EndIf
    EndIf 
    
    If KeyboardReleased(#PB_Key_Escape)
      MENUSelect = 10
      Break  
    EndIf  
    
    FlipBuffers()
  Until KeyboardReleased(#PB_Key_4)
  
  
  If MENUSelect = 1
    SceneNumber = #SceneLevel1
  ElseIf   MENUSelect = 2 
    
    SceneNumber = #SceneLevel2
  ElseIf MENUSelect =3 
    SceneNumber = #SceneLevel3
  ElseIf MENUSelect = 4 ;CalibrationScene
    SceneNumber = #CalibrationScene
  ElseIf MENUSelect =5
    SceneNumber = #Tutorial
    
  ElseIf  MENUSelect = 10
    SceneNumber = #Program_End
  EndIf   
  Debug MENUSelect
  
EndProcedure


;Engine Init
InitSprite()
InitSound()
InitKeyboard()
OpenConsole()
;Setup Sprite
UsePNGImageDecoder()

;1536*897

;MainWindow
MainWindow= OpenWindow(0, 0, 0, 1980, 1020, "QookQook", #PB_Window_SystemMenu |#PB_Window_Maximize | #PB_Window_ScreenCentered |#PB_Window_BorderLess)
OpenWindowedScreen(WindowID(0), 0, 0, 1980, 1020)

SceneNumber = #StartScene

Repeat
  FlipBuffers()
  
  If SceneNumber = #StartScene
    
    StartDrawing(ScreenOutput())
    DrawImage(ImageID(#Image_MAIN), 0, 0, BackgroundX, BackgroundY)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(Impact30))
    DrawTextEx(0,0, "A-MAJOR")
    DrawingFont(FontID(Font25))
    DrawText(600, 700 + 3*Sin(posy), "아무키나 누르세요", TextColor) 
    StopDrawing() 
    
    posy= var_x/5
    var_x+1
    ExamineKeyboard()
    If KeyboardReleased(#PB_Key_All)
      ClearScreen(RGB(0, 0, 0))
      SceneNumber = #MenuSelect
    EndIf 
    
    
    
  ElseIf SceneNumber = #MenuSelect
    MenuSelectScene()
    ;Scene Tutorial
  ElseIf SceneNumber = #Tutorial
    CreateTutorial()
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 0))
    ;Scene Level 1
  ElseIf SceneNumber = #SceneLevel1
    SelectedStage = StageSelectScene(1)
    CreateLevel1(SelectedStage)
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 0))
    ;Scene Level 2  
  ElseIf SceneNumber = #SceneLevel2
    CreateLevel2()
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 0))
    ;Scene Level 3
  ElseIf SceneNumber = #SceneLevel3    
    CreateLEVEL3()
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 0))  
    ;Scene Calibration
  ElseIf SceneNumber = #CalibrationScene ; 여기 제스쳐 할때 캘리브레이션한 마스크 리턴해가지고 trackred한테 넘겨주면될듯?
    Createcali()
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 0))
    
  ElseIf  SceneNumber = #Program_End
    Break
    
  EndIf 
  
Until KeyboardReleased(#PB_Key_6) 


FreeArray(problem_list()) 
FreeArray(userAnswers()) 
FreeArray(ptBox())
FreeImage(pbImage)
cvReleaseCapture(@*capture)  
midiOutReset_(hMidiOut)
midiOutClose_(hMidiOut)
CloseWindow(#PB_All)
CloseConsole()
cvDestroyAllWindows()
CloseScreen()


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 412
; FirstLine = 105
; Folding = g
; EnableXP
; Executable = maestro.exe
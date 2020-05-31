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

IncludeFile "./includes/cv_functions.pbi"
IncludeFile "LEVEL1.pb"
IncludeFile "LEVEL2.pb"
IncludeFile "TUTORIAL.pb"
IncludeFile "cv_colorcalibration.pb"
;EnableExplicit
Global Event
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

; + correct.png, incorrect.png


;Setup Font
ImpactFont = LoadFont(#PB_Any, "Impact", 30)
Font15 = LoadFont(#PB_Any, "System", 15)
Font20 = LoadFont(#PB_Any, "System", 20)
Font25 = LoadFont(#PB_Any, "System", 23)
Font40 = LoadFont(#PB_Any, "System", 40,#PB_Font_Bold)



;Image Size
Global *image.IplImage
;Global BackgroundX = 1536, BackgroundY = 897
Global LevelNodeX = 300, LevelNodeY = 300
Global StageNodeX = 400, StageNodeY = 400
Global StageNodePosX = 548 ,StageNodePosY = 349
Global ScorePosX = 845, ScorePosY =349
Global ScoreWidth=200 , ScoreHeight=50
Global NodeTextX = StageNodePosX+105,NodeTextY = StageNodePosY+155


;Setup Screen Color
ScreenDefaultColor    = RGB(215, 73, 11)
TextColor             = RGB(200, 0, 0)



Global Event          

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력, 키보드 3으로 정답 화음 재생

Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, answerTone.i, currentTime, currentProblem.i, spriteinitial.i
Global.l hMidiOut



Procedure drawStageSelect(StageNum, LeftOrRight, LevelNum)
  
  
  
  If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf

  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "./graphics/MAIN.png")
  Font202 = LoadFont(#PB_Any, "Impact", 50)
  ;  Font202 = LoadFont(#PB_Any, "System", 50)
  
  
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
      DrawingFont(FontID(Font202))
      DrawText(NodeTextX, NodeTextY, "Stage"+AfterStage, TextColor)    
      StopDrawing()

      StartDrawing(ScreenOutput())
      
      DrawImage(ImageID(#Image_StageNode), StageNodePosX-x+z, StageNodePosY,StageNodeX, StageNodeY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Font202))
      DrawText(NodeTextX -x+z, NodeTextY, "Stage"+StageNum, TextColor)    
      StopDrawing()
        
         x+20
         If x > 700
              Break  
         EndIf  
   
      ElseIf LeftOrRight = 1
  
      StartDrawing(ScreenOutput())     
      DrawImage(ImageID(#Image_StageNode), StageNodePosX, StageNodePosY,StageNodeX, StageNodeY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Font202))
      DrawText(NodeTextX, NodeTextY, "Stage"+StageNum, TextColor)    
      StopDrawing()
      
      StartDrawing(ScreenOutput())
      DrawImage(ImageID(#Image_StageNode), StageNodePosX-x+z, StageNodePosY,StageNodeX, StageNodeY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Font202))
      DrawText(NodeTextX-x+z, NodeTextY, "Stage"+BeforeStage, TextColor)    
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
  Font202 = LoadFont(#PB_Any, "Impact", 50)
  ;Font202 = LoadFont(#PB_Any, "System", 50)
  
    Repeat
   
    FlipBuffers()
      StartDrawing(ScreenOutput())
      DrawImage(ImageID(#Image_StageBackground), 0, 0,BackgroundX, BackgroundY) 
      DrawingMode(#PB_2DDrawing_Transparent)
      StopDrawing() 
      
      StartDrawing(ScreenOutput())
      DrawImage(ImageID(#Image_StageNode), StageNodePosX-20*Sin(x), StageNodePosY,StageNodeX, StageNodeY)
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(Font202))
      DrawText(NodeTextX-20*Sin(x), NodeTextY, "Stage"+StageNum, TextColor)
      StopDrawing()
      x+20      
    ExamineKeyboard()
  Until KeyboardPushed(#PB_Key_Escape) Or x > 300
       
  
EndProcedure

Procedure StageSelectScene(LevelNum)
  
  
    If LevelNum = 1 
    StageMax =3 
   ElseIf LevelNum =2
     StageMax=2
   EndIf 
  
  
  
  If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf
  StageNum =1

  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "./graphics/MAIN.png")
  Font202 = LoadFont(#PB_Any, "Impact", 50)
  ;Font202 = LoadFont(#PB_Any, "System", 50)
  Repeat
   
    FlipBuffers()
    
    
          
       If StageNum = 1         
         Score = LEVEL1_stage1_score         
       ElseIf StageNum = 2         
          Score = LEVEL1_stage2_score
       ElseIf  StageNum = 3         
          Score = LEVEL1_stage3_score         
       EndIf  
    
    
 ;     StartDrawing(ScreenOutput())
 ;     DrawingFont(FontID(Font202))
 ;     DrawText(200, 200, "LEVEL"+ LevelNum, TextColor)
 ;     DrawingMode(#PB_2DDrawing_Transparent)
 ;     StopDrawing()
      
      StartDrawing(ScreenOutput())
      Box(0, 0, 600, 600, RGB(0,0,0))
      DrawImage(ImageID(#Image_StageBackground), 0, 0, BackgroundX, BackgroundY) 
      DrawingMode(#PB_2DDrawing_Transparent)
       StopDrawing() 

         
       StartDrawing(ScreenOutput())
       DrawingMode(#PB_2DDrawing_Transparent)
       DrawImage(ImageID (#Image_StageNode),StageNodePosX,StageNodePosY,StageNodeX,StageNodeY)
       DrawingFont(FontID(Font202))
       DrawingMode(#PB_2DDrawing_Transparent)
       DrawText(NodeTextX, NodeTextY, "Stage"+StageNum, TextColor)
       DrawText(NodeTextX-50, NodeTextY+100, "score : "+Score, TextColor)
       StopDrawing()
       


       ExamineKeyboard()
       ; 이부분...귀찮은데 나중에 고치기 (return stagenum 하고 함수안에서 stagenum 판별해서 vibe할지 이동할지 하도록.)
       ; 나중에.....
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
  Font202 = LoadFont(#PB_Any, "System", 20)
  MENUSelect = 1
  Debug MENUSelect
  Repeat  

   StartDrawing(ScreenOutput())
   ; 똑같은건데 #Image_MENU는 오류나고 #Image_MENU2는 괜찮음. 어디서 이름이 겹치나..? 그래서 그냥 #Image_MENU2 로 합니다.
   DrawImage(ImageID(#Image_MENU2), 0, 0, BackgroundX, BackgroundY)  
   DrawingMode(#PB_2DDrawing_Transparent)
   DrawingFont(FontID(Font202))
   ;DrawText(20, 15, "MENU SCENE", TextColor)
   ;DrawText(20, 50, "USER NAME", TextColor)
   
   DrawImage(ImageID(#Image_LEVEL1_Button), 200, 350- (3*Sin(LEVEL1_pos)),LevelNodeX,LevelNodeY)  
   DrawImage(ImageID(#Image_LEVEL2_Button), 600, 350 -(3*Sin(LEVEL2_pos)),LevelNodeX,LevelNodeY) 
   DrawImage(ImageID(#Image_LEVEL3_Button), 1000, 350 -(3*Sin(LEVEL3_pos)),LevelNodeX,LevelNodeY) 
   DrawImage(ImageID(#Image_Calibration_Button), 50, 100-(3*Sin(CaliButton)), 200,50)
   DrawImage(ImageID(#Image_Calibration_Button), 1300, 100-(3*Sin(Tutorialbutton)), 200,50)
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


;1980*1020 에서 배율 125%
;1536*897


;Screen
MainWindow= OpenWindow(0, 0, 0, 1980, 1020, "Main Window", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, 1980, 1020)

 SceneNumber = #StartScene
	 

  Repeat
  FlipBuffers()
  
    
 
  If SceneNumber = #StartScene
    
  StartDrawing(ScreenOutput())
  DrawImage(ImageID(#Image_MAIN), 0, 0, BackgroundX, BackgroundY)
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(ImpactFont))
  DrawText(20, 15, "A-MAJOR", TextColor)
  DrawText(20, 50, "USER NAME", TextColor)
    DrawText(700, 700 + 3*Sin(posy), "Press Any Key", TextColor) 
  StopDrawing() 
    
    posy= x/5
    x+1
    ExamineKeyboard()
    If KeyboardReleased(#PB_Key_All)
      ClearScreen(RGB(0, 0, 0))
      SceneNumber = #MenuSelect
    EndIf 
    
    
    
  ElseIf SceneNumber = #MenuSelect
    ; 여기도 나중에 MENUSCENE함수로 빼내기    
    MenuSelectScene()   
  ElseIf SceneNumber = #Tutorial
    CreateTutorial()
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 0))
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
      CreateTutorial()
      SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 0))  
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
  ;FreeSprite(#PB_All)
  ;FreeImage(#PB_All)
  CloseWindow(#PB_All)
  CloseConsole()
  cvDestroyAllWindows()
  CloseScreen()
  Debug "프로그램끝"
  

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 270
; FirstLine = 144
; Folding = 1
; EnableXP
; Executable = maestro.exe
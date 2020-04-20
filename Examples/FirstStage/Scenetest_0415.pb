IncludeFile "../OpenCV_32/includes/cv_functions.pbi"
IncludeFile "LEVEL1.pb"
;IncludeFile "Typeface/Typeface.pbi" : UseModule Typeface
;IncludeFile "LEVEL2.pb"

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
  #SettingScene
  #StageSelect
  #SceneLevel1
  #SceneLevel2
  #SceneLevel3
  #GameEnding
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
  #Image_MENU2
  #Image_PAUSE2
  #Image_StageBackground    
  #Image_Stage_left
  #Image_Stage_right
EndEnumeration


;Setup Font
Font15 = LoadFont(#PB_Any, "System", 15)
Font20 = LoadFont(#PB_Any, "System", 20)
Font25 = LoadFont(#PB_Any, "System", 23)
Font40 = LoadFont(#PB_Any, "System", 40,#PB_Font_Bold)

;Setup Screen Color
ScreenDefaultColor    = RGB(215, 73, 11)
TextColor             = RGB(200, 0, 0)

;Setup Sprite
UsePNGImageDecoder()
LoadImage(#Image_MAIN, "MAIN.png")
LoadImage(#Image_MENU, "MENU.png")
LoadImage(#Image_MENU2, "MENU.png")
LoadImage(#Image_PAUSE2, "PAUSE.png")
LoadImage(#Image_StageBackground, "StageBackground.png")
LoadImage(#Image_Stage_left, "Stage_left.png")
LoadImage(#Image_Stage_right, "Stage_right.png")
Global Event          

; [KEYBOARD] 1: green tracking, 2: red tracking, spacebar: state change
; 처음 시작 후, 마우스 커서와 키보드 1(혹은 2)로 박스 영역 설정 -> 스페이스바로 상태 전환 -> 마우스 커서와 키보드 1(혹은 2)로 음 출력, 키보드 3으로 정답 화음 재생

Global markerState, marker1X, marker1Y, marker2X, marker2Y
Global keyInput, answerTone.i, currentTime, currentProblem.i, spriteinitial.i
Global.l hMidiOut

Procedure drawStageSelect(StageNum, LeftOrRight)
  
  CreateSprite(1,20,20)
  LoadSprite(0, "stage1.png")
  If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf
;
; Now, open a 800*600 - 32 bits screen
;
  ; Load our 16 bit sprite (which is a 24 bit picture in fact, as BMP doesn't support 16 bit format)
  ; 
  CopySprite(0, 1, 0)
  CopySprite(0, 2, 0)
  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "MAIN.png")
  Font202 = LoadFont(#PB_Any, "System", 20)
       Repeat

        FlipBuffers()
     

      StartDrawing(ScreenOutput())

       DrawImage(ImageID(#Image_StageBackground), 0, 0,1920, 1080) 
       DrawingMode(#PB_2DDrawing_Transparent)
       StopDrawing() 
  
      DisplayTransparentSprite(0, 800-x, 400)
      
      StartDrawing(SpriteOutput(0))
      DrawingFont(FontID(Font202))
      DrawText(800-x, 400, "Why black???"+StageNum, TextColor)
      DrawingMode(#PB_2DDrawing_Transparent)
     
      StopDrawing()
   
      StartDrawing(ScreenOutput())
      ;Box(0, 0, 600, 600, ScreenDefaultColor)
        DrawImage(ImageID(#Image_Stage_left), 0, 0,540, 1080) 
        DrawImage(ImageID(#Image_Stage_right), 1500, 0,540, 1080) 
      DrawingMode(#PB_2DDrawing_Transparent)
      StopDrawing() 

       ;LeftOrRight 값이 0이면 left, 1이면 right
       ; 고치다보니 뭔가 왼오 바꼇는데 나중에 고칠래... 
      ;0이면 왼쪽으로가는거  
       If LeftOrRight = 0
         x+20
         If x > 700
              Break  
         EndIf  
         
         
       ElseIf LeftOrRight = 1
         x-20
         
         If x <-700
           Break  
         EndIf  
         
       EndIf  
       
       
      ;Delay(50)
    ExamineKeyboard()
  Until KeyboardPushed(#PB_Key_Escape)
       
EndProcedure

Procedure drawStageVibe(StageNum)
  
   
  LoadSprite(0, "stage1.png")
  If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf

;
; Now, open a 800*600 - 32 bits screen
;
  ; Load our 16 bit sprite (which is a 24 bit picture in fact, as BMP doesn't support 16 bit format)
  ; 
  CopySprite(0, 1, 0)
  CopySprite(0, 2, 0)
  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "MAIN.png")
  Font202 = LoadFont(#PB_Any, "System", 20)
  
       Repeat
    
    ; Inverse the buffers (the back become the front (visible)... And we can do the rendering on the back)
    
    FlipBuffers()
     
    ;ClearScreen(RGB(0,0,0))
    
    ; Draw our sprite

      StartDrawing(ScreenOutput())
      ;Box(0, 0, 600, 600, ScreenDefaultColor)
        DrawImage(ImageID(#Image_StageBackground), 0, 0,1920, 1080) 
      DrawingMode(#PB_2DDrawing_Transparent)
       StopDrawing() 
  
      DisplayTransparentSprite(0, 800-y, 400)
      
      StartDrawing(ScreenOutput())
      DrawingFont(FontID(Font202))
      DrawText(800-y, 400, " "+StageNum, TextColor)
     ; DrawingMode(#PB_2DDrawing_Transparent)
      StopDrawing()
   
      StartDrawing(ScreenOutput())
      ;Box(0, 0, 600, 600, ScreenDefaultColor)
        DrawImage(ImageID(#Image_Stage_left), 0, 0,540, 1080) 
        DrawImage(ImageID(#Image_Stage_right), 1500, 0,540, 1080) 
      DrawingMode(#PB_2DDrawing_Transparent)
      StopDrawing() 
      
      
        
      x+20
      y = 20*Sin(x)
       
    ExamineKeyboard()
  Until KeyboardPushed(#PB_Key_Escape) Or x > 300
       
  
EndProcedure

Procedure StageSelectScene()
 
  LoadSprite(0, "stage1.png")
  If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Sprite system can't be initialized", 0)
  EndIf
  StageNum =1

  CopySprite(0, 1, 0)
  CopySprite(0, 2, 0)
  UsePNGImageDecoder()
  LoadImage(#Image_MAIN, "MAIN.png")
  Font202 = LoadFont(#PB_Any, "System", 20)
  Repeat
   
    FlipBuffers()

      StartDrawing(ScreenOutput())
      DrawingFont(FontID(Font202))
      DrawText(200, 200, "A-MAJOR", TextColor)
      DrawingMode(#PB_2DDrawing_Transparent)
      StopDrawing()
      
      StartDrawing(ScreenOutput())
      Box(0, 0, 600, 600, RGB(0,0,0))
        DrawImage(ImageID(#Image_StageBackground), 0, 0,1920, 1080) 
      DrawingMode(#PB_2DDrawing_Transparent)
       StopDrawing() 

       DisplayTransparentSprite(0, 800, 400)
         
       StartDrawing(ImageOutput(1))
       DrawingFont(FontID(Font202))
       DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(800-x, 400, " "+StageNum, TextColor)
      StopDrawing()
      
      
      StartDrawing(ScreenOutput())
        DrawImage(ImageID(#Image_Stage_left), 0, 0,540, 1080) 
        DrawImage(ImageID(#Image_Stage_right), 1500, 0,540, 1080) 
      DrawingMode(#PB_2DDrawing_Transparent)
       StopDrawing() 

       ExamineKeyboard()
       ; 이부분...귀찮은데 나중에 고치기 (return stagenum 하고 함수안에서 stagenum 판별해서 vibe할지 이동할지 하도록.)
       ; 나중에 하자.....
      If KeyboardPushed(#PB_Key_Left)

        StageNum + 1   
        drawStageSelect(StageNum, 0) 
      
      ElseIf KeyboardPushed(#PB_Key_Right)

      If StageNum > 1
         StageNum - 1
         drawStageSelect(StageNum, 1)
       Else
         drawStageVibe(StageNum)
       EndIf  
         
       EndIf 

    ExamineKeyboard()
    If KeyboardPushed(#PB_Key_Escape)
          ProcedureReturn StageNum 
    EndIf 

  Until KeyboardPushed(#PB_Key_Escape)

EndProcedure

Procedure MenuSelectScene() ;제스쳐로 선택하도록 
  
  Font202 = LoadFont(#PB_Any, "System", 20)
  
  Repeat  
    FlipBuffers()
   StartDrawing(ScreenOutput())
   ;Box(0, 0, 600, 600, ScreenDefaultColor)
   ;DrawImage(ImageID(#Image_MAIN), 0, 0, 1920, 1080)  
   ; 똑같은건데 #Image_MENU는 오류나고 #Image_MENU2는 괜찮음. 어디서 이름이 겹치나..? 그래서 그냥 #Image_MENU2 로 합니다.
   DrawImage(ImageID(#Image_MENU2), 0, 0, 1920, 1080)  
   DrawingMode(#PB_2DDrawing_Transparent)
   DrawingFont(FontID(Font202))
   DrawText(20, 15, "MENU SCENE", TextColor)
   DrawText(20, 50, "USER NAME", TextColor)
    StopDrawing()    
  
    If  ExamineKeyboard()
    If KeyboardPushed(#PB_Key_Left)
      SceneNumber = #SceneLevel2
    ElseIf   KeyboardPushed(#PB_Key_Right) 
      SceneNumber = #SceneLevel1
    ElseIf KeyboardPushed(#PB_Key_Up) 
      SceneNumber = #SceneLevel3
    ElseIf KeyboardPushed(#PB_Key_Down) ;SettingScene
      GameState = #SettingScene
    ElseIf KeyboardPushed(#PB_Key_Escape)
       CloseWindow(0)
       CloseConsole()
    EndIf
   EndIf 

  Until SceneNumber <> #MenuSelect
  
EndProcedure


;Engine Init
InitSprite()
InitSound()
InitKeyboard()
OpenConsole()
;Setup Sprite
UsePNGImageDecoder()

;Screen
MainWindow= OpenWindow(0, 0, 0, 1920, 1080, "Main Window", #PB_Window_SystemMenu |#PB_Window_MaximizeGadget | #PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, 1920, 1080)

If SceneNumber = #StartScene
	
  StartDrawing(ScreenOutput())
  ;Box(0, 0, 600, 600, ScreenDefaultColor)
  DrawImage(ImageID(#Image_MAIN), 0, 0,1920, 1080)
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawingFont(FontID(Font20))
  DrawText(20, 15, "A-MAJOR", TextColor)
  DrawText(20, 50, "USER NAME", TextColor)

  StopDrawing()

  Repeat
  FlipBuffers()

  If SceneNumber = #StartScene
    
      ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_All)
      ClearScreen(RGB(0, 0, 0))
      SceneNumber = #MenuSelect
    EndIf 
    

  ElseIf SceneNumber = #MenuSelect
    ; 여기도 나중에 MENUSCENE함수로 빼내기    
    MenuSelectScene()
  ;Scene Level 1
  ElseIf SceneNumber = #SceneLevel1
    SelectedStage = StageSelectScene()
    CreateLevel1(SelectedStage)
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 200, 0))
  ;Scene Level 2  
    ElseIf SceneNumber = #SceneLevel2
    SelectedStage = StageSelectScene()
    CreateLevel1(SelectedStage)
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 200, 0))
  ;Scene Level 3
    ElseIf SceneNumber = #SceneLevel3 
    SelectedStage = StageSelectScene()
    CreateLevel1(SelectedStage)
    SceneNumber = #MenuSelect
    ClearScreen(RGB(0, 0, 200))
    
  ElseIf SceneNumber = #SettingScene ;원래는 스크린조절이나 볼륨조절같은거 들어가야하는데.... 여기다 뭐넣지..?
    

    
  EndIf 
    
  Until KeyboardPushed(#PB_Key_Escape)

EndIf
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 281
; FirstLine = 169
; Folding = 6
; EnableXP
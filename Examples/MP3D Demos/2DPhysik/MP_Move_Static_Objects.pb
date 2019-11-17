;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Move_Static_Objects.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic move static Objects 
;// 2D Physik Statisches Objekt bewegen
;//
;//
;////////////////////////////////////////////////////////////////

Global wX = 640
Global wY = 480
Global Event
;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4MP3D Demo: MoveStaticObject, Move the StaticWood with MouseButton/MouseWheel", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

; Sprite
Ball = MP_LoadSprite("Ball72x72.bmp")
Balken = MP_LoadSprite("Balken160x30.bmp")
Goal = MP_LoadSprite("Goal72x72.bmp")

; Background
If CreateImage(0, 256, 256,32)
  MP_CreateImageColored(0, 0, #Yellow,#Yellow,#Red,#Green)     
  Surface = MP_ImageToSurface(0) 
  FreeImage(0)
  MP_SurfaceSetPosition(Surface,0,0,1)
  MP_SurfaceDestRect(Surface,0, 0, wX, wY)
EndIf


MP_2DPhysicInit()
;MP_Physic2DSetGravity(100)

GoalBody   = MP_2DPhysicStaticCircle (30, 320, 31, Goal)

BalkenBody = MP_2DPhysicStaticBox(wX/2,400, 160 , 30, Balken)
MP_2DPhysicBodySetProperties(BalkenBody, 1, 1)

BalkenBody2 = MP_2DPhysicStaticBox(wX/2,200, 160 , 30, Balken)
MP_2DPhysicBodySetProperties(BalkenBody2, 1, 1)


BallBody   = MP_2DPhysicBodyCircle (wX/2,5 , 31, Ball, 0.001)
MP_2DPhysicBodySetProperties(BallBody, 1, 1)

MP_2DPhysicCollisionInit()
   
Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  Else  
    Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
  
  ;{- Only Move Moause functions
 
  If MP_MouseButtonDown(0)
    If *shape
      MP_2DPhysicBodySetColor(*shape, 0)
    EndIf 
    *shape  = MP_2DPhysicPickBody(WindowMouseX(0),WindowMouseY(0))
     If Not *shape = GoalBody And Not *shape = BallBody
       switch = 1
     Else
       *shape = 0  
       switch = 0
     EndIf  
  EndIf
   
  If MP_MouseButtonUp(0)
    switch = 0
  EndIf  
  
  If switch = 1
      MP_2DPhysicBodySetColor(*shape, $FF0000)
      MP_2DPhysicBodySetX (*shape,  WindowMouseX(0)) 
      MP_2DPhysicBodySetY (*shape,  WindowMouseY(0)) 
  EndIf 
  
  Mousewheel = MP_MouseDeltaWheel()
  If Mousewheel
    angle + Mousewheel * 0.01
    MP_2DPhysicBodySetAngle(*shape, angle)
    
  EndIf  

  ;}-
  
  If pressesdKey = #True
    MP_DrawText(200,440, "Press SPACE to restart this demo!")
  Else
    MP_DrawText(200,440, "Press SPACE to start this demo!")
  EndIf
  
  If MP_KeyDown( #PB_Key_Space) ; reset the Ball
    pressesdKey = #True
    MP_2DPhysicBodySetVector( BallBody, 0, 0) ; Set 2D Physic Vector
    MP_2DPhysicBodySetAngVeloc(BallBody, 0)
    MP_2DPhysicBodySetAngle(BallBody, 0)
    MP_2DPhysicBodySetX (BallBody,  wX/2) 
    MP_2DPhysicBodySetY (BallBody,  5)
    MP_2DPhysicSetGravity(100)
  EndIf
  
  
  If MP_2DPhysicCollBody(BallBody,GoalBody)
    
    MessageRequester("Gratulation", "You won this hard level", 0)
    End
    
  EndIf  
  
  MP_2DPhysicUpdate(2)

  MP_DrawText(1,1, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj),0,MP_ARGB(255,255,0,255))
  ;- ****  Rendern  ***
  MP_RenderWorld() ; Render World yeh go on
  MP_Flip ()
  
Until MP_KeyDown(#PB_Key_Escape) Or Event=#PB_Event_CloseWindow

MP_2DPhysicEnd()
End

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 63
; FirstLine = 56
; Folding = -
; Executable = C:\MP_Pachinko.exe
; SubSystem = dx9
; EnableCompileCount = 2651
; EnableBuildCount = 19
; 꺅뇦ꖍ跧뒽跥떉ꗧ뎑뗦¥
; 藦꺕뇦ꂀ觧ꆵ釧ꖉ賥붐ꗣ肔藦ꊱ跤떍
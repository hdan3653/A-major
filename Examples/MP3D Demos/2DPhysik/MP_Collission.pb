;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Collission.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic collission check
;// 2D Physik kollisionstest
;//
;//
;////////////////////////////////////////////////////////////////

;XIncludeFile "C:\Program Files\PureBasic\Examples\DirectX For PB4\Source\MP3D_Library.pb"


Global wX = 640
Global wY = 480
Global Event
;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4MP3D Demo: Collision, let the ball hit the Goal", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

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

GoalBody   = MP_2DPhysicStaticCircle (30, 320, 31, Goal)

BalkenBody = MP_2DPhysicStaticBox(wX/2,400, 160 , 30, Balken)
MP_2DPhysicBodySetProperties(BalkenBody, 0.9, 0)

BalkenBody2 = MP_2DPhysicBodyBox(wX/2-80,200, 160 , 30, Balken, 1)
MP_2DPhysicBodySetProperties(BalkenBody2, 0.5, 0)

MP_2DPhysicAddPivotConstraint(BalkenBody2, 0, 0)


BallBody   = MP_2DPhysicBodyCircle (wX/2,5 , 31, Ball, 10)
MP_2DPhysicBodySetProperties(BallBody, 0.9, 0)

MP_2DPhysicCollisionInit()

Dim a(1)
a(0) = BallBody
a(1) = GoalBody


Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  Else  
    Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
  
  ;MP_2DPhysicMoveBody( Event, WindowMouseX(0), WindowMouseY(0), A(), 1)
  MP_2DPhysicMoveBody( Event, WindowMouseX(0), WindowMouseY(0), A(), 1)
  
  If pressesdKey = #True
    MP_DrawText(200,440, "Press SPACE to restart this demo!")
  Else
    MP_DrawText(200,440, "Press SPACE to start this demo!")
  EndIf
  
  If MP_KeyDown( #PB_Key_Space)
    pressesdKey = #True
    MP_2DPhysicBodySetVector( BallBody, 0, 0) ; Set 2D Physic Vector
    MP_2DPhysicBodySetAngVeloc(BallBody, 0)
    MP_2DPhysicBodySetAngle(BallBody, 0)
    MP_2DPhysicBodySetX (BallBody,  wX/2) 
    MP_2DPhysicBodySetY (BallBody,  5)
    MP_2DPhysicSetGravity(100)
  EndIf
  
  If MP_KeyDown( #PB_Key_F1)
    MP_2DPhysicBodyRemove(BallBody)
    BallBody = 0
  EndIf
  
  
  If MP_2DPhysicCollBody(BallBody,GoalBody)
    
    MessageRequester("Gratulation", "You won this hard level", 0)
    End
    
  EndIf  
  
 ; MP_2DPhysicUpdate(2)
  MP_2DPhysicUpdate(2)

  ;MP_DrawText(1,1, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj),0,MP_ARGB(255,255,0,255))
  MP_DrawText(1,1, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj),0,MP_ARGB(255,255,0,255))
  ;- ****  Rendern  ***
  MP_RenderWorld() ; Render World yeh go on
  MP_Flip ()
  
Until MP_KeyDown(#PB_Key_Escape) Or Event=#PB_Event_CloseWindow

MP_2DPhysicEnd()
End

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 48
; Executable = C:\MP_Pachinko.exe
; SubSystem = dx9
; EnableCompileCount = 2870
; EnableBuildCount = 20
; ꪫꫮ뮺ꯪꪪꫪ꪿뫮몺꯫ꪪꫪ꺻ꫮꪾ꿪
; ꫪ꺻ꫮ몮꿫꺺ꫪꪫꫮ뾪꯫ꮪꫫꪯ뫮꺪
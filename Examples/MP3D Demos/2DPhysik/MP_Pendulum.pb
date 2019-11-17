;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Pendulum.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic Pendulum
;// 2D Physik Pendel
;//
;//
;////////////////////////////////////////////////////////////////
 
Global wX = 640
Global wY = 480
Global Event
;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4MP3D Demo: Pendulum, get the Pendulums and move them", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

; Sprite
;Ball = MP_LoadSprite("Ball72x72.bmp")
;Balken = MP_LoadSprite("Balken160x30.bmp")
;Goal = MP_LoadSprite("Goal72x72.bmp")

; Background
If CreateImage(0, 256, 256,32)
  MP_CreateImageColored(0, 0, #Yellow,#Yellow,#Red,#Green)     
  Surface = MP_ImageToSurface(0) 
  FreeImage(0)
  MP_SurfaceSetPosition(Surface,0,0,1)
  MP_SurfaceDestRect(Surface,0, 0, wX, wY)
EndIf

MP_2DPhysicInit()
MP_2DPhysicSetGravity(100)

Pendlum1 = MP_2DPhysicBodyCircle (140, 320, 30, 0,100,$FF0000)
MP_2DPhysicAddPivotConstraint(Pendlum1, 0, -200)
MP_2DPhysicBodySetProperties(Pendlum1, 0.95, 0.95)

Pendlum2 = MP_2DPhysicBodyCircle (200, 320, 30, 0,100,$FF0000)
MP_2DPhysicAddPivotConstraint(Pendlum2, 0, -200)
MP_2DPhysicBodySetProperties(Pendlum2, 0.95, 0.95)

Pendlum3 = MP_2DPhysicBodyCircle (260, 320, 30, 0,100,$FF0000)
MP_2DPhysicAddPivotConstraint(Pendlum3, 0, -200)
MP_2DPhysicBodySetProperties(Pendlum3, 0.95, 0.95)

Pendlum4 = MP_2DPhysicBodyCircle (320, 320, 30, 0,100,$FF0000)
MP_2DPhysicAddPivotConstraint(Pendlum4, 0, -200)
MP_2DPhysicBodySetProperties(Pendlum4, 0.95, 0.95)

Pendlum5 = MP_2DPhysicBodyCircle (380, 320, 30, 0,100,$FF0000)
MP_2DPhysicAddPivotConstraint(Pendlum5, 0, -200)
MP_2DPhysicBodySetProperties(Pendlum5, 0.95, 0.95)

Pendlum6 = MP_2DPhysicBodyCircle (440, 320, 30, 0,100,$FF0000)
MP_2DPhysicAddPivotConstraint(Pendlum6, 0, -200)
MP_2DPhysicBodySetProperties(Pendlum6, 0.95, 0.95)



Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  Else  
    Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
  
  MP_LineXY (MP_2DPhysicBodyGetX (Pendlum1), MP_2DPhysicBodyGetY (Pendlum1), 140, 120,$FF0000) 
  MP_LineXY (MP_2DPhysicBodyGetX (Pendlum2), MP_2DPhysicBodyGetY (Pendlum2), 200, 120,$FF0000) 
  MP_LineXY (MP_2DPhysicBodyGetX (Pendlum3), MP_2DPhysicBodyGetY (Pendlum3), 260, 120,$FF0000) 
  MP_LineXY (MP_2DPhysicBodyGetX (Pendlum4), MP_2DPhysicBodyGetY (Pendlum4), 320, 120,$FF0000) 
  MP_LineXY (MP_2DPhysicBodyGetX (Pendlum5), MP_2DPhysicBodyGetY (Pendlum5), 380, 120,$FF0000) 
  MP_LineXY (MP_2DPhysicBodyGetX (Pendlum6), MP_2DPhysicBodyGetY (Pendlum6), 440, 120,$FF0000) 
  
  
  MP_2DPhysicMoveBody( Event, WindowMouseX(0), WindowMouseY(0))
  
  MP_2DPhysicUpdate(2)

  MP_DrawText(1,1, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj),0,MP_ARGB(255,255,0,255))
  ;- ****  Rendern  ***
  MP_RenderWorld() ; Render World yeh go on
  MP_Flip ()
  
Until MP_KeyDown(#PB_Key_Escape) Or Event=#PB_Event_CloseWindow

MP_2DPhysicEnd()
End

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 39
; FirstLine = 23
; Executable = C:\MP_Pachinko.exe
; SubSystem = dx9
; EnableCompileCount = 2842
; EnableBuildCount = 20
; ꪫꛮ뮺ꯪ趦ꫫꢿ뫮몚鯨隢ꫪ꺋ꫮ麞꿪
; ꫪ꺻ꫮ骞꿨꺺諪ꢛ껮龢꯫Ɪꫩꦯ뫮ꊶ
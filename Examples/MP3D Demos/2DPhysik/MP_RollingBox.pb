;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_RollingBox.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic rolling box
;// 2D Physik rollende Box
;//
;//
;////////////////////////////////////////////////////////////////

Global wX = 640
Global wY = 480

;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4MP3D Demo: RollingBox, Space makes more Objects", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

; Cube Color
If CreateImage(0, 40, 40)
  MP_CreateImageColored(0, 0, #Blue,#Blue,#Red,#Green)  
  img = MP_ImageToTexture(0) 
  Sprite = MP_SpriteFromTexture(img)
  FreeImage(0)
EndIf

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

*Body = MP_2DPhysicStaticLine(-200, -200, -200, 200,1)
MP_2DPhysicBodySetX (*Body,  320)
MP_2DPhysicBodySetY (*Body,  240)
MP_2DPhysicBodySetAngVeloc(*Body, 0.4)

*Body = MP_2DPhysicStaticLine(-200, 200, 200, 200,1)
MP_2DPhysicBodySetX (*Body,  320)
MP_2DPhysicBodySetY (*Body,  240)
MP_2DPhysicBodySetAngVeloc(*Body, 0.4)

*Body = MP_2DPhysicStaticLine(200, 200, 200, -200,1)
MP_2DPhysicBodySetX (*Body,  320)
MP_2DPhysicBodySetY (*Body,  240)
MP_2DPhysicBodySetAngVeloc(*Body, 0.4)

*Body = MP_2DPhysicStaticLine(200, -200, -200, -200,1)
MP_2DPhysicBodySetX (*Body,  320)
MP_2DPhysicBodySetY (*Body,  240)
MP_2DPhysicBodySetAngVeloc(*Body, 0.4)

Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  Else  
    Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
  
  If pressesdKey = #True
    MP_DrawText(200,500, "Press SPACE to restart this demo!")
  Else
    MP_DrawText(200,500, "Press SPACE to start this demo!")
  EndIf
    
  If MP_KeyDown( #PB_Key_Space)
    pressesdKey = #True

    ;{ Make Body

    MP_2DPhysicBodyBox(wX/2, wY/2, 40, 40, Sprite , 1);,RGB(Random(255),Random(255),Random(255)))   
    obj+1
    ;}
    
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
; CursorPosition = 28
; FirstLine = 12
; Folding = -
; Executable = C:\MP_BoxPyramid.exe
; SubSystem = dx9
; CurrentDirectory = D:\Documents and Settings\eddy.eded.000\Bureau\zzzzzzz\
; CompileSourceDirectory
; EnableCompileCount = 2435
; EnableBuildCount = 18
; 超闧ꆱ胥ꆉ뗦ꖑ觧ꂌ郤颥铤꺅뇦ꖍ跧
; 藦ꊱ跤떍뷦궍触鎥釧ꖵ超闧ꆱ胥ꆉ뗦
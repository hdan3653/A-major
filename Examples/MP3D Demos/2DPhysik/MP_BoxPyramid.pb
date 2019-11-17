;XIncludeFile "Chipmunk4PB_v0.5_lib.pbi"
;XIncludeFile "Chipmunk4PB.pbi"

;- Diese Version funktioniert richtig!!!!

;http://www.alexandre-gomes.com/articles/chipmunk/initchipmunk.php

Global wX = 640
Global wY = 480

;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4MP3D Demo: Box Pyramid, Space makes more Objects", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

If CreateImage(0, 30, 30)
  MP_CreateImageColored(0, 0, #Yellow,#Blue,#Red,#Green)  
  img = MP_ImageToTexture(0) 
  Sprite = MP_SpriteFromTexture(img)
  StartDrawing(ImageOutput(0))
  Box(0, 0, 30, 30, $0)
  Circle(15, 15, 15, RGB(Random(255), Random(255), Random(255)))
  StopDrawing() 
  img = MP_ImageToTexture(0) 
  Sprite2 = MP_SpriteFromTexture(img)
  FreeImage(0)
EndIf

If CreateImage(0, 256, 256,32)
  MP_CreateImageColored(0, 0, #Yellow,#Yellow,#Red,#Green)     
  Surface = MP_ImageToSurface(0) 
  FreeImage(0)
  MP_SurfaceSetPosition(Surface,0,0,1)
  MP_SurfaceDestRect(Surface,0, 0, wX, wY)
EndIf

MP_2DPhysicInit()
MP_2DPhysicSetGravity(100)


; Aussenrand
MP_2DPhysicStaticLine(0, 0, 0, wY)
MP_2DPhysicStaticLine(0, wY, wX, wY)
MP_2DPhysicStaticLine(wX, 0, wX, wY)

radius.f=15.0
*Body = MP_2DPhysicBodyCircle(320-radius, 480-radius, radius, Sprite2, 10)
MP_2DPhysicBodySetProperties(*Body, 0 , 0.9)

For i=0 To 14
  For j=0 To i
        
    obj +1

    *Body = MP_2DPhysicBodyBox((j*32-i*16)+320, -50-(i*-32), 30, 30, Sprite , 1)
    MP_2DPhysicBodySetProperties(*Body, 0 , 0.8)

  Next
Next

Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  Else  
    Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
  
  If MP_KeyDown( #PB_Key_Space)
    
    obj +1
  ;{ Make Body
    *Body = MP_2DPhysicBodyBox(wX/2, -20, 30, 30, Sprite , 1)    
    ;}
    
  EndIf
   
  MP_2DPhysicUpdate()
 
  MP_DrawText(1,1, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj),0,MP_ARGB(255,255,0,255))
  ;- ****  Rendern  ***
  MP_RenderWorld() ; Render World yeh go on
  MP_Flip ()
  
  
Until MP_KeyDown(#PB_Key_Escape) Or Event=#PB_Event_CloseWindow

MP_2DPhysicEnd()
End

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 76
; FirstLine = 31
; Folding = -
; Executable = C:\MP_BoxPyramid.exe
; SubSystem = dx9
; CurrentDirectory = D:\Documents and Settings\eddy.eded.000\Bureau\zzzzzzz\
; CompileSourceDirectory
; EnableCompileCount = 2297
; EnableBuildCount = 19
; ꫪ꺫ꫮ몮꿪꺺ꫩꪫꫮ뾪꯫ꮪꫫꮯ뫮꺪
; ꪫꫮ뮺ꯪ꾪ꫫꮿ뫮몺诪ꪦꫪ꺫ꫮꪾ꿪
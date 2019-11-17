;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ComplexObject.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic complex object
;// 2D Physik komplexes Objekt
;//
;//
;////////////////////////////////////////////////////////////////

Global wX = 640
Global wY = 480

;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4PB Demo: ComplexObject, Space makes more Objects", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)


If CreateImage(0, 30, 30)
  MP_CreateImageColored(0, 0, #Yellow,#Blue,#Red,#Green)  
  img = MP_ImageToTexture(0) 
  Sprite = MP_SpriteFromTexture(img)
  FreeImage(0)
EndIf

If CreateImage(0, 20, 20) 
  StartDrawing(ImageOutput(0))
  Circle(10, 10, 10, RGB(255,0,0))
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
MP_2DPhysicStaticLine(0, 0, 0, wY ,1)
MP_2DPhysicStaticLine(0, wY, wX, wY,1)
MP_2DPhysicStaticLine(wX, 0, wX, wY,1)

For i=0 To 50
  j=i+1
  MP_2DPhysicStaticLine(i*10, i*10, j*10,i*10 ,$FF00FF)
  MP_2DPhysicStaticLine(j*10, i*10, j*10, j*10 ,$FFFFFF)
Next

*Body = MP_2DPhysicBodyBox(30, -20, 30, 30, Sprite , 1)
*Body2 = MP_2DPhysicAddCircle (*Body, -25, 0 ,10, Sprite2,1)
MP_2DPhysicBodySetProperties(*Body2, 0.9, 1.5)

obj +1

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
    
    ;}
    
    obj +1
    

    ;{ Make Body
    *Body = MP_2DPhysicBodyBox(50, -20, 30, 30, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
    ;}
    
  EndIf
  
   
   
  MP_2DPhysicUpdate(2)
 
  MP_DrawText(200,1, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj),0,MP_ARGB(255,0,0,255))
  ;- ****  Rendern  ***
  MP_RenderWorld() ; Render World yeh go on
  MP_Flip ()
  
  
Until MP_KeyDown(#PB_Key_Escape) Or Event=#PB_Event_CloseWindow

MP_2DPhysicEnd()
End

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 10
; Folding = -
; Executable = C:\MP_Stairs.exe
; SubSystem = dx9
; CurrentDirectory = D:\Documents and Settings\eddy.eded.000\Bureau\zzzzzzz\
; CompileSourceDirectory
; EnableCompileCount = 2363
; EnableBuildCount = 19
; ꚗ黮閺蟫ꆖ苪ꞧ髮떆蟩ꖞ雪ꖳ鋮邶韪
; 뫪ꚇ鋮趖럨떚鋫ꖷ髮視韪鎞軫ꚗꗂꚗ
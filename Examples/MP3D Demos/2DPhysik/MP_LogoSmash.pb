 ;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_LogoSmash.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic logo smash 
;// 2D Physik Logosmash
;//
;//
;////////////////////////////////////////////////////////////////

Global wX = 640
Global wY = 640
Global Dim aSprite(5)
Global myImage = CreateImage(#PB_Any, 155, 71)
Global obj

Procedure.i init()
    
  StartDrawing(ImageOutput(myImage))
  image_width = ImageWidth(myImage)
  image_height = ImageHeight(myImage)
  
  For y = image_height-1 To 0 Step -1
    For x = image_width-1 To 0 Step -1
      
      color = Point(x, y)
      
      If  color = 0 
       If x % 7 <> 0 And y % 7 <> 0
          Continue
          EndIf
      EndIf
      
       MP_2DPhysicBodyCircle (2.5*(x - image_width/2 + x_jitter) + 320, 2.5*(y-image_height/2  + y_jitter) + 300, 1, aSprite(color),1)
      
      obj+1

    Next x
  Next y
  StopDrawing()
  
EndProcedure

;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4PB Demo: LogoSmash with MP3D", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

StartDrawing(ImageOutput(myImage))
  DrawText(14, 0,  "*   Chipmunk4PB   *", 1)
  DrawText(14, 18, "* wrapper 5.3.5.1 *", 2)
  DrawText(14, 36, "*  together with  *", 3)
  DrawText(14, 54, "* the MP3D engine *", 4)
StopDrawing() 

If CreateImage(0, 3,3) 
  StartDrawing(ImageOutput(0))
  Circle(1,1,1,#Gray)
  StopDrawing()
  img1 = MP_ImageToTexture(0) 

aSprite(0) = MP_SpriteFromTexture(img1)
  StartDrawing(ImageOutput(0))
  Circle(1,1,1,#Red)
  StopDrawing()
  img2 = MP_ImageToTexture(0) 
  
aSprite(1) = MP_SpriteFromTexture(img2)
  StartDrawing(ImageOutput(0))
  Circle(1,1,1,#Yellow)
  StopDrawing()
  img3 = MP_ImageToTexture(0) 

aSprite(2) = MP_SpriteFromTexture(img3)
  StartDrawing(ImageOutput(0))
  Circle(1,1,1,#Green)
  StopDrawing()
  img4 = MP_ImageToTexture(0) 

aSprite(3) = MP_SpriteFromTexture(img4)
  StartDrawing(ImageOutput(0))
  Circle(1,1,1,#Blue)
  StopDrawing()
  img5 = MP_ImageToTexture(0) 
aSprite(4) = MP_SpriteFromTexture(img5)
  
  FreeImage(0)
EndIf

MP_2DPhysicInit()

init()

If CreateImage(0, 256, 256,32)
  MP_CreateImageColored(0, 0, #Blue,#Yellow,#Red,#Green)     
  
  Surface = MP_ImageToSurface(0) 
  
  FreeImage(0)
  MP_SurfaceSetPosition(Surface,0,0,1)
  MP_SurfaceDestRect(Surface,0, 0, wX, wY)
EndIf



Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  ;Else  
   ; Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
  
  If pressesdKey = #True
    MP_DrawText(200,500, "Press SPACE to restart this demo!")
  Else
    MP_DrawText(200,500, "Press SPACE to start this demo!")
  EndIf
  
 
  
  If MP_KeyDown( #PB_Key_Space)
    pressesdKey = #True
    
    ;{ Physic Reset
    MP_2DPhysicEnd()
    MP_2DPhysicInit()
    ;}
    
    obj = 0
    
    init()
    
    ;{ Make Bullets
    
    *Body = MP_2DPhysicBodyCircle(-300, 200, 8, 0, 9999999)
    MP_2DPhysicBodySetVector( *Body, 700, 105)
    
    *Body = MP_2DPhysicBodyCircle(900, 390, 8, 0, 9999999)
    MP_2DPhysicBodySetVector( *Body, -700, -105)
    ;}
    
  EndIf
  
  MP_2DPhysicUpdate()
 
  MP_DrawText(200,560, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj))
  ;- ****  Rendern  ***
  
  ;MP_RenderBegin()
    
   ;Draw your text first
  ;  MP_RenderText() 
   
   ; Draw your sprite last and over text
  ;  MP_RenderSprite() 
      
  ;  MP_RenderEnd()
  
  MP_RenderWorld() ; Render World yeh go on
  MP_Flip ()
  
Until MP_KeyDown(#PB_Key_Escape) Or Event=#PB_Event_CloseWindow

MP_2DPhysicEnd()
End

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 15
; Folding = -
; Executable = C:\LogoSmash_6.0.2.exe\MP_LogoSmash.exe
; SubSystem = dx9
; DisableDebugger
; CurrentDirectory = D:\Documents and Settings\eddy.eded.000\Bureau\zzzzzzz\
; CompileSourceDirectory
; EnableCompileCount = 2206
; EnableBuildCount = 21
; 鮪诪릪黩ꢯ뫮ꪖ鯨늦ꋪ꺫ꛮ芪꿪ꮺ雨
; ꯩꞦ뫪꺫ꋮꚚ뿩ꦺ髪ꪋꋮ뮢鯪閪黨ꦯ
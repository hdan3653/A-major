;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteBlendmodus_2.pb
;// Erstellt am: 21.10.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einsatz des Blendmodus, nach einer Idee von STARGÅTE  
;//
;//
;////////////////////////////////////////////////////////////////


InitNetwork()

Enumeration
  #Background
  #Light
EndEnumeration

MP_Graphics3D (800,600,0,3)

ReceiveHTTPFile("http://data.unionbytes.de/sand.jpg", GetTemporaryDirectory()+"sand.jpg")

Background = MP_LoadSprite(GetTemporaryDirectory()+"sand.jpg")

CreateImage(#Light, 256, 256)
StartDrawing(ImageOutput(#Light))
   For r = 127 To 0 Step -1
     Circle(128, 128, r, RGB(255-r*2, 0,0))
   Next
StopDrawing()
  
Texture = MP_ImageToTexture(#Light)
FreeImage(#Light)
Light = MP_SpriteFromTexture(Texture) 
  
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    
    MP_SpriteBlendingMode(Background, 5, 6)
    MP_SpriteBlendingMode(Light, 5, 6)
    ;
    MP_DrawSprite(Background, 100, 100)
    MP_DrawSprite(Light, 400, 50, 255)
    
    MP_SpriteBlendingMode(Light, 5, 2)
    MP_DrawSprite(Light, 150, 150,128+Sin(ElapsedMilliseconds()/100)*32)
      
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

  Wend
  
  
  
 
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 39
; FirstLine = 3
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

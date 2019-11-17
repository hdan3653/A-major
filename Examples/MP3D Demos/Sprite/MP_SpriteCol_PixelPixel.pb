
;///////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpritePick.pb
;// Erstellt am: 9.2.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple SpritePick Test
;// Einfacher SpritePick Test
;//
;//
;////////////////////////////////////////////////////////////////

wX = 640
wY = 480

MP_Graphics3D (wX,wY,0,3)

MP_VSync(0)

Sprite0 = MP_CatchSprite(?pic, ?picend-?pic) 
Sprite1 = MP_CatchSprite(?pic, ?picend-?pic) 

MP_TransparentSpriteColor(Sprite0, 11)

angle0.f = 90

MP_AmbientSetLight($666611) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen


    angle0.f + 40 * MP_VSyncTime() ; Geschwindigkeit bleibt trotz anderer FPS gleich 

    x0 = wX/2-MP_SpriteGetWidth(Sprite0)/2 ; Mitte des Bildschirms
    y0 = wY/2-MP_SpriteGetHeight(Sprite0)/2 ; Mitte des Bildschirms

    x1 = WindowMouseX(0) 
    y1 = WindowMouseY(0) 
 
    
    MP_RotateSprite(Sprite0,angle0)
    MP_DrawSprite(Sprite0,x0,y0)  

    MP_RotateSprite(Sprite1,-angle0)
    MP_DrawSprite(Sprite1,x1,y1)  
    
    
    If MP_SpritePixelCollision(Sprite0,x0,y0,Sprite1,x1,y1,3)
         MP_DrawText(1,1,"Treffer Sprite Mitte")
    EndIf
    
   SetWindowTitle(0,"MP Sprite Kollisions Test "+Str(MP_FPS())+" FPS + "+Str(kol)+" Treffer")
   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend

DataSection
  pic: 
  IncludeBinary "SpinnerBlock3.bmp";"Bild.png"
   picend:
   
EndDataSection

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 64
; FirstLine = 19
; EnableXP
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
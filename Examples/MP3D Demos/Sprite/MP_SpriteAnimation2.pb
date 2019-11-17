;////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteAnimation2.pb
;// Erstellt am: 27.10.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple animated sprite display
;// Einfache animierte Sprite Darstellung
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,2)

Sprite = MP_LoadSprite("donut.bmp") ; Donutgrafik linksdrehend
MP_SpriteSetAnimate(Sprite,30,60,64,64)

MP_AmbientSetLight (RGB(0,50,128))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    
       MP_DrawSprite(Sprite, x, 100, x, 0)
       MP_DrawSprite(Sprite, x+80, 100, x, 5)
       MP_DrawSprite(Sprite, x+160, 100, x, 10)
       MP_DrawSprite(Sprite, x+240, 100, x, 20)
       MP_DrawSprite(Sprite, x+320, 100, x, 25)

       MP_DrawSprite(Sprite, x, 180, x, 1)
       MP_DrawSprite(Sprite, x+80, 180, x, 17)
       MP_DrawSprite(Sprite, x+160, 180, x, 5)
       MP_DrawSprite(Sprite, x+240, 180, x, 16)
       MP_DrawSprite(Sprite, x+320, 180, x, 3)

       MP_DrawSprite(Sprite, x, 260, x, 4)
       MP_DrawSprite(Sprite, x+80, 260, x, 28)
       MP_DrawSprite(Sprite, x+160, 260, x, 2)
       MP_DrawSprite(Sprite, x+240, 260, x, 14)
       MP_DrawSprite(Sprite, x+320, 260, x, 5)
       
       MP_DrawSprite(Sprite, x, 340, x, 17)
       MP_DrawSprite(Sprite, x+80, 340, x, 25)
       MP_DrawSprite(Sprite, x+160, 340, x, 14)
       MP_DrawSprite(Sprite, x+240, 340, x, 7)
       MP_DrawSprite(Sprite, x+320, 340, x, 2)
       
    x+1
    If x = 400
      x=0
    EndIf   
      
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend



; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 45
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

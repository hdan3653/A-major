
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Parallax_Backdrop.pb
;// Created On: 27.04.2010
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// a simple scrolling backdrop with parallax effect
;// 
;//
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,480,0,2)

Sprite = MP_LoadSprite("stars.bmp") ; Grafik hat 10 Ziffern

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_DrawTiledSprite(Sprite, 0, scroll_y)

    MP_DrawTiledSprite(Sprite, 9, scroll_y*2)

    MP_DrawTiledSprite(Sprite, 23, scroll_y*3)

	  scroll_y+1
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 20
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

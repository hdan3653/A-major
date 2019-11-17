;////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_DrawBitMapFont.pb
;// Erstellt am: 3.11.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple Bitmap text display
;// Einfache Bitmap Text Darstellung
;//
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,480,0,1)

Sprite0 = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData); Grafik hat 60 Zeichen mit 16x16
MP_SpriteSetAnimate(Sprite0,60,0,16,16) 

Sprite1 = MP_CatchSprite(?EndOfMyData, ?EndOfMyData2 - ?EndOfMyData) ; Grafik hat 120 Zeichen mit 28x24
MP_SpriteSetAnimate(Sprite1,120,0,28,24) 
MP_TransparentSpriteColor(Sprite1, RGB(152,152,152)) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_DrawBitMapText(Sprite1, 100, 200, "MP3D finde ich gut",123,32,-8)
    MP_DrawBitMapText(Sprite0, 100, 240, "MP3D FINDE ICH GUT")
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend


DataSection
  MyData:
     IncludeBinary "Spherical.bmp"
  EndOfMyData:
     IncludeBinary "Fugger2.bmp"
  EndOfMyData2:
     
EndDataSection





; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 24
; EnableXP
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

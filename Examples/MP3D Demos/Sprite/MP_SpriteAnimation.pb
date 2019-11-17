;////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteAnimation.pb
;// Erstellt am: 9.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple animated sprite display
;// Einfache animierte Sprite Darstellung
;//
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,480,0,1)

Sprite7 = MP_LoadSprite("numbers.bmp") ; Grafik hat 10 Ziffern

Sprite0 = MP_LoadSprite("numbers.bmp") ; Grafik hat 10 Ziffern
MP_SpriteSetAnimate(Sprite0,10,0,17,27) 

Sprite1 = MP_LoadSprite("donut.bmp") ; Donutgrafik linksdrehend
MP_SpriteSetAnimate(Sprite1,30,60,64,64) ; 

Sprite2 = MP_LoadSprite("donut.bmp"); Donutgrafik linksdrehend versetzt
MP_SpriteSetAnimate(Sprite2,30,60,64,64)
MP_SpriteSetFrame(Sprite2 , 15)

Sprite3 = MP_LoadSprite("donut.bmp") ; Donutgrafik rechtsdrehend
MP_SpriteSetAnimate(Sprite3,30,60,64,64)
MP_SpriteSetAnimdirection(Sprite3,-1)

Sprite4 = MP_LoadSprite("explosion.bmp") ; Hat nur 14 Bilder, 15 Bild ist quasi ein Leerbild
MP_SpriteSetAnimate(Sprite4,15,10,42,36)

x1 = Random (620)
y1 = Random (460)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    x+1
    If x > 1 : z0 + 1 : x = 0 : EndIf ; Grundzähler

    If z0 > 9 : z0 = 0 : z1 + 1 : EndIf ; Erstes Zahlenpaar    
    If z1 > 9 : z1 = 0 : z2 + 1 : EndIf ; Zweites Zahlenpaar    
    If z2 > 9 : z2 = 0 : EndIf ; Drittes Zahlenpaar     
    If z3 > 9 : z3 = 0 : EndIf ; Viertes Zahlenpaar     
       
    MP_DrawFrameSprite(Sprite0, 100, 200 , z3 ,255)
    MP_DrawFrameSprite(Sprite0, 118, 200 , z2 ,255)
    MP_DrawFrameSprite(Sprite0, 136, 200 , z1 ,255)
    MP_DrawFrameSprite(Sprite0, 154, 200 , z0 ,255)

    MP_DrawFrameSprite(Sprite0, 450, 200 , z0 ,255)
    MP_DrawFrameSprite(Sprite0, 468, 200 , z1 ,255)
    MP_DrawFrameSprite(Sprite0, 486, 200 , z2 ,255)
    MP_DrawFrameSprite(Sprite0, 504, 200 , z3 ,255)
    
    MP_DrawSprite(Sprite1,200,180)
    
    MP_DrawSprite(Sprite1,200,280)
    
    MP_DrawSprite(Sprite1,200,380)
    
    

    MP_DrawSprite(Sprite2,280,180)

    MP_DrawSprite(Sprite3,360,180)

    MP_DrawRectSprite (Sprite7,240,280,1+z0,1+z1,170,17,255)
    
    MP_DrawSprite(Sprite4,x1,y1)

    If MP_SpriteGetFrame(Sprite4) = 14
      MP_SpriteSetFrame(Sprite4,0)
      x1 = Random (620)
      y1 = Random (460)
    EndIf
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend






; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 63
; FirstLine = 28
; EnableAsm
; Executable = \\Hh\transfer\test2.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

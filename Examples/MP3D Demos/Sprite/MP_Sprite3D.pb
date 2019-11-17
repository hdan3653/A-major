;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Sprite3D.pb
;// Erstellt am: 13.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einfache Sprite3D Demo
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,0)

Sprite = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData)
Sprite2 = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData)
;Sprite2 = MP_CopySprite(Sprite)

MP_TransparentSpriteColor(Sprite,  RGB(255,0,255))
MP_TransparentSpriteColor(Sprite2, RGB($FF,0,$FF))


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    
    MP_AmbientSetLight (RGB(0,50,128))
    
    ; Draw our sprite
      
      MP_DrawSprite(Sprite, 0, 25)
      MP_DrawSprite(Sprite, x+100, 100, x)
      MP_DrawSprite(Sprite, x*2, 100, x)

      ; Zoom..
      ;
      MP_ScaleSprite(Sprite2, x, x)
      MP_RotateSprite(Sprite2, x)
      MP_DrawSprite  (Sprite2, 0, 100, x/2)
      MP_DrawSprite  (Sprite2, x*2, 100, x)
      MP_DrawSprite  (Sprite2, 0, 100, x/2)
      MP_DrawSprite  (Sprite2, x*2, 200+x, x)
      
    x+1
    
    If x = 300
      x=0
    EndIf   
    
      
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

DataSection
  MyData:
     IncludeBinary #PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp"
  EndOfMyData:
EndDataSection

; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 18
; FirstLine = 6
; EnableXP
; Executable = C:\sprite.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
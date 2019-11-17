;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_DrawOrder.pb
;// Erstellt am: 13.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Different Draw order
;// Shows the Darw order of text and Sprite
;//
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,480,0,3)

Sprite = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    
    MP_AmbientSetLight (RGB(0,50,128))
    
    MP_DrawText(0,0, "Hello World")
    
    MP_DrawSprite(Sprite, 40, 0)

    
    MP_RenderBegin()
    
      ; Draw your text first
      MP_RenderText() 
    
      ; Draw your sprite last and over text
      MP_RenderSprite() 
      
    MP_RenderEnd()

    MP_Flip () ; Stelle Sie dar

Wend

DataSection
  MyData:
     IncludeBinary #PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp"
  EndOfMyData:
EndDataSection

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 15
; EnableXP
; Executable = C:\Programme\PureBasic\Tools\sprite.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
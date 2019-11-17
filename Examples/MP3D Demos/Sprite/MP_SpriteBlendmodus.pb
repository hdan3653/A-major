;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Sprite3DBlendmodus.pb
;// Erstellt am: 13.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einfache Sprite3D Demo mit Blendmodus
;//
;//
;////////////////////////////////////////////////////////////////

;Konstante vor Sprite3DBlendingMode

#D3DBLEND_ZERO            = 1
#D3DBLEND_ONE             = 2
#D3DBLEND_SRCCOLOR        = 3
#D3DBLEND_INVSRCCOLOR     = 4
#D3DBLEND_SRCALPHA        = 5
#D3DBLEND_INVSRCALPHA     = 6
#D3DBLEND_DESTALPHA       = 7
#D3DBLEND_INVDESTALPHA    = 8
#D3DBLEND_DESTCOLOR       = 9
#D3DBLEND_INVDESTCOLOR    = 10
#D3DBLEND_SRCALPHASAT     = 11
#D3DBLEND_BOTHSRCALPHA    = 12
#D3DBLEND_BOTHINVSRCALPHA = 13

MP_Graphics3D (640,480,0,3)

SetWindowTitle(0, "Blendmodus vor Sprites, Use Key 1 and 2 to change") 

Sprite = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData)
Sprite2 = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData)

MP_TransparentSpriteColor(Sprite,  RGB(255,0,255))
MP_TransparentSpriteColor(Sprite2, RGB($FF,0,$FF))

MP_AmbientSetLight (RGB(0,50,128))

a = #D3DBLEND_SRCALPHA
b = #D3DBLEND_INVSRCALPHA

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
      If MP_KeyHit(#PB_Key_1)
        a + 1
        If a > 13 
          a = 1
        EndIf  
      EndIf
      
      If MP_KeyHit(#PB_Key_2)
        b + 1
        If b > 13 
          b = 1
        EndIf  
      EndIf
      
      MP_SpriteBlendingMode(Sprite, a, b)
      MP_SpriteBlendingMode(Sprite2, a, b)
    
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
       x = 0
    EndIf   
    MP_DrawText(1,1,"Sprite3DBlendingMode, Source = "+Str(a)+ " Destination = "+Str(b))
      
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

DataSection
  MyData:
     IncludeBinary #PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp"
  EndOfMyData:
EndDataSection
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 47
; FirstLine = 25
; EnableXP
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_Sprite3DBlendmode.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
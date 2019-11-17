;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteScroll.pb
;// Erstellt am: 15.11.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einfache SpriteScroll Demo
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3)
SetWindowTitle(0, "Easy Scroll Texture demo") 

  If CreateImage(0, 255, 120)

    StartDrawing(ImageOutput(0))
    
    For k=0 To 255
      FrontColor(RGB(k,0, k))  ; a rainbow, from black to pink
      Line(1, k, 255, 1)
    Next

    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(255,255,255)) ; print the text to white !
    DrawText(40, 50, "An image created easely...")

    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
  EndIf
  
  Texture = MP_ImageToTexture(0)  
  sprite = MP_SpriteFromTexture(Texture) 
  
  Texture2 = MP_CreateTexture(200, 200) 
  sprite2 = MP_SpriteFromTexture(Texture2) 
  
  Texture3 = MP_CreateTexture(80, 40) 
  sprite3 = MP_SpriteFromTexture(Texture3) 

  
  MP_AmbientSetLight (RGB(0,50,128))
  

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
      
      MP_CopyTexture(Texture, Texture2 , 40, 10, 50, 50) 
      
      MP_CopyTexture(Texture, Texture3 ) 
      
      MP_CopyTexture(Texture, Texture2 ,40,40,40,40, 40,40,40,40 ) 

      
      MP_DrawSprite(Sprite, 25, 25)
      
      MP_DrawSprite(Sprite2, 25, 250)
      
      MP_DrawSprite(Sprite3, 250, 250)
      
      MP_ScrollTexture(Texture, 1,0)

      
      
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 16
; EnableXP
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
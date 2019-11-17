;////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_RenderTotexture.pb
;// Erstellt am: 3.11.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Use Sprite and 2D Draw on Texture
;// Benutze Sprite and 2D Draw auf Texture
;//
;////////////////////////////////////////////////////////////////

  MP_Graphics3D (640,480,0,3)  
  SetWindowTitle(0, "Use Sprite and 2D Draw on Texture") 

  If CreateImage(0, 255, 120)

    StartDrawing(ImageOutput(0))
    
    For k=0 To 255
      FrontColor(RGB(k,0, k))  ; a rainbow, from black to pink
      Line(1, k, 255, 1)
    Next

    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(255,255,200)) ; print the text to white !
    DrawText(40, 50, "An image created easely...")

    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
  EndIf
  
  Texture = MP_ImageToTexture(0)  
  sprite = MP_SpriteFromTexture(Texture) 
  
  Texture2 = MP_CreateTexture(200, 200) 
  sprite2 = MP_SpriteFromTexture(Texture2) 
  
  Texture3 = MP_CreateTexture(80, 40) 
  sprite3 = MP_SpriteFromTexture(Texture3) 

  
  Sprite4 = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData); Grafik hat 60 Zeichen mit 16x16
  MP_SpriteSetAnimate(Sprite4,60,0,16,16) 

  Sprite5 = MP_CatchSprite(?EndOfMyData, ?EndOfMyData2 - ?EndOfMyData) ; Grafik hat 120 Zeichen mit 28x24
  MP_SpriteSetAnimate(Sprite5,120,0,28,24) 
  MP_TransparentSpriteColor(Sprite5, RGB(152,152,152)) 
  
  ;- Alle Sprite Befehle UND 2D befehele können jetzt auf die Textur gerendert werden
  
  
  MP_RotateSprite(Sprite, 90)
  
  MP_DrawSprite(Sprite, 0, 0)
  
  MP_DrawBitMapText(Sprite5, 0, 20, "MP3D ist Geil",123,32,-8)
  
  MP_Line (0,0, 254,119, MP_ARGB($FF,$FF,0,0))
  MP_Line (0,120,254,-119, MP_ARGB($FF,$FF,0,0))
  
  MP_RenderToTexture( Texture )
  
  ;- Alle Sprite udn 2D Befehle sind jetzt zurückgesetzt worden  
  
  MP_RotateSprite(Sprite, 0)
  
  ;- Die Eigenschaft der Rotation MP_RotateSprite() muss zurückgestzet werden
 
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
      
      MP_DrawBitMapText(Sprite4, 100, 200, "MP3D MACHT ES MOEGLICH")
      
      MP_CopyTexture(Texture, Texture2 , 40, 10, 50, 50) 
     
      MP_CopyTexture(Texture, Texture3 ) 
     
      MP_CopyTexture(Texture, Texture2 ,40,40,40,40, 40,40,40,40 ) 
           
      MP_DrawSprite(Sprite, 25, 25)
      
      MP_DrawSprite(Sprite2, 25, 250)
      
      MP_DrawSprite(Sprite3, 250, 250)
      
      MP_ScrollTexture(Texture, 1,0)
      
       MP_DrawText (1,1,"FPS = "+Str(MP_FPS()))
      
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

  Wend
  
DataSection
  MyData:
     IncludeBinary "..\BitmapFont\Spherical.bmp"
  EndOfMyData:
     IncludeBinary "..\BitmapFont\Fugger2.bmp"
  EndOfMyData2:
     
EndDataSection


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 73
; FirstLine = 41
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

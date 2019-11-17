;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteCollision2.pb
;// Erstellt am: 13.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple rotated sprite collision test
;// Einfacher gedrehter Sprite Kollisionstest
;//
;//
;////////////////////////////////////////////////////////////////





count = 4000
Dim DropX(count)
Dim DropY(count)

MP_Graphics3D (640,480,0,1)

MP_VSync(0)

Sprite0 = MP_CatchSprite(?pic, ?picend-?pic) 
Sprite1 = MP_CatchSprite(?picend, ?picend2-?picend)
Sprite2 = MP_CatchSprite(?picend2, ?picend3-?picend2)

MP_SpriteSetParent(Sprite2, Sprite0)  

For i=0 To count
  DropX(i)=Random(639)
  DropY(i)=-Random(1000)
Next


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
 
; 
    grad.f + 0.1
    
    MP_RotateSprite(Sprite0, grad)
    MP_DrawSprite(Sprite0,300,100)
    MP_RotateSprite(Sprite2, grad)
    MP_DrawSprite(Sprite2,100,0)
        
    For i=0 To count
      DropY(i)+1
      
      
      If MP_SpritePixelCollision(Sprite0,300,100,Sprite1,DropX(i),DropY(i))
;      If MP_SpriteCollision (Sprite0,300,100,Sprite1,DropX(i),DropY(i))
        
        
        kol +1
        DropX(i)=Random(639)
        DropY(i)=-Random(1000)
      EndIf

      If MP_SpritePixelCollision(Sprite2,100,0,Sprite1,DropX(i),DropY(i))
;      If MP_SpriteCollision (Sprite0,300,100,Sprite1,DropX(i),DropY(i))
        
        
        kol +1
        DropX(i)=Random(639)
        DropY(i)=-Random(1000)
      EndIf
      
      If DropY(i) > 500
        DropX(i)=Random(639)
        DropY(i)=-Random(1000)
      EndIf      
      
      MP_DrawSprite(Sprite1,DropX(i),DropY(i))
   Next
    
   SetWindowTitle(0,"MP Sprite Coll Test "+Str(MP_FPS())+" FPS + "+Str(kol)+" Hits")
   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend

DataSection
  ; pic:
  ;  IncludeBinary "Ground.png";"Bild.png"
  ; pic:
  ;  IncludeBinary "retangle.bmp";"Bild.png"
  ; pic:
  ;  IncludeBinary "retangle2.bmp";"Bild.png"
    pic:
    IncludeBinary "retangle3.bmp";"Bild.png"
  ; pic:
  ;  IncludeBinary "retangle4.bmp";"Bild.png"
  
  picend:
  IncludeBinary "drop.bmp";"Bild.png"
  picend2:
  IncludeBinary "retangle5.bmp"
   picend3:

   
EndDataSection

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 100
; FirstLine = 56
; UseIcon = ..\mp3d.ico
; Executable = C:\test3.exe
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem
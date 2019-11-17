;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteCollision.pb
;// Erstellt am: 13.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple Sprite Collision Test
;// Einfacher Sprite Kollisionstest
;//
;//
;////////////////////////////////////////////////////////////////

count = 5000

Dim DropX(count)
Dim DropY(count)

MP_Graphics3D (640,480,0,1)

MP_VSync(0)


Sprite0 = MP_CatchSprite(?pic, ?picend-?pic) 

Sprite1 = MP_CatchSprite(?picend, ?picend2-?picend) 


For i=0 To count
  DropX(i)=Random(639)
  DropY(i)=-Random(1000)
Next

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_DrawSprite(Sprite0,0,280)
        
    For i=0 To count
      DropY(i)+1
     If MP_SpritePixelCollision(Sprite0,0,280,Sprite1,DropX(i),DropY(i))
  ;    If MP_SpriteCollision (Sprite0,0,280,Sprite1,DropX(i),DropY(i))
        kol +1
        DropX(i)=Random(639)
       DropY(i)=-Random(1000)
      EndIf
      MP_DrawSprite(Sprite1,DropX(i),DropY(i))
   Next
 
     
   SetWindowTitle(0,"MP Sprite Kollisions Test "+Str(MP_FPS())+" FPS + "+Str(kol)+" Treffer")
   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend

DataSection
  pic: 
  IncludeBinary "Ground.png";"Bild.png"
  picend:
  IncludeBinary "drop.bmp";"Bild.png"
  picend2:
   
EndDataSection
; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 46
; FirstLine = 8
; EnableXP
; UseIcon = ..\mp3d.ico
; Executable = \\Hh\transfer\test.exe
; SubSystem = dx9
; DisableDebugger
; EnableCustomSubSystem
; Manual Parameter S=DX9
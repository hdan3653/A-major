;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteParent.pb
;// Erstellt am: 13.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// MP Sprite Parent - Kid relationship
;//
;//
;////////////////////////////////////////////////////////////////


xres = 800
yres = 400

MP_Graphics3D (xres, yres,0,1)
SetWindowTitle(0,"MP Sprite Parent - Kid relationship, movement cursor right / left / down / up and angle Q/A")

Sprite0 = MP_CatchSprite(?pic, ?picend-?pic) 
Sprite1 = MP_CatchSprite(?picend, ?picend2-?picend) 

If CreateImage(0, 256, 256)
  MP_CreateImageColored(0, 0, RGB(255,0,0), RGB(255,0,0), RGB(255,255,0), RGB(255,255,0))     
  Surface = MP_ImageToSurface(0) ; Image = 0, 
  FreeImage(0)
  MP_SurfaceSetPosition(Surface,0,0,1)
  MP_SurfaceDestRect(Surface,0, 0, xres, yres)
EndIf

x.f = 200
y.f = 120
Rot.f = 0

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

   If MP_KeyDown(#PB_Key_Left)=1 : x-1 : EndIf ;links Debug #PB_Key_Left
   If MP_KeyDown(#PB_Key_Right)=1 : x+1 :EndIf ;rechts #PB_Key_Right
   If MP_KeyDown(#PB_Key_Down)=1 : y+1 : EndIf ;Runter #PB_Key_Down
   If MP_KeyDown(#PB_Key_Up)=1 : y-1 : EndIf   ;rauf #PB_Key_Up
   If MP_KeyDown(#PB_Key_Q)=1 : Rot+1 : EndIf  ;Rotation #PB_Key_Q
   If MP_KeyDown(#PB_Key_A)=1 : Rot-1 : EndIf  ;Rotation rauf #PB_Key_A

   MP_DrawSprite(Sprite0,x,y) ; bewegt das Sprite0
   MP_RotateSprite(Sprite0, Rot)  ; rotiert das Sprite1

   MP_SpriteSetParent (Sprite1, Sprite0)
   MP_DrawSprite(Sprite1,-170,11)     ; Position abhängig vom Sprite0
   MP_DrawSprite(Sprite1,94,11)       ; Position abhängig vom Sprite0
   
   Rotation.f - (4*240 * MP_VSyncTime()) ; FPS unabhängige Framerate
   
   MP_RotateSprite(Sprite1, Rotation.f) 
   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend

DataSection
   pic: 
    IncludeBinary "Auto.bmp";"Bild.png"
    picend:
    IncludeBinary "rad2.bmp";"Bild.png"
   picend2:
   
EndDataSection
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 65
; FirstLine = 18
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_Sprite Parent.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
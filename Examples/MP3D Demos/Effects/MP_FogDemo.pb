;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Kollisionstest.pb
;// Created On: 14.1.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Fog Demo
;// 
;////////////////////////////////////////////////////////////////

;- Init

MP_Graphics3D (640,480,0,3)

SetWindowTitle(0, "Fog Demo, Cursor to move") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

mesh = MP_CreateSphere (16)

If CreateImage(0, 255, 255) ; Etwas Farbe selber erzeugen
   MP_CreateImageColored(0,0,RGB($FF,$00,$00),RGB($00,$FF,$00),RGB($00,$00,$FF),RGB($FF,$FF,$00)) ; 
   MP_EntitySetTexture (mesh, MP_ImageToTexture(0))
   FreeImage(0)
EndIf

x.f=2
y.f=0
z.f=8

MP_Fog (RGB(0,0,0),5,10)

MP_PositionEntity (Mesh,0,0,z)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage

    xx.f = x : zz.f = z 

    ; nen bishen apielen und das Objekt drehen
    If MP_KeyDown(#PB_Key_Down)=1 : z=z-0.1 : EndIf ;Runter #PB_Key_Down
    If MP_KeyDown(#PB_Key_Up)=1 : z=z+0.1 : EndIf ;rauf #PB_Key_Up 
 

    MP_PositionEntity (Mesh,0,0,z)
     
    MP_RenderWorld ()
    MP_Flip ()
Wend


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 41
; Executable = C:\MP_Fog.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

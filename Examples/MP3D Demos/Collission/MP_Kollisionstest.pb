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
;// Demofile für Kollissionstest
;// 
;////////////////////////////////////////////////////////////////

;- Init

If MP_Graphics3D (640,480,0,3)

Else

  End

EndIf

SetWindowTitle(0, "Kollisionstest, einfache Demo") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

mesh1 = MP_CreateSphere (10)
mesh2 = MP_CreateSphere (10)


If CreateImage(0, 255, 255) ; Etwas Farbe selber erzeugen
   MP_CreateImageColored(0,0,RGB($FF,$00,$00),RGB($00,$FF,$00),RGB($00,$00,$FF),RGB($FF,$FF,$00)) ; 
   MP_EntitySetTexture (mesh1, MP_ImageToTexture(0))
   MP_CreateImageColored(0,0,RGB($FF,$00,$FF),RGB($FF,$FF,$FF),RGB($00,$FF,$FF),RGB($FF,$00,$FF)) ; 
   MP_EntitySetTexture (mesh2, MP_ImageToTexture(0))
   FreeImage(0)
EndIf

x.f=2
y.f=0
z.f=8

;MP_Fog (MP_ARGB(0,0,0,0),5,10)

MP_PositionEntity (Mesh1,2,0,z)
MP_PositionEntity (Mesh2,-2,0,z)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage

    xx.f = x : yy.f = y : zz.f = z 

    ; nen bishen apielen und das Objekt drehen
    If MP_KeyDown(#PB_Key_Left)=1 : x=x-0.1 : EndIf ;links Debug #PB_Key_Left
    If MP_KeyDown(#PB_Key_Right)=1 : x=x+0.1 :EndIf ;rechts #PB_Key_Right
    If MP_KeyDown(#PB_Key_Down)=1 : z=z-0.1 : EndIf ;Runter #PB_Key_Down
    If MP_KeyDown(#PB_Key_Up)=1 : z=z+0.1 : EndIf ;rauf #PB_Key_Up
    If MP_KeyDown(#PB_Key_Z)=1  : y=y-0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur
    If MP_KeyDown(#PB_Key_A)=1  : y=y+0.1 : EndIf ;a #PB_Key_A 
 
 

    MP_PositionEntity (Mesh1,x,y,z)
    If MP_3DCollisionSphere2Sphere(Mesh1,Mesh2)
       x = xx : y = yy : z = zz 
       MP_PositionEntity (Mesh1,x,y,z)
       MP_DrawText (10,10,"Kollission") ; Textanzeige an Position x,y, Farbe RGB und Text$
    EndIf
     
    MP_RenderWorld ()
    MP_Flip ()
Wend


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 52
; FirstLine = 23
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

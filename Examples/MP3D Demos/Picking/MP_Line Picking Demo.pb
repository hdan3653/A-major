;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Line Picking Demo.pb
;// Created On: 14.1.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Line Pick command 
;// Demofile f�r Line Pick Befehl
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Line Picking Demo") 

Camera=MP_CreateCamera() ; Kamera erstellen
MP_PositionEntity(camera, 10, 7, -30)
MP_CreateLight(1) ; Es werde Licht


Cylinder =   MP_CreateCone (8,12) 
MP_RotateEntity (Cylinder,0 ,270 ,0) 
MP_EntitySetColor (Cylinder, $FF0000) 

cube1 = MP_CreateCube()
MP_EntitySetName(cube1, "Cube1")

cube2 = MP_CreateCube()
MP_EntitySetName(cube2, "Cube2")

cube3 = MP_CreateCube()
MP_EntitySetName(cube3, "Cube3")

cube4 = MP_CreateCube()
MP_EntitySetName(cube4, "Cube4")


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
   
   count.f + 0.01
   MP_PositionEntity(cube1, 10, 0, Cos(count) * 10)
   MP_PositionEntity(cube2, 15, 0, Sin(count) * 10)
   MP_PositionEntity(cube3, 20, 0, Cos(count+0.785) * 10) ; 0.785 = 1/4 Pi
   MP_PositionEntity(cube4, 25, 0, Sin(count+0.785) * 10) 

   picked = MP_PickLine (1, 0, 0, 90, 0) ; Rechts neben dem Objekt beginnen und dann 90 Grad nach Rechts zeigen 
   
   If picked
      txt$ = MP_EntityGetName(picked)
      txt2$ = txt$ + " gefunden, X = "+Str(MP_EntityGetX(picked))+ " Y = "+Str(MP_EntityGetY(picked))+" Z = "+Str(MP_EntityGetZ(picked))+ " Picked Entfernung = "+StrF(MP_PickedGetDistance (),2)
   Else
      txt$=""
   EndIf
   
   MP_DrawText (1,1,txt$) ; mesh gefunden

   MP_DrawText (1,20,txt2$) ; 


   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 21
; FirstLine = 14
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; 湡慵⁬慐慲敭整⁲㵓塄9
; 湅扡敬畃瑳浯畓卢獹整m慍畮污倠牡浡瑥牥匠䐽㥘
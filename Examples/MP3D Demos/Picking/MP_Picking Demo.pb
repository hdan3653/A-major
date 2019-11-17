;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_PickingDemo.pb
;// Created On: 14.1.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für PickBefehl
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
 
SetWindowTitle(0, "Picking Demo, left mouse show mesh, right one delete the mesh") 

cam=MP_CreateCamera() ; Kamera erstellen
MP_CreateLight(1) ; Es werde Licht

Max = 40 ; Was der Rechner kann = ?

Dim Meshs(Max) 
Dim x(Max)
Dim y(Max)
Dim z(Max)

For n = 0 To Max

    Meshs (n) = MP_CreateSphere(10)
    MP_PositionEntity (Meshs(n),10-Random(20),10-Random(20),24+Random(40))
   
    
Next n




While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen


   If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
   
      If GetFocus_()=WindowID(0) ; Fenster aktiv? 
         
         Meshfound = MP_PickCamera (cam,WindowMouseX(0),WindowMouseY(0))

         If Meshfound   
               MP_DrawText (100,40,"Mesh "+Str(Meshfound)+" found")

         EndIf
  
     EndIf
    EndIf

   If MP_MouseButtonDown(1) ; Rechte Maustaste gedrückt?
   
      If GetFocus_()=WindowID(0) ; Fenster aktiv? 
         
         Meshfound = MP_PickCamera (cam,WindowMouseX(0),WindowMouseY(0))

         If Meshfound   
               MP_FreeEntity (Meshfound)
         EndIf
  
     EndIf
    EndIf


   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 33
; EnableAsm
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
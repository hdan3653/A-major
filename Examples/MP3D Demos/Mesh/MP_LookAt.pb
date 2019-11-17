;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_LookAt.pb
;// Created On: 31.7.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für ein LookAt Funktion
;// 
;////////////////////////////////////////////////////////////////

;- ProgrammStart


MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "LookAt Demo, Push Space and the camera is following") 

Camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Max = 30 ; Was der Rechner kann = ?
Dim Cone(Max) 

For n = 0 To Max

    Cone(n)=MP_CreateCone (8,2)
    MP_EntitySetColor (Cone(n),RGB(Random(255),Random(255),Random(255)))
    MP_PositionEntity (Cone(n),10-Random(20),10-Random(20),10+Random(20))
    
Next n

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_AmbientSetLight (RGB(123,222,204)) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    count.f + 0.01
    MP_PositionEntity(Mesh,  Sin(count) * 5, Cos(count) * 5, 20)

    For n = 0 To Max
       MP_EntityLookAt(Cone(n),MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))
    Next n

    If MP_KeyDown(#PB_Key_Space)=1
      
      MP_EntityLookAt(Camera,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))
      
    EndIf


    MP_TurnEntity (Mesh,1,1,1) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 51
; FirstLine = 1
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\temp\demos\MP_LookAt.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
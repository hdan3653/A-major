;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Primitives.pb
;// Erstellt am: 07.03.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Creates three lines of a primitive
;// Erstellt drei Linien eins Primitives
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Show Primitives") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

Entity = MP_CreatePrimitives (6, 2) ; 6 Vertexe und LINELIST (einzelne Linien)

MP_EntitySetZ (Entity, 8)
    
MP_SetPrimitives(Entity, 0,  0, 2, 0,  $FFFFFFFF)
MP_SetPrimitives(Entity, 1,  0, -2, 0, $FF0000FF)
MP_SetPrimitives(Entity, 2,  -2, 0, 0, $FF00FF00)
MP_SetPrimitives(Entity, 3, 2, 0, 0,   $FF00FFFF)    
MP_SetPrimitives(Entity, 4, 0, 0, 2,   $FFFF0000) 
MP_SetPrimitives(Entity, 5, 0, 0, -2,  $FFFF00FF)    

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Entity,0.1,0.1,0.1) ; dreh den W�rfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 33
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\Primitives.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

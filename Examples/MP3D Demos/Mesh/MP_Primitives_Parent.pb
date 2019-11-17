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

Entity2 = MP_CreatePrimitives (6, 2) ; 6 Vertexe und LINELIST (einzelne Linien)

MP_EntitySetZ (Entity2, 2)
    
MP_SetPrimitives(Entity2, 0,  0, 1, 0,  $FFFFFFFF)
MP_SetPrimitives(Entity2, 1,  0, -1, 0, $FF0000FF)
MP_SetPrimitives(Entity2, 2,  -1, 0, 0, $FF00FF00)
MP_SetPrimitives(Entity2, 3, 1, 0, 0,   $FF00FFFF)    
MP_SetPrimitives(Entity2, 4, 0, 0, 1,   $FFFF0000) 
MP_SetPrimitives(Entity2, 5, 0, 0, -1,  $FFFF00FF)    

MP_EntitySetParent (Entity2, Entity)

Entity3 = MP_CreatePrimitives (6, 2) ; 6 Vertexe und LINELIST (einzelne Linien)

MP_EntitySetZ (Entity3, -2)
    
MP_SetPrimitives(Entity3, 0,  0, 1, 0,  $FFFFFFFF)
MP_SetPrimitives(Entity3, 1,  0, -1, 0, $FF0000FF)
MP_SetPrimitives(Entity3, 2,  -1, 0, 0, $FF00FF00)
MP_SetPrimitives(Entity3, 3, 1, 0, 0,   $FF00FFFF)    
MP_SetPrimitives(Entity3, 4, 0, 0, 1,   $FFFF0000) 
MP_SetPrimitives(Entity3, 5, 0, 0, -1,  $FFFF00FF)    

MP_EntitySetParent (Entity3, Entity)
;MP_PrimitivesSetParent (Entity3, Entity)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Entity,0.1,0.1,0.1) ; dreh den Würfel
    MP_TurnEntity (Entity2,0.5,0.5,0.5) ; dreh den Würfel
    MP_TurnEntity (Entity3,-0.5,-0.5,-0.5) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.10 (Windows - x86)
; CursorPosition = 15
; FirstLine = 15
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\Primitives.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
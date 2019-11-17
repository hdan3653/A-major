;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ResizeMesh.pb
;// Erstellt am: 20.2.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Resize of Teapot
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart
MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0

camera=MP_CreateCamera() ; Create Camera

light=MP_CreateLight(1) ; Now light on

Mesh=MP_Createteapot() ; New mesh teapot
 
MP_PositionEntity (Mesh,0,0,3) ; Position of teapot

SetWindowTitle(0, "3D real-time resize of a teapot with "+Str(MP_CountVertices(Mesh))+" vertices and "+Str(MP_CountTriangles(Mesh))+" triangles") ; Setzt einen Fensternamen

MP_CountVertices(Mesh)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  x.f + 0.1
  
    MP_ResizeMesh(mesh,Sin(x)+1,Cos(x)+1,Sin(x)*Cos(x)+1)
  
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 34
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

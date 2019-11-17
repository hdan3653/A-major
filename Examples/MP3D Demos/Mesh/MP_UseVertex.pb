;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_UseVertex.pb
;// Erstellt am: 3.9.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Vertex und Triangle Demo
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Vertex und Triangle Demo") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(2) ; Es werde Licht

Mesh = MP_CreateMesh() ; Erzeuge leeres Mesh

; Erstelle 2 x drei Eckpunkte mit UV Koordinaten
MP_AddVertex (Mesh, 1, 1,0,0,1,0) 
MP_AddVertex (Mesh, 1,-1,0,0,1,1) 
MP_AddVertex (Mesh,-1, 1,0,0,0,0) 

MP_AddVertex (Mesh, 0.9,-1.1,0,0,1,1) 
MP_AddVertex (Mesh,-1.1, 0.9,0,0,0,0) 
MP_AddVertex (Mesh,-1.1,-1.1,0,0,0,1) 

; Erstelle zwei Dreicke = 1 x Viereck
MP_AddTriangle (Mesh, 0,1,2)
MP_AddTriangle (Mesh, 4,3,5)

MP_EntitySetNormals(Mesh) 


Texture = MP_LoadTexture("five.bmp")
MP_EntitySetTexture (Mesh, Texture )

MP_PositionEntity (Mesh,0,0,5) ; Position des Meshs

;MP_AmbientSetLight(RGB(20,20,134))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.1,0.1) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 48
; EnableXP
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

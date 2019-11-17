;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_VertexTriangle.pb
;// Erstellt am: 24.1.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Textru on Triangle
;// Kopiert eine Textur im Teilbereich
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Vertex und Triangle Demo") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(2) ; Es werde Licht


; Mesh 1 mit StandardVertexen
Mesh1 = MP_CreateMesh() ; Erzeuge leeres Mesh
; Erstelle 2 x drei Eckpunkte mit UV Koordinaten Textur wird einfach gemacht
MP_AddVertex (Mesh1, 1, 1,0,0,1,0) 
MP_AddVertex (Mesh1, 1,-1,0,0,1,1) 
MP_AddVertex (Mesh1,-1, 1,0,0,0,0) 
MP_AddVertex (Mesh1, 1,-1,0,0,1,1) 
MP_AddVertex (Mesh1,-1, 1,0,0,0,0) 
MP_AddVertex (Mesh1,-1,-1,0,0,0,1) 

; Erstelle zwei Dreicke = 1 x Viereck
MP_AddTriangle (Mesh1, 0,1,2)
MP_AddTriangle (Mesh1, 4,3,5)

; Mesh 2 mit StandardVertexen
Mesh2 = MP_CreateMesh() ; Erzeuge leeres Mesh
; Erstelle 2 x drei Eckpunkte mit UV Koordinaten um Textur zu verdoppeln
MP_AddVertex (Mesh2, 1, 1,0,0,2,0) 
MP_AddVertex (Mesh2, 1,-1,0,0,2,2) 
MP_AddVertex (Mesh2,-1, 1,0,0,0,0) 

MP_AddVertex (Mesh2, 1,-1,0,0,2,2) 
MP_AddVertex (Mesh2,-1, 1,0,0,0,0) 
MP_AddVertex (Mesh2,-1,-1,0,0,0,2) 

; Erstelle zwei Dreicke = 1 x Viereck
MP_AddTriangle (Mesh2, 0,1,2)
MP_AddTriangle (Mesh2, 4,3,5)

; Mesh 3 mit StandardVertexen
Mesh3 = MP_CreateMesh() ; Erzeuge leeres Mesh
; Erstelle 2 x drei Eckpunkte mit UV Koordinaten
MP_AddVertex (Mesh3, 0.5, 1,0,0,1,0) 
MP_AddVertex (Mesh3, 1,-1,0,0,1,1) 
MP_AddVertex (Mesh3,-0.8, 0.6,0,0,0,0) 

MP_AddVertex (Mesh3, 1,-1,0,0,1,1) 
MP_AddVertex (Mesh3,-0.8, 0.6,0,0,0,0) 
MP_AddVertex (Mesh3,-1.4,-1,0,0,0,1) 

; Erstelle zwei Dreicke = 1 x Viereck
MP_AddTriangle (Mesh3, 0,1,2)
MP_AddTriangle (Mesh3, 4,3,5)


Texture = MP_CatchTexture(?MyData, ?EndOfMyData - ?MyData)
MP_EntitySetTexture (Mesh1, Texture )
MP_EntitySetTexture (Mesh2, Texture )
MP_EntitySetTexture (Mesh3, Texture )

MP_PositionEntity (Mesh1,-4,0,10) ; Position des Meshs
MP_PositionEntity (Mesh2,0,0,10) ; Position des Meshs
MP_PositionEntity (Mesh3,4,0,10) ; Position des Meshs

MP_AmbientSetLight(RGB(20,20,134))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

DataSection
  MyData:
     IncludeBinary "five.bmp"
  EndOfMyData:
     
EndDataSection
  
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 78
; FirstLine = 37
; EnableXP
; Executable = C:\uv test.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

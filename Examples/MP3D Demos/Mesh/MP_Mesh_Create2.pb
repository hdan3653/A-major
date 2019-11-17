;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Mesh_Create2.pb
;// Erstellt am: 30.3.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Mesh Create Demo
;// Demo from @Schmock
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0

camera=MP_CreateCamera() ; Kamera erstellen
light= MP_CreateLight(1) ; Es werde Licht


; Mesh Vorne und Hinten
Mesh  = MP_CreateCylinder(32, 0.1) : MP_scalemesh(Mesh, 0.3 , 0.3, 0.3)  : MP_TranslateMesh(Mesh,  0, 0,  0.30 )
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_scalemesh(Mesh2, 0.3 , 0.3, 0.3) : MP_TranslateMesh(Mesh2, 0, 0, -0.30 ) : MP_AddMesh(Mesh2 , Mesh ) : MP_freeEntity(Mesh2)


; Rechts und Links
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_scalemesh(Mesh2, 0.3 , 0.3, 0.3) : MP_TranslateMesh(Mesh2, 0 , 0, 0.30 )  : 
MP_RotateMesh(Mesh2 , 0 , 90, 0)  : MP_AddMesh(Mesh2 , Mesh ) 
MP_freeEntity(Mesh2)

Mesh2 = MP_CreateCylinder(32, 0.1) : MP_scalemesh(Mesh2, 0.3 , 0.3, 0.3) : MP_TranslateMesh(Mesh2, 0, 0, -0.30 )  : 
MP_RotateMesh(Mesh2 , 0 , 90, 0)  : MP_AddMesh(Mesh2 , Mesh ) 
MP_freeEntity(Mesh2)

; Oben und Unten
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_scalemesh(Mesh2, 0.3 , 0.3, 0.3) : MP_TranslateMesh(Mesh2, 0, 0, -0.30 )  : 
MP_RotateMesh(Mesh2 , 90 , 0, 0)  :  MP_AddMesh(Mesh2 , Mesh )
MP_freeEntity(Mesh2)


Mesh2 = MP_CreateCylinder(32, 0.1) : MP_scalemesh(Mesh2, 0.3 , 0.3, 0.3) : MP_TranslateMesh(Mesh2, 0,  0, -0.30 )  : 
MP_RotateMesh(Mesh2 , -90 , 0, 0)  :  MP_AddMesh(Mesh2 , Mesh )
MP_freeEntity(Mesh2)


MP_PositionEntity (Mesh,0,0,3) ; Position the combined mesh in space

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,1.1,0.7,0.5) ; dreh den Würfel  
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
    
Wend
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 40
; EnableXP
; SubSystem = dx9
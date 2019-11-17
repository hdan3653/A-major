MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
camera=MP_CreateCamera()    ; Kamera erstellen
light= MP_CreateLight(1)    ; Es werde Licht

; Letz combine some mesh
; Mesh Vorne und Hinten
Mesh  = MP_CreateCylinder(32, 0.1) : MP_ScaleMesh(Mesh , 0.25 , 0.25, 0.3) : MP_TranslateMesh(Mesh,  0, 0,  0.25 )
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_ScaleMesh(Mesh2, 0.25 , 0.25, 0.3) : MP_TranslateMesh(Mesh2, 0, 0, -0.25 )
MP_AddMesh(Mesh2 , Mesh ) : MP_FreeEntity(Mesh2)

; Rechts und Links
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_ScaleMesh(Mesh2, 0.25 , 0.25, 0.3) : MP_RotateMesh(Mesh2 , 0 , 90, 0)
MP_TranslateMesh(Mesh2, 0.25 , 0, 0 ) : MP_AddMesh(Mesh2 , Mesh ): MP_FreeEntity(Mesh2)
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_ScaleMesh(Mesh2, 0.25 , 0.25, 0.3) : MP_RotateMesh(Mesh2 , 0 , 90, 0)
MP_TranslateMesh(Mesh2, -0.25, 0, 0 )  :MP_AddMesh(Mesh2 , Mesh ): MP_FreeEntity(Mesh2)

; Oben und Unten
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_ScaleMesh(Mesh2, 0.25 , 0.25, 0.3) : MP_RotateMesh(Mesh2 , 90 , 0, 0)
MP_TranslateMesh(Mesh2, 0, -0.25, 0 )  :MP_AddMesh(Mesh2 , Mesh ): MP_FreeEntity(Mesh2)
Mesh2 = MP_CreateCylinder(32, 0.1) : MP_ScaleMesh(Mesh2, 0.25 , 0.25, 0.3) : MP_RotateMesh(Mesh2 , -90 , 0, 0)
MP_TranslateMesh(Mesh2, 0,  0.25, 0 )  : MP_AddMesh(Mesh2 , Mesh ): MP_FreeEntity(Mesh2)

;Add some Spikes
Spike = MP_CreateCone(32,0.2) : MP_ScaleMesh(Spike , 0.05 , 0.05, 2.0) : MP_TranslateMesh(Spike,  0, 0,  -0.45 )
MP_AddMesh(Spike , Mesh ) : MP_FreeEntity(Spike)
Spike = MP_CreateCone(32,0.2) : MP_ScaleMesh(Spike , 0.05 , 0.05, 2.0) : MP_RotateMesh(Spike , 0 , 180, 0)
MP_TranslateMesh(Spike,  0, 0,   0.45 ) : MP_AddMesh(Spike , Mesh ) : MP_FreeEntity(Spike)

Spike = MP_CreateCone(32,0.2) : MP_ScaleMesh(Spike , 0.05 , 0.05, 2.0) : MP_RotateMesh(Spike , 90 , 0, 0)
MP_TranslateMesh(Spike,  0, 0.45,   0 ) : MP_AddMesh(Spike , Mesh ) : MP_FreeEntity(Spike)
Spike = MP_CreateCone(32,0.2) : MP_ScaleMesh(Spike , 0.05 , 0.05, 2.0) : MP_RotateMesh(Spike , -90 , 0, 0)
MP_TranslateMesh(Spike,  0, -0.45,   0 ) : MP_AddMesh(Spike , Mesh ) : MP_FreeEntity(Spike)

Spike = MP_CreateCone(32,0.2) : MP_ScaleMesh(Spike , 0.05 , 0.05, 2.0) : MP_RotateMesh(Spike , 0 , -90, 0)
MP_TranslateMesh(Spike,  0.45, 0,   0 ) : MP_AddMesh(Spike , Mesh ) : MP_FreeEntity(Spike)
Spike = MP_CreateCone(32,0.2) : MP_ScaleMesh(Spike , 0.05 , 0.05, 2.0) : MP_RotateMesh(Spike ,  0 , 90, 0)
MP_TranslateMesh(Spike,  -0.45, 0,   0 ) : MP_AddMesh(Spike , Mesh ) : MP_FreeEntity(Spike)

MP_PositionEntity (Mesh,0,0,2)
MP_EntitySetNormals (Mesh)
MP_MaterialDiffuseColor (Mesh,255,255,128,50)
MP_MaterialSpecularColor (Mesh, 255, 255 ,255, 155,5)


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_TurnEntity (Mesh,1.1,0.7,0.5) ; rotate our fresh created object  
  
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
    
Wend
; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 37
; EnableAsm
; EnableXP
; EnableUser
; SubSystem = dx9
MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
 SetWindowTitle(0, "press left right to rotate")

 camera = MP_CreateCamera()    ; Kamera erstellen

 MP_PositionEntity(camera, 0, 4, -5 )
 MP_EntityLookAt(camera,0,0,0)

 light= MP_CreateLight(0)    ; Es werde Licht
 
 texture = MP_CreateTextureColor(256, 256, RGBA(0, 0, 255, 255))
 plane = MP_CreatePlane(10, 10)
 MP_EntitySetTexture(plane, texture)
 MP_PositionEntity (plane,0,-3,0)
 MP_RotateEntity(plane, 90, 0, 0)
 
 block1 = MP_CreateCube() ; just heavy blocks on the ground
 block2 = MP_CreateCube()
 MP_PositionEntity (block1,3.3,0,0)
 MP_PositionEntity (block2,-3.3,0,0)
 
 Global body = MP_CreateRectangle(0.5,2,0.5)
 MP_RotateEntity(body, 0, 0, 90 )
 
 Global Mesh = MP_CreateCylinder(10,1)
 MP_ResizeMesh(Mesh,0.25,0.25,4)
 MP_RotateEntity(Mesh, 0, 90, 0 )

 block3 = MP_CreateCube()  ; b;ocks attached to the cylinder
 block4 = MP_CreateCube()
 MP_ResizeMesh(block3,0.6,0.6,1)
 MP_TranslateMesh (block3,0,0,2)
 MP_AddMesh(block3 , Mesh ) : MP_FreeEntity(block3)
 MP_ResizeMesh(block4,0.6,0.6,1)
 MP_TranslateMesh (block4,0,0,-2)
 MP_AddMesh(block4 , Mesh ) : MP_FreeEntity(block4)
 
 MP_EntitySetNormals (Mesh)
 MP_MaterialDiffuseColor (Mesh,255,255,128,50)
 MP_MaterialSpecularColor (Mesh, 255, 255 ,255, 155,5)
 sliderX.f=0:sliderY.f=0:sliderZ.f=0
 hingX.f=0:hingY.f=0:hingZ.f=1
 
 MP_PositionEntity (Mesh,sliderX,sliderY,sliderZ)
 MP_PositionEntity (body,sliderX,sliderY,sliderZ)
 
 MP_PhysicInit()


 MP_EntityPhysicBody(Mesh , 4, 10)
 MP_EntityPhysicBody(body , 4, 10)
 NewMaterial = MP_CreatePhysicMaterial()
 ;MP_SetPhysicMaterialProperties(MaterialID1, Elasticity.f, staticFriction.f, kineticFriction.f [, MaterialID2])
 MP_SetPhysicMaterialProperties(NewMaterial,0,2,2)
 MP_SetPhysicMaterialtoMesh (body, NewMaterial)
 MP_SetPhysicMaterialtoMesh (Mesh, NewMaterial)
 
 MP_ConstraintCreateHinge (body,0,0,1,hingX,hingY,hingZ)
 ;MP_EntitySetGravity(Mesh, 0 , -1 ,0)
 MP_EntityPhysicBody(plane , 1, 1)
 MP_SetPhysicMaterialtoMesh (plane, NewMaterial)
 MP_EntityPhysicBody(Block1 , 2, 100)
 MP_EntityPhysicBody(Block2 , 2, 100)

 MP_ConstraintCreateSlider (Mesh,1,0,0 ,sliderX,sliderY,sliderZ, body) ; create a slider joint functions
 
 MP_AmbientSetLight (RGB(0,100,200))

 While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
   
   If MP_Keydown(#PB_Key_Right)
     MP_MoveEntity(Mesh, 0, 0, 0.1)

     ;MP_EntityAddImpulse(body, 0, -2, 0 , 1.0,0, 0)
     
   ElseIf MP_Keydown(#PB_Key_Left)
     MP_MoveEntity(Mesh, 0, 0, -0.1)
     ;MP_EntityAddImpulse(body, 0, -2, 0 , -1.0,0, 0)
   EndIf
   ;omega.f=0.01
     ;MP_EntitySetOmega(body, 0 , 0 ,-1)
     MP_PhysicUpdate()
     
     MP_RenderWorld() ; Erstelle die Welt
     MP_Flip () ; Stelle Sie dar
     
 Wend
   
 MP_PhysicEnd()
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 35
; FirstLine = 3
; EnableXP
; SubSystem = dx9
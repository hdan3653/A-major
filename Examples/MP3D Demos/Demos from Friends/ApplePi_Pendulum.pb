ExamineDesktops()
Global bitplanes.b=DesktopDepth(0),RX.w=DesktopWidth(0),RY.w=DesktopHeight(0),s_bg.i
MP_Graphics3D(RX,RY,0,1);MP_VSync(0)
SetWindowTitle(0, "MP3D Physik Pendulum & Escapement demo, press Space , Z for more testing ")

camera = MP_CreateCamera()    ; Kamera erstellen

MP_PositionEntity(camera, 0, 0, -5 )
MP_EntityLookAt(camera,0,0,0)

light= MP_CreateLight(0)    ; Es werde Licht

MP_AmbientSetLight (RGB(0,100,200))

;construction of a gear with 18 teeth
ang=40 ; the angle wanted for every tooth of the gear
Mesh = MP_CreateCylinder(10,0.2)
For i=1 To 18
angle.f+20
x.f = Cos(Radian(angle)) * 1: z.f = Sin(Radian(angle)) * 1
Mesh2 = MP_CreateRectangle (0.5,0.05,0.2)
;MP_PositionEntity (Mesh2,x,z,0)
;ang+20
;MP_RotateEntity(Mesh2 , 0 , 0, ang)
;MP_ChangeMeshCoord(Mesh2)

ang+20
MP_RotateMesh(Mesh2 , 0 , 0, ang)
MP_TranslateMesh(Mesh2,x,z,0)


MP_AddMesh(Mesh2 , Mesh ) : MP_FreeEntity(Mesh2)
Next

MP_EntitySetNormals (Mesh)
MP_MaterialDiffuseColor (Mesh,255,255,255,50)
MP_MaterialSpecularColor (Mesh, 255, 255 ,255, 155,5)
;MP_MeshSetAlpha(Mesh, 1)

escape = MP_CreateRectangle (1.5,0.05,0.2) ;the rod above the gear teeth
MP_PositionEntity (escape, 0, 0, 0)
escape2 = MP_CreateRectangle (0.5,0.05,0.2) ; the right small piece attached to the rod
;MP_PositionEntity (escape2, 0.7, -0.1, 0)
;MP_RotateEntity(escape2 , 0 , 0, 90)
;MP_ChangeMeshCoord(escape2)
MP_RotateMesh(escape2 , 0 , 0, 90)
MP_TranslateMesh(escape2, 0.7, -0.1, 0)

MP_AddMesh(escape2 , escape ) : MP_FreeEntity(escape2)

escape2 = MP_CreateRectangle (0.5,0.05,0.2) ; the left small piece attached to the rod
;MP_PositionEntity (escape2, -0.7, -0.1, 0)
;MP_RotateEntity(escape2 , 0 , 0, -100)
;MP_ChangeMeshCoord(escape2)
MP_RotateMesh(escape2 , 0 , 0, -100)
MP_TranslateMesh(escape2, -0.7, -0.1, 0)

MP_AddMesh(escape2 , escape ) : MP_FreeEntity(escape2)

; pendulum
Mesh7 = MP_CreateRectangle (0.05,2.5,0.05)
;MP_PositionEntity (Mesh7, 0, -1.3, -0.3)
;MP_ChangeMeshCoord(Mesh7)
MP_TranslateMesh(Mesh7, 0, -1.3, -0.3)

MP_AddMesh(Mesh7 , escape ) :MP_FreeEntity(Mesh7)

sphere = MP_CreateSphere(10)
MP_ResizeMesh(sphere,0.5,0.5,0.3)
;MP_PositionEntity (sphere, 0, -2.3,  -0.5)
;MP_ChangeMeshCoord(sphere)
MP_TranslateMesh(sphere, 0, -2.3,  -0.5)



; repositioning of the rod and its 2 attached pieces above the gear teeth
MP_PositionEntity (escape, 0, 1.35, 0) ; repositioning of the rod and its 2 attached pieces above the gear teeth

MP_EntitySetNormals (escape)
MP_MaterialDiffuseColor (escape,255,33,255,50)
MP_MaterialSpecularColor (escape, 255, 255 ,255, 155,5)

MP_PhysicInit()
;MP_EntityPhysicBody(sphere , 5, 1)
MP_AddMesh(sphere , escape ) :MP_FreeEntity(sphere)

MP_EntityPhysicBody(escape , 5, 2)
;MP_ConstraintCreateHinge(Entity, PinX.f, PinY.f, PinZ.f [, Pivotx.f, Pivoty.f, Pivotz.f [, MasterEntity]]); create a Hinge joint functions
MP_ConstraintCreateHinge (escape,0,0,1)

MP_EntityPhysicBody(Mesh , 5, 10)
MP_ConstraintCreateHinge (Mesh,0,0,1)
;MP_EntitySetWind(Mesh, 1.0 , 1.0 ,0)


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
       
    MP_EntityAddImpulse(Mesh, 0, -0.5, 0 , -1.7,0, 0)
   
   If MP_KeyHit(#PB_Key_Space)
          MP_EntityAddImpulse(escape, -1, 0, 0 , 1,0, 0)
          MP_EntityAddImpulse(Mesh, 0, -0.1, 0 , -1.7,0, 0)
        ElseIf MP_KeyHit(#PB_Key_Z)
          MP_PositionEntity (escape, 0, 2.5, 0)
         
   EndIf
   
    MP_PhysicUpdate()
   
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
   
Wend
 
MP_PhysicEnd()
; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 11
; EnableXP
; SubSystem = dx9
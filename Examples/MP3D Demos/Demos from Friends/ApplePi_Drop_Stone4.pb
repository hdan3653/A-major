Declare dropStone()

Declare Gear()
Global Flow.b = 0
Global accel.f = -5
 ExamineDesktops()
Global bitplanes.b=DesktopDepth(0),RX.w=DesktopWidth(0),RY.w=DesktopHeight(0)
MP_Graphics3D(RX,RY,0,1):MP_VSync(0)
 SetWindowTitle(0, "Push Space to toggle water flow ....Up/ Down to change gravity")
 Global stone
 camera = MP_CreateCamera()    ; Kamera erstellen

 ;MP_PositionCamera(camera, 0, 4, -10 )
 MP_PositionEntity(camera, -5, 4, -10 )
 ;MP_PositionCamera(camera, -8, 0, -1 )
 MP_EntityLookAt(camera,0,0,0)

 light= MP_CreateLight(1)    ; Es werde Licht
 
 texture = MP_CreateTextureColor(256, 256, RGBA(50, 255, 100, 255))
 texture2 = MP_LoadTexture(#PB_Compiler_Home + "Examples/3D/Data/Textures\Wood.jpg",0)
 Global texture3 = MP_LoadTexture(#PB_Compiler_Home + "Examples/3D/Data/Textures\grass.jpg",0)
 
 Global plane = MP_CreateRectangle(20,20,1)
 MP_EntitySetTexture(plane, texture)
 MP_PositionEntity (plane,0,-3,0)
 MP_RotateEntity(plane, 90, 0, 0)
   
 torus = MP_CreateTorus(0.1, 1, 20) ; just a fake pot
 MP_ResizeMesh(torus,6,6,1)
 MP_RotateEntity(torus, 90, 0, 0 )
 MP_PositionEntity (torus,-1,-2, 0)
 MP_EntitySetTexture(torus, texture2)
 
 Global spring = MP_CreateRectangle(2,1,1)
     
 MP_EntitySetNormals(torus)
 MP_MaterialDiffuseColor(torus,255,255,128,50)
 MP_MaterialSpecularColor(torus,255,255,255,155,5)
 MP_EntitySetTexture(spring, texture2)
 
 MP_PositionEntity (spring, -4.6, 2, 0)
 MP_RotateEntity (spring, 0, 0, 45)
 MP_PhysicInit()
 
 MP_EntityPhysicBody(spring , 1, 100)
 MP_EntityPhysicBody(torus , 1, 1)
 MP_EntityPhysicBody(plane , 1, 1)
 
 MP_AmbientSetLight (RGB(100,100,230))
 
 Gear() ; call the Gear construction

 While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
   If MP_KeyHit(#PB_Key_Space)
        Flow ! 1
   ElseIf Flow = 1
       dropStone()
   EndIf
     
   If MP_KeyHit(#PB_Key_Up)   
     accel + 1
   ElseIf MP_KeyHit(#PB_Key_Down)
     accel - 1
     EndIf
           
     MP_PhysicUpdate()
     
     MP_RenderWorld() ; Erstelle die Welt
     MP_Flip () ; Stelle Sie dar
     
 Wend
   
 MP_PhysicEnd()
   
    Procedure dropStone()
   stone=MP_CreateSphere(16)
   MP_ResizeMesh(stone,0.05,0.05,0.05)
   
   MP_PositionEntity(stone,-4.0, 2.8, 0)
   MP_RotateEntity (stone, 0, 0, 45)
   MP_EntityPhysicBody(stone,2,0.2)
   MP_EntitySetGravity(stone, 0 , accel ,0)
 
  ; Kill all meshs with y < -10   
     For n = 0 To MP_ListGetSize(1)-1
       TempMesh = MP_ListGetElement(1, n)
       If MP_EntityGetY(TempMesh) < -10
         
           MP_FreeEntity(TempMesh)
       EndIf
     Next 
 
   EndProcedure
   
   
Procedure Gear()
  ; we want to make 8 teeth gear from 2 overlapped rectangles rotated by 135
  Mesh = MP_CreateRectangle (2,2,2)
  Mesh2 = MP_CreateRectangle (2,2,2)
  MP_RotateMesh(Mesh2, 0, 0, 135 )
  MP_AddMesh(Mesh2 , Mesh ) : MP_FreeEntity(Mesh2)
 
  Mesh7 = MP_CreateCylinder (16,5) ; axes for the gear
  MP_ResizeMesh(Mesh7, 0.3, 0.3, 4)
  MP_RotateMesh(Mesh7 , 0 , 180, 90)
  MP_AddMesh(Mesh7 , Mesh )
  MP_FreeEntity(Mesh7)
 
  MP_PositionEntity (Mesh,-0.4,0,0)
  MP_EntityPhysicBody(Mesh , 5, 150)
  MP_ConstraintCreateHinge (Mesh,0,0,1,0,0,0)
 
  ;MP_EntitySetNormals(Mesh)
  MP_MaterialEmissiveColor(Mesh, 255, 156 ,118, 39)
 
EndProcedure
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 74
; FirstLine = 59
; Folding = -
; EnableXP
; SubSystem = dx9
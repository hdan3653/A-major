Declare dropStone()
 
 ExamineDesktops()
Global bitplanes.b=DesktopDepth(0),RX.w=DesktopWidth(0),RY.w=DesktopHeight(0)
MP_Graphics3D(RX,RY,0,1):MP_VSync(0)
 SetWindowTitle(0, "Push Space for boxes")
 
 camera = MP_CreateCamera()    ; Kamera erstellen

 MP_PositionEntity(camera, 0, 4, -15 )
 MP_EntityLookAt(camera,0,0,0)

 light= MP_CreateLight(0)    ; Es werde Licht
 
 texture = MP_CreateTextureColor(256, 256, RGBA(0, 0, 255, 255))
 texture2 = MP_CreateTextureColor(256, 256, RGBA(100, 100, 255, 250))
 
 Global plane = MP_CreateRectangle(20,20,1)
 MP_EntitySetTexture(plane, texture)
 MP_PositionEntity (plane,0,-3,0)
 MP_RotateEntity(plane, 90, 0, 0)
   
 torus = MP_CreateTorus(0.1, 1, 20)
 MP_ResizeMesh(torus,4,4,4)
 MP_RotateEntity(torus, 90, 0, 0 )
 MP_PositionEntity (torus,2,-3,0)
 MP_EntitySetTexture(torus, texture2)
 
 Global body = MP_CreateRectangle(1.0,2,1.0)
 MP_RotateEntity(body, 0, 0, 120 )
 ;Global block = MP_CreateRectangle(0.5,2,0.5)
 ;MP_RotateEntity(block, 0, 0, 90 )
 ;MP_PositionEntity(block,-1,0.1,0)
 
 
 MP_EntitySetNormals(torus)
  MP_MaterialDiffuseColor(torus,255,255,128,50)
  MP_MaterialSpecularColor(torus,255,255,255,155,5)
 
 hingX.f=0:hingY.f=0:hingZ.f=1
 
 MP_PositionEntity (body,-2,1.5,0)
 
 MP_PhysicInit()
 
 MP_EntityPhysicBody(body , 4, 10)
 MP_EntityPhysicBody(torus , 1, 1)
 NewMaterial = MP_CreatePhysicMaterial()
 ;MP_SetPhysicMaterialProperties(MaterialID1, Elasticity.f, staticFriction.f, kineticFriction.f [, MaterialID2])
 MP_SetPhysicMaterialProperties(NewMaterial,0,2,2)
 MP_SetPhysicMaterialtoMesh (body, NewMaterial)
 
 MP_ConstraintCreateHinge (body,0,0,1,hingX,hingY,hingZ)
 MP_ConstraintCreateHinge (body,0,0,1,hingX+1,hingY,hingZ)
 
 MP_EntityPhysicBody(plane , 1, 1)
 MP_SetPhysicMaterialtoMesh (plane, NewMaterial)
 Global Mesh4
 
 MP_AmbientSetLight (RGB(0,100,200))

 While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
   If MP_KeyDown(#PB_Key_Space)
    dropStone()
  EndIf
 
 
     
     MP_PhysicUpdate()
     
     MP_RenderWorld() ; Erstelle die Welt
     MP_Flip () ; Stelle Sie dar
     
 Wend
   
 MP_PhysicEnd()
 
 Procedure dropStone()
  Mesh4 = MP_CreateRectangle(0.3,0.3,0.3)
      MP_EntityPhysicBody(Mesh4, 2, 3)
      MP_PositionEntity (Mesh4,-1,2.0,0)
     
     ; Kill all meshs with y < -10   
     For n = 0 To MP_ListGetSize(1)-1
       TempMesh = MP_ListGetElement(1, n)
       If MP_EntityGetY(TempMesh) < -10
           MP_FreeEntity(TempMesh)
       EndIf
     Next 
   
EndProcedure
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 10
; Folding = -
; EnableXP
; SubSystem = dx9
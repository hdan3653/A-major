;// Project Title: MP 3D Engine Beispielprogramme
 ;// Dateiname: MP_Physik_ConstraintCreatHinge.pb
 ;// Erstellt am: 11.8.2011
 ;// Update am  :
 ;// Author: Michael Paulwitz
 ;//
 ;// Info:
 ;// Physic with Hinge
 ;// Physik mit Rad
 ;//
 ;//
 ;////////////////////////////////////////////////////////////////
 ;MP_Physik_ConstraintCreatHinge tutorial
 ExamineDesktops()
 Global bitplanes.b=DesktopDepth(0),RX.w=DesktopWidth(0),RY.w=DesktopHeight(0),s_bg.i
 MP_Graphics3D(RX,RY,0,1);MP_VSync(0)
 SetWindowTitle(0, "Press left/Right move pivot _ Up/Down rotate pivot _ space drop stone")
 Declare HingePosition(disp.f)
 Declare dropStone()
 
 camera = MP_CreateCamera()    ; Kamera erstellen
 MP_PositionEntity(camera, 0, 5, -5 )
 MP_EntityLookAt(camera,0,0,0)

 light= MP_CreateLight(2)    ; Es werde Licht
 MP_LightSetColor(light, RGB(255,128,50))
 MP_PositionEntity(light, -6 , 10, -5)
   
 MP_AmbientSetLight (RGB(0,100,200))
 Global.f hingX=0,hingY=0,hingZ=0, disp.f
 Global piv = MP_CreateCylinder(10,1)
 Global.f length = 6, angle = 0, rot = 5, dirX = 1, dirZ = 1
 Global stone
 MP_ResizeMesh(piv,0.4,0.4,0.4)
 Global Mesh = MP_CreateRectangle (length,0.05,0.5)
 MP_PositionEntity (Mesh,0,0,0)
 MP_PositionEntity (piv,hingX,hingY,hingZ) ; the pivot position
 HingePosition(0)
 
 While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
   If MP_KeyHit(#PB_Key_Right)
     disp.f = 0.5 ; disp :the displacement og the Hinge to the right
     rot = 0 ; we don't want to change the pivot angle when we move pivot left or right
     HingePosition(disp)
   
   ElseIf MP_KeyHit(#PB_Key_Left)
     disp = -0.5 ; disp :the displacement of the Hinge to the left
     rot = 0
     HingePosition(disp)
   EndIf 
     
   If MP_KeyHit(#PB_Key_Up)
     rot = 5 ; the increment of angle
     disp = 0
     HingePosition(disp)
     ElseIf MP_KeyHit(#PB_Key_Down)
       rot = -5  ;the decrement of angle
       disp = 0
       HingePosition(disp)
   EndIf 
     
   If MP_KeyHit(#PB_Key_Space)
     dropStone()
   
   EndIf
   
     MP_Drawtext(10,20,"Length of rect="+StrF(length,2)+" /   Hinge relative X Position = "+StrF(HingX,2) + "   Y = 0  " + "  Z = 0")
     MP_Drawtext(10,40,"Angle= "+StrF(angle,2))
     MP_PhysicUpdate()
     MP_RenderWorld() ; Erstelle die Welt
     MP_Flip () ; Stelle Sie dar
     
 Wend
   
 MP_PhysicEnd()
 

 Procedure HingePosition(disp.f )
     hingX + disp
     MP_FreeEntity(Mesh): MP_FreeEntity(piv)
     piv = MP_CreateCylinder(10,1)
     MP_ResizeMesh(piv,0.4,0.4,0.4)
     MP_RotateMesh(piv , 0 , angle, 0)
     
     angle + rot     
     Mesh = MP_CreateRectangle (length,0.05,0.5)
     MP_PositionEntity (Mesh,0,0,0)
     MP_TranslateMesh (piv,hingX,hingY,hingZ) ; the pivot position relative to the Mesh
     
     MP_AddMesh(piv , Mesh ) : MP_FreeEntity(piv)
     MP_PhysicInit()
     MP_EntityPhysicBody(Mesh , 4, 10)
     
     ;http://www.mathwarehouse.com/vectors/images/main/how-To-solve.gif
     dirX = 1*Sin(Radian(angle)) ; the X component of the pivot vector
     dirZ = 1*Cos(Radian(angle)) ; the Z component of the pivot vector
     
     MP_ConstraintCreateHinge (Mesh,dirX,0,dirZ,hingX,hingY,hingZ)
     
     MP_EntitySetNormals (Mesh)
     MP_MaterialDiffuseColor (Mesh,255,255,128,50)
     MP_MaterialSpecularColor (Mesh, 255, 255 ,255, 155,5)
   EndProcedure
   
   Procedure dropStone()
   stone = MP_CreateRectangle(1,1,1)
   MP_EntityPhysicBody(stone, 2, 1)
   ;MP_EntitySetGravity(stone, 0 , -1 ,0)
   MP_PositionEntity (stone,-2.5,1,0) 
   stone2 = MP_CreateRectangle(1,1,1)
   MP_EntityPhysicBody(stone2, 2, 1)
   ;MP_EntitySetGravity(stone2, 0 , -1 ,0)
   MP_PositionEntity (stone2,1,1,0) 
   
   EndProcedure
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 52
; Folding = -
; EnableXP
; SubSystem = dx9
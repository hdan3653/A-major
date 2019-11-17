

;How to manually orbitate a camera (eye) around a point (any object) in space without the use of quaternions or tensors
;Use mouse wheel to increase-decrease distance of camera to the point
;Please don't hesitate in contact me (Psychophanta) if you want a fast and easy explanation of this.
Define .f
ExamineDesktops()
Global bitplanes.b=DesktopDepth(0),RX.w=DesktopWidth(0),RY.w=DesktopHeight(0)
MP_Graphics3D(RX,RY,bitplanes,0):MP_VSync(1)
SetWindowTitle(0,"manual camera orbitation")
Global.i camera,light,arrow,cone
camera=MP_CreateCamera()
MP_PositionEntity(camera,2,1,-10)
light=MP_CreateLight(2)
MP_LightSetColor(light,RGB(219,118,50))
MP_PositionEntity(light,-6,10,-5)
MP_AmbientSetLight(RGB(0,100,200))
arrow=MP_CreateCylinder(60,200)
MP_ScaleMesh(arrow,0.025,0.025,0.025)
MP_TranslateMesh(arrow,0,0,0)
cone=MP_CreateCone(60,4)
MP_TranslateMesh(cone,0,0,-27)
MP_ScaleMesh(cone,0.1,0.1,0.1)
MP_AddMesh(cone,arrow):MP_FreeEntity(cone)
MP_EntitySetNormals(arrow)
MP_MaterialDiffuseColor(arrow,255,255,128,50)
MP_MaterialSpecularColor(arrow,255,255,255,155,5)
MP_EntityLookAt(camera,MP_EntityGetX(arrow),MP_EntityGetY(arrow),MP_EntityGetZ(arrow))
Structure Vector
  x.f:y.f:z.f
  StructureUnion
    Length.f
    modulo.f
    m.f
  EndStructureUnion
EndStructure
Global CamAngle.Vector
Macro getmodulo(v)
  v#\m=Sqr(v#\x*v#\x+v#\y*v#\y+v#\z*v#\z)
EndMacro
Procedure Rotate_3DVector_by_Angle_adding(*angle.Vector,*radius.Vector)
  Protected vel.Vector
  getmodulo(*radius):getmodulo(*angle)
  If *angle\Length
    ;Calculates the vectorial product of two 3D vectors *vel-> = *angle-> X *radius->
    vel\x=*angle\y**radius\z-*angle\z**radius\y
    vel\y=*angle\z**radius\x-*angle\x**radius\z
    vel\z=*angle\x**radius\y-*angle\y**radius\x
    ;Now do R_t-> = cos(|wt->|)·R_0-> + |R_0->|/|u->|·sin(|wt->|)·u->
    getmodulo(vel)
    *radius\x=Cos(*angle\Length)**radius\x+*radius\Length/vel\Length*Sin(*angle\Length)*vel\x
    *radius\y=Cos(*angle\Length)**radius\y+*radius\Length/vel\Length*Sin(*angle\Length)*vel\y
    *radius\z=Cos(*angle\Length)**radius\z+*radius\Length/vel\Length*Sin(*angle\Length)*vel\z
  EndIf
EndProcedure

Macro OrbitEntity(item,angle,cx,cy,cz,farfactor=1.0)
  
  nr.Vector
  nr\x=MP_EntityGetX(camera)-cx#:nr\y=MP_EntityGetY(camera)-cy#:nr\z=MP_EntityGetZ(camera)-cz#
  nr\x*farfactor#:nr\y*farfactor#:nr\z*farfactor#
  Rotate_3DVector_by_Angle_adding(@angle#,@nr)
  MP_PositionEntity(item#,nr\x+cx#,nr\y+cy#,nr\z+cz#)
  
EndMacro

MP_UseCursor(0)

Repeat
  MP_DrawText(1,1,"! Push control and move mouse")
  MP_DrawText(1,25,"MP_EntityGetPitch(eye) = "+StrF(MP_EntityGetPitch(camera)))
  MP_DrawText(1,45,"MP_EntityGetYaw(eye) = "+StrF(MP_EntityGetYaw(camera)))
  MP_DrawText(1,65,"MP_EntityGetRoll(eye) = "+StrF(MP_EntityGetRoll(camera)))
  MP_DrawText(1,85,"MP_CameraGetX(eye) = "+StrF(MP_EntityGetX(camera)))
  MP_DrawText(1,105,"MP_CameraGetY(eye) = "+StrF(MP_EntityGetY(camera)))
  MP_DrawText(1,125,"MP_CameraGetZ(eye) = "+StrF(MP_EntityGetZ(camera)))
  If MP_KeyDown(#PB_Key_LeftControl)
    MouseWheel=-MP_MouseDeltaWheel()/1000+1
    mdx.f=MP_MouseDeltaX()/1000:mdy.f=MP_MouseDeltaY()/1000
    CamAngle\x=mdy
    CamAngle\y=mdx
    getmodulo(CamAngle)
    If CamAngle\m Or MouseWheel<>1.0
      OrbitEntity(camera,CamAngle,MP_EntityGetX(arrow),MP_EntityGetY(arrow),MP_EntityGetZ(arrow),MouseWheel)
      ;MP_EntityLookAt(camera,MP_EntityGetX(arrow),MP_EntityGetY(arrow),MP_EntityGetZ(arrow))
      MP_PointEntity (camera,arrow)
    EndIf
  EndIf
  MP_RenderWorld()
  MP_Flip()
Until MP_KeyDown(#PB_Key_Escape) Or WindowEvent()=#PB_Event_CloseWindow
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 69
; FirstLine = 32
; Folding = -
; EnableAsm
; EnableXP
; SubSystem = dx9
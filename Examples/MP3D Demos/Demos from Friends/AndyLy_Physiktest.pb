MP_Graphics3DWindow(0, 0, 1024, 768, "MP3D Physik Demo, Move ball with cusror",0)
Procedure Move(*CurX, *CurY,Angle.f,Speed.f)
   PokeF(*CurX,PeekF(*CurX)+Sin(Angle*0.01745)*Speed): PokeF(*CurY,PeekF(*CurY)-Cos(Angle*0.01745)*Speed)
  EndProcedure

light0 = MP_CreateLight(2): MP_PositionEntity(light0,-400,150,-100)
camera=MP_CreateCamera(): camangleX=0: camangleZ=0: camz.f=-256: camy.f=16: camx.f=0: CamRotSpeed.f=0.07

MP_PhysicInit()

NewMaterial = MP_CreatePhysicMaterial()
MP_SetPhysicMaterialProperties(NewMaterial,0.5,0.3,0.3)
;Global NewMaterial
nwMesh=MP_CreateSphere(24)
MP_ScaleMesh(nwMesh, 2.5,2.5,2.5)
MP_EntityPhysicBody(nwMesh, 3, 1): MP_SetPhysicMaterialtoMesh (nwMesh, NewMaterial)
MP_EntitySetColor(nwMesh,MP_ARGB(255,155,155,55))
MP_PositionEntity(nwMesh, 0,6,-100)

tex0 = MP_LoadTexture("F:\PUREBASIC\MP3D_30\MP3D Demos\3DPhysik\detail3.bmp")
MP_MaterialEmissiveColor(tex0, 0, 122, 132, 132)
;bodenplatte = MP_LoadMesh("F:\PUREBASIC\MP3D_30\MP3D Demos\3DPhysik\Scene2.x")
;MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
bodenplatte = MP_CreatePlane(200,200): MP_RotateEntity(bodenplatte,90,0,0):  MP_PositionEntity(bodenplatte,0,0,-100)
MP_EntitySetTexture(bodenplatte, tex0)
MP_EntityPhysicBody(bodenplatte, 1, 0)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
MouseDnMb=MP_MouseButtonDown(2)
 If MouseDnMb: camangleX+MP_MouseDeltaX()* CamRotSpeed: camangleZ-MP_MouseDeltaY()* CamRotSpeed: EndIf
 If MP_KeyDown(#PB_Key_W): camspd.f=-0.5: Move(@Camz,@Camx,Int(MP_LimitTo360(CamAngleX-90)),camspd): EndIf
    If MP_KeyDown(#PB_Key_S): camspd.f=0.5: Move(@Camz,@Camx,Int(MP_LimitTo360(CamAngleX-90)),camspd): EndIf
    If MP_KeyDown(#PB_Key_A): camspd.f=0.5: Move(@Camz,@Camx,Int(MP_LimitTo360(CamAngleX)),camspd): EndIf
    If MP_KeyDown(#PB_Key_D): camspd.f=0.5: Move(@Camz,@Camx,Int(MP_LimitTo360(CamAngleX-180)),camspd): EndIf
     If MP_KeyDown(#PB_Key_PageUp): camspd.f=0.1: camy+camspd: EndIf: If MP_KeyDown(#PB_Key_PageDown): camspd.f=0.1: camy-camspd: EndIf
  MP_RotateEntity(camera,camangleX,0,camangleZ): MP_PositionEntity(camera,camx,camy,camz)

If MP_KeyDown(#PB_Key_Up): MP_EntityAddImpulse(nwMesh,0,0,1,0,0,0): EndIf
If MP_KeyDown(#PB_Key_Down): MP_EntityAddImpulse(nwMesh,0,0,-1,0,0,0): EndIf
If MP_KeyDown(#PB_Key_Left): MP_EntityAddImpulse(nwMesh,-1,0,0,MP_EntityGetX (nwMesh),MP_EntityGetY (nwMesh),MP_EntityGetZ (nwMesh)) : EndIf
If MP_KeyDown(#PB_Key_Right): MP_EntityAddImpulse(nwMesh,1,0,0,0,0,0): EndIf
If MP_KeyDown(#PB_Key_Space): MP_EntityAddImpulse(nwMesh,0,10,0,0,0,0): EndIf

MP_Drawtext(10,20,StrF(camx,2)+" / "+StrF(camy,2)+" / "+StrF(camz,2))
  MP_PhysicUpdate(): MP_RenderWorld(): MP_Flip() 
Wend
MP_PhysicEnd()
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 35
; Folding = -
; EnableXP
; SubSystem = dx9
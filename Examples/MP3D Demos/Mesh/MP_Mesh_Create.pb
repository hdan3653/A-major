;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Mesh_Create.pb
;// Erstellt am: 30.3.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Mesh Create Demo
;// Demo from @graphy
;//
;////////////////////////////////////////////////////////////////

Structure D3DXVector3
    x.f
    y.f
    z.f
EndStructure

MP_Graphics3D(800, 600, 32, 1)
MP_CreateLight(1)

cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 4, 2048)
MP_PositionEntity(cam0, -16, 16, -32)
MP_EntityLookAt(cam0, 0, 0, 0)

cordx = MP_CreateMesh()
cordy = MP_CreateMesh()
cordz = MP_CreateMesh()

cyl0 = MP_CreateCylinder(10, 20)
MP_ScaleMesh(cyl0, 0.5, 0.5, 1)
MP_AddMesh(cyl0, cordz)
MP_FreeEntity(cyl0)

con0 = MP_CreateCone(10, 4)
MP_TranslateMesh(con0, 0, 0, -12)
MP_AddMesh(con0, cordz)
MP_FreeEntity(con0)

con1 = MP_CreateCone(10, 4)
MP_RotateMesh(con1, 0, 180, 0)
MP_TranslateMesh(con1,0, 0, 12)
MP_AddMesh(con1, cordz)
MP_FreeEntity(con1)

MP_AddMesh(cordz, cordx)
MP_RotateMesh(cordx, 0, 90, 0)

MP_AddMesh(cordz, cordy)
MP_RotateMesh(cordy, 90, 90, 0)

xplus = MP_Create3DText("", "x+", 4)
MP_EntitySetColor(xplus, MP_ARGB(255, 255, 0, 0))
MP_TranslateMesh(xplus, 5, 1, 0)

; This add the xplus mesh to the cordx mesh
MP_AddMesh(xplus, cordx)
MP_FreeEntity(xplus)

xminus = MP_Create3DText("", "x-", 4)
MP_EntitySetColor(xminus, MP_ARGB(255, 255, 0, 0))
MP_TranslateMesh(xminus, -9, 1, 0)

; This add the xmnius mesh to the cordx mesh
MP_AddMesh(xminus, cordx)
MP_FreeEntity(xminus)

yplus = MP_Create3DText("", "y+", 4)
MP_EntitySetColor(yplus, MP_ARGB(255, 0, 255, 0))
MP_TranslateMesh(yplus, 1, 7, 0)
MP_AddMesh(yplus, cordy)
MP_FreeEntity(yplus)

yminus = MP_Create3DText("", "y-", 4)
MP_EntitySetColor(yminus, MP_ARGB(255, 0, 255, 0))
MP_TranslateMesh(yminus, 1, -8, 0)

MP_AddMesh(yminus, cordy)
MP_FreeEntity(yminus)

zminus = MP_Create3DText("", "z-", 4)
MP_EntitySetColor(zminus, MP_ARGB(255, 0,   0, 255))
MP_TranslateMesh(zminus, 7,1, 0)
MP_RotateMesh(zminus, 0, 90, 0)
MP_AddMesh(zminus, cordz)
MP_FreeEntity(zminus)

zplus = MP_Create3DText("", "z+", 4)
MP_EntitySetColor(zplus, MP_ARGB(255, 0,   0, 255))
MP_TranslateMesh(zplus, -9, 1, 0)
MP_RotateMesh(zplus, 0, 90, 0)
MP_AddMesh(zplus, cordz)
MP_FreeEntity(zplus)

MP_EntitySetColor(cordx, MP_ARGB(255, 255, 0, 0))
MP_EntitySetColor(cordy, MP_ARGB(255, 0, 255, 0))
MP_EntitySetColor(cordz, MP_ARGB(255, 0,   0, 255))

MP_SaveMesh("c:\temp\cordx.x",cordx) ; you see a mesh with different meshs
MP_SaveMesh("c:\temp\cordy.x",cordy)
MP_SaveMesh("c:\temp\cordz.x",cordz)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  
  MP_TurnEntity(cordx, 1,1,0)
  MP_TurnEntity(cordy, 1,1,0)
  MP_TurnEntity(cordz, 1,1,0)
  
  MP_RenderWorld()
  MP_Flip()
  
Wend

;cyl0
;72 Vertices
;100 Triangles
;con0
;72 Vertices
;100 Triangles
;con1
;72 Vertices
;100 Triangles
;cordz
;217 Vertices
;301Triangles


; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 109
; FirstLine = 68
; EnableXP
; Executable = \\Hh\Transfer\test.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
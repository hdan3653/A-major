
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_PickingTriangle.pb
;// Erstellt am: 26.2.2011
;// Update am  : 
;// Author: grapy 
;// 
;// Info:
;// Easy Picking Triangle of Mesh
;//
;//
;////////////////////////////////////////////////////////////////



MP_Graphics3D(800, 600, 32, 2)
MP_VSync(1)
MP_Wireframe(1)
MP_CreateLight(1)

cam0 = MP_CreateCamera()
MP_PositionEntity(cam0, -150, 90, -140)
MP_RotateEntity(cam0, 29, 45, -30)

tex0 = MP_CreateTextureColor(256, 256, RGBA(255, 0, 0, 255))
tex1 = MP_CreateTextureColor(256, 256, RGBA(0, 255, 0, 255))
tex2 = MP_CreateTextureColor(256, 256, RGBA(0, 0, 255, 255))
tex3 = MP_CreateTextureColor(256, 256, RGBA(0, 255, 255, 255))

plane0 = MP_CreatePlane(10, 10)
MP_EntitySetTexture(plane0, tex3)
MP_ScaleMesh(plane0, 16, 16, 1)
MP_RotateEntity(plane0, 90, 0, 0)

cone0 = MP_CreateCone(16, 16)
MP_EntitySetTexture(cone0, tex0)
MP_ScaleMesh(cone0, 2, 2, 1)
MP_RotateEntity(cone0, 270, 0, 0)

cone1 = MP_CreateCone(16, 16)
MP_EntitySetTexture(cone1, tex1)
MP_ScaleMesh(cone1, 2, 2, 1)
MP_RotateEntity(cone1, 270, 0, 0)

cone2 = MP_CreateCone(16, 16)
MP_EntitySetTexture(cone2, tex2)
MP_ScaleMesh(cone2, 2, 2, 1)
MP_RotateEntity(cone2, 270, 0, 0)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  pickedmesh = MP_PickCamera(cam0, WindowMouseX(0),WindowMouseY(0))
  triangleindex = MP_PickedGetTriangle();
  If triangleindex And pickedmesh = plane0
    index0 = MP_EntityGetTriangle(pickedmesh, triangleindex, 0)
    index1 = MP_EntityGetTriangle(pickedmesh, triangleindex, 1)
    index2 = MP_EntityGetTriangle(pickedmesh, triangleindex, 2)
    MP_PositionEntity(cone0, MP_VertexGetX(pickedmesh, index0), MP_VertexGetZ(pickedmesh, index0)+8, MP_VertexGetY(pickedmesh, index0))
    MP_PositionEntity(cone1, MP_VertexGetX(pickedmesh, index1), MP_VertexGetZ(pickedmesh, index1)+8, MP_VertexGetY(pickedmesh, index1))
    MP_PositionEntity(cone2, MP_VertexGetX(pickedmesh, index2), MP_VertexGetZ(pickedmesh, index2)+8, MP_VertexGetY(pickedmesh, index2))
  EndIf
  MP_DrawText(0, 0, "triangleindex = " + Str(triangleindex))
  MP_RenderWorld()
  MP_Flip()  
Wend

; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 19
; FirstLine = 14
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
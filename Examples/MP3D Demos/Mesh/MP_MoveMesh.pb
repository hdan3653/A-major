

MP_Graphics3D(640,480,0,3)
camera=MP_CreateCamera()

MP_PositionEntity(camera,0,0,0)
light=MP_CreateLight(1)
mesh=MP_CreateCube()
MP_PositionEntity(Mesh,0,0,3)

MP_TurnEntity(Mesh, 0, 0,45)

While Not MP_Keydown(#PB_Key_Escape) And WindowEvent()<>#PB_Event_CloseWindow
  
  If MP_KeyDown(#PB_Key_Right):MP_MoveEntity(Mesh,0.01,0,0)
  ElseIf MP_KeyDown(#PB_Key_Left):MP_MoveEntity(Mesh,-0.01,0,0)
  ElseIf MP_KeyDown(#PB_Key_Up):MP_MoveEntity(Mesh,0,0.01,0)
  ElseIf MP_KeyDown(#PB_Key_Down):MP_MoveEntity(Mesh,0,-0.01,0)
  EndIf 
  
  MP_TurnEntity(Mesh, 0, 0,0.1)

  MP_RenderWorld()
  MP_Flip()
  
Wend
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 12
; EnableAsm
; EnableXP
; SubSystem = dx9
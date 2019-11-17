;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_FrustumCulling.pb
;// Created On: 15.3.2011
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Frustum Culling Demo
;// 
;////////////////////////////////////////////////////////////////

;- Init

MP_Graphics3DWindow(0,0,800, 600,"",0)
MP_MouseInWindow()
MP_UseCursor(0) 
MP_VSync(0)

Define x.f,y.f,z.f  = -400
Define cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 4, 2048)
MP_PositionEntity(cam0, 0,0,0)
MP_RotateEntity(cam0, 10,10,10)

Global NewList cubelist()
Define cubeswidth = 100
Define xxx,yyy,zzz,tempmesh,alltriangles
For zzz = -cubeswidth  To cubeswidth Step 20
  For xxx = -cubeswidth To cubeswidth Step 20
    For yyy = -cubeswidth To cubeswidth Step 20
      
       tempmesh = MP_CreateRectangle(10, 10, 10)
       MP_MeshCulling (tempmesh, 2)
      
      ; tempmesh = MP_CreateTeapot()
      ; MP_MeshCulling (tempmesh, 1)
      
      MP_EntitySetTexture(tempmesh, MP_CreateTextureColor(32, 32, RGBA(Random(255), Random(255), Random(255), 0)))
      MP_PositionEntity(tempmesh, xxx, yyy, zzz)
      AddElement(cubelist())
      cubelist() = tempmesh
      alltriangles + MP_CountTriangles(tempmesh)     
    Next 
  Next
Next

;-

MP_FrustumCulling(1)
  

Define camspeed,cam0
Define vst.f,yaw.f,pitch.f,roll.f,dirnormx.f,dirnormy.f,dirnormz.f
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  
  camspeed = 128
  vst.f = MP_VSyncTime()
  
  pitch.f + MP_MouseDeltaX()/3
  roll.f - MP_MouseDeltaY()/3
  If pitch.f >= 360
    pitch.f - 360
  ElseIf pitch.f < 0 
    pitch.f + 360   
  EndIf 
  If roll.f >= 89
    roll.f = 89
  ElseIf roll.f <= -89 
    roll.f = -89
  EndIf   
  
  dirnormx.f = Sin(Radian(pitch.f))*Cos(Radian(roll.f))
  dirnormy.f = Sin(Radian(roll.f))
  dirnormz.f = Cos(Radian(roll.f))*Cos(Radian(pitch.f))
  
  If MP_KeyDown(#PB_Key_W) = 1
    x.f + camspeed*dirnormx.f*vst.f
    y.f + camspeed*dirnormy.f*vst.f   
    z.f + camspeed*dirnormz.f*vst.f
  EndIf 
  If MP_KeyDown(#PB_Key_A) = 1
    x.f - camspeed*Cos(Radian(pitch.f))*vst.f
    z.f + camspeed*Sin(Radian(pitch.f))*vst.f
  EndIf
  If MP_KeyDown(#PB_Key_D) = 1
    x.f + camspeed*Cos(Radian(pitch.f))*vst.f
    z.f - camspeed*Sin(Radian(pitch.f))*vst.f
  EndIf 
  If MP_KeyDown(#PB_Key_S) = 1
    x.f - camspeed*dirnormx.f*vst.f
    y.f - camspeed*dirnormy.f*vst.f
    z.f - camspeed*dirnormz.f*vst.f
  EndIf

  ;checkScene()
  
  MP_PositionEntity(cam0, x.f, y.f, z.f)
  MP_RotateEntity(cam0, pitch.f, yaw.f, roll.f) 
  
  MP_DrawText(0, 0, "visible Meshs = " + Str(MP_CullingCount() ))
  MP_DrawText(0, 12, "FPS = " + Str(MP_FPS()))
  
  MP_RenderWorld()
  
  MP_Flip()
Wend




; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 36
; FirstLine = 15
; EnableXP
; Executable = C:\frustum.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
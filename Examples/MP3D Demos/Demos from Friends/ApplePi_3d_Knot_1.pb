Global xres=640, yres=480
MP_Graphics3D (xres,yres,0,3)
SetWindowTitle(0, "3D Knot, press space key to stop rotation,  press Z, X keys to zoom in/out")

camera=MP_CreateCamera()

light=MP_CreateLight(2)
MP_LightSetColor (light, RGB(255,255,255))

MP_PositionEntity(camera, 0, 5, 10)
MP_EntityLookAt(camera,0,0,0)

MP_PositionEntity(light, 0, 10, 20)
MP_EntityLookAt(light,0,0,0)

Global Entity= MP_CreatePrimitives (2000000, 7)   
 
Global.f x, y, z
Define.f red, green, blue

Quit.b = #False

;==============================================================
red = 0: green = 255: blue = 0
pointSize.f=20
    NumOfPoints = 3.14159*2 / 0.003     
    For PointNumber = 0 To NumOfPoints
             
              t.f+0.003
              ;x = Cos(2*t) + 0.75*Cos(5*t)
              ;y = Sin(2*t) + 0.75*Sin(5*t)
              ;z = 0.4*Sin(6*t)
              x = Cos(t) + 1.5*Cos(-2*t)
              y = Sin(t) + 1.5*Sin(-2*t)
              ;z = 0.35 * Sin(3*t)
              z = 1 * Sin(3*t)
              If PointNumber > 1000
                PointSize = 3: red = 255:green=255:blue=255
              EndIf 
                           
              MP_SetPrimitives(Entity, PointNumber, x, y, z, MP_ARGB(0,red,green,blue) ,pointSize)             
         
            Next
           
MP_ScaleEntity(Entity, 1.5, 1.5, 1.5)

MP_PositionEntity(camera, 0, 0, 10)
MP_EntityLookAt(camera,0,0,0)
MP_PositionEntity(light, 0 , 0, 10)
MP_EntityLookAt(light,0,0,0)

xx.f=0 :zz.f=0 : turn.b = 0: rot.f=0.5
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
 
  If MP_KeyDown(#PB_Key_Z)
    ;xx.f + 0.1
    zz.f + 0.1
  ElseIf MP_KeyDown(#PB_Key_X)
    ;xx.f - 0.1
    zz.f - 0.1
  ElseIf MP_KeyHit(#PB_Key_Space) 
    If turn
       rot=0.5
     Else
       rot=0
    EndIf
    turn ! 1
  EndIf
     
    MP_PositionEntity(Entity, xx, 0, zz)
    MP_TurnEntity(Entity,0,rot,0)
   
  MP_RenderWorld()
   
  MP_Flip ()

Wend
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 47
; FirstLine = 27
; EnableXP
; SubSystem = dx9
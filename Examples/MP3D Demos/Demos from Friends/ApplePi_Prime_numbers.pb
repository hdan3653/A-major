;edited to work with MP3D v32 prerelease
Global xres=640, yres=480
MP_Graphics3D (xres,yres,0,3)
SetWindowTitle(0, "Prime Numbers Spiral, press space key to stop rotation,  press Z, X keys to zoom in/out")

camera=MP_CreateCamera()

light=MP_CreateLight(2)
MP_LightSetColor (light, RGB(255,255,255))
;MP_InitShadow()

MP_PositionEntity(camera, 0, 5, 10)
MP_EntityLookAt(camera,0,0,0)

MP_PositionEntity(light, 0, 10, 20)
MP_EntityLookAt(light,0,0,0)

Global Entity= MP_CreatePrimitives (2000000, 7)   ; 7 ie sizable points
 
Global.f x, y, z
Define.f red, green, blue

Procedure IsPrime(Number.l)
  n = Sqr(number)
  For t = 2 To n
    If number % t = 0
      ProcedureReturn 0
    EndIf
  Next t
 
  ProcedureReturn 1
EndProcedure

Quit.b = #False : pointSize.f=3

;==============================================================
    iterations = 100000
         
    For number = 0 To 100000
             
              t.f+0.01  ; the angle
              ; the spiral equation
              x = t*Cos(6*t)
              y = t*Sin(6*t)
              z = t
             
              i+1
              a=IsPrime(number)
              If a=1
                red=0:green=255:blue=0 : pointSize = 3
                  Else
                    red=255:green=0:blue=0 : pointSize = 1
              EndIf
             
              MP_SetPrimitives(Entity, number, x, y, z, MP_ARGB(0,red,green,blue) ,pointSize)             
         
       Next
MP_ScaleEntity(Entity, 0.1, 0.1, 0.1)
;MP_MeshSetAlpha(Entity,2)

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
; CursorPosition = 61
; FirstLine = 41
; Folding = -
; EnableXP
; SubSystem = dx9
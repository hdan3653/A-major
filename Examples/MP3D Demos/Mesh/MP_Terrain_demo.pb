;original codes by Michael and Sveinung
MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "My first Terrain example, to Move use arrow keys up/down  ,to Turn  use arrow keys right/left") 



Global amplitude.f = 0.10
Global frequency.f = 4.0
Global sp=mp_createsphere(40)
Global sp_o
camera=MP_CreateCamera() ; Kamera erstellen

MP_CameraSetRange(Camera, 0.1, 5000) 

light=MP_CreateLight(2) 
MP_LightSetColor (light, RGB(255,255,255))
MP_PositionEntity(light, 0,200,-5029)

MP_CreateSkyBox ("rhills","jpg",100)

Terrain = MP_LoadTerrain ("rhills_hmap.bmp", 64,64) 
Texture = MP_LoadTexture("rhills_tmap.jpg") 

MP_EntitySetTexture (Terrain,texture)
MP_EntitySetName(Terrain, "Terrain")

sp_o=MP_CopyEntity(sp)
MP_HideEntity(sp_o,1)
texture =  MP_LoadTexture("marble.jpg")
MP_EntitySetTexture(sp, texture)
;MP_MaterialSpecularColor(texture,0,255,255,255,1)
MP_MaterialEmissiveColor (texture,0,255,255,255)
MP_MaterialAmbientColor (texture, 255, 128 , 255, 128) ; 
MP_MaterialSpecularColor (texture, 255, 128 ,255, 128,40) ; 

;MP_VSync(1)
MP_Wireframe(0)
Global countvertices.l = mp_countvertices(sp)-1

Procedure ufo()
  ;warping a sphere
  dtime.f=ElapsedMilliseconds()/800
  offset.f
  For i=0 To countvertices
    ;--------------------------------
    vx.f=MP_VertexGetX(sp_o,i)
    vy.f=MP_VertexGetY(sp_o,i)
    vz.f=MP_VertexGetZ(sp_o,i)
    ;--------------------------------
    offset = amplitude * Sin((dtime+MP_VertexGetX(sp_o,i))*frequency)
    vx + offset
    vy + offset
    vz + offset
    MP_VertexSetX(sp,i,vx)
    MP_VertexSetY(sp,i,vy)
    MP_VertexSetZ(sp,i,vz)
  Next
  
   EndProcedure
MP_PositionEntity(camera,-714,500,-4308)
;the beginning angle, press J to know the camera position at any time
angle.f = Degree(ATan(714/4308)+Radian(90)) ; 99.41 degrees
;Debug(StrF(angle))
;the sphere is 10 units away from the camera
;the sphere position differences in x, z coordinates from the camera x, z
xDelta.f = Cos(Radian(angle)) * 10 :  zDelta.f = Sin(Radian(angle)) * 10   
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

  ufo() ; call the warped sphere
  
  ;Driving the sphere
  If MP_KeyDown(#PB_Key_Up)
      rotY+3 ;sphere rotation
      MP_MoveEntity(camera,0,0,15)
     ElseIf MP_KeyDown(#PB_Key_Down)
       rotY-3 ;sphere rotation
       MP_MoveEntity(camera,0,0,-15)
          
     EndIf 
     
     If MP_KeyDown(#PB_Key_Right)
       rotX+3 
       angle.f - 0.76
       xDelta.f = Cos(Radian(angle)) * 10 :  zDelta.f = Sin(Radian(angle)) * 10
       rotX-3 ;sphere rotation
       MP_TurnEntity(camera, 0.76,0,0)
     ElseIf MP_KeyDown(#PB_Key_Left)
       angle.f + 0.76
       xDelta.f = Cos(Radian(angle)) * 10 :  zDelta.f = Sin(Radian(angle)) * 10
       rotX-3 ;sphere rotation
       MP_TurnEntity(camera, -0.76,0,0)
     EndIf
   
   MP_RotateEntity(sp, rotX, rotY, 0 ) ;sphere rotation
   MP_EntitySetNormals(sp)
  
  ;;pppppppppppppppppppppppppppppppppppppppppppppppppppppp
        
    x.f = MP_EntityGetX (camera)
    z.f = MP_EntityGetZ (camera)
    
    yyyy.f = MP_TerrainGetY (Terrain,x,0,z) + 500
    
    MP_PositionEntity(camera, x, yyyy  , z)
    MP_PositionEntity (sp,x+xDelta,MP_TerrainGetY(Terrain,x,0,z)+500,z+zDelta)
    MP_PositionEntity(light, x-200,200,z)
    
    MouseX = -(MP_MouseDeltaX()/10)
    MouseY = MP_MouseDeltaY()/10
    
    If MP_KeyHit(#PB_Key_J); to know the current camera position
    Debug("x = "+StrF(x))
    Debug("z = "+StrF(z))
    Debug("Altitude = "+ StrF(yyyy))
    Debug("  ")
    
  EndIf
        
    MP_TurnEntity(camera, MouseY, MouseX, 0 );, #PB_Relative)
        
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend



; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 103
; FirstLine = 69
; Folding = -
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\Primitives.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Physic_CatchMove.pb
;// Erstellt am: 15.5.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Catch Objekt and Moveit
;// Objekt nehmen und bewegen
;//
;//
;////////////////////////////////////////////////////////////////
Structure vecf
  x.f
  y.f
  z.f
EndStructure  

Structure matrix
  m.f[16]
EndStructure  


MP_Graphics3DWindow(0, 0, 800, 600, "MP3D Handle Demo, catch and move with mouse and Mousewheel w/s", 0)

light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 0, 128, 0)
cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -32, 64, -152)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

tex0 = MP_LoadTexture("detail3.bmp")
tex1 = MP_LoadTexture("crate01.jpg")



;################ Bodenplatte ################
bodenplatte = MP_CreateRectangle(256, 1, 256) ; Bodenplatte kann natürlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
MP_EntitySetTexture(bodenplatte, tex0)
MP_EntityPhysicBody(bodenplatte, 1, 0)
;#############################################

Mesh = MP_CreateRectangle(5, 5, 5) 
MP_EntitySetTexture(Mesh , tex1)
MP_EntityPhysicBody(Mesh , 2, 10)
MP_PositionEntity(Mesh, 0, 20,0)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow

  If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
     If Mouseon = 0
       Meshfound = MP_PickCamera (cam0,WindowMouseX(0),WindowMouseY(0))
       Mouseon = 1
       MP_3Dto2D(MP_EntityGetX(Meshfound),MP_EntityGetY(Meshfound),MP_EntityGetZ(Meshfound), @pointPosit.vecf );=  box\m[12], box\m[13], box\m[14])
       KeyZ.f = pointPosit\z
       MP_EntitySetPhysic(Meshfound,0)

     Else      
       MP_2Dto3D(WindowMouseX(0),WindowMouseY(0),KeyZ, @pointPosit )
       
       If Meshfound
          *Mesh.Matrix = MP_EntityGetMatrix (Meshfound)
          *Mesh\m[12] = pointPosit\x
          If pointPosit\y <7
             pointPosit\y = 7
          EndIf  
          *Mesh\m[13] = pointPosit\y
          *Mesh\m[14] = pointPosit\z
         
           MP_3Dto2D(pointPosit\x,pointPosit\y,pointPosit\z, @pointPosit.vecf );=  box\m[12], box\m[13], box\m[14])
           MP_Circle (pointPosit\x, pointPosit\y, 30, MP_ARGB(0,255,0,0))
         
            MP_DrawText (100,40,"Mesh "+Str(Meshfound)+" found")
         EndIf
     EndIf
     
   Else
       MP_EntitySetPhysic(Meshfound,1)
       Mouseon = 0
   EndIf
     
   If MP_MouseDeltaWheel() > 0
      KeyZ.f +0.0003
   ElseIf  MP_MouseDeltaWheel() <0 
      KeyZ.f - 0.0003
   EndIf
   If MP_EntityGetY(Mesh) < -60
     MP_EntitySetY(Mesh,60)
     MP_EntitySetX(Mesh,0)
     MP_EntitySetZ(Mesh,0)
   EndIf  
     
  MP_PhysicUpdate()  
  MP_RenderWorld()
  MP_Flip()  
Wend

MP_PhysicEnd()


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 32
; FirstLine = 30
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
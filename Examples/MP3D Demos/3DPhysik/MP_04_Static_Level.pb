;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_04_Static_Level.pb
;// Erstellt am: 15.5.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Physic with different Meshs
;// Physik mit unterschiedlichen Meshs
;//
;//
;////////////////////////////////////////////////////////////////


Structure Liste
  Mesh.i
  Tyoe.i
EndStructure  

Structure vecf
  x.f
  y.f
  z.f
EndStructure  

Structure matrix
  m.f[16]
EndStructure  

Global NewList MyList.Liste()
Global NewMaterial


Procedure Newmesh ()
  
For n = 0 To 19  
  
AddElement(MyList())

Ergebnis = Random(9)   
If Ergebnis = 0  
    MyList()\Mesh = MP_CreateRectangle(5, 5, 5)
    MP_EntityPhysicBody(MyList()\Mesh, 2, 10)
ElseIf Ergebnis = 1   
    MyList()\Mesh = MP_CreateRectangle(7, 3, 5)
    MP_EntityPhysicBody(MyList()\Mesh, 2, 10)
ElseIf Ergebnis = 2   
    MyList()\Mesh = MP_CreateSphere(20)
    MP_ScaleMesh(MyList()\Mesh, 2.5,2.5,2.5)
    MP_EntityPhysicBody(MyList()\Mesh, 3, 10)
    MP_SetPhysicMaterialtoMesh (MyList()\Mesh, NewMaterial)
ElseIf Ergebnis = 3   
    MyList()\Mesh = MP_CreateSphere(20)
    MP_ScaleMesh(MyList()\Mesh, 4,2.5,2.5) 
    MP_EntityPhysicBody(MyList()\Mesh, 3, 10)
    MP_SetPhysicMaterialtoMesh (MyList()\Mesh, NewMaterial)
ElseIf Ergebnis = 4   
    MyList()\Mesh = MP_CreateTorus(2, 5, 12)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 5   
    MyList()\Mesh = MP_CreatePyramid(5, 5, 5) 
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 6   
    MyList()\Mesh = MP_CreateTeapot()
    MP_ScaleMesh(MyList()\Mesh, 3,3,3)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 7     
  
  MyList()\Mesh = MP_Create3DText("Times","MP3D",10) 
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 8     
    MyList()\Mesh = MP_CreateCone(10,5) 
    MP_ScaleMesh(MyList()\Mesh, 2.5,2.5,2.5)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 9     
    MyList()\Mesh = MP_CreateCylinder(15,5)   
    MP_ScaleMesh(MyList()\Mesh, 2.5,2.5,2.5)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
EndIf
MP_EntitySetColor(MyList()\Mesh,MP_ARGB(255,Random(255),Random(255),Random(255))) 

MP_PositionEntity(MyList()\Mesh, 0, 40 + n*10,0)

Next n

EndProcedure


MP_Graphics3DWindow(0, 0, 1024, 768, "MP3D Physik Demo, Mouse to hit and move, Space to delete Meshs",0)
; MP_VSync(0)
light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 0, 128, 0)
cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -32, 64, -152)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

NewMaterial = MP_CreatePhysicMaterial() 
MP_SetPhysicMaterialProperties(NewMaterial,1,0,0)

tex0 = MP_CreateTextureColor(128, 128, RGBA(0, 255, 0, 0))

tex0 = MP_LoadTexture("detail3.bmp")
MP_MaterialEmissiveColor(tex0, 0, 122, 132, 132)

;################ Bodenplatte ################
bodenplatte = MP_LoadMesh("Scene2.x"); Bodenplatte kann nat�rlich auch ein x-beliebiges Mesh sein



MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
MP_EntitySetTexture(bodenplatte, tex0)

;MP_RotateEntity (bodenplatte,0,0,16)
MP_EntityPhysicBody(bodenplatte, 1, 0)




Newmesh ()

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  
    If MP_MouseButtonDown(0) ; Linke Maustaste gedr�ckt?
     If Mouseon = 0
       Meshfound = MP_PickCamera (cam0,WindowMouseX(0),WindowMouseY(0))
       If Meshfound <> bodenplatte 
         Mouseon = 1
         MP_3Dto2D(MP_EntityGetX(Meshfound),MP_EntityGetY(Meshfound),MP_EntityGetZ(Meshfound), @pointPosit.vecf );=  box\m[12], box\m[13], box\m[14])
         KeyZ.f = pointPosit\z
         MP_EntitySetPhysic(Meshfound,0)
       EndIf  
     Else      
       MP_2Dto3D(WindowMouseX(0),WindowMouseY(0),KeyZ, @pointPosit )
       
       If Meshfound
          *Mesh.Matrix = MP_EntityGetMatrix (Meshfound)
          *Mesh\m[12] = pointPosit\x
        ;  If pointPosit\y <7
        ;     pointPosit\y = 7
        ;  EndIf  
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
  
  If MP_KeyDown(#PB_Key_Space)=1
     
      ForEach MyList()
        MP_FreeEntity(MyList()\Mesh)
        DeleteElement(MyList())
      Next
       Newmesh ()
      
    EndIf
  
  MP_PhysicUpdate()
  MP_RenderWorld()
  MP_Flip()  
Wend

MP_PhysicEnd()
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 119
; FirstLine = 83
; Folding = -
; EnableXP
; Executable = C:\MP_Physik3.exe
; SubSystem = dx9
; 湅扡敬畃瑳浯畓卢獹整m慍畮污倠牡浡瑥牥匠䐽㥘
; 湡慵⁬慐慲敭整⁲㵓塄9
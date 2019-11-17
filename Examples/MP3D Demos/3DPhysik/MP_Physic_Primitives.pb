;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Physic_Primitives.pb
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

Global NewList MyList.Liste()
Global NewMaterial


Procedure Newmesh ()
  
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

MP_PositionEntity(MyList()\Mesh, 20, 45,0)

EndProcedure


IncludeFile "MP_Screen3DRequester.pb"

If MP_Screen3DRequester("PureBasic - MP3D Demos")
  
; MP_VSync(0)
light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 0, 256, 0)
MP_EntityLookAt(light0, 0, 0, 0)

cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -32, 40, -152)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

NewMaterial = MP_CreatePhysicMaterial() 
MP_SetPhysicMaterialProperties(NewMaterial,1,0,0)

;tex0 = MP_CreateTextureColor(128, 128, RGBA(0, 128, 0, 0))
;MP_MaterialEmissiveColor(tex0, 0, 122, 132, 132)


;################ Bodenplatte ################
bodenplatte = MP_CreatePlane (16,16)

MP_EntitySetColor(bodenplatte,MP_ARGB(255,Random(255),Random(255),Random(255))) 


MP_ScaleMesh(bodenplatte,4,8,4)

For i=0 To mp_countvertices(bodenplatte)-1
  
    MP_VertexSetZ(bodenplatte,i,MP_VertexGetZ(bodenplatte,i)+Random(10)/100-0.05)
    
Next
  
;MP_EntitySetTexture(bodenplatte, tex0)

MP_RotateEntity (bodenplatte,70,90,0)
MP_EntityPhysicBody(bodenplatte, 1,0)

;mp_wireframe(1)
MP_AmbientSetLight (RGB( 200, 100, 255))

      
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  
  count+1
  
  If count > 120
    Newmesh ()
    count = 0
  EndIf  
  
  
      dtime.f=ElapsedMilliseconds()/3000
      
      dummy + 1
      If dummy = 1
      
      
       For i=0 To mp_countvertices(bodenplatte)-1
          vy.f=MP_VertexGetY(bodenplatte,i)
          MP_VertexSetZ(bodenplatte,i,Sin(vy/10+dtime)*8)
      Next
      MP_EntitySetNormals(bodenplatte)
      MP_ChangePhysicHull(bodenplatte,1) 
      dummy = 0
    EndIf

    If MP_KeyDown(#PB_Key_Space)=1
      
      ForEach MyList()
        MP_FreeEntity(MyList()\Mesh)
        DeleteElement(MyList())
      Next

    EndIf
    
    ForEach MyList()
      If MP_EntityGetY(MyList()\Mesh) < -120 
        MP_FreeEntity(MyList()\Mesh)
        DeleteElement(MyList())
      EndIf  
    Next
    
    If ListSize(MyList()) > 40
      FirstElement(MyList()) 
      MP_FreeEntity(MyList()\Mesh)
      DeleteElement(MyList())
    EndIf  
    
  MP_DrawText (1,1,"FPS = "+Str(MP_FPS()) + " / Count of Meshs = "+Str(ListSize(MyList())))
  
  MP_PhysicUpdate()
  MP_RenderWorld()
  MP_Flip()  
Wend

MP_PhysicEnd()


EndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 120
; FirstLine = 104
; Folding = -
; EnableAsm
; EnableXP
; EnableUser
; Executable = C:\Temp\2\Physic.exe
; SubSystem = dx9
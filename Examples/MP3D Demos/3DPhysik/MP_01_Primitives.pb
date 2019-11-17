;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_01_Primitives.pb
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

MP_PositionEntity(MyList()\Mesh, 0, 70,0)

EndProcedure


MP_Graphics3DWindow(0, 0, 1024, 768, "MP3D Physik Demo, Space to delete Meshs",0)
;MP_VSync(0)
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


;tex0 = MP_LoadTexture("detail3.bmp")
;tex1 = MP_LoadTexture("crate01.jpg")
MP_MaterialEmissiveColor(tex0, 0, 122, 132, 132)
;MP_MaterialEmissiveColor(tex1, 0, 128, 128, 128)


;################ Bodenplatte ################
bodenplatte = MP_CreateRectangle(256, 1, 256) ; Bodenplatte kann nat�rlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
MP_EntitySetTexture(bodenplatte, tex0)

MP_RotateEntity (bodenplatte,0,0,16)
MP_EntityPhysicBody(bodenplatte, 1, 0)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  
  count+1
  
  If count > 60
    Newmesh ()
    count = 0
  EndIf  
  
    If MP_KeyDown(#PB_Key_Space)=1
      
      ForEach MyList()
        MP_FreeEntity(MyList()\Mesh)
        DeleteElement(MyList())
      Next

    EndIf
    
    ForEach MyList()
      If MP_EntityGetY(MyList()\Mesh) < -40 
        MP_FreeEntity(MyList()\Mesh)
        DeleteElement(MyList())
      EndIf  
    Next
    
    If ListSize(MyList()) > 30
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
; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 78
; FirstLine = 63
; Folding = -
; EnableXP
; Executable = C:\MP_Physik3.exe
; SubSystem = dx9
; 慮汢䍥獵潴卭扵祓瑳浥
; 慍畮污倠牡浡瑥牥匠䐽㥘䔀慮汢䍥獵潴卭扵祓瑳浥
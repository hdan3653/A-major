;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Domino_Day.pb
;// Erstellt am: 4.8.2012
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Physic with Dominos Meshs
;// Physik mit Domino Meshs
;//
;//
;////////////////////////////////////////////////////////////////


Structure Liste
  Mesh.i
  Tyoe.i
EndStructure  

Global NewList MyList.Liste()
Global NewMaterial


MP_Graphics3DWindow(0, 0, 1024, 768, "MP3D Physik Demo, Space to delete Meshs",0)
; MP_VSync(0)

light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 0, 128, 0)
cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -10, 22, -60)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

NewMaterial = MP_CreatePhysicMaterial() 
MP_SetPhysicMaterialProperties(NewMaterial,1,0,0)

tex0 = MP_CreateTextureColor(128, 128, RGBA(0, 255, 0, 0))
MP_MaterialEmissiveColor(tex0, 0, 122, 132, 132)


;################ Bodenplatte ################
bodenplatte = MP_CreateRectangle(156, 1, 156) ; Bodenplatte kann natürlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
MP_EntitySetTexture(bodenplatte, tex0)

;MP_RotateEntity (bodenplatte,0,0,16)
MP_EntityPhysicBody(bodenplatte, 1, 0)


For i = 1 To 200
    
    AddElement(MyList())
    MyList()\Mesh = MP_CreateRectangle(1.5,3,0.4);,0.1)
    MP_EntityPhysicBody(MyList()\Mesh, 2, 20)
  
    MP_MaterialDiffuseColor(MyList()\Mesh,255,Random(255),Random(255),Random(255)) 
    
    radius.f = (10 + i) / 10.0
	  ugol.f = (ugol + 120.0) / radius
	  x.f = radius * Sin(ugol) * 2
	  z.f = radius * Cos(ugol) * 2
	  
    MP_PositionEntity(MyList()\Mesh, x,1.6,z)
    
    MP_EntityLookAt(MyList()\Mesh,0,1.6,0)    
    
    MP_TurnEntity(MyList()\Mesh, 0, 140,0)
    
  Next
  
  MyList()\Mesh = MP_CreateSphere(20)
  MP_ScaleMesh(MyList()\Mesh, 2,2,2)
  MP_EntityPhysicBody(MyList()\Mesh, 3, 40)
  MP_PositionEntity(MyList()\Mesh,x-2,10,z)
  
  
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  
  MP_DrawText (1,1,"FPS = "+Str(MP_FPS()) + " / Count of Meshs = "+Str(ListSize(MyList())))
  
  MP_PhysicUpdate()
  MP_RenderWorld()
  MP_Flip()  
  
Wend

MP_PhysicEnd()
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 33
; FirstLine = 30
; EnableXP
; Executable = C:\MP_Physik3.exe
; SubSystem = dx9
; DisableDebugger
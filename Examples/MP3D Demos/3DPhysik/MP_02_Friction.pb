
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_02_Friction.pb
;// Erstellt am: 19.5.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Physic with Elasticity Meshs
;// Physik mit elastischen Kugeln
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


MP_Graphics3DWindow(0, 0, 800, 600, "MP3D Demo about Friction of Mesh, Space to reset", 0)

light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 0, 128, 0)
MP_EntityLookAt(light0, 0, 0, 0)
cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -32, 64, -152)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

tex0 = MP_LoadTexture("detail3.bmp")

;################ Bodenplatte ################
bodenplatte = MP_CreateRectangle(256, 1, 256) ; Bodenplatte kann natürlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
MP_RotateEntity (bodenplatte, -20, 0, 0)

MP_EntitySetTexture(bodenplatte, tex0)
MP_EntityPhysicBody(bodenplatte, 1, 0)
;#############################################

NewList TempMesh()

For m = 0 To 7
  
    AddElement(TempMesh())
    TempMesh() = MP_CreateRectangle(2,1,4)
    
    MP_ScaleMesh (TempMesh(),3,3,3)
    MP_RotateEntity (TempMesh(), -20, 0, 0)
    
    MP_MaterialDiffuseColor(TempMesh(),255,Random(255),Random(255),Random(255)) 
    
    MP_EntityPhysicBody(TempMesh(), 2, 1)
    
    NewMaterial = MP_CreatePhysicMaterial() 
    MP_SetPhysicMaterialProperties(NewMaterial,0,m/14,m/14)
    MP_SetPhysicMaterialtoMesh (TempMesh(), NewMaterial)
    
    MP_PositionEntity(TempMesh(), (m-4) * 14, 9 ,20)
  
Next 
  

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow

   
   If MP_KeyDown(#PB_Key_Space)=1
      FirstElement(TempMesh()) 
      
      For m = 0 To 7
        
          MP_EntityResetPhysic(TempMesh())
          MP_RotateEntity (TempMesh(), -20, 0, 0)
          MP_PositionEntity(TempMesh(), (m-4) * 14, 9 ,20)
          NextElement(TempMesh()) 

      Next 

   EndIf
   
   MP_DrawText (1,1,"FPS = "+Str(MP_FPS()))
   
  MP_PhysicUpdate()  
  
  MP_RenderWorld()
  
  MP_Flip()  
Wend

MP_PhysicEnd()


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 82
; FirstLine = 40
; EnableXP
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
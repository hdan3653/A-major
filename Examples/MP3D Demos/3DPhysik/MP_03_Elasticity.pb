;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_03_Elasticity.pb
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


MP_Graphics3DWindow(0, 0, 800, 600, "MP3D Demo about Elasticity of Mesh, Space to reset", 0)


light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 50, 128, 0)
MP_EntityLookAt(light0, 0, 0, 0)
cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -32, 64, -152)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

;tex0 = MP_CatchTexture(?Texture,?Texture-?Textur_end)
tex0 = MP_LoadTexture("detail3.bmp")


;################ Bodenplatte ################
bodenplatte = MP_CreateRectangle(256, 1, 256) ; Bodenplatte kann natürlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
MP_EntitySetTexture(bodenplatte, tex0)
MP_EntityPhysicBody(bodenplatte, 1, 0)
;#############################################

NewList TempMesh()

For m = 0 To 7
  
    AddElement(TempMesh())
    TempMesh() = MP_CreateSphere(5)
    
    MP_ScaleMesh (TempMesh(),3,3,3)
        
    MP_MaterialDiffuseColor(TempMesh(),255,Random(255),Random(255),Random(255)) 
    
    MP_EntityPhysicBody(TempMesh(), 3, 10)
    
    TempMaterial = MP_CreatePhysicMaterial() 
    MP_SetPhysicMaterialProperties(TempMaterial,m/7,0,0)
    MP_SetPhysicMaterialtoMesh (TempMesh(), TempMaterial)
    
    MP_PositionEntity(TempMesh(), (m-4) * 14, 60 ,0)
  
Next 
  

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow

   
   If MP_KeyDown(#PB_Key_Space)=1
      FirstElement(TempMesh()) 
      
      For m = 0 To 7
          
          MP_EntityResetPhysic(TempMesh())
          MP_PositionEntity(TempMesh(), (m-4) * 14, 40 ,0)
          NextElement(TempMesh()) 

      Next 

   EndIf
   
   MP_DrawText (1,1,"FPS = "+Str(MP_FPS()))
   
  MP_PhysicUpdate()  
  
  MP_RenderWorld()
  
  MP_Flip()  
Wend

MP_PhysicEnd()


;DataSection
;  Texture:
;  IncludeBinary  "detail3.bmp" ; Einfache Textur
;  Textur_end:
;EndDataSection


; IDE Options = PureBasic 5.22 LTS (Windows - x86)
; CursorPosition = 53
; FirstLine = 9
; Executable = C:\MP_Elastity2.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
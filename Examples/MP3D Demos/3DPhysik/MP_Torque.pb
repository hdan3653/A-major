
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Torque.pb
;// Erstellt am: 22.12.2015
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Physic with Torque Meshs
;// Physik mit drehung 
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

MP_Graphics3DWindow(0, 0, 800, 600, "MP3D Demo with Torque, Space to reset", 0)

light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 0, 128, 0)
MP_EntityLookAt(light0, 0, 0, 0)
cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -32, 64, -152)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

If CreateImage(0, 255, 255)
  MP_CreateImageColored(0, 0, RGB(100,155,255), RGB(110,255,255), RGB(0,0,255), RGB(0,0,255))     
EndIf

tex0 = MP_ImageToTexture( 0 )

;################ Bodenplatte ################
bodenplatte = MP_CreateRectangle(256, 1, 256) ; Bodenplatte kann nat�rlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
;MP_RotateEntity (bodenplatte, -20, 0, 0)

MP_EntitySetTexture(bodenplatte, tex0)
MP_EntityPhysicBody(bodenplatte, 1, 0)
;#############################################

NewList TempMesh()

For m = 0 To 7
  
    AddElement(TempMesh())
   ;TempMesh() = MP_CreatePyramid(3,4,3)
    TempMesh() = MP_CreateCone(16,12)
    MP_ScaleMesh (TempMesh(),6,6,1)
   ;MP_ScaleMesh (TempMesh(),3,3,3)
    MP_RotateEntity (TempMesh(), 266, 0, 0)
    ;MP_RotateEntity (TempMesh(), 180, 0, 0)
    
    MP_MaterialDiffuseColor(TempMesh(),255,Random(255),Random(255),Random(255)) 
    
    MP_EntityPhysicBody(TempMesh(), 4, 1)
    
    NewMaterial = MP_CreatePhysicMaterial() 
    MP_SetPhysicMaterialProperties(NewMaterial,0,m/14,m/14)
    MP_SetPhysicMaterialtoMesh (TempMesh(), NewMaterial)
    
    MP_EntitySetOmega(TempMesh(), 0 , 100 ,0)
    
    MP_PositionEntity(TempMesh(), (m-4) * 14, 15 + (m*2) ,0)
  
Next 
  

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow

   
   If MP_KeyDown(#PB_Key_Space)=1
      FirstElement(TempMesh()) 
      
      For m = 0 To 7
          MP_EntityResetPhysic(TempMesh())
          ;MP_RotateEntity (TempMesh(), 180, 0, 0)
          MP_EntitySetOmega(TempMesh(), 0 , 100 ,0)
          MP_PositionEntity(TempMesh(), (m-4) * 14, 15 + (m*2) ,0)
          NextElement(TempMesh()) 

      Next 

   EndIf
   
   MP_EntityGetOmega(TempMesh(),Omega.vecf)
   MP_DrawText (1,1,"FPS = "+Str(MP_FPS())+" / GetOmega = "+StrF(Omega\y))
   
  MP_PhysicUpdate()  
  
  
  
  MP_RenderWorld()
  
  MP_Flip()  
Wend

MP_PhysicEnd()


; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 15
; EnableXP
; SubSystem = dx9
; 慍畮污倠牡浡瑥牥匠䐽㥘䔀慮汢䍥獵潴卭扵祓瑳浥
; 慮汢䍥獵潴卭扵祓瑳浥
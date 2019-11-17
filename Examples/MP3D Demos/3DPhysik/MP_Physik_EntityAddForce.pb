
MP_Graphics3DWindow(0, 0, 800, 600, "MP3D MP_EntityAddImpulse Demo, Push Entity with left mouse, Space to reset", 0)

light0 = MP_CreateLight(1)
MP_PositionEntity(light0, 0, 128, 0)
cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_PositionEntity(cam0, -32, 64, -152)
MP_EntityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

tex0 = MP_CatchTexture( ?MyData, ?MyData2 - ?MyData) 
tex1 = MP_CatchTexture(?MyData2, ?MyData3 - ?MyData2)

;################ Bodenplatte ################
bodenplatte = MP_CreateRectangle(256, 1, 256) ; Bodenplatte kann natürlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( bodenplatte ,0.6,0.6,0.6)
MP_EntitySetTexture(bodenplatte, tex0)
MP_EntityPhysicBody(bodenplatte, 1, 0)
;#############################################

NewList TempMesh()

For m = 0 To 7
  For n = 0 To 7
  
    AddElement(TempMesh())
    TempMesh() = MP_CreateRectangle(5, 5, 5) 
    MP_EntitySetTexture(TempMesh() , tex1)
    MP_EntityPhysicBody(TempMesh(), 2, 10)
    MP_PositionEntity(TempMesh(), (m-4) * 6, n * 5.2 + 5 ,0)
  
  Next
Next 
  
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow

  If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
    
    Meshfound = MP_PickCamera (cam0,WindowMouseX(0),WindowMouseY(0))
    If Meshfound 
      MP_EntityAddImpulse(Meshfound,0,0,20) 
    EndIf
    
  EndIf
     
  If MP_KeyDown(#PB_Key_Space)=1
     FirstElement(TempMesh()) 
      
      For m = 0 To 7
        For n = 0 To 7
          
          MP_EntityResetPhysic(TempMesh())
          MP_PositionEntity(TempMesh(), (m-4) * 6, n * 5.2 + 5 ,0)
          NextElement(TempMesh()) 

        Next
      Next 

  EndIf
    
  MP_DrawText (1,1,"FPS = "+Str(MP_FPS()))
   
  MP_PhysicUpdate()  
  
  MP_RenderWorld()
  
  MP_Flip()  
Wend

MP_PhysicEnd()


DataSection
  MyData:
     IncludeBinary "detail3.bmp"
  MyData2:
     IncludeBinary "crate01.jpg"
  MyData3:
EndDataSection
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 8
; FirstLine = 3
; EnableXP
; Executable = C:\newton1.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_PhysikShadow.pb
;// Erstellt am: 15.5.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Newton Physic with Shadow
;// Newton Physik mit Schatten
;//
;//
;////////////////////////////////////////////////////////////////

#D3DRS_CULLMODE = 22 ;/* D3DCULL */

#D3DCULL_NONE = 1
#D3DCULL_CW = 2
#D3DCULL_CCW = 3


Structure Liste
  Mesh.i
  Tyoe.i
EndStructure  

Global NewList MyList.Liste()
Global NewMaterial

Procedure Newmesh (tex0)
  
AddElement(MyList())
Ergebnis = Random(7)   

If Ergebnis = 0  
    MyList()\Mesh = MP_CreateRectangle(5, 5, 5)
    MP_EntityPhysicBody(MyList()\Mesh, 2, 10)
ElseIf Ergebnis = 1   
    MyList()\Mesh = MP_CreateSphere(20)
    MP_ScaleMesh(MyList()\Mesh, 2.5,2.5,2.5)
    MP_EntityPhysicBody(MyList()\Mesh, 3, 10)
    MP_SetPhysicMaterialtoMesh (MyList()\Mesh, NewMaterial)
ElseIf Ergebnis = 2   
    MyList()\Mesh = MP_CreateTorus(2, 5, 12)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 3   
    MyList()\Mesh = MP_CreatePyramid(5, 5, 5) 
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 4   
    MyList()\Mesh = MP_CreateTeapot()
    MP_ScaleMesh(MyList()\Mesh, 3,3,3)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 5     
  
  MyList()\Mesh = MP_Create3DText("Times","MP3D",10) 
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 6     
    MyList()\Mesh = MP_CreateCone(10,5) 
    MP_ScaleMesh(MyList()\Mesh, 2.5,2.5,2.5)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
ElseIf Ergebnis = 7     
    MyList()\Mesh = MP_CreateCylinder(15,5)   
    MP_ScaleMesh(MyList()\Mesh, 2.5,2.5,2.5)
    MP_EntityPhysicBody(MyList()\Mesh, 4, 10)  
EndIf

MP_MaterialDiffuseColor(MyList()\Mesh,255,Random(255),Random(255),Random(255)) 

MP_PositionEntity(MyList()\Mesh, 0, 70, 0)

EndProcedure


MP_Graphics3DWindow(0, 0, 1024, 768, "MP3D Physik Demo, Space to delete Meshs",0)

If CreateImage(1, 256, 256)
  txp=8 : txres=1 << txp : txcp=txp-6 : txcell=1 << txcp-1
  StartDrawing(ImageOutput(1))
 
  For x=0 To 63
    ux=x << txcp
    For y=0 To 63
      uy=y << txcp
      col=1
      ; Definition of color of section
      If x>=4 And x <60 And y>=4 And y <60

        hups = Round(((x-4)/7), #PB_Round_Down) + Round(((y-4)/7), #PB_Round_Down)
        If hups & 1
          col=0
        EndIf
 
      ElseIf x>=3 And x <61 And y>=3 And y <61 
        col=0
      EndIf
 
      ;  A shading of section with addition of color noise
      For xx=ux To ux+txcell
        For yy=uy To uy+txcell
          FrontColor (RGB( MP_RandomInt(-8,8) +192*col+16, MP_RandomInt(-8,8) +128*col+16, MP_RandomInt(-8,8) +16))
          Plot (xx, yy)
        Next
      Next  
    Next
  Next
 
  StopDrawing() 

EndIf

Muster=MP_ImageToTexture (1)
FreeImage(1)


; MP_VSync(0)
light0 = MP_CreateLight(1)
MP_PositionEntity(light0, -14, 54, -34)
MP_EntityLookAt(light0,0,0,0)

cam0 = MP_CreateCamera()
MP_CameraSetRange(cam0, 2, 2024)
MP_Positionentity(cam0, -32, 64, -152)
MP_entityLookAt(cam0, 0, 0, 0)
MP_PhysicInit()

NewMaterial = MP_CreatePhysicMaterial() 
MP_SetPhysicMaterialProperties(NewMaterial,1,0,0)

tex0 = MP_CreateTextureColor(128, 128, RGBA(0, 255, 0, 0))


;tex0 = MP_LoadTexture("detail3.bmp")
;tex1 = MP_LoadTexture("crate01.jpg")
MP_MaterialEmissiveColor(tex0, 0, 122, 132, 132)
;MP_MaterialEmissiveColor(tex1, 0, 128, 128, 128)


;################ Bodenplatte ################

bodenplatte = MP_CreateRectangle(154, 1, 154) ; Bodenplatte kann natürlich auch ein x-beliebiges Mesh sein

MP_EntitySetTexture(bodenplatte, tex0)

MP_EntitySetTexture(bodenplatte, muster)


MP_RotateEntity (bodenplatte,0,0,16)
MP_EntityPhysicBody(bodenplatte, 1, 0)

MP_InitShadow() 

;MP_SetShadowEpsilon(0.00005)

;MP_SetRenderState(#D3DRS_CULLMODE, #D3DCULL_CCW)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
  
  count+1
  
  If count > 60
    Newmesh (tex0)
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
    
    If ListSize(MyList()) > 80
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
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 118
; FirstLine = 132
; Folding = -
; EnableXP
; Executable = C:\MP_Physik3.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
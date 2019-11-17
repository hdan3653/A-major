





shaderFX.s = PeekS(?Shader,?ShaderEnd-?Shader) ; Load Shader

MP_Graphics3D (640,480,0,3) ; Create Window
SetWindowTitle(0, "Postprocessing Overlay Sprite") 



camera=MP_CreateCamera() : light=MP_CreateLight(1)  ; Cam and Light



; Creater a bigger Object
Cube1=MP_CreateCube() : Cube3=MP_CreateCube() : 
Cube4=MP_CreateCube() : Cube2=MP_CreateCube() :

MP_TranslateMesh  (Cube2,0, 0,-1): MP_PositionEntity (Cube1 ,0,1,0) 
MP_PositionEntity (Cube3 ,0,0,1): MP_PositionEntity (Cube4 ,0,-1,0) 
MP_PositionEntity (Cube2 ,0,0,6) 

MP_EntitySetParent(Cube3, Cube2)
MP_EntitySetParent(Cube4, Cube2)
MP_EntitySetParent(Cube1, Cube2) 




Spritetexture = MP_LoadTexture("Power2.png",1) ; Our Sprite Texture
sprite        = MP_SpriteFromTexture(Spritetexture) 


 
;{ Create Cube Textures
If CreateImage(1, 255, 255) : CreateImage(1, 255, 255,32)
  StartDrawing(ImageOutput(1))
    DrawingMode(#PB_2DDrawing_Default)
    For t = 0 To 100
      Col = RGB(55+(t*1),55+(t*1),155+(t*1))
      Box(0+t, 0+t, 255-(t*2), 255-(t*2), Col)
    Next t
  StopDrawing() : EndIf
CubeTex1  = MP_ImageToTexture(1,0,0,1) : FreeImage(1)
MP_MaterialEmissiveColor (CubeTex1,64,64,64,64) 


If CreateImage(1, 255, 255) : CreateImage(1, 255, 255,32)
  StartDrawing(ImageOutput(1))
    DrawingMode(#PB_2DDrawing_Default)
    For t = 0 To 100
      Col = RGB(155+(t*1),55+(t*1),155+(t*1))
      Box(0+t, 0+t, 255-(t*2), 255-(t*2), Col)
    Next t
  StopDrawing() : EndIf
CubeTex2  = MP_ImageToTexture(1,0,0,1) : FreeImage(1)
MP_MaterialEmissiveColor (CubeTex2,64,64,64,64)


If CreateImage(1, 255, 255) : CreateImage(1, 255, 255,32)
  StartDrawing(ImageOutput(1))
    DrawingMode(#PB_2DDrawing_Default)
    For t = 0 To 100
      Col = RGB(155+(t*1),155+(t*1),55+(t*1))
      Box(0+t, 0+t, 255-(t*2), 255-(t*2), Col)
    Next t
  StopDrawing() : EndIf
CubeTex3  = MP_ImageToTexture(1,0,0,1) : FreeImage(1)
MP_MaterialEmissiveColor (CubeTex3,64,64,64,64)


If CreateImage(1, 255, 255) : CreateImage(1, 255, 255,32)
  StartDrawing(ImageOutput(1))
    DrawingMode(#PB_2DDrawing_Default)
    For t = 0 To 100
      Col = RGB(55+(t*1),155+(t*1),55+(t*1))
      Box(0+t, 0+t, 255-(t*2), 255-(t*2), Col)
    Next t
  StopDrawing() : EndIf
CubeTex4  = MP_ImageToTexture(1,0,0,1) : FreeImage(1)
MP_MaterialEmissiveColor (CubeTex4,64,64,64,64)
;}




MP_EntitySetTexture (Cube1, CubeTex1) : MP_EntitySetTexture (Cube2, CubeTex2)
MP_EntitySetTexture (Cube3, CubeTex3) : MP_EntitySetTexture (Cube4, CubeTex4)




Texture  = MP_CreateBackBufferTexture()
MyShader = MP_CreateMyShader(shaderFX)





While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  
  
    MP_TurnEntity (Cube2, 0.3,0.5 ,1) ; Rotate the Object
    MP_RenderWorld() ; Render 
    
    
    
;{ Postprossesing
    MP_BackBufferToTexture (Texture)
    MP_SetTechniqueMyShader (MyShader,"PostProcess")
    MP_ShaderSetTexture (MyShader,"entSkin1",Texture)
    
    MP_UseBackbufferShader(Texture, MyShader)
    
     MP_DrawSprite(Sprite, 360, 350)  ; Sprite Overlay
     MP_RenderToTexture( Texture )    

    MP_TextureToBackBuffer (Texture)
    ;}
    
    
    
    
    
    
    MP_Flip () ; Show us the world pls

Wend




DataSection
   Shader: 
     IncludeBinary "epyx.fx"
   ShaderEnd:
EndDataSection
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 28
; Folding = +
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
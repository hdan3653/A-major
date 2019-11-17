;////////////////////////////////////////////////////////////////
;//

;// 
;////////////////////////////////////////////////////////////////




shader1FX.s = PeekS(?Shader1,?Shader2-?Shader1) ; Load Shader
shader2FX.s = PeekS(?Shader2,?Shader3-?Shader2) ; Load Shader
shader3FX.s = PeekS(?Shader3,?Shader4-?Shader3) ; Load Shader
shader4FX.s = PeekS(?Shader4,?Shader5-?Shader4) ; Load Shader
shader5FX.s = PeekS(?Shader5,?Shader6-?Shader5) ; Load Shader
shader6FX.s = PeekS(?Shader6,?Shader7-?Shader6) ; Load Shader
shader7FX.s = PeekS(?Shader7,?Shader8-?Shader7) ; Load Shader
shader8FX.s = PeekS(?Shader8,?Shader9-?Shader8) ; Load Shader
shader9FX.s = PeekS(?Shader9,?Shader10-?Shader9) ; Load Shader
shader10FX.s = PeekS(?Shader10,?Shader11-?Shader10) ; Load Shader
shader11FX.s = PeekS(?Shader11,?Shader12-?Shader11) ; Load Shader
shader12FX.s = PeekS(?Shader12,?Shader13-?Shader12) ; Load Shader
shader13FX.s = PeekS(?Shader13,?Shader14-?Shader13) ; Load Shader
shader14FX.s = PeekS(?Shader14,?Shader15-?Shader14) ; Load Shader
shader15FX.s = PeekS(?Shader15,?Shader16-?Shader15) ; Load Shader
shader16FX.s = PeekS(?Shader16,?Shader17-?Shader16) ; Load Shader
shader17FX.s = PeekS(?Shader17,?Shader18-?Shader17) ; Load Shader
shader18FX.s = PeekS(?Shader18,?Shader19-?Shader18) ; Load Shader
shader19FX.s = PeekS(?Shader19,?Shader20-?Shader19) ; Load Shader
shader20FX.s = PeekS(?Shader20,?Shader21-?Shader20) ; Load Shader
shader21FX.s = PeekS(?Shader21,?Shader22-?Shader21) ; Load Shader
shader22FX.s = PeekS(?Shader22,?Shader23-?Shader22) ; Load Shader
shader23FX.s = PeekS(?Shader23,?Shader24-?Shader23) ; Load Shader
shader24FX.s = PeekS(?Shader24,?Shader25-?Shader24) ; Load Shader
shader25FX.s = PeekS(?Shader25,?Shader26-?Shader25) ; Load Shader
shader26FX.s = PeekS(?Shader26,?Shader27-?Shader26) ; Load Shader


shader27FX.s = PeekS(?Shader27,?ShaderEnd-?Shader27) ; Load Shader


MP_Graphics3D (640,480,0,3) ; Create Window
SetWindowTitle(0, "ShaderTest by Epyx VertexShader: "+Hex(MP_VersionOf(2))+" Pixelshader: "+Hex(MP_VersionOf(3))) 



camera=MP_CreateCamera() : light=MP_CreateLight(1)  ; Cam and Light


mp_vsync(0)

; Creater a bigger Object
Cube1=MP_CreateCube() : Cube3=MP_CreateCube() : 
Cube4=MP_CreateCube() : Cube2=MP_CreateCube() :

MP_TranslateMesh (Cube2,0, 0,-1): MP_PositionEntity (Cube1 ,0,1,0) 
MP_PositionEntity (Cube3 ,0,0,1): MP_PositionEntity (Cube4 ,0,-1,0) 
MP_PositionEntity (Cube2 ,0,0,6) 

MP_EntitySetParent(Cube3, Cube2) : MP_EntitySetParent(Cube4, Cube2)
MP_EntitySetParent(Cube1, Cube2) 


;Spritetexture = MP_LoadTexture("Power2.png",1) ; Our Sprite Texture
Spritetexture = MP_CatchTexture(?ShaderEnd,?PowerEnd-?ShaderEnd ,1) ; Our Sprite Texture
sprite        = MP_SpriteFromTexture(Spritetexture) 
Tex01 = MP_CatchTexture(?PowerEnd,?TexEnd-?PowerEnd ,1) ; Our Sprite Texture
 
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
Dim MyShader.i(27)

MyShader(1) = MP_CreateMyShader(shader1FX)
MyShader(2) = MP_CreateMyShader(shader2FX)
MyShader(3) = MP_CreateMyShader(shader3FX)
MyShader(4) = MP_CreateMyShader(shader4FX)
MyShader(5) = MP_CreateMyShader(shader5FX)
MyShader(6) = MP_CreateMyShader(shader6FX)
MyShader(7) = MP_CreateMyShader(shader7FX)
MyShader(8) = MP_CreateMyShader(shader8FX)
MyShader(9) = MP_CreateMyShader(shader9FX)
MyShader(10) = MP_CreateMyShader(shader10FX)
MyShader(11) = MP_CreateMyShader(shader11FX)
MyShader(12) = MP_CreateMyShader(shader12FX)
MyShader(13) = MP_CreateMyShader(shader13FX)
MyShader(14) = MP_CreateMyShader(shader14FX)
MyShader(15) = MP_CreateMyShader(shader15FX)
MyShader(16) = MP_CreateMyShader(shader16FX)
MyShader(17) = MP_CreateMyShader(shader17FX)
MyShader(18) = MP_CreateMyShader(shader18FX)
MyShader(19) = MP_CreateMyShader(shader19FX)
MyShader(20) = MP_CreateMyShader(shader20FX)
MyShader(21) = MP_CreateMyShader(shader21FX)
MyShader(22) = MP_CreateMyShader(shader22FX)
MyShader(23) = MP_CreateMyShader(shader23FX)
MyShader(24) = MP_CreateMyShader(shader24FX)
MyShader(25) = MP_CreateMyShader(shader25FX)
MyShader(26) = MP_CreateMyShader(shader26FX)
MyShader(27) = MP_CreateMyShader(shader27FX)

Post_FX = 1

;MP_AmbientSetLight(RGB(0,0,30))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  
    If MP_KeyHit(#PB_Key_F1)=1 : Post_FX = Post_FX + 1 : If Post_FX = 28 : Post_FX= 0 : EndIf : EndIf  
  
    MP_TurnEntity (Cube2, 0.3,0.5 ,1) ; Rotate the Object
    MP_RenderWorld() ; Render 
    
    ;{ Postprossesing
 If Post_FX > 0
      
    MP_ShaderSetVar_f (MyShader(Post_FX),"time",MP_ElapsedMicroseconds()/100000 )
    MP_BackBufferToTexture (Texture)    
    MP_SetTechniqueMyShader (MyShader(Post_FX),"PostProcess")
    MP_ShaderSetTexture (MyShader(Post_FX),"entSkin1",Texture)    
    MP_ShaderSetTexture (MyShader(Post_FX),"Tex01",Tex01)    
    MP_UseBackbufferShader(Texture, MyShader(Post_FX)) 
       
EndIf

    MP_DrawSprite(Sprite, 360, 350) ; Sprite Overlay
    
If Post_FX > 0
      
  MP_RenderToTexture( Texture )
  MP_TextureToBackBuffer (Texture)
EndIf
    ;}
 
    MP_DrawText(0, 1, "Press F1 to toggle Shader, Post_FX = "+Str(Post_FX)+", FX  = "+Str(MP_FPS()))
    MP_RenderText()
 
    MP_Flip () ; Show us the world pls

Wend




DataSection
   Shader1: 
     IncludeBinary "heart.fx"
   Shader2: 
     IncludeBinary "flower.fx"
   Shader3: 
     IncludeBinary "Apfel.fx"
   Shader4: 
     IncludeBinary "Julia.fx"
   Shader5: 
     IncludeBinary "plasma.fx"
   Shader6: 
     IncludeBinary "Metablob.fx"
   Shader7: 
     IncludeBinary "Twist.fx"
   Shader8: 
     IncludeBinary "Star.fx"
   Shader9: 
     IncludeBinary "Radial Blur.fx"
   Shader10: 
     IncludeBinary "Motion Blur.fx"
   Shader11: 
     IncludeBinary "postprocessing.fx"
   Shader12: 
     IncludeBinary "Multitexture.fx"
   Shader13: 
     IncludeBinary "Kaleidoscope.fx"
   Shader14: 
     IncludeBinary "deform.fx"
   Shader15: 
     IncludeBinary "Pulse.fx"
   Shader16: 
     IncludeBinary "ZInvert.fx"
   Shader17: 
     IncludeBinary "sierpinski.fx"
   Shader18: 
     IncludeBinary "nautilus.fx"
   Shader19: 
     IncludeBinary "Relieftunnel.fx"
   Shader20: 
     IncludeBinary "fly.fx"
   Shader21: 
     IncludeBinary "Monjori.fx"
   Shader22: 
     IncludeBinary "Chocolux.fx"
   Shader23: 
     IncludeBinary "tunnel.fx"
   Shader24: 
     IncludeBinary "disco.fx"
   Shader25: 
     IncludeBinary "Squaretunnel.fx"
   Shader26: 
     IncludeBinary "RoadRibbon.fx"
   Shader27: 
     IncludeBinary "704.fx"
   
   
   
   ShaderEnd:
     IncludeBinary "Power2.png"
   PowerEnd:
      IncludeBinary "tex0.jpg"
   TexEnd:
 EndDataSection
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 54
; FirstLine = 44
; Folding = -
; EnableXP
; Executable = C:\MP_Shadettest.exe
; SubSystem = dx9
; DisableDebugger
; EnableCustomSubSystem
; Manual Parameter S=DX9
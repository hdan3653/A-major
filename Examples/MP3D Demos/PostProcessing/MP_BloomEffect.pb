
;-
;- ProgrammStart

;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_BloomEffect.pb
;// Created On: 7.1.2011
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Afterburner with Bloomeffect
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart

shaderFX.s = PeekS(?Shader,?ShaderEnd-?Shader)

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D Darstellung eine Würfels") ; Setzt einen Fensternamen

MP_VSync(0) 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

;Mesh=MP_CreateCube() ; Und jetzt eine Würfel
Mesh=MP_CreateTeapot() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels


;Texture = MP_CreateTexture(640,480)
;Texture2 = MP_CreateTexture(640,480)

Texture  = MP_CreateBackBufferTexture() 
Texture2 = MP_CreateBackBufferTexture() 

MyShader = MP_CreateMyShader(shaderFX)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_DrawText (1,1,"FPS = "+Str(MP_FPS())) 
  
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    
    ;{ Bloom
    
    MP_BackBufferToTexture (Texture)
    MP_BackBufferToTexture (Texture2)
    
    MP_SetTechniqueMyShader (MyShader,"DownScale")
    MP_ShaderSetTexture (MyShader,"TextureA",Texture)
    MP_UseBackbufferShader(Texture, MyShader)
    
    MP_SetTechniqueMyShader (MyShader,"DownScale")
    MP_ShaderSetTexture (MyShader,"TextureA",Texture2)
    MP_UseBackbufferShader(Texture, MyShader)
    
    MP_SetTechniqueMyShader (MyShader,"GaussianBlurH")
    MP_ShaderSetTexture (MyShader,"TextureA",Texture)
    MP_UseBackbufferShader(Texture, MyShader)
    
    MP_SetTechniqueMyShader (MyShader,"GaussianBlurV")
    MP_ShaderSetTexture (MyShader,"TextureA",Texture)
    MP_UseBackbufferShader(Texture, MyShader)
    
    MP_SetTechniqueMyShader (MyShader,"Bloom")
    MP_ShaderSetTexture (MyShader,"TextureA",Texture)
    MP_ShaderSetTexture (MyShader,"TextureB",Texture2)
    MP_UseBackbufferShader(Texture, MyShader)
    
    MP_TextureToBackBuffer (Texture)
    ;} Bloom
    
    MP_Flip () ; Stelle Sie dar

Wend

DataSection
   Shader: 
     IncludeBinary "bloom.fx";"Effect"
   ShaderEnd:
EndDataSection
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 45
; FirstLine = 35
; Folding = -
; EnableXP
; Executable = C:\bloom.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

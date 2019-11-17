;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_BloomEffect3.pb
;// Created On: 7.1.2011
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// PostProcessing with Bloomeffect
;// OnePass
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart

shaderFX.s = PeekS(?Shader,?ShaderEnd-?Shader)

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D bloom with teapot") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

;Mesh=MP_CreateCube() ; Und jetzt eine Würfel
Mesh=MP_CreateTeapot() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

Texture = MP_CreateBackBufferTexture()
Texture2 = MP_CreateBackBufferTexture()

MyShader = MP_CreateMyShader(shaderFX)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    
    ;{ Effect
    MP_BackBufferToTexture (Texture)
    MP_BackBufferToTexture (Texture2)
    MP_SetTechniqueMyShader (MyShader,"MainTechnique")
    MP_ShaderSetTexture (MyShader,"sceneTexture",Texture)
    MP_ShaderSetTexture (MyShader,"currentTexture",Texture2)
    MP_UseBackbufferShader(Texture, MyShader)
    MP_TextureToBackBuffer (Texture)
    ;}
    
    MP_Flip () ; Stelle Sie dar

Wend


DataSection
   Shader: 
     IncludeBinary "bloom3.fx";"Effect"
   ShaderEnd:
EndDataSection
; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 20
; FirstLine = 6
; Folding = -
; EnableXP
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
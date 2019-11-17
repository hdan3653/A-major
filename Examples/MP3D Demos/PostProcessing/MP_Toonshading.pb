;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Toonshading.pb
;// Created On: 7.1.2011
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// PostProcessing with Toonshading
;// OnePass
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart

shaderFX.s = PeekS(?Shader,?ShaderEnd-?Shader)

MP_Graphics3D (800,600,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Toonshader") ; Setzt einen Fensternamen


camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

;Mesh=MP_CreateCube() ; Und jetzt eine Würfel
Mesh=MP_CreateTeapot() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

Texture = MP_CreateBackBufferTexture()

MyShader = MP_CreateMyShader(shaderFX)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    
        X_Add.f + 1   
    Cam_SX.f   = Sin((X_Add.f * #PI / 180)) * 0.9
    
    MP_PositionEntity (Camera, Cam_SX , 0, 0)
    
    
    MP_RenderWorld() ; Erstelle die Welt
    
    ;{ Effect
    MP_BackBufferToTexture (Texture)
    MP_SetTechniqueMyShader (MyShader,"postFX")
    MP_ShaderSetTexture (MyShader,"TargetMap",Texture)
    MP_UseBackbufferShader(Texture, MyShader)
    MP_TextureToBackBuffer (Texture)
    ;}
    
    MP_Flip () ; Stelle Sie dar

Wend

DataSection
   Shader: 
     IncludeBinary "Toonshading.fx";"Effect"
   ShaderEnd:
EndDataSection
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 43
; FirstLine = 16
; Folding = -
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
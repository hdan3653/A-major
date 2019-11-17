
;-
;- ProgrammStart

;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Emboss.pb
;// Created On: 7.1.2011
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Afterburner with emboss, only 1/4 side of the screen
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart

shaderFX.s = PeekS(?Shader,?ShaderEnd-?Shader)

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Emboss Effect 1/4 side of the screen") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

;Mesh=MP_CreateCube() ; Und jetzt eine Würfel
Mesh=MP_CreateTeapot() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position of Mesh

Texture = MP_CreateTexture(640,480) ; Texture for backbuffer

MyShader = MP_CreateMyShader(shaderFX)

;MP_ShaderSetVar_f (MyShader,"g_fGlowInt", g_fGlowInt) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    
    ;{ Effect
    MP_BackBufferToTexture (Texture)
    MP_SetTechniqueMyShader (MyShader,"tech_00")
    MP_ShaderSetTexture (MyShader,"entSkin1",Texture)
    MP_UsePixelShader(Texture, MyShader)
    MP_TextureToBackBuffer (Texture)
    ;}
    
    MP_Flip () ; Stelle Sie dar

Wend

DataSection
   Shader: 
     IncludeBinary "emboss2.fx";"Effect"
   ShaderEnd:
EndDataSection

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 40
; FirstLine = 8
; Folding = -
; EnableXP
; Executable = C:\MP_Emboss.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

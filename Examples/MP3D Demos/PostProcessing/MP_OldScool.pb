
;-
;- ProgrammStart

;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_OldScool.pb
;// Created On: 7.1.2011
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Afterburner with olscool
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart

shaderFX.s = PeekS(?Shader,?ShaderEnd-?Shader)

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D Darstellung eine Würfels") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

;Mesh=MP_CreateCube() ; Und jetzt eine Würfel
Mesh=MP_CreateTeapot() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

Texture = MP_CreateBackbufferTexture()

MyShader = MP_CreateMyShader(shaderFX)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    
    ;{ oldscool
    MP_BackBufferToTexture (Texture)
    
    If Pixelation_x.f < 640
       Pixelation_x + 1 
    EndIf
     
    If Pixelation_y.f < 480
      Pixelation_y + 1 
    EndIf
     
    MP_ShaderSetVar_f (MyShader,"Pixelation_x",Pixelation_x)
    MP_ShaderSetVar_f (MyShader,"Pixelation_y",Pixelation_y)
    MP_SetTechniqueMyShader (MyShader,"postFX")
    MP_ShaderSetTexture (MyShader,"TargetMap",Texture)
    MP_UsePixelShader(Texture, MyShader)
    
    MP_TextureToBackBuffer (Texture)
    ;}

    MP_Flip () ; Stelle Sie dar

Wend

DataSection
   Shader: 
     IncludeBinary "oldscool.fx";"Effect"
   ShaderEnd:
EndDataSection

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 38
; FirstLine = 18
; Folding = -
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

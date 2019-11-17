;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: Bewegende Objekte2.pb
;// Created On: 26.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Soundemo 
;//
;//
;////////////////////////////////////////////////////////////////

XIncludeFile "C:\Program Files\PureBasic\Examples\DirectX For PB4\Source\MP3D_Library.pb"

;-
;- ProgrammStart

MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "SoundDemo (mit Würfel)") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
MP_PositionEntity (Mesh,0,0,5) ; Position des Würfels


Sound = MP_LoadSound("Explosion.wav")

MP_PlaySound2(Sound,1) 

MP_SoundSetVolume(Sound, 85)
MP_SoundSetPan(Sound, 100)


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.2,0.3) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 7
; EnableAsm
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
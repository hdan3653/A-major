;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: Bewegende Objekte2.pb
;// Created On: 26.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Sound Demo aus dem Speicher geladen
;//
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart


MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "SoundDemo2 mit Torus") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht


If CreateImage(0, 255, 255)

    Font = LoadFont(#PB_Any, "Arial"  , 138) 
    StartDrawing(ImageOutput(0))

    Box(0, 0, 128, 128,RGB(255,0,0))
    Box(128, 0, 128, 128,RGB(0,255,0))
    Box(0, 128, 128, 128,RGB(0,0,255))
    Box(128, 128, 128, 128,RGB(255,255,0))

    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(73,35,"5",RGB(0,0,0))
  
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Texture = MP_ImageToTexture(0) ; Create Texture from image 

Sound = MP_CatchSound(?theSound)

;Mesh=MP_CreateCube() ; Und jetzt eine Würfel
;Mesh=MP_CreatePyramid (1,2,1)
;Mesh=MP_CreateRetangle (1,2,3)
;Mesh=MP_CreateTeapot ()
;Mesh=MP_CreateCylinder (8,3)
;Mesh=MP_CreateCone (8,3)
Mesh=MP_CreateTorus (0.5, 2, 88)
;Mesh=MP_CreatePolygon (2, 6)
;Mesh=MP_CreatePlane ( 10, 10)
 



MP_EntitySetTexture (Mesh, Texture ) ; textur to mesh
MP_PositionEntity (Mesh,0,0,12) ; Position des Würfels

MP_PlaySound(Sound) 

MP_SoundSetVolume(Sound, 33)
MP_SoundSetPan(Sound, -80)
;Debug MP_SetSoundPosition(Soundb, 0) 


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.2,0.3) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

DataSection
  theSound:
  IncludeBinary "Explosion.wav"
EndDataSection

; IDE Options = PureBasic 5.40 LTS Beta 8 (Windows - x64)
; CursorPosition = 62
; FirstLine = 18
; EnableAsm
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
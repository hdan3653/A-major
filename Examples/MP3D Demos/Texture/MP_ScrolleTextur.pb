;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ScrolleTextur.pb
;// Erstellt am: 29.1.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// scroll texture on cube
;// Scrolle eine Textur 
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Scroll Texture on cube") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

Texture =  MP_LoadTexture(#PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp",0,1)

MP_EntitySetTexture (Mesh, Texture) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_ScrollTexture(Texture, 1, -1 ) 

    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 30
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

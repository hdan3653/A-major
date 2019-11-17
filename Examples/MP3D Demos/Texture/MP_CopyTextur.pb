;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_CopyTextur.pb
;// Erstellt am: 24.1.201
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// copy texture 
;// Kopiert eine Textur im Teilbereich
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D Darstellung eine Würfels") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

Texture =  MP_LoadTexture(#PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp")

Texture2 = MP_CreateTexture(64, 64)

MP_EntitySetTexture (Mesh, Texture2) 


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    n + 1 
    If n = 78 : n = 0 : EndIf
      
    MP_CopyTexture (Texture,Texture2,n,n,60,60)

    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 33
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

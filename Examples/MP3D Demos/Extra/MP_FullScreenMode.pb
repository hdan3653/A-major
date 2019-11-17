;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_FullSceenMode.pb
;// Erstellt am: 17.06.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Umschaltung zwischen Windows und ScreenMode Einfache 3D Darstellung eines Teapot mit Wireframe
;// Switched between full and Screemmode
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3D (800,600,0,2) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "FullScreen on = a, FullScreen off = s") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
    
    If MP_KeyDown(#PB_Key_A)=1
       MP_FullScreenMode(1)  
    EndIf
    
    If MP_KeyDown(#PB_Key_S)=1
       MP_FullScreenMode(0)  
    EndIf

    
Wend
     
     

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 18
; EnableXP
; SubSystem = dx9
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_WireframeDouble.pb
;// Erstellt am: 28.12.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einfache 3D Darstellung eines Teapot mit Wireframe
;// Easy 3D Printig with Wireframe
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

#Rendernormal = 0

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D Printing of Teapot with Wireframe") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

;Mesh=MP_Createcube() ; Und jetzt eine Würfel
Mesh=MP_Createteapot() ; Und jetzt einen Teapot
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,1,1,1) ; dreh den Würfel
    
    If #Rendernormal 
      
      MP_RenderWorld() ; Erstelle die Welt
      
    Else
      
      MP_RenderBegin() 
    
      MP_Wireframe (0) 
      MP_RenderMesh() 
    
      MP_Wireframe (1) 
      MP_RenderMesh() 
    
      MP_Renderend() 
      
    EndIf 
      
    MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 31
; FirstLine = 1
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

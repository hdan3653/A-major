;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Wuerfel.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einfache 3D Darstellung eines Würfels
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

;MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
;SetWindowTitle(0, "3D Darstellung eine Würfels") ; Setzt einen Fensternamen

IncludeFile "MP_Screen3DRequester.pb"

If MP_Screen3DRequester("PureBasic - MP3D Demos")

  camera=MP_CreateCamera() ; Kamera erstellen

  light=MP_CreateLight(1) ; Es werde Licht

  Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
  MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

  While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
 
     MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
     MP_RenderWorld() ; Erstelle die Welt
     MP_Flip () ; Stelle Sie dar
     
  Wend
  
EndIf
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 22
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
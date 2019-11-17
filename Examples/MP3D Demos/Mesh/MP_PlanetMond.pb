;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_PlanetMond.pb
;// Erstellt am: 29.12.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple 3D representation of a planet with a moon and satellite
;// Einfache 3D Darstellung eines Planeten mit Mond und Satellit
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart


MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D Darstellung eines Planeten mit Parent - Kid Beziehung") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

Mesh  = MP_CreateSphere(16) ; Und jetzt eine Kugel
Mesh2 = MP_CreateSphere(16)
Mesh3 = MP_CreateSphere(16)

If CreateImage(0, 255, 255) ; Etwas Farbe selber erzeugen
   MP_CreateImageColored(0,0,RGB($00,$F0,$00),RGB($00,$F0,$00),RGB($00,$00,$FF),RGB($00,$00,$ff)) ; 
   MP_EntitySetTexture (mesh, MP_ImageToTexture(0))
   MP_CreateImageColored(0,0,RGB($F0,$00,$00),RGB($F0,$00,$00),RGB($00,$FF,$FF),RGB($00,$FF,$FF)) ; 
   MP_EntitySetTexture (mesh2, MP_ImageToTexture(0))
   MP_CreateImageColored(0,0,RGB($00,$00,$F0),RGB($00,$00,$F0),RGB($FF,$00,$00),RGB($FF,$00,$00)) ; 
   MP_EntitySetTexture (mesh3, MP_ImageToTexture(0))
   FreeImage(0)
EndIf

MP_PositionEntity (Mesh,0,0,4) ; Position des Planeten
MP_RotateEntity(Mesh, 40, 40, 0) ; Achsneigung des Planeten

MP_PositionEntity (Mesh2,0,0,2) ; Position des Mondes
MP_ScaleEntity (Mesh2, 0.2, 0.2, 0.2 ) 
MP_RotateEntity(Mesh2, -40, 40, 0)  ; Achsneigung des Mondes

MP_PositionEntity (Mesh3,0,0,0.5) ; Position des Sateliten
MP_ScaleEntity (Mesh3, 0.1, 0.1, 0.1 ) 

MP_EntitySetParent(Mesh2,Mesh)
MP_EntitySetParent(Mesh3,Mesh2)


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    
    MP_TurnEntity (Mesh,0.5,0,0) ; dreh den Planeten
    MP_TurnEntity (Mesh2,2,0,0)  ; dreh den Mond
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 50
; FirstLine = 16
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_PlanetMond.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Parent_Free.pb
;// Erstellt am: 29.12.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple parent free function
;// Einfache Parent free Funktion
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart


MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Parent Kid with [free] Parameter") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

Mesh  = MP_CreateCube() ; Und jetzt eine Kugel
Mesh2 = MP_CreateRectangle(0.5,3,0.5)
Mesh3 = MP_CreateRectangle(0.5,3,0.5)

If CreateImage(0, 255, 255) ; Etwas Farbe selber erzeugen
   MP_CreateImageColored(0,0,RGB($00,$F0,$00),RGB($00,$F0,$00),RGB($00,$00,$FF),RGB($00,$00,$ff)) ; 
   MP_EntitySetTexture (mesh, MP_ImageToTexture(0))
   MP_CreateImageColored(0,0,RGB($F0,$00,$00),RGB($F0,$00,$00),RGB($00,$FF,$FF),RGB($00,$FF,$FF)) ; 
   MP_EntitySetTexture (mesh2, MP_ImageToTexture(0))
   MP_CreateImageColored(0,0,RGB($00,$00,$F0),RGB($00,$00,$F0),RGB($FF,$00,$00),RGB($FF,$00,$00)) ; 
   MP_EntitySetTexture (mesh3, MP_ImageToTexture(0))
   FreeImage(0)
EndIf

MP_PositionEntity (Mesh,0,0,6) ; Position des Planeten
MP_RotateEntity(Mesh, 40, 40, 0) ; Achsneigung des Planeten

MP_PositionEntity (Mesh2,0,-0.5,2) ; Position des Mondes
MP_ScaleEntity (Mesh2, 0.2, 0.2, 0.2 ) 
MP_RotateEntity(Mesh2, 90, 0, 0) ; Achsneigung des Planeten


MP_PositionEntity (Mesh3,0,0.5,2) ; Position des Mondes
MP_ScaleEntity (Mesh3, 0.2, 0.2, 0.2 ) 
MP_RotateEntity(Mesh3, 130, 40, 0) ; Achsneigung des Planeten

MP_EntitySetParent(Mesh2,Mesh,0) ; is the same like MP_EntitySetParent(Mesh2,Mesh)
MP_EntitySetParent(Mesh3,Mesh,1) ; Free function, Mesh looks in the same direction

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    
    MP_TurnEntity (Mesh,0.5,0,0) ; dreh den Planeten
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 19
; FirstLine = 5
; EnableAsm
; Executable = C:\MP_PlanetMond.exe
; SubSystem = dx9
; 雨ꚧ髮閲韩莞軫ꚗ黮閎럨ꊞꛫꚗ뛦ꚗ
; ꚧ髮薖蟨겚苩ꚗ髮閶韩뒊諫ꎗ雮ꆒꚧ
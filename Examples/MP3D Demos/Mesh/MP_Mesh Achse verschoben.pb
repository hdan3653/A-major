;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Mesh Achse verschoben.pb
;// Erstellt am: 20.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Axis of a cube is moved
;// Achse eines Würfels wird verschoben
;//
;// Der Mittelpunkt eines Mesh ist immer x,y,z = 0,0,0. Die Vertices, bzw. Eckpunkte kugelfömig um die Punkte 0,0,0 
;// verschoben. Die Eckunkte des Würfels sind also 
;// -0.5 , -0.5 , -0.5
;// -0.5, -0.5 , 0.5 
;// -0.5, 0.5 , 0.5
;// usw.
;// Man muss also die X und z Koordinate um 0.5 verschieben. Bei dem Beispiel könnt Ihr mal mit den Werten rumspielen...
;// 
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Mesh Achse wird verschoben") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
MP_PositionEntity (Mesh,0,0,5) ; Position des Würfels

MP_TranslateMesh (Mesh,0.5,0,0.5) ; Position des Würfels

; Der Befehl MP_PositionMesh ersetzt folgende Befehle 
;For n = 0 To MP_CountVertices(Mesh)-1 ; Anzahl der Vertices in dem Würfel
;    x.f = MP_VertexGetX (Mesh,n) ; X Wert auslesen
;    y.f = MP_VertexGetY (Mesh,n) ; Y Wert auslesen
;    z.f = MP_VertexGetZ (Mesh,n) ; Z Wert auslesen

;    MP_VertexSetX (Mesh,n, x + 0.5) ; Würfel X Achse um 0.5 verschoben ist daher 0 und andere Achse 1
;    MP_VertexSetY (Mesh,n, y )      ; 
;    MP_VertexSetZ (Mesh,n, z + 0.5) ; Würfel Z Achse um 0.5 verschoben ist daher 0 und andere Achse 1

;Next

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,1,0,0) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 34
; SubSystem = dx9
; DisableDebugger
; EnableCustomSubSystem
; Manual Parameter S=DX9
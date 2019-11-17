;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: 3D Wuerfel.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Simple 3D representation of a cube with six sides texture
;// Einfache 3D Darstellung eines Würfels mit 6 Texturseiten
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Erzeugt ein Würfel mit 6 Texturseiten") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel

;- Tausch die Textkoordinaten

MP_VertexSetU (Mesh, 0, 0.333) ; Erste Würfelseite
MP_VertexSetV (Mesh, 0, 0.5)
MP_VertexSetU (Mesh, 1, 0)
MP_VertexSetV (Mesh, 1, 0.5)
MP_VertexSetU (Mesh, 2, 0)
MP_VertexSetV (Mesh, 2, 0)
MP_VertexSetU (Mesh, 3, 0.333)
MP_VertexSetV (Mesh, 3, 0)
;
MP_VertexSetU (Mesh, 4, 0.333); Zweite Würfelseite
MP_VertexSetV (Mesh, 4, 0.5)
MP_VertexSetU (Mesh, 5, 0.333)
MP_VertexSetV (Mesh, 5, 0)
MP_VertexSetU (Mesh, 6, 0.666)
MP_VertexSetV (Mesh, 6, 0)
MP_VertexSetU (Mesh, 7, 0.666)
MP_VertexSetV (Mesh, 7, 0.5)

MP_VertexSetU (Mesh, 8, 0.666) ; Dritte Würfelseite
MP_VertexSetV (Mesh, 8, 0)
MP_VertexSetU (Mesh, 9, 1)
MP_VertexSetV (Mesh, 9, 0)
MP_VertexSetU (Mesh, 10, 1)
MP_VertexSetV (Mesh, 10, 0.5)
MP_VertexSetU (Mesh, 11, 0.666)
MP_VertexSetV (Mesh, 11, 0.5)

MP_VertexSetU (Mesh, 13, 0) ; Vierte Würfelseite
MP_VertexSetV (Mesh, 13, 0.5)
MP_VertexSetU (Mesh, 14, 0.333)
MP_VertexSetV (Mesh, 14, 0.5)
MP_VertexSetU (Mesh, 15, 0.333)
MP_VertexSetV (Mesh, 15, 1)
MP_VertexSetU (Mesh, 12, 0)
MP_VertexSetV (Mesh, 12, 1)

MP_VertexSetU (Mesh, 19, 0.333) ; Fünfte Würfelseite
MP_VertexSetV (Mesh, 19, 1)
MP_VertexSetU (Mesh, 16, 0.333)
MP_VertexSetV (Mesh, 16, 0.5)
MP_VertexSetU (Mesh, 17, 0.666)
MP_VertexSetV (Mesh, 17, 0.5)
MP_VertexSetU (Mesh, 18, 0.666)
MP_VertexSetV (Mesh, 18, 1)

MP_VertexSetU (Mesh, 20, 0.666) ; Sechste Würfelseite
MP_VertexSetV (Mesh, 20, 1)
MP_VertexSetU (Mesh, 21, 0.666)
MP_VertexSetV (Mesh, 21, 0.5)
MP_VertexSetU (Mesh, 22, 1)
MP_VertexSetV (Mesh, 22, 0.5)
MP_VertexSetU (Mesh, 23, 1)
MP_VertexSetV (Mesh, 23, 1)

If CreateImage(0,255+128, 255) ; Erzeuge 6 unterschiedliche Texturseiten 

    Font = LoadFont(#PB_Any, "Arial"  , 80) 
    StartDrawing(ImageOutput(0))

    Box(0, 0, 128, 128,RGB(255,0,0))
    Box(128, 0, 128, 128,RGB(0,255,0))
    Box(256, 0, 128, 128,RGB(0,0,255))
    
    Box(0, 128, 128, 128,RGB(255,255,0))
    Box(128, 128, 128, 128,RGB(255,0,255))
    Box(256, 128, 128, 128,RGB(0,255,255))

    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(40,8,"1",RGB(0,0,0))
    DrawText(168,8,"2",RGB(0,0,0))
    DrawText(296,8,"3",RGB(0,0,0))
    DrawText(40,136,"4",RGB(0,0,0))
    DrawText(168,136,"5",RGB(0,0,0))
    DrawText(296,136,"6",RGB(0,0,0))
    
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Texture = MP_ImageToTexture(0) ; Create Texture from image 

MP_EntitySetTexture (Mesh, Texture ) ; textur to mesh

MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.2,1,0.3) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 114
; FirstLine = 67
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem

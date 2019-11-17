;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: 3D Wuerfel.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 3D of two cubes with different UV coords
;// Einfache 3D Darstellung eines Würfels mit unterschiedlicher UV darstellung 
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D of two cubes with different UV coords") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel

Mesh2=MP_CreateCube() ; Und jetzt eine Würfel

;- Tausch die Texturkoordinaten

MP_VertexSetU (Mesh2, 16, 0)
MP_VertexSetV (Mesh2, 16, 0)
MP_VertexSetU (Mesh2, 17, 1)
MP_VertexSetV (Mesh2, 17, 0)
MP_VertexSetU (Mesh2, 18, 1)
MP_VertexSetV (Mesh2, 18, 1)
MP_VertexSetU (Mesh2, 19, 0)
MP_VertexSetV (Mesh2, 19, 1)

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
MP_EntitySetTexture (Mesh, Texture ) ; textur to mesh

MP_EntitySetTexture (Mesh2, Texture ) ; textur to mesh


MP_PositionEntity (Mesh,-1,0,5) ; Position des Würfels

MP_PositionEntity (Mesh2,1,0,5) ; Position des Würfels

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,1,0,0) 
    MP_TurnEntity (Mesh2,0,1,0) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 67
; FirstLine = 21
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem

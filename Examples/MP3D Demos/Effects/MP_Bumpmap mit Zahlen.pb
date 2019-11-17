;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: 3D Wuerfel.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Bumpmapdemo with numbers
;// Bumpmapdemo mit zahlen
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Kleine Bumpmapdemo mit Zahlen")

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
    Box(0, 0, 128, 128,RGB(255,0,0)); 1
    Box(12, 12, 104, 104,RGB(255,255,255)); 1
    Box(128, 0, 128, 128,RGB(0,255,0))
    Box(140, 12, 104, 104,RGB(255,255,255))
    Box(256, 0, 128, 128,RGB(0,0,255))
    Box(268, 12, 104, 104,RGB(255,255,255))
    Box(0, 128, 128, 128,RGB(255,255,0))
    Box(12, 140, 104, 104,RGB(255,255,255))
    Box(128, 128, 128, 128,RGB(255,0,255))
    Box(140, 140, 104, 104,RGB(255,255,255))
    Box(256, 128, 128, 128,RGB(0,255,255))
    Box(268, 140, 104, 104,RGB(255,255,255))
    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    FrontColor(RGB(255,0,0))
    DrawText(40,8,"1")
    FrontColor(RGB(0,255,0))
    DrawText(168,8,"2")
    FrontColor(RGB(0,0,255))
    DrawText(296,8,"3")
    FrontColor(RGB(255,255,0))
    DrawText(40,136,"4")
    FrontColor(RGB(255,0,255))
    DrawText(168,136,"5")
    FrontColor(RGB(0,255,255))
    DrawText(296,136,"6")
    StopDrawing() 
    
EndIf
x.f=0 : y.f=0 : z.f = -4 
MP_PositionEntity(camera,x.f,y.f,z.f)

Texture = MP_ImageToTexture(0) ; Create Texture from image 
TexturNormal = MP_CreateNormalMap(Texture, 4, 25) ; Erzeugt eine Normal Map aus der Textur  
;MP_SaveTexture("c:\test.jpg", TexturNormal, 1) ; -> Zeigt Normaldatei an  Bumpmap Datei 

MP_EntitySetTexture (Mesh, Texture ) ; textur to mesh
MP_EntitySetBumpmap (Mesh,TexturNormal)

MP_PositionEntity (Mesh,0,0,0) ; Position des Würfels

pitchi = 1
pitch = -60
yawi = -1
yaw = 60

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    
    pitch + (1 * pitchi) ; pitch geht hin und her von -60 nach + 60
    If pitch = 60
       pitchi = -1
    EndIf
    
    If pitch = -60
       pitchi = 1
    EndIf
    
    yaw + (1 * yawi) ; pitch geht hin und her von -60 nach + 60
    If yaw = 60
       yawi = -1
    EndIf
    
    If yaw = -60
       yawi = 1
    EndIf
    
    MP_BumpmapSetDest(pitch, yaw) 
    MP_TurnEntity (Mesh,0.2,1,0.3) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 116
; FirstLine = 110
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
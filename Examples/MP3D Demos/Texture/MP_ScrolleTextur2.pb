;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ScrolleTextur2.pb
;// Erstellt am: 12.3.2013
;// Update am  :
;// Author: Michael Paulwitz
;//
;// Info:
;// Textur Scrolling Demo
;// Textur Scrollen
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Vertex und Triangle Demo")

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(2) ; Es werde Licht


If CreateImage(0,32, 32) ; Erzeuge 6 unterschiedliche Texturseiten

    Font = LoadFont(#PB_Any, "Arial"  , 16)
    StartDrawing(ImageOutput(0))
    Box(0, 0, 16, 16,RGB(255,0,0))
    Box(0, 16, 16, 16,RGB(255,255,0))
    Box(16, 0, 16, 16,RGB(0,255,0))
    Box(16, 16, 16, 16,RGB(0,0,255))
    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(11,6,"5",RGB(0,0,0))
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
   
EndIf

Texture = MP_ImageToTexture(0) ; Create Texture from image
Texture2 = MP_ImageToTexture(0) ;
Texture3 = MP_ImageToTexture(0) ;
Texture4 = MP_ImageToTexture(0) ;

FreeImage(0)


; Mesh 1 mit StandardVertexen
Mesh1 = MP_CreateMesh() ; Erzeuge leeres Mesh
; Erstelle 2 x drei Eckpunkte mit UV Koordinaten Textur wird einfach gemacht
MP_AddVertex (Mesh1, 1, 1,0,0,1,0)
MP_AddVertex (Mesh1, 1,-1,0,0,1,1)
MP_AddVertex (Mesh1,-1, 1,0,0,0,0)
MP_AddVertex (Mesh1, 1,-1,0,0,1,1)
MP_AddVertex (Mesh1,-1, 1,0,0,0,0)
MP_AddVertex (Mesh1,-1,-1,0,0,0,1)

; Erstelle zwei Dreicke = 1 x Viereck
MP_AddTriangle (Mesh1, 0,1,2)
MP_AddTriangle (Mesh1, 4,3,5)

Mesh2 = MP_CopyEntity(Mesh1)
Mesh3 = MP_CopyEntity(Mesh1)
Mesh4 = MP_CopyEntity(Mesh1)

MP_EntitySetTexture (Mesh1, Texture2 )
MP_EntitySetTexture (Mesh2, Texture )
MP_EntitySetTexture (Mesh3, Texture4 )
MP_EntitySetTexture (Mesh4, Texture3 )

MP_PositionEntity (Mesh1,-1.5,-1.5,8) ; Position des Meshs
MP_PositionEntity (Mesh2,-1.5,1.5,8) ; Position des Meshs
MP_PositionEntity (Mesh3,1.5,-1.5,8) ; Position des Meshs
MP_PositionEntity (Mesh4,1.5,1.5,8) ; Position des Meshs

MP_AmbientSetLight(RGB(20,20,134))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
 
 
    ; Scroll methode 1
    MP_ScrollTexture(Texture, 1, 1 )
   
   
    ; Scroll methode 1
    x.f + 0.05
    If x > 1
       MP_ScrollTexture(Texture3, 1, 1 )
       x = 0
    EndIf   
   
    ; Scroll methode 3 over uv coords
     For n = 0 To 5
          MP_VertexSetU (Mesh1,n,MP_VertexGetU (Mesh1,n)+0.0014)
          MP_VertexSetV (Mesh1,n,MP_VertexGetV (Mesh1,n)+0.0014)
     Next
     
    ; Scroll methode as Joke over uv coords
     For n = 0 To 5
          MP_VertexSetU (Mesh3,n,Sin(MP_VertexGetU (Mesh1,n)+0.002)*2)
          MP_VertexSetV (Mesh3,n,Cos(MP_VertexGetV (Mesh1,n)+0.002)*2)
     Next
     
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 3
; EnableXP
; SubSystem = dx9
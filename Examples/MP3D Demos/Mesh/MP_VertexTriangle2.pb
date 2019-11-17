;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_VertexTriangle2.pb
;// Erstellt am: 14.7.2012
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Create Triangles 
;// Erzeugt Triangles
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Vertex und Triangle Demo 2") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(2) ; Es werde Licht

Mesh = MP_CreateMesh() ; Erzeuge leeres Mesh

If CreateImage(0,128, 128) ; Erzeuge 6 unterschiedliche Texturseiten 

    Font = LoadFont(#PB_Any, "Arial"  , 24) 
    StartDrawing(ImageOutput(0))
    Box(0, 0, 64, 64,RGB(255,0,0))
    Box(0, 64, 64, 64,RGB(255,255,0))
    Box(64, 0, 64, 64,RGB(0,255,0))
    Box(64, 64, 64, 64,RGB(0,0,255))
    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(20,45,"MP3D",RGB(0,0,0))
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Texture = MP_ImageToTexture(0) ; Create Texture from image 
MP_EntitySetTexture (Mesh, Texture )

; Create 0 Vertex for middle
MP_AddVertex (Mesh, 0, 0,0,0,0.5,0.5)

For n = 0 To 360 Step 20
  
  ; Create 18 Vertexe
  MP_AddVertex (Mesh, Sin (Radian(n)), Cos(Radian(n)),0,0,Sin (Radian(n))/2+0.5,-Cos(Radian(n))/2+0.5)
  
Next n  

MP_AddTriangle (Mesh, 0,1,18)
MP_PositionEntity (Mesh,0,0,3) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    count + 1
    
    If count > 60 ; easy counter
      count = 0
      count2 + 1
      If count2 < 18 ; add max 18 triangles
        MP_AddTriangle (Mesh, 0,count2,count2+1)
      EndIf
    EndIf  
    
    If  count2 > 18 ; change x,y position of vertex
      For n = 0 To 20
          MP_VertexSetX (Mesh,n,MP_VertexGetX (Mesh,n)+Sin(count2+n)/100)
          MP_VertexSetY (Mesh,n,MP_VertexGetY (Mesh,n)+Cos(count2+n)/100)
      Next
    EndIf
 
    MP_TurnEntity (Mesh,0,0,0.2) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.61 (Windows - x86)
; FirstLine = 13
; EnableXP
; SubSystem = dx9
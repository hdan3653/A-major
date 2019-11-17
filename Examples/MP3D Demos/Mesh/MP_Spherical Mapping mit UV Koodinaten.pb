;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: Bewegende Objekte2.pb
;// Created On: 26.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Objekte mit UV Koordinaten versehen
;//
;// http://www.mvps.org/directx/articles/spheremap.htm
;//
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart


MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "2 Methodics for Spherical Mapping with x,y,z Coords") ; So soll es heissen

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

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

;Create Sphere
Sphere1 = MP_CreateSphere(12)
Sphere2 = MP_CreateSphere(12)
Teapot1 = MP_CreateTeapot()
Teapot2 = MP_CreateTeapot() ; Yes teapot not Sphere

MP_PositionEntity (Sphere1,-1.5,1.3,6 )
MP_PositionEntity (Sphere2,1.5,1.3,6 )
MP_PositionEntity (Teapot1,-1.5,-1.3,6 )
MP_PositionEntity (Teapot2,1.5,-1.3,6 )

;- Create Sphere1 Methodic 1, UV coordinate is calculated from the XY coordinate, with ASin   
For n = 0 To MP_CountVertices(Sphere1)-1
        x.f = MP_VertexGetX (Sphere1,n)
        y.f = MP_VertexGetY (Sphere1,n)
        MP_VertexSetU (Sphere1,n, ASin(x)/#PI+0.5)  ; Alternate fast methodic = x*0.5+0.5 
        MP_VertexSetV (Sphere1,n, ASin(-y)/#PI+0.5) ; Alternate fast methodic = -y*0.5+0.5
Next

;- Sphere2 with Methodic 2, UV coordinate is calculated with from the XY coordinate  
For n = 0 To MP_CountVertices(Sphere2)-1

        x.f = MP_VertexGetX (Sphere2,n)
        y.f = MP_VertexGetY (Sphere2,n)
        z.f = MP_VertexGetZ (Sphere2,n)
 
       ; MP_VertexSetU (Sphere2,n, MP_Atan2(x,z)/360)
       ; MP_VertexSetV (Sphere2,n, ASin(-y)/#PI+0.5)

        MP_VertexSetU (Sphere2,n, MP_Atan2(x,z)/360)
        MP_VertexSetV (Sphere2,n, -y*0.5+0.5)
        
Next

;- Create Teapot and make you own uv Mapping
For n = 0 To MP_CountVertices(Teapot1)-1

        x.f = MP_VertexGetX (Teapot1,n)
        y.f = MP_VertexGetY (Teapot1,n)
        z.f = MP_VertexGetZ (Teapot1,n)
 
        MP_VertexSetU (Teapot1,n, ASin(x)/#PI+0.5) 
        MP_VertexSetV (Teapot1,n, ASin(-y)/#PI+0.5)
        
Next

;- Create Teapot and make you own uv Mapping
For n = 0 To MP_CountVertices(Teapot2)-1

        x.f = MP_VertexGetX (Teapot2,n)
        y.f = MP_VertexGetY (Teapot2,n)
        z.f = MP_VertexGetZ (Teapot2,n)
 
        MP_VertexSetU (Teapot2,n, MP_Atan2(x,z)/360) 
        MP_VertexSetV (Teapot2,n, ASin(-y)/#PI+0.5)

Next

Texture = MP_ImageToTexture(0) ; Create Texture from image 

MP_EntitySetTexture (Sphere1, Texture ) ; textur to mesh
MP_EntitySetTexture (Sphere2, Texture ) ; textur to mesh
MP_EntitySetTexture (Teapot1, Texture ) ; textur to mesh
MP_EntitySetTexture (Teapot2, Texture ) ; textur to mesh

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen
  
    MP_TurnEntity (Sphere1,1,0,0.1) ; Moving Sphere
    MP_DrawText (10,10,"method 1"+Chr(10)+"Sphere") 

    MP_TurnEntity (Sphere2,1,0,0.1) ; Moving Sphere
    MP_DrawText (320,10,"method 2"+Chr(10)+"Sphere") 

    MP_TurnEntity (Teapot1,1,0,0.1) ; Moving Sphere
    MP_DrawText (10,240,"method 1 used on not Sphere Objekt") 

    MP_TurnEntity (Teapot2,1,0,0.1) ; Moving Sphere
    MP_DrawText (320,240,"method 2 used on not Sphere Objekt") 
    
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

End

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 108
; FirstLine = 74
; UseIcon = ..\mp3d.ico
; Executable = C:\Mapping2.exe
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem

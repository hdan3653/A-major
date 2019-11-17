;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: Surface erzeugen.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple 3D representation of a cube with image as background
;// Einfache 3D Darstellung eines Würfels mit Image als Hintergrund
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D Darstellung eine Würfels und Hintergrund ein Image") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel


;Surface = MP_LoadSurface("c:\z\comet.jpg") ; Mann kann auch eine Grafik laden

;- 

Width=255
Height=255 

If CreateImage(0, Width, Height)

    Width=255
    Height=255 

    x = Width/2
    y = Height/2

    StartDrawing(ImageOutput(0))

    For Radius = Height/2 To 10 Step -10
       Circle(x, y, radius ,RGB(Random(255),Random(255),Random(255)))
    Next
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Surface = MP_ImageToSurface(0,0) ; Image = 0, 

;-

MP_SurfaceSetPosition(Surface,0,0,1)

MP_SurfaceSrcRect(Surface,10, 10, 120, 120)

MP_SurfaceDestRect(Surface,0, 0, 640, 480)
 
MP_PositionEntity (Mesh,0,0,5) ; Position des Würfels

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
   
    MP_DrawText (10,10,Str(MP_FPS()))
    MP_TurnEntity (Mesh,0.1,0.1,0.1) 


    MP_RenderWorld() ; Erstelle die Welt

    MP_Flip () ; Stelle Sie dar

Wend



























; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 63
; FirstLine = 21
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

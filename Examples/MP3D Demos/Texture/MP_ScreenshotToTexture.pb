;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ScreenshottoTexture.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Easy Screenshot Render to texture
;// Einfacher Screenshot zur Textur rendern
;//
;//
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Screenshotdemo") 


cam=MP_CreateCamera() ; Kamera erstellen
MP_CreateLight(1) ; Es werde Licht

Max = 40 ; Was der Rechner kann = ?

Dim Meshs(Max) 
Dim x(Max)
Dim y(Max)
Dim z(Max)

For n = 0 To Max
    Meshs (n) = MP_CreateSphere(10)
    MP_PositionEntity (Meshs(n),10-Random(20),10-Random(20),24+Random(40))
    MP_EntitySetColor(meshs(n), RGB(Random(255),Random(255),Random(255))) 
Next n

MP_RenderWorld() ; Erstelle die Welt

time = MP_ElapsedMicroseconds() 

Texture = MP_ScreenshotToTexture() 

Debug MP_ElapsedMicroseconds()  - time

For n = 0 To Max
    MP_FreeEntity(Meshs (n) )
Next n

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
MP_EntitySetTexture (Mesh, Texture )

MP_PositionEntity (Mesh,0,0,2) ; Position des Würfels

MP_AmbientSetLight (RGB(100,100,100))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

   MP_TurnEntity (Mesh,0.1,0.1,0.1) 
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 40
; FirstLine = 6
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_ScreenshottoTextur.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_LichtBewegung.pb
;// Created On: 14.1.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// litte light demo with moving light
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle (0,"litte light demo with moving light")

Cam=MP_CreateCamera() ; Kamera erstellen
Light = MP_CreateLight(2) ; Es werde Licht
Light2 = MP_CreateLight(2) ; Es werde Licht
Light3 = MP_CreateLight(2) ; Es werde Licht

MP_LightSetColor(Light,RGB(255,0,0)) 
MP_LightSetColor(Light2,RGB(0,255,0)) 
MP_LightSetColor(Light3,RGB(0,0,255)) 

If CreateImage(0, 255, 255) 

    StartDrawing(ImageOutput(0))
    Box (0,0,255,255,RGB(255,0,0)) ; Rotes Image
    StopDrawing() 
    
EndIf

If CreateImage(1, 255, 255) 

    StartDrawing(ImageOutput(1))
    Box (0,0,255,255,RGB(0,255,0)) ; Grünes Image
    StopDrawing() 
    
EndIf

If CreateImage(2, 255, 255) 

    StartDrawing(ImageOutput(2))
    Box (0,0,255,255,RGB(0,0,255)) ; Blaues Image
    StopDrawing() 
    
EndIf

Mesh=MP_CreateSphere(10) ; Und jetzt eine Kugel
MP_ScaleEntity(Mesh, 0.4, 0.4, 0.4) 
Textur1 = MP_ImageToTexture(0) ; Create Texture from image 
MP_EntitySetTexture (Mesh, Textur1 ) ; textur to mesh

Mesh2=MP_CreateSphere(10) ; Und jetzt eine Kugel
MP_ScaleEntity(Mesh2, 0.4, 0.4, 0.4) 
Textur2 = MP_ImageToTexture(1) ; Create Texture from image 
MP_EntitySetTexture (Mesh2, Textur2 ) ; textur to mesh

Mesh3=MP_CreateSphere(10) ; Und jetzt eine Kugel
MP_ScaleEntity(Mesh3, 0.4, 0.4, 0.4) 
Textur3 = MP_ImageToTexture(2) ; Create Texture from image 
MP_EntitySetTexture (Mesh3, Textur3 ) ; textur to mesh

Max = 15 ; Was der Rechner kann = ?

Dim Mesh(Max) 
Dim x(Max)
Dim y(Max)
Dim z(Max)

For n = 0 To Max

    Mesh (n) = MP_CreateSphere(10)
    MP_PositionEntity (Mesh(n),10-Random(20),10-Random(20),24+Random(40))
    
Next n

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    x.f + 0.02
    MP_PositionEntity (Light,Cos(x)*15,Sin(x)*15,44) ; Position des Würfels
    MP_PositionEntity (Mesh,Cos(x)*15,Sin(x)*15,44) ; Position des Würfels
    MP_PositionEntity (Light2,Cos(x+2)*15,Sin(x+2)*15,44) ; Position des Würfels
    MP_PositionEntity (Mesh2,Cos(x+2)*15,Sin(x+2)*15,44) ; Position des Würfels
    MP_PositionEntity (Light3,Cos(x+4)*15,Sin(x+4)*15,44) ; Position des Würfels
    MP_PositionEntity (Mesh3,Cos(x+4)*15,Sin(x+4)*15,44) ; Position des Würfels

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

 Wend
  

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 95
; FirstLine = 48
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
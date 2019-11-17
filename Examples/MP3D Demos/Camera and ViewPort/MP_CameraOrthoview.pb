
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_CameraOrthoview.pb
;// Erstellt am: 15.5.2013
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Physic with different Meshs
;// Physik mit unterschiedlichen Meshs
;//
;//
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,240,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "2 Cameras Ortho View") ; Setzt einen Fensternamen

camera1=MP_CreateCamera() ; Kamera erstellen
camera2=MP_CreateCamera(0.22) ; Kamera erstellen (Orthoview)

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt ein TeaPot

MP_PositionEntity(camera1,0,0,-3)
MP_PositionEntity(camera2,0,0,-3)

BackColor1 = RGB(0,0,123)
BackColor2 = RGB(0,66,123)

MP_CameraSetPerspective(camera1,45,1.33)
MP_CameraSetPerspective(camera2,0.22,1.33)


camera5 = MP_CameraViewPort (camera1,0,0,640/2,240,BackColor1)
camera6 = MP_CameraViewPort (camera2,640/2,0,640/2,240,BackColor2)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld () ; Hier gehts los
    MP_Flip ()   

Wend
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 28
; EnableXP
; SubSystem = dx9
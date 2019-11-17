;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_4_CameraViewports.pb
;// Created On: 2.8.2010
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für 4 MP_CameraViewports
;// 
;////////////////////////////////////////////////////////////////


;XIncludeFile "C:\Program Files\PureBasic\Examples\DirectX For PB4\Source\MP3D_Library.pb"


MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "4 CameraViewPorts") ; Setzt einen Fensternamen

camera1=MP_CreateCamera() ; Kamera erstellen
camera2=MP_CreateCamera() ; Kamera erstellen
camera3=MP_CreateCamera() ; Kamera erstellen
camera4=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateTeapot() ; Und jetzt ein TeaPot

MP_PositionEntity(camera1,0,0,-3)

MP_PositionEntity(camera2,-3,0,-3)
MP_EntityLookAt(Camera2,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))

MP_PositionEntity(camera3,-3,0,0)
MP_EntityLookAt(Camera3,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))

MP_PositionEntity(camera4,0,-3,-3)
MP_EntityLookAt(Camera4,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))

MP_CameraSetRange(camera1, 0.1, 100) ; <- Hier den Wert von 1 bis 2 (1.1 , 1.2 etc testweise verändern)... 
MP_CameraSetRange(camera2, 0.1, 100) 
MP_CameraSetRange(camera3, 0.1, 100) 
MP_CameraSetRange(camera4, 0.1, 100) 

BackColor1 = RGB(0,0,123)
BackColor2 = RGB(0,66,123)
BackColor3 = RGB(66,0,123)
BackColor4 = RGB(66,66,123)

MP_CameraSetPerspective(camera1,45,1)
MP_CameraSetPerspective(camera2,45,1)
MP_CameraSetPerspective(camera3,45,1)
MP_CameraSetPerspective(camera4,45,1)

camera5 = MP_CameraViewPort (camera1,0,0,640/2,480/2,BackColor1)
camera6 = MP_CameraViewPort (camera2,640/2,0,640/2,480/2,BackColor2)
camera7 = MP_CameraViewPort (camera3,0,480/2,640/2,480/2,BackColor3)
camera8 = MP_CameraViewPort (camera4,640/2,480/2,640/2,480/2,BackColor4)




While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld () ; Hier gehts los
    
    MP_Flip ()   

Wend

; IDE Options = PureBasic 5.11 (Windows - x64)
; CursorPosition = 58
; FirstLine = 14
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_TwoCameras_SetRenderCallback.pb
;// Erstellt am: 10.12.2011
;// Update am  :
;// Author: Dario
;//
;// Info:
;// Example for MP_SetRenderWorldCallback() to turn the same entity around different angles
;// implied by currently rendered camera
;//
;//
;////////////////////////////////////////////////////////////////

EnableExplicit

Global camera1, camera2, Cube1, Cube2
Define light

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "camera callback") ; Setzt einen Fensternamen

camera1 = MP_CreateCamera() ; Kamera erstellen
camera2 = MP_CreateCamera() ; Kamera erstellen
light   = MP_CreateLight(1) ; Es werde Licht
Cube1   = MP_CreateCube()     ; Würfel erstellen
Cube2   = MP_CreateCube()     ; Würfel erstellen

MP_PositionEntity(Cube1,-1,0,0)
MP_PositionEntity(Cube2, 1,0,0)

MP_CameraViewPort(camera1,0,  0,640,240) ; Kamera zeichenbereich erstellen
MP_CameraViewPort(camera2,0,240,640,240) ; Kamera zeichenbereich erstellen
MP_CameraSetPerspective(camera1, 45, 640/240) ; Kamera Perspektive anpassen (sonst verzehrt)
MP_CameraSetPerspective(camera2, 45, 640/240) ; Kamera Perspektive anpassen (sonst verzehrt)

MP_PositionEntity(camera1,0,0,-5) ; Kamera positionieren
MP_PositionEntity(camera2,0,0,-5) ; Kamera positionieren

Procedure cameraCallback(*camera,*viewport)
 
  Static angle.f
 
  Select *camera
    Case camera1
      MP_RotateEntity(Cube1,angle, 0,0)
      MP_RotateEntity(Cube2,-angle,0,0)
    Case camera2
      MP_RotateEntity(Cube1,0,angle, 0)
      MP_RotateEntity(Cube2,0,-angle,0)
  EndSelect
 
  angle + 0.5
 
EndProcedure

MP_SetRenderWorldCallback(@cameraCallback())

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_RenderWorld()
    MP_Flip ()

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 38
; Folding = -
; EnableXP
; SubSystem = dx9
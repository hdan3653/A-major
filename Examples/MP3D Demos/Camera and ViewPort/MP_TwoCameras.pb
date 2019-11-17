;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_TwoCameras.pb
;// Erstellt am: 21.08.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Change the View of the camers 
;// Ändert die Anzeigekamera
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart


#Modus = 1

; 0 = is the normnal methode to change the camera in renderworld
; 1 = if you want to render directly the canera with renderfunctions 

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "2 x camera, to change push 1 or 2") ; Setzt einen Fensternamen

camera1=MP_CreateCamera() ; Kamera erstellen

camera2=MP_CreateCamera() ; Kamera erstellen
MP_PositionEntity(camera2,5,0,0)
MP_EntityLookAt(camera2,-1.5,0,5)

light=MP_CreateLight(1) ; Es werde Licht

Mesh1=MP_CreateCube() ; Und jetzt eine Würfel
Mesh2=MP_CreateCube() ; Und jetzt eine Würfel

MP_PositionEntity (Mesh1,-1.5,0,5) ; Position des Würfels
MP_PositionEntity (Mesh2,1.5,0,5) ; Position des Würfels

BackColor = RGB(123,0,0)

Cam = camera2

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh1,0.1,0.1,0.1) ; dreh den Würfel
    MP_TurnEntity (Mesh2,-0.1,0.2,0.1) ; dreh den Würfel
    
    CompilerIf #Modus = 0
      
      If MP_KeyDown(#PB_Key_1)=1 : MP_MoveCamera (camera1,0,0,0) : EndIf 
      If MP_KeyDown(#PB_Key_2)=1 : MP_MoveCamera (camera2,0,0,0) : EndIf 
    
      MP_RenderWorld()
    
    CompilerElse

      If MP_KeyDown(#PB_Key_1)=1 : Cam = camera1 : EndIf 
      If MP_KeyDown(#PB_Key_2)=1 : Cam = camera2 : EndIf 
    
      MP_RenderBegin(cam) ;

      MP_Rendermesh()

      MP_RenderEnd() 

    CompilerEndIf

    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 30
; FirstLine = 24
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
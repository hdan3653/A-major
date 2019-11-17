
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Physik_ConstraintCreatBall.pb
;// Erstellt am: 11.8.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Physic with Rope
;// Physik mit SeilFunktion 
;//
;//
;////////////////////////////////////////////////////////////////



MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Bewege das Seil mit den Cursor Tasten, move Rope with Cursor Keys ") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht
MP_PhysicInit()

MP_PositionEntity (camera,0,-2,-16)

Dim NewMesh(10)

  NewMesh(0)=MP_CreateCube() ; Und jetzt eine Würfel
  MP_PositionEntity (NewMesh(0),0,3,0) ; Position des Würfels
  MP_EntityPhysicBody(NewMesh(0), 2, 0)

For n = 1 To 10

  NewMesh(n)=MP_CreateRectangle(0.3,0.8,0.3) ; Und jetzt eine Würfel
  MP_PositionEntity (NewMesh(n),0,n * -1 + 2.8,0) ; Position des Würfels
  MP_EntityPhysicBody(NewMesh(n), 2, 5)
;  MP_ConstraintCreateBall (NewMesh(n),0,0,0,1,1,0,n * -1 + 2.8,0,NewMesh(n-1))
  MP_ConstraintCreateBall (NewMesh(n),0,0,0,2,2,0,0,0,NewMesh(n-1))

Next n

y.f = 3
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  
    If MP_KeyDown(#PB_Key_Left)
      x.f-0.1
      MP_PositionEntity (NewMesh(0),x.f,y.f,z.f)
    EndIf
  
    If MP_KeyDown(#PB_Key_Right)
      x.f+0.1
      MP_PositionEntity (NewMesh(0),x.f,y.f,z.f)
    EndIf
  
    If MP_KeyDown(#PB_Key_Up)
      y.f-0.1
      MP_PositionEntity (NewMesh(0),x.f,y.f,z.f)
    EndIf
  
    If MP_KeyDown(#PB_Key_Down)
      y.f+0.1
      MP_PositionEntity (NewMesh(0),x.f,y.f,z.f)
    EndIf

    MP_TurnEntity (NewMesh(0),0.1,0.1,0.1) ; dreh den Würfel
    MP_EntitySetPhysicMatrix(NewMesh(0))


    MP_PhysicUpdate()
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend
  
MP_PhysicEnd()


; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 40
; FirstLine = 18
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
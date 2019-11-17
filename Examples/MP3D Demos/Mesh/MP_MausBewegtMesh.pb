;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_MausBewegtMesh.pb
;// Erstellt am: 24.6.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple movement of a mesh With mouse
;// Einfache Bewegung eines Meshs mit Maus
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D Meshdemo, End with Esc, right mouse move cube , mouse wheel distance") 

camera=MP_CreateCamera() ; Kamera erstellen
MP_PositionEntity(Camera, 0, 0, -5) 

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel

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
  
    StopDrawing() ; 
    
EndIf

Texture = MP_ImageToTexture(0) ; Create Texture from image 

MP_EntitySetTexture (Mesh, Texture ) ; textur to mesh

MP_UseCursor(0) ; Maussymbol weg 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

          MP_MouseInWindow()

        ;- Hier kommt ein reine Mesh Maussteuerung
                
          RotX = 0 : RotY = 0
          MouseX = -MP_MouseDeltaX()/5
          MouseY = -MP_MouseDeltaY()/5   

          If MP_MouseButtonDown(1)

            RotX = MouseX
            RotY = MouseY
            MouseX = 0
            MouseY = 0
          EndIf
         
          If MP_MouseDeltaWheel() > 0
             KeyY.f = -0.6
          ElseIf  MP_MouseDeltaWheel() <0 
             KeyY.f =  0.6
          Else
             KeyY.f = 0
          EndIf
         
        ;- Ende der Maussteuerung

        MP_TurnEntity(Mesh, RotY, RotX, RollZ) 
        MP_TurnEntity(Camera, MouseY/3,-MouseX/3,0)
        MP_MoveEntity(Camera, KeyX, 0, KeyY)




    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 52
; FirstLine = 33
; EnableXP
; Executable = C:\3d_Meshtest.exe
; SubSystem = dx9
; DisableDebugger
; EnableCustomSubSystem
; Manual Parameter S=DX9
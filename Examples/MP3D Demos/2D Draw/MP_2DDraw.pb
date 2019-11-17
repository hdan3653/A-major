;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Demo Programs
;// Dateiname: MP_2DDraw.pb
;// Erstellt am: 28.9.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple Demo of 2D circle, box and line commands
;// Einfacher 2D Test von Kreisen, Boxen und LInien Funktion
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Create ein Window with 3D Function #Window = 0
SetWindowTitle(0, "2D Command Test") ; Name of Window

camera=MP_CreateCamera() ; Create camera
light=MP_CreateLight(0) ; Light on

Mesh=MP_CreateTeapot() ; Create TeaPot
MP_PositionEntity(camera,0,0,-4)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  
  For n = 0 To 10
    
      MP_Circle( MP_RandomInt(100, 540), MP_RandomInt(100, 380), Random(100), Random($FFFFFF),Random(1)) ; Circle
      MP_Box( MP_RandomInt(100, 540), MP_RandomInt(100, 380), Random(100), Random(100), Random($FFFFFF),Random(1)) ; Box 
      MP_LineXY( MP_RandomInt(100, 540), MP_RandomInt(100, 380), MP_RandomInt(100, 540), MP_RandomInt(100, 380),Random($FFFFFF)) ; Line
    
  Next  

    MP_DrawText (290,232,"FPS = "+Str(MP_FPS())) ; Have i the normal FPS?
    
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; Turn the Teapot
    MP_RenderWorld () ; Render World yeh go on
    MP_Flip ()   

Wend
; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 31
; EnableXP
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
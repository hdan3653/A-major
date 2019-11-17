;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ChangeViewPort.pb
;// Erstellt am: 07.03.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Verändert ein ViewPort
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,2) ; Erstelle ein 3D WindowsFenster mit #Window = 0
SetWindowTitle(0, "Hier passiert nicht viel") ; So soll es heissen

x = 10 : y = 10 : xw = 10 : yw = 10

camera=MP_CreateCamera()
light=MP_CreateLight(1)
teapot = MP_CreateTeapot() 

MP_EntitySetZ (teapot , 8)

While Not WindowEvent() = #PB_Event_CloseWindow; Oben rechts schliessen wählen 
 
    If xw < 460 ; Mache langsam das 3D Fenster grösser
       xw + 1
       yw + 1
       MP_Viewport(x,y,xw,yw) 
    EndIf

    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 25
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

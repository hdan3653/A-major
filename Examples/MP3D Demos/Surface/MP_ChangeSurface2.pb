;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ChangeSurface2.pb
;// Erstellt am: 4.7.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Verändere das Surface für den Hintergrund
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Create Windows, #Window = 0
SetWindowTitle(0, "Change Pixel of Background") 

MP_SetAntialiasing(1)

MP_VSync(0) 

camera=MP_CreateCamera() ; Create Camera
light=MP_CreateLight(1) ; Create light

Surface  = MP_CreateSurface(640,480) ; Make a empty Surface 

MP_SurfaceSetPosition(Surface,0,0,1) ; Start Surface on Position 0,0

timer = MP_ElapsedMicroseconds() 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

  
    z.f + 0.0005 
    For n = 1 To 1000
      x = Random(639)
      y = Random(479)
      Color = RGB(128+Cos(x/800+z*#PI*2/3)*127, 128+Cos(y/600+z*#PI*4/3)*127, 128+Cos((x-y)/(800+600)+z*#PI*2)*127)
      MP_SurfaceSetPixel(Surface,x,y,Color)  
      
    Next    
    
    MP_DrawText (10,10,"FPS = "+Str(MP_FPS())) ; Have i the normal FPS?

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 32
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
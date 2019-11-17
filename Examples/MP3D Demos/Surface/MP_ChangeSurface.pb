;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ChangeSurface.pb
;// Erstellt am: 4.7.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Modify the Surface For the background
;// Verändere das Surface für den Hintergrund
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Create Windows, #Window = 0
SetWindowTitle(0, "Change Pixel of scrolling Background") 

MP_VSync(0)

camera=MP_CreateCamera() ; Create Camera
light=MP_CreateLight(1) ; Create light

Surface  = MP_CreateSurface(640,480) ; Make a empty Surface 

MP_SurfaceSetPosition(Surface,0,0,1) ; Start Surface on Position 0,0

timer = MP_ElapsedMicroseconds() 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    If MP_ElapsedMicroseconds() > timer + 2500 ; mache alle 2,5 ms eine Reihe fertig
      
      timer = MP_ElapsedMicroseconds()
      
      For n = 0 To 479
       
        MP_SurfaceSetPixel(Surface, 0, n , MP_ARGB(Random(255),Random(255),Random(255),Random(255)))  
       
      Next
      
      MP_ScrollSurface(Surface, 0, -1 ) ; Scroll the Surface Image 
  
    EndIf
    
    MP_DrawText (10,10,Str(MP_FPS())) ; Have i the normal FPS?

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.61 (Windows - x64)
; CursorPosition = 26
; UseIcon = ..\mp3d.ico
; Executable = C:\Scrollen2.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
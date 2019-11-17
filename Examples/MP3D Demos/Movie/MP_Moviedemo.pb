;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Moviedemo.pb
;// Created On: 4.4.2013
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Moviedemo
;// 
;////////////////////////////////////////////////////////////////


avifile.s = OpenFileRequester ( "AVI File auswählen", "", "Video as Avi|*.avi", 0 )
If avifile = ""
  MessageRequester("avifile", "no avifile found")
  End
EndIf  

; Normal Wiondows
MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Movie") ; Setzt einen Fensternamen


camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel

MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels


Movie = MP_OpenMovie (avifile)

Texture = MP_CreateTexture(0,0)

Sprite = MP_SpriteFromTexture(Texture)

MP_EntitySetTexture (Mesh, Texture)

max = MP_MovieNumFrames (  Movie )

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_RotateSprite(Sprite, x*1.5)
    MP_DrawSprite  (Sprite, 100, 100, x/2)
      
    x+1
    
    If x = 300
      x=0
    EndIf
  
    Frame.f + 0.5
    If Frame > Max : Frame = 0 : EndIf
    
    MP_MovieToTexture (  Movie, Texture, Frame )
    
    MP_DrawText (10,10,"FPS: "+Str(MP_FPS ()))
    
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
    
Wend

MP_CloseMovie(  Movie )


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 36
; FirstLine = 24
; EnableXP
; Executable = C:\MP_Moviedemo.exe
; SubSystem = dx9
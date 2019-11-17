;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_MoviePlayer.pb
;// Erstellt am: 06.04.2013
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Plays Movies on a cube
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D with Video") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine WürfelMesh2=MP_CreateCube() ; Und jetzt eine Würfel

MP_PositionEntity (Mesh,0,0,2) ; Position des Würfels

avifile.s = OpenFileRequester ( "AVI File auswählen", "", "Video|*.avi", 0 ) 

Movie =  MP_OpenMovie(avifile)

Texture = MP_CreateTexture(0,0)

MP_EntitySetTexture (Mesh, Texture)

max = MP_MovieNumFrames (  Movie ) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    Frame.f + 0.5
    If Frame > Max : Frame = 0 : EndIf
    
    MP_MovieToTexture (  Movie, Texture, Frame ) 
    
    If MP_KeyHit(#PB_Key_Space) 
      avifile.s = OpenFileRequester ( "AVI File auswählen", "", "Video|*.avi", 0 )
      MP_CloseMovie(  Movie ) 
      Movie = MP_OpenMovie (avifile)
    EndIf
    
    MP_DrawText (10,10,"FPS: "+Str(MP_FPS ()))
    
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
    
Wend

MP_CloseMovie(  Movie ) 
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 46
; FirstLine = 9
; EnableXP
; SubSystem = dx9
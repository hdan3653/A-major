;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_WriteMiplevelTextur.pb
;// Erstellt am: 24.1.2012
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// write texture on Miplevel 0 of texture 
;// schreibt eine Farbe auf den Miplevel 0 der textur
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D Darstellung eine Würfels") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels


Texture =  MP_LoadTexture(#PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp")

Debug MP_TextureGetHeight (texture)


MP_EntitySetTexture (Mesh, Texture) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    For M=20 To 108
      For N=20 To 108
        
        If n> 88 Or n < 40 
            MP_TextureSetPixel(Texture,m,n,MP_ARGB(0,m*2,n*2,m+n))
        EndIf
        If m> 88 Or m < 40 
            MP_TextureSetPixel(Texture,m,n,MP_ARGB(0,m*2,n*2,m+n))
        EndIf
        
      Next
    Next
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 3
; SubSystem = dx9
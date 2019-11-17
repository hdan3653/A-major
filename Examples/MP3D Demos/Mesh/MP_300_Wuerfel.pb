;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_300_Wuerfel.pb
;// Created On: 19.4.2008
;// Updated On: 3.5.2008
;// Author: Michael Paulwitz
;//
;// Create 300 cubes
;// Erzeuge 300 W�rfel
;//
;////////////////////////////////////////////////////////////////


;- Init

MP_Graphics3D (640,480,0,2)

camera=MP_CreateCamera()

light=MP_CreateLight(1)

#Max = 300

Dim wuerfel(#Max) 
Dim x(#Max)
Dim y(#Max)
Dim z(#Max)


For n = 0 To #Max

    wuerfel (n) = MP_CreateCube()

    MP_EntitySetColor (wuerfel (n),MP_ARGB(Random(255),Random(255),Random(255),Random(255)))

    MP_PositionEntity (wuerfel(n),10-Random(20),10-Random(20),10+Random(40))
    
    x(n) = Random (20)/10
    y(n) = Random (20)/10
    z(n) = Random (20)/10
    
;    MP_MeshSetAlpha (wuerfel(n),1)
;    MP_MeshSetAlpha (wuerfel(n),2)
    
        
Next n


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen

    For n = 0 To #Max
       MP_TurnEntity (wuerfel (n),x(n),y(n),z(n))
    Next n

;    MP_MeshAlphaSort()

    MP_RenderWorld ()
    MP_Flip ()

Wend


; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 32
; UseIcon = ..\mp3d.ico
; Executable = C:\Temp\Cubes_with_mp3d_lib.exe
; SubSystem = dx9
; 湅扡敬畃瑳浯畓卢獹整m慍畮污倠牡浡瑥牥匠䐽㥘
; 湡慵⁬慐慲敭整⁲㵓塄9
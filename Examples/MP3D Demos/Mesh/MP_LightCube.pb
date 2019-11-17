;////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_LightCube.pb
;// Erstellt am: 3.11.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Zeigt wie man einen texturierten Würfel Lichtabhängig macht
;// Schoch light effect on texture Cube
;//
;////////////////////////////////////////////////////////////////
       
       
       
MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Rotiere Textur auf Würfel") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(2) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
Mesh2=MP_CreateCube() ; Und jetzt eine Würfel

MP_PositionEntity (Mesh,-1,0,4) ; Position des Würfels
MP_PositionEntity (Mesh2,1,0,4) ; Position des Würfels


; Hier einfach mal die Textur remarken um den Unterschied zum Textures und Untextured Lightsourcing zu sehen
Texture =  MP_LoadTexture(#PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp") : MP_EntitySetTexture (Mesh, Texture) 
   MP_MaterialDiffuseColor (Texture,255,128,128,128)
   MP_MaterialAmbientColor (Texture, 255, 155 , 255, 255) ; 
   MP_MaterialEmissiveColor (Texture,155,15,25,25) ; 
   MP_MaterialSpecularColor (Texture, 255, 255 ,255, 255,20) ;
   
MP_AmbientSetLight(RGB(55,34,167)) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    Angle.f + 0.5
    MP_RotateTexture (Texture , Angle)

    MP_TurnEntity (Mesh,0.3,0.4,0.5) ; dreh den Würfel
    MP_TurnEntity (Mesh2,0.3,0.4,0.5) ; dreh den Würfel
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 39
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

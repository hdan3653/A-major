
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_CubeInCube.pb
;// Erstellt am: 28.02.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einfache Darstellung von 4 Würfeln in Würfeln
;// Show 4 cubes in cubes with RenderToTexture
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3D (800,600,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "4 Cubes in Cubes with MP_RenderToTexture") ; Setzt einen Fensternamen

Texture = MP_CreateBackBufferTexture() 
MP_MaterialEmissiveColor (Texture,155,15,25,25)
MP_SetRenderToTexture (Texture,1)

Texture2 = MP_CreateBackBufferTexture() 
MP_MaterialEmissiveColor (Texture2,155,15,25,25)
MP_SetRenderToTexture (Texture2,1)

Texture3 = MP_CreateBackBufferTexture() 
MP_MaterialEmissiveColor (Texture3,155,15,25,25)
MP_SetRenderToTexture (Texture3,1)

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel

Mesh2=MP_CreateCube()

Mesh3=MP_CreateCube()

Mesh4=MP_CreateTeapot()

MP_EntitySetTexture(Mesh, Texture) 

MP_EntitySetTexture(Mesh2, Texture2) 

MP_EntitySetTexture(Mesh3, Texture3) 

MP_PositionEntity (Mesh,0,0,2.4) ; Position des Würfels

MP_PositionEntity (Mesh2,0,0,2.4) ; Position des Würfels

MP_PositionEntity (Mesh3,0,0,2.4) ; Position des Würfels

MP_PositionEntity (Mesh4,0,0,3.4) ; Position des Würfels

MP_AmbientSetLight (RGB(34,44,211))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    MP_HideEntity(Mesh, 0) 
    MP_HideEntity(Mesh2, 1) 
    MP_HideEntity(Mesh3, 1) 
    MP_HideEntity(Mesh4, 1) 
 
  
    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    MP_TurnEntity (Mesh2,-0.1,-0.1,-0.1) ; dreh den Würfel
    MP_TurnEntity (Mesh3,0.1,-0.1,-0.2) ; dreh den Würfel
    MP_TurnEntity (Mesh4,-0.1,0.2,0.1) ; dreh den Würfel
    
    MP_RenderWorld() ; Erstelle die Welt

    MP_HideEntity(Mesh, 1) 
    MP_HideEntity(Mesh2, 0) 
    MP_HideEntity(Mesh3, 1) 
    MP_HideEntity(Mesh4, 1) 
    MP_RenderToTexture( Texture,RGB(25,66,77) ) ;
   
    MP_HideEntity(Mesh, 1) 
    MP_HideEntity(Mesh2, 1) 
    MP_HideEntity(Mesh3, 0) 
    MP_HideEntity(Mesh4, 1) 
    MP_RenderToTexture( Texture2,RGB(255,66,77) ) ;
    
    MP_HideEntity(Mesh, 1) 
    MP_HideEntity(Mesh2, 1) 
    MP_HideEntity(Mesh3, 1) 
    MP_HideEntity(Mesh4, 0) 
    MP_RenderToTexture( Texture3,RGB(0,255,0) ) ;
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 73
; FirstLine = 42
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

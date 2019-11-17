;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Terrain.pb
;// Created On: 29.8.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// First Terrain
;// Erstes Terrain
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart





MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "My first Terrain example, to Move use a,w,d,s and Mouse") 

;mp_wireframe(1)

camera=MP_CreateCamera() ; Kamera erstellen

MP_CameraSetRange(Camera, 0.1, 5000) 

light=MP_CreateLight(1) ; Es werde Licht

;MP_CreateSkyBox ("landscape1","bmp",100)
;MP_CreateSkyBox ("skybox","bmp",100)
MP_CreateSkyBox ("rhills","jpg",100)



Mesh=MP_CreateCube() ; Und jetzt eine Würfel
MP_PositionEntity (Mesh,0,34,5) ; Position des Würfels

Terrain = MP_LoadTerrain ("rhills_hmap.bmp", 64,64) 
Texture = MP_LoadTexture("rhills_tmap.jpg") 


MP_EntitySetTexture (Terrain,texture)
MP_EntitySetName(Terrain, "Terrain") 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen


    If MP_KeyDown(#PB_Key_A)=1
       MP_MoveEntity(camera, -1,0,0)
    EndIf
    
    If MP_KeyDown(#PB_Key_D)=1
       MP_MoveEntity(camera,1,0,0)
    EndIf
    
    If MP_KeyDown(#PB_Key_S)=1
       MP_MoveEntity(camera,0,0,-1)
    EndIf
    
    If MP_KeyDown(#PB_Key_W)=1
       MP_MoveEntity(camera,0,0,1)
    EndIf 
    
    x.f = MP_EntityGetX (camera)
    z.f = MP_EntityGetZ (camera)
    
    MP_PositionEntity(camera, x, MP_TerrainGetY (Terrain,x,0,z) + 8 , z)

    MouseX = -(MP_MouseDeltaX()/10)
    MouseY = MP_MouseDeltaY()/10
      
    MP_TurnEntity(camera, MouseY, MouseX,0);, #PB_Relative)
    
    MP_DrawText (1,1,txt$) ; mesh gefunden

    MP_DrawText (1,20,txt2$) ; 


    MP_TurnEntity (Mesh,0.1,0.1,0.1) 
    ;mp_turnEntity(camera, 1,0,0)
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 75
; FirstLine = 40
; EnableAsm
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
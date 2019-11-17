;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_3_AnimMesh.pb
;// Created On: 31.7.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für 3 animiertes Meshs
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3 animierte Meshs") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

mesh = MP_LoadAnimMesh("bones_all.x")

mesh2 = MP_LoadAnimMesh("bones_all.x")

mesh3 = MP_LoadAnimMesh("bones_all.x")

MP_PositionEntity(Camera, 0, 2, -8) 

MP_PositionEntity (Mesh,0,0,0) 
MP_PositionEntity (Mesh2,1,0,0) 
MP_PositionEntity (Mesh3,-1,0,0) 

MP_SetAnimationSet(Mesh2 , 3) ; Set 3 aktiviert Kampfszene
MP_SetAnimationSet(Mesh3 , 4) ; Set 4 aktiviert Sterbescene

MP_AmbientSetLight (RGB(200,220,220))  


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    count +1
    If count = 120
       count = 0
       count2 + 1
    EndIf
    If count2 = MP_CountAnimateSets(Mesh)
       count2 = 0
    EndIf      
    MP_SetAnimationSet(Mesh , count2)
    
    MP_TextSetColor($FFFF0000) 
    MP_DrawText (1,1,"Animation "+MP_GetAnimationSetName(Mesh,count2)+" läuft")

    MP_TurnEntity (Mesh,0,1,0) 

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
    
    
   MP_MoveEntity (Mesh, 0, 0, 0)

Wend
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 25
; FirstLine = 12
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
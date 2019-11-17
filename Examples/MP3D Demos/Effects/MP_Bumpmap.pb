
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: DX9_Vorlage.pb
;// Created On: 28.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für meine 3D Engine
;// 

MP_Graphics3D (640,480,0,3) ; Create Windows #Window = 0
SetWindowTitle(0, "3D Bumpmap Demo, left world / right with created normals") ; Name

camera=MP_CreateCamera() ; Create Camera

x.f=0 : y.f=0 : z.f = -4 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Camera position 
light=MP_CreateLight(1) ; Light on 

earth1=MP_CreateSphere(20) ; Sphere 1
earth2=MP_CreateSphere(20) ; Sphere 2

Textur=MP_CatchTexture(?Earth_map,?Earth_map_end-?Earth_map)
Textur2 = MP_CreateNormalMap(Textur, 2, 25) ; Erzeugt eine Normal Map aus der Textur  

MP_EntitySetTexture (earth1,textur)
MP_EntitySetBumpmap (earth1,textur2)

MP_EntitySetTexture (earth2,textur)

MP_PositionEntity (Earth1,1,0,0) ; Position Earth1 
MP_PositionEntity (Earth2,-1,0,0) ; Position Earth2 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc or close

    MP_TurnEntity (earth1,-0.05,0,0) ; Move Earth1
    MP_TurnEntity (earth2,-0.05,0,0) ; Move Earth2
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

DataSection
  Earth_map:
  IncludeBinary  "earth_map.jpg" ; Mein MP Bild included
  Earth_map_end:
EndDataSection

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 19
; FirstLine = 1
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
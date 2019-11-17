;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: DX9_Vorlage.pb
;// Created On: 28.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// MP_Bumpmap mit Affe
;// 

MP_Graphics3D (640,480,0,3) ; Create Windows #Window = 0
SetWindowTitle(0, "3D Bumpmap Demo mit Affe") ; Name

camera=MP_CreateCamera() ; Create Camera

x.f=0 : y.f=0 : z.f = -2 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Camera position 
light=MP_CreateLight(1) ; Light on 
MP_LightSetColor(Light,RGB(128,192,0)) 


Cube=MP_CreateCube() ; Sphere 2

Textur=MP_CatchTexture(?Texture,?Texture-?Affe_normals)
Textur2=MP_CatchTexture(?Affe_normals,?Affe_normals-?Textur_end)

MP_EntitySetTexture (Cube,textur)
MP_EntitySetBumpmap (Cube,textur2)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc or close

    MP_TurnEntity (cube,0,-0.05,0) ; Move Earth1
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

DataSection
  Texture:
  IncludeBinary  "texture.png" ; Einfache Textur
  Affe_normals:
  IncludeBinary  "normalmap.png" ; Affe als normal map
  Textur_end:
EndDataSection

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 18
; EnableAsm
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
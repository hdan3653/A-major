;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Kollisionstest.pb
;// Created On: 14.1.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für Musikplayer
;// 
;////////////////////////////////////////////////////////////////

Structure D3DXVECTOR3 
   x.f
   y.f
   z.f
EndStructure

;- Init

If MP_Graphics3D (640,480,0,3)

Else

  End

EndIf

SetWindowTitle(0, "Einfacher V2 Musikplayer") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

mesh1 = MP_CreateRectangle (0.8,3,0.8)
mesh2 = MP_CreateRectangle (0.8,3,0.8)

If CreateImage(0, 255, 255) ; Etwas Farbe selber erzeugen
   MP_CreateImageColored(0,0,RGB($FF,$00,$00),RGB($00,$FF,$00),RGB($00,$00,$FF),RGB($FF,$FF,$00)) ; 
   MP_EntitySetTexture (mesh1, MP_ImageToTexture(0))
   MP_CreateImageColored(0,0,RGB($FF,$00,$FF),RGB($FF,$FF,$FF),RGB($00,$FF,$FF),RGB($FF,$00,$FF)) ; 
   MP_EntitySetTexture (mesh2, MP_ImageToTexture(0))
   FreeImage(0)
EndIf

MP_PositionEntity (Mesh1,0,0,6)
MP_PositionEntity (Mesh2,0,0,6)

x.f=0
y.f=45
z.f=135


MP_RotateEntity (Mesh1, x, y, z)
MP_RotateEntity (Mesh2, x, y, z-90)

MP_CatchV2M(?theTune1) ; Im Speicher eingebettet
;MP_LoadV2M("pzero_new.v2m") ; Oder als Datei laden

MP_PlayV2M()

left.f
right.f

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage

    MP_GetMainVUV2M(@left, @right)
    
    MP_ScaleEntity (mesh1,1,0.5+left*5,1)
    MP_ScaleEntity (mesh2,1,0.5+right*5,1 )
    
    x + 0.1:y-0.2:z+0.1
    
    MP_RotateEntity(mesh1,x, y, z)
    MP_RotateEntity (mesh2,x, y, z-90)
    
    If Not MP_IsPlayingV2M()     
       MP_PlayV2M()
    EndIf
    
    MP_RenderWorld ()
    MP_Flip ()
    
Wend



DataSection
  theTune1:
  IncludeBinary "pzero_new.v2m"
 
EndDataSection


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 38
; FirstLine = 35
; UseIcon = ..\mp3d.ico
; Executable = C:\temp\demos\MP_Musikplayer.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpriteonTexture.pb
;// Erstellt am: 29.1.2010
;// Update am  :
;// Author: Michael Paulwitz
;//
;// Info:
;// Make two texures as Sprite on Texture
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Rotiere Textur auf Würfel") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen
MP_PositionEntity (camera,0,0,-50)
light=MP_CreateLight(1) ; Es werde Licht

plane = MP_CreateRectangle(50, 1, 50) ; Bodenplatte kann natürlich auch ein x-beliebiges Mesh sein
MP_ScaleMesh( plane ,1,0.1,1)
MP_PositionEntity (plane,0,-3,10) ; Position des Würfels

MP_RotateEntity(plane, 90, 0, 0)

Texture =  MP_LoadTexture(#PB_Compiler_Home + "Examples\3D\Data\Textures\wood.jpg")
Texture2 =  MP_LoadTexture(#PB_Compiler_Home +"Examples\3D\Data\Textures\MRAMOR6X6.jpg")

SpriteA = MP_SpriteFromTexture(Texture)
SpriteB = MP_SpriteFromTexture(Texture2)

PlaneTexture = MP_CreateBackBufferTexture(400,400)

MP_EntitySetTexture (plane, PlaneTexture)

MP_AmbientSetLight(RGB(55,34,167))

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
    x + 1
    If x = 256 : x = 0 : EndIf
    
    MP_RotateSprite(SpriteA, x)
    MP_DrawSprite(SpriteA, 1, 1 ,x )
    MP_DrawSprite(SpriteB, 1, 1 ,255-x)
    
    MP_RenderToTexture(PlaneTexture)
   
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 44
; EnableAsm
; EnableXP
; SubSystem = dx9
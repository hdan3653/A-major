;#*************************************************************#
;*                                                             *
;*     Textur scroller Example by Epyx / Epyx_FXLib v1.21      *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib Textur Scrolltext Example")



camera = MP_CreateCamera() ; Kamera erstellen
light  = MP_CreateLight(1) ; Es werde Licht
Mesh   = MP_CreateCube()   ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3)
MyTexture = MP_LoadTexture(#PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp",1,1)
MP_EntitySetTexture (Mesh, MyTexture) 


 EP_LoadFont16(0,"Fonts/pix16 Silver.bmp")

 EP_Write16(MyTexture,0,0,10," Textur ",0)
 EP_Write16(MyTexture,0,0,26,"Scroller",0)
 
 
 
EP_SetScrollText(0, "Kleiner Test-text zum Scrolltext auf einer Textur, es scrollt so lustig vor sich hin ?!!")

EP_Create16Scroll(0, 0, 0,100,0,128) ;<- Einen Scroller in Texturbreite erstellen




Repeat
   MP_AmbientSetLight (RGB(0,0,65))
   
   MP_TurnEntity (Mesh,0.5,0.4,0.7)
   
  
   EP_Move16TexScroll(MyTexture , 0)
   
   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)




End

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 35
; FirstLine = 4
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

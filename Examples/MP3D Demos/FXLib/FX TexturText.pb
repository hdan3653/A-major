;#*************************************************************#
;*                                                             *
;*     GFX Texture Text Example by Epyx / Epyx_FXLib v1.21     *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib Textur GFXText Example")

camera = MP_CreateCamera() ; Kamera erstellen
light  = MP_CreateLight(1) ; Es werde Licht
Mesh   = MP_CreateCube()   ; Und jetzt ein Würfel
 
MP_PositionEntity (Mesh,0,0,3)
MyTexture = MP_CreateTexture(256, 256, 1) 
 
 EP_LoadFont32(0,"Fonts/pix32 gold.bmp")
 EP_LoadFont16(0,"Fonts/pix16 Silver.bmp")


 
 
 ;Fill our Texture with some interesting Text
 EP_Write16(MyTexture,0,0,0,"Diese Textur ist Opfer",0)
 EP_Write16(MyTexture,0,128,20,"Opfer einer",1)
 EP_Write16(MyTexture,0,128,40,"feigen GFX Text",1)
 EP_Write16(MyTexture,0,128,60,"Attacke !!!",1)
 EP_Write32(MyTexture,0,128,100,"Gemein",1)
 EP_Write16(MyTexture,0,128,155,"Sie konnte sich",1)
 EP_Write16(MyTexture,0,128,175,"nicht wehren.",1) 
 EP_Write16(MyTexture,0,128,220,"und das ist gut",1) 
 
 MP_EntitySetTexture (Mesh, MyTexture) 
 
Repeat
  

   MP_AmbientSetLight (RGB(5,0,50))
  
   MP_TurnEntity (Mesh,0.5,0.2,0.2)
   
   EP_Text32(0,320,30,"Text kann man auch",1)
   EP_Text32(0,320,380,"auf eine Textur",1)
   EP_Text32(0,320,430,"Schreiben",1)



  MP_RenderWorld() ; Erstelle die Welt
  MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)



  EP_FreeFont32(0)


End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 8
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem

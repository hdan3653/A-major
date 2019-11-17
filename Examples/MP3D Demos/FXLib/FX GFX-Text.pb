;#*************************************************************#
;*                                                             *
;*         GFX Text Example by Epyx / Epyx_FXLib v1.21         *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib GFX Text Example")


 
 EP_LoadFont32(0,"Fonts/pix32 gold.bmp")
 EP_LoadFont32(1,"Fonts/pix32silber2.bmp")
 EP_LoadFont16(0,"Fonts/pix16 Silver.bmp")
 EP_LoadFont8( 0,"Fonts/pix8 Goldfont.bmp")

 EP_LoadFreeFont(0 ,"Fonts/pix16 golden.bmp", 16, 16)


Repeat
  
  
   EP_FreeText(0,320,100,"Texte mit Grafik Fonts",1)
   EP_FreeText(0,320,125,"sind kein Problem",1)
 
   EP_Text32(0,0,200,"Linksbuendig",0)
   EP_Text16(0,0,245,"Linksbuendig",0)
   EP_Text8(0,0,270,"Linksbuendig",0)
; 
; 
   EP_Text32(0,640,275,"Rechtsbuendig",2)
   EP_Text16(0,640,320,"Rechtsbuendig",2)
   EP_Text8(0,640,345,"Rechtsbuendig",2)
; 
   EP_Text32(1,320,375,"Zentriert",1)
   EP_Text16(0,320,410,"Zentriert",1)
   EP_Text8(0, 320,435,"Zentriert",1)   

  MP_RenderWorld() ; Erstelle die Welt
  MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)



  EP_FreeFont32(0)


End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 8
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

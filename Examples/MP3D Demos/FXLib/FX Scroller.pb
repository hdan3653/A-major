;#*************************************************************#
;*                                                             *
;*        Textscroll Example by Epyx / Epyx_FXLib v1.21        *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#


EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib Scrolltext Example")



 
 EP_LoadFont32(0,"Fonts/pix32 gold.bmp")
 EP_LoadFont32(1,"Fonts/Font 32 - Neon.png")
 EP_LoadFont16(0,"Fonts/pix16 Silver.bmp")



EP_SetScrollText(0, "Hi and Welcome this is the Scrolltext Example of the FXLib, rewritten by epyx for the powerful mp3d Engine ")

EP_Create16Scroll(0, 0, 0,370, 105,350)
EP_SetScroll16Speed(0, 2)

EP_Create16Scroll(1, 0, 0, 100, 205,500)
EP_SetScroll16Speed(1, 1)

EP_Create32Scroll(0, 0, 1, 270)
EP_SetScroll32Speed(0, 3)


EP_Create32Scroll(1, 0, 0, 210)


Repeat
   MP_AmbientSetLight (RGB(0,0,20))

   EP_Move32Scroll(0)   
   EP_Move32Scroll(1)    

   EP_Move16Scroll(0)
   EP_Move16Scroll(1)
   
   

   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)

EP_FreeFont32(0)



End

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 27
; FirstLine = 5
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

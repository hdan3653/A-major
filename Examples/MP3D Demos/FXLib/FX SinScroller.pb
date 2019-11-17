;#*************************************************************#
;*                                                             *
;*       Sinusscroll Example by Epyx / Epyx_FXLib v1.21        *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib Sinus Scroller Example")


 
; Load two Fonts to Use with Scroller
EP_LoadFont32(0,"Fonts/pix32 gold.bmp")
EP_LoadFont16(0,"Fonts/pix16 Silver.bmp")

;Load a tine 8 pix font To show you FPS
EP_CatchFont8(0,?font, ?fontnd)


; a little Message to Scroll over the Screen
EP_SetScrollText(0, "Dies ist ein Text der in dem Sinus Scrollern zu lesen sein soll.")

; Prepare 16 Pixel Scroller and made him as a SinScroller 
EP_Create16Scroll(0, 0, 0,258)
EP_SetSinScroll16(0, 2, 0, 55, 10)

; Prepare 32 Pixel Scroller also goes to the Sinus thing 
EP_Create32Scroll(0, 0, 0, 250)
EP_SetSinScroll32(0, 0, 1, 125, 4)
EP_SetScroll32Speed(0, 2)

Repeat
  
  
  ;Move two Scrollers and Enjoy the Show, simply eh ???
  EP_Move32Scroll(0)   
  EP_Move16Scroll(0)
  
  
  EP_Text8(0,637,10,"FPS: "+Str(EP_FPS()),2)
  
  
  MP_RenderWorld() ; Erstelle die Welt
  MP_Flip ()       ; Stelle Sie dar
Until MP_KeyDown(#PB_Key_Escape)


End


font: 
IncludeBinary "Fonts/pix8 Goldfont.bmp" 
fontnd:
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 58
; FirstLine = 1
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
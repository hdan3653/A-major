;#*************************************************************#
;*                                                             *
;*         2d Stars Example by Epyx / Epyx_FXLib v1.21         *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib 2d Stars Example")

 ; Init our Stars in the middle of the Screen
 EP_Init2DStars(2000,7,0.5,0,80,640,300)


 ;Change some colors to show you, its possible
 EP_2DStarsColor(1,RGB(255,0,0))
 EP_2DStarsColor(2,RGB(0,255,0))
 EP_2DStarsColor(3,RGB(0,0,255))
 EP_2DStarsColor(4,RGB(255,0,255))
 EP_2DStarsColor(5,RGB(0,255,255))

 
 

 
Repeat

   MP_AmbientSetLight (RGB(0,0,40))

   EP_2DStarsDraw() ; Yes simply Draw all Stars, thats it :)
  
   EP_2DStarsDegree(winkel); Set a new Scrolling Angle for the Stars 
   
   winkel + 1 ; Add this Angle


   
   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)


 
End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 8
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

;#*************************************************************#
;*                                                             *
;*     2d Sprite Stars Example by Epyx / Epyx_FXLib v1.21      *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib 2d Sprite Stars Example")



EP_LoadStarSprite(1,"Bobs/SpriteStar4.bmp") ; Load a Starsprite
EP_Init2DStars(200,5,0.7,0,80,640,300)    ; Init visible star area







Repeat

   EP_2DSpritesDraw(1)
   EP_2DStarsDegree(b.f)
 
   b.f - 0.5

 
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)



End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 10
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem

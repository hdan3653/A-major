;#*************************************************************#
;*                                                             *
;*      Screen Fading Example by Epyx / Epyx_FXLib v1.21       *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib Fading Example")


 ; Sprite = MP_LoadSprite("gfx/Calvin01.jpg"); <-- Dieses LoadSprite einfach mal Remarken, mit läufts und ohne stürzt es ab


 ;Init some Stars to Display 
 EP_Init2DStars(500,7,0.5,0,90,640,300) ; <- Es muss anscheinend ein Sprite geladen werden bevor created sprite Aktionen funktionieren ?


 ;Init a Fading Screen with Black Color and Speed 2.5
 EP_InitFading(RGB(0,0,0), 2.5, 0 ,90, 640, 300)
 

 
 ; We Say the Screen is Fadet out,
 EP_SetFadeState(2)
 
 

Repeat
  MP_AmbientSetLight (RGB(0,0,20))
  
  
  
  ;Draw some Stars, anything To move on our Screen
  EP_2DStarsDraw()
  

  ; Now Let the Screen Fade
  X = EP_FadeScreen(Richtung)

  
  If X=-2 : Richtung=1 : 
     ; Uh Screen is Fadet out, start again with a random Color
  ;   EP_SetFadeColor(RGB(Random(255),Random(255),Random(255)))
  EndIf
  
  ; Screen full fadet, now Fade out again
  If X= 2 : Richtung=0 :   EndIf
  
 
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)



End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 7
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

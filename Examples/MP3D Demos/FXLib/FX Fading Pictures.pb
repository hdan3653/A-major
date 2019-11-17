;#*************************************************************#
;*                                                             *
;*       Fade Screen Example by Epyx / Epyx_FXLib v1.21        *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib Fading Example")


 Dim Picture(2)
 Picture(0) = MP_LoadSprite("gfx/Calvin01.jpg")
 Picture(1) = MP_LoadSprite("gfx/bifrost01.jpg")
 Picture(2) = MP_LoadSprite("gfx/Inferno13.jpg")
 
 
 
 ;Init a Fading Screen with White Color and Speed 2.5
 EP_InitFading(RGB(1,1,1), 2.5)
 
 
 
 ; We Say the Screen is Fadet out,
 EP_SetFadeState(2)
 
 
 
 Background_Picture = 1 ; Start with Picture 1
 

 

 
 
Repeat
  
  
  MP_DrawSprite(Picture(Background_Picture), 0, 0) ; Show Picture, no ScreenClear needet

  ; Now Lets the Screen Fade
  X=EP_FadeScreen(Richtung)
  
  
  
  
  If X=-2 : Richtung=1 
    
    ;Uh Screen is Fadet out, start again with a random Color
     EP_SetFadeColor(RGB(Random(255),Random(255),Random(255)))
     
     EP_SetFadeSpeed(2); After the first Fade, now a bit faster please
     
     Delay(1000); 4 You, to see the complete Picture one second
  EndIf
  
  ; Screen full fadet, now Fade out again
  If X= 2  
    
  ;Next Picture please
  Background_Picture+1 : If Background_Picture=3 : Background_Picture=0 : EndIf
  Delay(500) : Richtung=0 :   EndIf
  

  MP_RenderWorld() ; Erstelle die Welt
  MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)


 
End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 8
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem

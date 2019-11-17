;#*************************************************************#
;*                                                             *
;*        Rasterbars Example by Epyx / Epyx_FXLib v1.21        *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#





EP_InitFXLib()

MP_Graphics3D (640,480,0,1) ; Fullscreen Modus, #Windowed = 1
SetWindowTitle(0, "FXLib Rasterbars Example")


;There are two ways to create a rasterbar
;Prepare the Color Table, a Red gradient and the same for the Yellow one
   R=0 : G=0 : B=0
For t = 1 To 16 
   R+16
   EP_SetColorTable(t, RGB(R,G,B))
Next t

For t = 16 To 31 
   R-16
   EP_SetColorTable(t, RGB(R,G,B))
Next t
   R=0
For t = 32 To 95 
   R+4 : G+4
   EP_SetColorTable(t, RGB(R,G,B))
Next t

For t = 95 To 161 
   R-4 : G-4
   EP_SetColorTable(t, RGB(R,G,B))
Next t


;Now we define a Rasterbar with Yellow Color
EP_CreateRasterBar(1, 32, 159)


;Some Jumping Rasterbars with Fast Creating
For t = 2 To 7
   EP_FastRasterBar(t, RGB(Random(255),Random(255),Random(255)), 32, 200,2, 200+(t*20), 2)
Next t
 
 

 
 
Repeat
  
  ;Showing the big Rasterbar, hmm nothing else...
  EP_DisplayRasterBar(1, 240)

  ;Now display the Moving Bars
  For t = 2 To 7 : EP_DisplayRasterBar(t,260+(t*10)) : Next t

  

  MP_RenderWorld() ; Erstelle die Welt
  MP_Flip ()       ; Stelle Sie dar
  
Until MP_KeyDown(#PB_Key_Escape)


 
End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 8
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

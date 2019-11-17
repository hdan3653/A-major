;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP_SpriteParent2
;// Dateiname: MP_SpriteParent2.pb
;// Erstellt am: 12.1.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Crane With two elements , Parnet check
;// Kran mit zwei Elementen
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

Global d.f,d1.f,d2.f
Global x.f,y.f

MP_Graphics3DWindow(30,30, 900,600 ,"", #PB_Window_SystemMenu ); Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Sprite parent relationship, control over q - e, a - d und z - c") ; So soll es heissen
MP_Viewport(20,20,400,400) 

spr_raupe = MP_LoadSprite("raupe40_60.bmp")
spr_arm = MP_LoadSprite("greifer10_40.bmp")
spr_arm1 = MP_LoadSprite("greifer1_10_40.bmp")

MP_SpriteSetCenterY(spr_arm,-20.0) 
MP_SpriteSetCenterY(spr_arm1,-20.0) 

MP_SpriteSetParent (spr_arm, spr_raupe)
MP_SpriteSetParent (spr_arm1, spr_arm)
    
MP_AmbientSetLight (RGB(255,255,0))

x=140
y=140

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow

    If MP_KeyDown(#PB_Key_Q)=1 : d=d-1 : EndIf
    If MP_KeyDown(#PB_Key_E)=1 : d=d+1 : EndIf
    If MP_KeyDown(#PB_Key_A)=1 : d1=d1+1 : EndIf
    If MP_KeyDown(#PB_Key_D)=1 : d1=d1-1 : EndIf
    If MP_KeyDown(#PB_Key_Z)=1 : d2=d2-1 : EndIf
    If MP_KeyDown(#PB_Key_C)=1 : d2=d2+1 : EndIf  
    
    MP_DrawSprite(spr_raupe,140,140)   
    MP_RotateSprite(spr_raupe,d) 

    MP_DrawSprite(spr_arm,-5,20) 
    MP_RotateSprite(spr_arm,d1)  

    MP_DrawSprite(spr_arm1,-4,35) 
    MP_RotateSprite(spr_arm1,d2)      
     
    MP_RenderWorld() 
    MP_Flip () 

Wend
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 39
; FirstLine = 6
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

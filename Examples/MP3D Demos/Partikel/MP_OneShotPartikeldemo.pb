;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_OneShotPartikeldemo.pb
;// Created On: 3.8.2012
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile for Oneshot partikelemmiter
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart


Structure vecf
  x.f
  y.f
  z.f
EndStructure  

MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D OneShot Partikel Test, push mouse to create a particleemmiter") ; So soll es heissen
MP_VSync(0) ; Ab gehts hier


camera=MP_CreateCamera() ; Kamera erstellen

x.f=0 : y.f=0 : z.f = -18 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Kameraposition 


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen

    
    If MP_MouseButtondown(0)
      
      MP_2Dto3D(WindowMouseX(0),WindowMouseY(0),MP_3DZto2D (- z), @pointPosit.vecf )
      
      Particle = MP_CreateOneShotEmitter (3, pointPosit\x,pointPosit\y,0,40, 6,1, 0, 6)
      
    EndIf  
    
    
    MP_DrawText (10,10,"FPS: "+Str(MP_FPS ())+"   "+"MausX = "+Str(WindowMouseX(0))+ " MausY = "+Str(WindowMouseX(0))) ; Textanzeige an Position x,y, Farbe RGB und Text$
    MP_DrawText (10,30,"Count of Particleemmiter "+Str(MP_ListGetSize (11) ))
    MP_DrawText (10,50,"Count of Particle "+Str( MP_GetRenderedParticles(0))) ; Textanzeige an Position x,y, Farbe RGB und Text$
    
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

End
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 31
; FirstLine = 7
; EnableXP
; SubSystem = dx9
;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Gadget.pb
;// Created On: 13.10.2010
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Container Gadget
;// 
;////////////////////////////////////////////////////////////////

;- Init


If OpenWindow(0, 0, 0, 322, 150, "ContainerGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
    ContainerGadget(0, 8, 8, 306, 133, #PB_Container_Raised)
      MP_ScreenToHandle( GadgetID(0))
    CloseGadgetList()
      
      
    camera=MP_CreateCamera() ; Kamera erstellen

    light=MP_CreateLight(1) ; Es werde Licht

    Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
    MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

    While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

        MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
        MP_RenderWorld() ; Erstelle die Welt
        MP_Flip () ; Stelle Sie dar

    Wend


  EndIf 

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 33
; EnableXP
; SubSystem = DX9
; Manual Parameter S=DX9
; EnableCustomSubSystem

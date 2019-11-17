;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_ViewPort_Gadget.pb
;// Erstellt am: 27.11.2015
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Shows Viewport and Gadgets
;//
;//
;////////////////////////////////////////////////////////////////

OpenWindow(0, 732, 301, 540, 540, "", #PB_Window_ScreenCentered | #PB_Window_BorderLess )
;-SET WINDOW ALWAYS ON TOP
  SetWindowPos_(WindowID(0),#HWND_TOPMOST,0,0,0,0,#SWP_NOMOVE|#SWP_NOSIZE)
StringGadget(1, 18, 10, 240, 20, "Test")
ButtonGadget(2, 300, 10, 80, 20, "Push me!") 

;-HANDLE 3D SCREEN
MP_ScreenToHandle(WindowID(0))

camera=MP_CreateCamera()
x = 0 : y = 40 : xw = 540 : yw = 510
MP_Viewport(x,y,xw,yw)
teapot = MP_CreateTeapot() 
MP_EntitySetZ (teapot ,6 )
light=MP_CreateLight(1)

Repeat
    Event = WindowEvent()
    
    If Event = #PB_Event_Gadget

      Select EventGadget()

          
        Case 2 ; Test
          MessageRequester("Info", "Yes push me again", 0)
          
      EndSelect

    EndIf
    
    MP_TurnEntity (teapot,0.1,0.2,0.3)
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ;

  Until Event = #PB_Event_CloseWindow Or MP_KeyDown(#PB_Key_Escape)

; IDE Options = PureBasic 5.40 LTS (Windows - x86)
; CursorPosition = 50
; EnableXP
; SubSystem = dx9
; DisableDebugger
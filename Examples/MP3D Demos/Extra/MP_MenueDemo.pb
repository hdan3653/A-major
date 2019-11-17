;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_MenueDemo.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Kleines Menüprogram
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart




MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Little Menue program") 

  If CreateMenu(0, WindowID(0)) ; Menü erstellen/Create Menu 
    MenuTitle("Change Mesh") 
      MenuItem( 1, "Use Cube") 
      MenuItem( 2, "Use TeaPot") 
      MenuItem( 3, "Use Sphere") 
  EndIf
    
camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht
Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,5) ; Position des Würfels

While Not MP_KeyDown(#PB_Key_Escape) ; Esc abfrage / SC pushed?

    Select WindowEvent()  ; WindowsEvent abfrage 
      Case #PB_Event_Menu 
        Select EventMenu()  ; Welches Menü? / Menuquestion 
         Case 1 ; Erzeuge Cube
            MP_FreeEntity (Mesh)
            Mesh=MP_CreateCube()
            MP_PositionEntity (Mesh,0,0,5)
         Case 2 ; Erzeuge Teapot
            MP_FreeEntity (Mesh)
            Mesh=MP_CreateTeapot()
            MP_PositionEntity (Mesh,0,0,5)
         Case 3 ; Erzeuge Kugel
            MP_FreeEntity (Mesh)
            Mesh=MP_CreateSphere(16)
            MP_PositionEntity (Mesh,0,0,5)
         EndSelect 
      Case #PB_Event_CloseWindow 
         End 
   EndSelect        

   MP_TurnEntity (Mesh,0.1,0.1,0.1) 
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 27
; FirstLine = 6
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; DisableDebugger
; EnableCustomSubSystem
; Manual Parameter S=DX9
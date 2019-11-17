;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_PickingWith4Viewport.pb
;// Created On: 23.8.2011
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für PickBefehl
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "4 CameraViewPorts and Higlight one teepot with Mouse") ; Setzt einen Fensternamen

camera1=MP_CreateCamera() ; Kamera erstellen
camera2=MP_CreateCamera() ; Kamera erstellen
camera3=MP_CreateCamera() ; Kamera erstellen
camera4=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateTeapot() ; Und jetzt ein TeaPot
Mesh2=MP_CreateTeapot() ; Und jetzt ein TeaPot
Mesh3=MP_CreateTeapot() ; Und jetzt ein TeaPot
Mesh4=MP_CreateTeapot() ; Und jetzt ein TeaPot

MP_PositionEntity(Mesh,1,1,0)
MP_PositionEntity(Mesh2,-1,1,0)
MP_PositionEntity(Mesh3,1,-1,0)
MP_PositionEntity(Mesh4,-1,-1,0)


MP_PositionEntity(camera1,0,0,-7)

MP_PositionEntity(camera2,-3,0,-7)
MP_EntityLookAt(camera2,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))

MP_PositionEntity(camera3,-7,0,0)
MP_EntityLookAt(camera3,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))

MP_PositionEntity(camera4,0,-3,-7)
MP_EntityLookAt(camera4,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))

MP_CameraSetRange(camera1, 0.1, 100) ; <- Hier den Wert von 1 bis 2 (1.1 , 1.2 etc testweise verändern)... 
MP_CameraSetRange(camera2, 0.1, 100) 
MP_CameraSetRange(camera3, 0.1, 100) 
MP_CameraSetRange(camera4, 0.1, 100) 

BackColor1 = RGB(0,0,123)
BackColor2 = RGB(0,66,123)
BackColor3 = RGB(66,0,123)
BackColor4 = RGB(66,66,123)

MP_CameraSetPerspective(camera1,45,1)
MP_CameraSetPerspective(camera2,45,1)
MP_CameraSetPerspective(camera3,45,1)
MP_CameraSetPerspective(camera4,45,1)

ViewPortA = MP_CameraViewPort (camera1,0,0,640/2,480/2,BackColor1)
ViewPortB = MP_CameraViewPort (camera2,640/2,0,640/2,480/2,BackColor2)
ViewPortC = MP_CameraViewPort (camera3,0,480/2,640/2,480/2,BackColor3)
ViewPortD = MP_CameraViewPort (camera4,640/2,480/2,640/2,480/2,BackColor4)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
  MP_TurnEntity (Mesh2,0.1,-0.1,0.1) ; dreh den Würfel
  MP_TurnEntity (Mesh3,0.1,0.1,-0.1) ; dreh den Würfel
  MP_TurnEntity (Mesh4,-0.1,-0.1,0.1) ; dreh den Würfel
  
  MP_RenderBegin(camera1,ViewPortA) ;
  If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
      If GetFocus_()=WindowID(0) ; Fenster aktiv? 
         Meshfound = MP_PickCamera (camera1,WindowMouseX(0),WindowMouseY(0))
         If Meshfound   
            MP_Wireframe (1) 
            MP_RenderMesh (Meshfound)
         EndIf
  
     EndIf
  EndIf
  MP_Wireframe (0) 
  MP_RenderMesh()
  MP_RenderEnd() 
  
  MP_RenderBegin(camera2,ViewPortB) ;
  If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
      If GetFocus_()=WindowID(0) ; Fenster aktiv? 
         Meshfound = MP_PickCamera (camera2,WindowMouseX(0),WindowMouseY(0))
         If Meshfound   
            MP_Wireframe (1) 
            MP_RenderMesh (Meshfound)
         EndIf
     EndIf
  EndIf
  MP_Wireframe (0) 
  MP_RenderMesh()
  MP_RenderEnd() 

  MP_RenderBegin(camera3,ViewPortC) ;
  If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
      If GetFocus_()=WindowID(0) ; Fenster aktiv? 
         Meshfound = MP_PickCamera (camera3,WindowMouseX(0),WindowMouseY(0))
         If Meshfound   
            MP_Wireframe (1) 
            MP_RenderMesh (Meshfound)
         EndIf
  
     EndIf
  EndIf
  MP_Wireframe (0) 
  MP_RenderMesh()
  MP_RenderEnd() 
  
  MP_RenderBegin(camera4,ViewPortD) ;
  If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
      If GetFocus_()=WindowID(0) ; Fenster aktiv? 
         Meshfound = MP_PickCamera (camera4,WindowMouseX(0),WindowMouseY(0))
         If Meshfound   
            MP_Wireframe (1) 
            MP_RenderMesh (Meshfound)
         EndIf
  
     EndIf
  EndIf
  MP_Wireframe (0) 
  MP_RenderMesh()
  
  MP_RenderEnd() 
  
  ;MP_RenderWorld () ; Hier gehts los
  
  MP_Flip ()   
  
Wend
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 45
; FirstLine = 90
; EnableXP
; Executable = C:\ttt.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
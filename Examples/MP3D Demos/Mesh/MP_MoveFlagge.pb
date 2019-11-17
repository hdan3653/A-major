;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_MoveFlagge.pb
;// Created On: 2.12.2010
;// Author: djes
;// OS:Windows
;// 
;// Demofile to Move Vertex 
;// 
;////////////////////////////////////////////////////////////////

#subdivisions = 64

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Moving Flag texture")
camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

grid = MP_CreatePlane(#subdivisions, #subdivisions) 

If CreateImage(0, 1024, 1024)
   Font = LoadFont(#PB_Any, "Arial"  , 138*4) 
   StartDrawing(ImageOutput(0))
   Box(0, 0, 512, 512,RGB(255,0,0))
   Box(512, 0, 512, 512,RGB(0,255,0))
   Box(0, 512, 512, 512,RGB(0,0,255))
   Box(512, 512, 512, 512,RGB(255,255,0))
   DrawingFont(FontID(Font))
   DrawingMode(#PB_2DDrawing_Transparent)
   DrawText(73*4,35*4,"5",RGB(0,0,0))
   StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
EndIf
; 
Textur = MP_ImageToTexture(0) ; Create Texture from image 
MP_EntitySetTexture (grid,Textur)
MP_ScaleEntity (grid, 0.1, 0.1, 0.1)
MP_TurnEntity (grid, 0, 30, 0) ; Ein bischen drehen

i.d = 0
x.f=0 : y.f=0 : z.f+6

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

If MP_KeyDown(#PB_Key_Left)=1 : x=x-1 : EndIf ;links Debug #PB_Key_Left
If MP_KeyDown(#PB_Key_Right)=1 : x=x+1 : EndIf ;rechts #PB_Key_Right
If MP_KeyDown(#PB_Key_Down)=1 : y=y-1 : EndIf ;Runter #PB_Key_Down
If MP_KeyDown(#PB_Key_Up)=1 : y=y+1 : EndIf ;rauf #PB_Key_Up
If MP_KeyDown(#PB_Key_Z)=1  : z=z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur
If MP_KeyDown(#PB_Key_Y)=1  : z=z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur
If MP_KeyDown(#PB_Key_A)=1  : z=z-0.1 : EndIf ;a #PB_Key_A

MP_PositionEntity (grid, x, y, z) ; Position des Würfel
MP_TurnEntity (grid, 1, 0, 0) ; Ein bischen drehen
MP_RenderWorld() ; Erstelle die Welt
MP_Flip () ; Stelle Sie dar
     
;****************
; Vertices deform



For gz = 0 To #subdivisions ;min 1
  
  For gx = 0 To #subdivisions ;min 1
     
     MP_VertexSetz(grid, (gz * (#subdivisions )) + gx, Sin(i + gx / 2 + gz / 2 ))
     i+0.0001
  
  Next gx
  

Next gz
   

Wend

End


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 42
; FirstLine = 25
; EnableXP
; Executable = C:\flag.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

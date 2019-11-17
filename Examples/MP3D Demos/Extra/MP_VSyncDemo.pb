
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_VSyncDemo.pb
;// Erstellt am: 3.9.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// VSync On / Off
;//
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "VSync Demo, how fast is the computer") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
MP_PositionEntity (Mesh,0,0,5) ; Position des Würfels

If CreateImage(0, 255, 255)

    Font = LoadFont(#PB_Any, "Arial"  , 138) 
    StartDrawing(ImageOutput(0))

    Box(0, 0, 128, 128,RGB(255,0,0))
    Box(128, 0, 128, 128,RGB(0,255,0))
    Box(0, 128, 128, 128,RGB(0,0,255))
    Box(128, 128, 128, 128,RGB(255,255,0))

    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(73,35,"5",RGB(0,0,0))
  
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Texture = MP_ImageToTexture(0) ; Create Texture from image 
MP_EntitySetTexture (Mesh, Texture ) ; textur to mesh

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    
    count +1
    
    If count = 500
       MP_VSync(0)
    EndIf   

    If count = 30000
       MP_VSync(1)
       count = 0
    EndIf   

    MP_DrawText (1,1,"FPS = "+Str(MP_FPS())+" count = "+Str(count) + " VSync Time =" +StrF(MP_VSyncTime()))

    MP_TurnEntity (Mesh,0.1,0.2,0.3) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 46
; FirstLine = 12
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_Vsyncdemo.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

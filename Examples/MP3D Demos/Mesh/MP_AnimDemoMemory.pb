;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_AnimDemoMemory.pb
;// Created On: 31.7.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für ein Animiertes Mesh aus dem Memory
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "First animiertes Mesh") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

;mesh = MP_LoadAnimMesh("bones_all.x")

Textur = MP_CatchTexture(?EndOfMyData, ?EndOfMyDataToo - ?EndOfMyData)
MP_TextureSetName (Textur, "BONES.JPG") 

mesh = MP_CatchAnimMesh(?MyData, ?EndOfMyData - ?MyData)

MP_PositionEntity(Camera, 0, 1, 0) 

MP_PositionEntity (Mesh,0,0,3) 

MP_AmbientSetLight (RGB(200,220,220))  

MP_SetAnimationSet(Mesh , 1)

MP_TextSetColor($FFFF0000)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    count +1
    If count = 120
       count = 0
       count2 + 1
    EndIf
    If count2 = 5
       count2 = 0
    EndIf      
    MP_SetAnimationSet(Mesh , count2)

    MP_TextSetColor($FFFF0000) 
    MP_DrawText (1,1,"Animation "+MP_GetAnimationSetName(Mesh,count2)+" läuft")

    MP_TurnEntity (Mesh,0,1,0) 

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend

  Debug "Größe der Daten = " + Str(?EndOfMyData - ?MyData)
  End
  
  DataSection
    MyData:
      IncludeBinary "bones_all.x"
    EndOfMyData:
      IncludeBinary "BONES.JPG"
    EndOfMyDataToo:
  EndDataSection








; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 26
; FirstLine = 18
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\temp\demos\AnimMesh.exe
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem
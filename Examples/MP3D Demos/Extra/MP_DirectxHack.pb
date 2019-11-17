;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_DirectxHack.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// About the address of Directx different things are possible
;// Über die Adresse von Directx Adressen können z.B. verschiedene Dinge selber gemacht werden
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "MP3D DirectX Hack") ; Setzt einen Fensternamen

Debug "MP Version "+Str(MP_VersionOf(1)) 

*D3DDevice.IDIRECT3DDEVICE9 = MP_AddressOf(1)

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh,0,0,3) ; Position des Würfels

BackColor = RGB(123,0,0)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    
    *D3DDevice\Clear(#Null, #Null, 3, BackColor , 1, 0)
    *D3DDevice\BeginScene()

    MP_RenderMesh()

    *D3DDevice\EndScene()

    MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 22
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
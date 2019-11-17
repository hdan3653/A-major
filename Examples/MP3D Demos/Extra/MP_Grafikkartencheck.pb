;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP_Grafikartencheck 
;// Dateiname: MP_Grafikkartencheck.pb
;// Erstellt am: 11.1.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Informationen zur Grafikkarte werden ausgegeben
;//
;//
;////////////////////////////////////////////////////////////////

;- ProgrammStart

MP_Graphics3DWindow(0, 0, 20, 20, "" , #PB_Window_Invisible) ;MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0

a.s = "Maximale Grösse der Textur in Pixel "+Str(MP_FeaturesOf(1)) + Chr(10)

If MP_FeaturesOf(2)
  a + "Muss die Textur quadratisch sein: Ja " + Chr(10)
Else   
  a + "Muss die Textur quadratisch sein: Nein " + Chr(10)
EndIf

If MP_FeaturesOf(3)
  a + "Muss die Textur eine Vielfältiges von 2 (1,2,4,8,...) haben: Ja " + Chr(10)
Else   
  a + "Muss die Textur eine Vielfältiges von 2 (1,2,4,8,...) haben: Nein " + Chr(10)
EndIf

If MP_FeaturesOf(3)
  a + "Könnte es eine Ausnahme zu dem Vielfältiges von 2 geben: Ja " + Chr(10)
Else   
  a + "Könnte es eine Ausnahme zu dem Vielfältiges von 2 geben: Nein "  + Chr(10)
EndIf

a + "Vertex Shaderversion: "+Hex(MP_VersionOf(2)) + Chr(10)
a + "Pixel Shaderversion: "+Hex(MP_VersionOf(3))

MessageRequester("Info über Grafikkarte", a)

; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 9
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

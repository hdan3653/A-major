;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_ShaderForTexture.pb
;// Created On: 28.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für Shader
;// 
;
;// FX Files von http://keepcoding.bplaced.com/kcdev/download.php?file=kcTextureTool_1.42_install.exe
;//
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart
Global Textur1 , Textur2

Procedure ShaderMy(n,MyShader,cube)

 If MyShader
    MP_FreeShader(MyShader)
    MP_ShaderSetEntity (0,cube)        
    MyShader = 0
 EndIf 

 If n = 1
   If ReadFile(0, "Inverse.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"inverse")
     MP_ShaderSetTexture (MyShader,"texture0",Textur1)
     MP_ShaderSetEntity  (MyShader,cube)
   EndIf
 ElseIf n = 2
   If ReadFile(0, "blendover.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"TwoPassTextureBlend")
     MP_ShaderSetTexture (MyShader,"Texture1",Textur1)
     MP_ShaderSetTexture (MyShader,"Texture2",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
   EndIf
  ElseIf n = 3
   If ReadFile(0, "mirror.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"Mirror")
     MP_ShaderSetTexture (MyShader,"Texture1",Textur1)
     MP_ShaderSetTexture (MyShader,"Texture2",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
   EndIf
  ElseIf n = 4
   If ReadFile(0, "Signature.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"t1")
     MP_ShaderSetTexture (MyShader,"Texture1",Textur1)
     MP_ShaderSetTexture (MyShader,"Texture4",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
   EndIf
  ElseIf n = 5
   If ReadFile(0, "Sepia.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"t1")
     MP_ShaderSetTexture (MyShader,"Texture1",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
    EndIf
  ElseIf n = 6
   If ReadFile(0, "RadialBlur.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"t1")
     MP_ShaderSetTexture (MyShader,"Texture1",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
    EndIf
  ElseIf n = 7
   If ReadFile(0, "Wood.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"Wood1")
     MP_ShaderSetTexture (MyShader,"Texture6",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
    EndIf
  ElseIf n = 8
   If ReadFile(0, "Wood.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"Wood2")
     MP_ShaderSetTexture (MyShader,"Texture6",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
    EndIf
      ElseIf n = 9
   If ReadFile(0, "Wood.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"Wood3")
     MP_ShaderSetTexture (MyShader,"Texture6",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
    EndIf
      ElseIf n = 10
   If ReadFile(0, "Wood.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
     While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
      dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
     Wend
     CloseFile(0)               ; schließen der zuvor geöffneten Datei
     MyShader = MP_CreateMyShader (dummy)
     MP_SetTechniqueMyShader (MyShader,"Wood4")
     MP_ShaderSetTexture (MyShader,"Texture6",Textur2)
     MP_ShaderSetEntity  (MyShader,cube)
    EndIf
    EndIf

 ProcedureReturn MyShader

EndProcedure

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Shader over Shader, Use Space Key to go to next, save a Grafic file c:\test.jpg") ; So soll es heissen

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht
cube=MP_CreateCube() ; Nen Würfel
MP_PositionEntity (cube,0,0,2)

; Grafikerzeugung
Width=256: Height=256 : txp=8 : txres=1 << txp : txcp=txp-6 : txcell=1 << txcp-1

If CreateImage(0, Width, Height)
  MP_CreateImageColored(0, 0, RGB(0,255,255), RGB(0,255,255), RGB(0,0,255), RGB(0,0,255))     
EndIf

If CreateImage(1, Width, Height)

  StartDrawing(ImageOutput(1))
 
  For x=0 To 63
    ux=x << txcp
    For y=0 To 63
      uy=y << txcp
      col=1
      ; Definition of color of section
      If x>=4 And x <60 And y>=4 And y <60

        hups = Round(((x-4)/7), #PB_Round_Down) + Round(((y-4)/7), #PB_Round_Down)
        If hups & 1
          col=0
        EndIf
 
      ElseIf x>=3 And x <61 And y>=3 And y <61 
        col=0
      EndIf
 
      ;  A shading of section with addition of color noise
      For xx=ux To ux+txcell
        For yy=uy To uy+txcell
          FrontColor (RGB( MP_RandomInt(-8,8) +192*col+16, MP_RandomInt(-8,8) +128*col+16, MP_RandomInt(-8,8) +16))
          Plot (xx, yy)
        Next
      Next  
    Next
  Next
 
  StopDrawing() 

EndIf

Textur1 = MP_ImageToTexture(0) 
Textur2 = MP_ImageToTexture(1)  

MP_EntitySetTexture(cube, Textur1)

Demotext = MP_CreateTexture(640, 480)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen


    If MP_KeyDown(#PB_Key_Space)
        
        MP_EntitySetTexture(cube, 0) ; Textur löschen damit die Shadertexturen genommen werden

        a + 1
        If a = 11 
           a = 0 
           MP_EntitySetTexture(cube, Textur1) ; Alte Textur nehmen
        EndIf

        MyShader = ShaderMy(a,MyShader,cube)
        
 
        
        MP_UsePixelShader (Demotext , MyShader)
        MP_SaveTexture ("c:\test.jpg", Demotext, 1)
        
        
        While MP_KeyDown(#PB_Key_Space)
        Wend
    EndIf
    
    ;MP_TurnEntity (cube,0.05,0.5,1) ; Würfel Drehen
    
    MP_RenderWorld () ; Hier gehts los
    
    MP_Flip () ; 
Wend







; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 204
; FirstLine = 48
; Folding = +
; UseIcon = ..\mp3d.ico
; Executable = C:\test.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

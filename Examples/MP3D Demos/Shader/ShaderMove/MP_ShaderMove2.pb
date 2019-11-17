;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SchaderDemo_xxx.pb
;// Erstellt am: 16.9.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Erstes ShaderDemo
;//
;//
;////////////////////////////////////////////////////////////////

;
Global xres=800, yres=600
txp=8 : txres=1 << txp : txcp=txp-6 : txcell=1 << txcp-1

MP_Graphics3D (xres,yres,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Mesh moves with Shader") 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(2) ; Es werde Licht

;- 

Width=256
Height=256 

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

Surface = MP_ImageToSurface(0,0) ; Image = 0, 

Muster=MP_ImageToTexture (1)

FreeImage(0)

Mesh=MP_CreateRectangle (20,10,0)
MP_ScaleEntity (Mesh, 0.4, 0.4,0.4)


;Muster=MP_ImageToTexture (1)

FreeImage(1)

MP_EntitySetTexture (Mesh, Muster)

;- 

MP_SurfaceSetPosition(Surface,0,0,1)
MP_SurfaceDestRect(Surface,0, 0, xres, yres)


MP_PositionEntity (light,0,20,0)   
MP_PositionEntity (Camera, 0, 0, 10)
MP_EntityLookAt(Camera,MP_EntityGetX(Mesh),MP_EntityGetY(Mesh),MP_EntityGetZ(Mesh))

If ReadFile(0, "ShaderMove2.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...

   While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
     dummy.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
   Wend
   CloseFile(0)               ; schließen der zuvor geöffneten Datei

   MyShader = MP_CreateMyShader (dummy)

   MP_SetTechniqueMyShader (MyShader,"Technique0")

   MP_ShaderSetTexture (MyShader,"testTexture",Muster)

   MP_ShaderSet_D3DMATRIX (MyShader,"worldViewProj",MP_ShaderGetWorldViewI (Mesh))
 
   MP_ShaderSetEntity  (MyShader,Mesh)

EndIf
t1.f = 0
t2.f = 0
t3.f = 0

 
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen


  MP_RenderBegin()

    MP_RenderSurface()

    t.f + 0.1
    If t > 360 : t = 0 : EndIf

    MP_ShaderSetVar_f (MyShader,"currentAngle",t)
 
    MP_RenderMesh()

  MP_RenderEnd()
  
  MP_Flip () ; Stelle Sie dar

Wend

	

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 92
; FirstLine = 85
; UseIcon = ..\..\mp3d.ico
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
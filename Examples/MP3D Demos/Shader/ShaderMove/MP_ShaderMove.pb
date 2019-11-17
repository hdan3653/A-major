

;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SchaderDemo_xxx.pb
;// Erstellt am: 16.9.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// First Shader
;// Erstes ShaderDemo
;//
;//
;////////////////////////////////////////////////////////////////

;
Global xres=800, yres=600
txp=8 : txres=1 << txp : txcp=txp-6 : txcell=1 << txcp-1

MP_Graphics3D (xres,yres,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "First Shader Move Demo, Cursor / Q / A -> Movement") 

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
FreeImage(0)

brd=MP_CreateCube()

; Updating textural coordinates of a board;
For n=0 To 23
 If MP_VertexGetY(brd, n) < 0
    MP_VertexSetV(brd, n,3.0/64)
 EndIf 
Next

MP_ScaleEntity (brd, 9, 0.25,9)

Muster=MP_ImageToTexture (1)
FreeImage(1)

MP_EntitySetTexture (brd, Muster)
MP_PositionEntity (brd,0,-0.1,0) 

;- 

MP_SurfaceSetPosition(Surface,0,0,1)
MP_SurfaceDestRect(Surface,0, 0, xres, yres)

Mesh = MP_CreateTeapot()
MP_PositionEntity (Mesh,0,1.5,0) 

MP_PositionEntity (light,0,20,0)   
MP_PositionEntity (Camera, 0, 5, 10)
MP_EntityLookAt(Camera,MP_EntityGetX(brd),MP_EntityGetY(brd),MP_EntityGetZ(brd))


If ReadFile(0, "ShaderMove.fx")   ; wenn die Datei geöffnet werden konnte, setzen wir fort...

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

    If MP_KeyDown(#PB_Key_Left)=1
       t1 + 0.1       
       MP_ShaderSetVar_f (MyShader,"t1",t1) 
    EndIf
    If MP_KeyDown(#PB_Key_Right)=1
       t1 - 0.1       
       MP_ShaderSetVar_f (MyShader,"t1",t1) 
    EndIf
    If MP_KeyDown(#PB_Key_Up)=1
       t2 + 0.1       
       MP_ShaderSetVar_f (MyShader,"t2",t2) 
    EndIf
    If MP_KeyDown(#PB_Key_Down)=1
       t2 - 0.1       
       MP_ShaderSetVar_f (MyShader,"t2",t2) 
    EndIf
    If MP_KeyDown(#PB_Key_A)=1
       t3 + 0.1       
       MP_ShaderSetVar_f (MyShader,"t3",t3) 
    EndIf
    If MP_KeyDown(#PB_Key_Q)=1
       t3 - 0.1       
       MP_ShaderSetVar_f (MyShader,"t3",t3) 
    EndIf

    MP_RenderMesh()


  MP_RenderEnd()
  
  MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 100
; FirstLine = 98
; UseIcon = ..\..\mp3d.ico
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: 3D Mediaview
;// Created On: 22.4.2008
;// Updated On: 3.5.2008
;// Author: Michael Paulwitz
;//
;// Program loads 3D objects (. X, 3ds And b3d files)
;// Selection of 3D objects on Return, Or space For a new texture;// Programm lädt 3D Objekte (.x,3ds und b3d files)
;// Auswahl der 3D Objekte über return, oder Space für neue Textur  
;//
;////////////////////////////////////////////////////////////////


;- Init


MP_Graphics3D (640,480,0,3)
SetWindowTitle(0, "MediaView, Return lädt Mesh, Space lädt Textur, Cursor,a,y/z Bewegt den Mesh") ; Setzt einen Fensternamen

camera=MP_CreateCamera()
light=MP_CreateLight(1)

n=CountProgramParameters() 

For i=1 To n 
  File.s + " " + ProgramParameter() ; Get filename with space too, example = "c:\my space\test.3ds" 
Next 

If File.s

  SetWindowTitle(0, File.s) 
  mesh = MP_LoadMesh (File.s)
  max.f = MP_MeshGetHeight(mesh) ; find Maximum of Mesh
             
  If MP_MeshGetWidth(mesh) > max
     max = MP_MeshGetWidth(mesh) 
  EndIf

  If MP_MeshGetDepth(mesh) > max
     max = MP_MeshGetDepth(mesh) 
  EndIf

  scale.f = 3 / max ; 
  MP_ScaleEntity (mesh,scale,scale,scale) ; Auf Bildschirm maximieren / maximum to Screen
  x.f=0 : y.f=0 : z.f=4 ; Mesh Koordinaten 

EndIf


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen

  If MP_KeyDown(#PB_Key_Left)=1 : x=x-1 : EndIf 
  If MP_KeyDown(#PB_Key_Right)=1 : x=x+1 : EndIf
  If MP_KeyDown(#PB_Key_Down)=1 : y=y-1 : EndIf
  If MP_KeyDown(#PB_Key_Up)=1 : y=y+1 : EndIf 
  If MP_KeyDown(#PB_Key_Z)=1  : z=z+1 : EndIf ;y ist mit z getauscht
  If MP_KeyDown(#PB_Key_A)=1  : z=z-1 : EndIf 
  If MP_KeyDown(#PB_Key_1)=1  : MP_MeshSetAlpha(Mesh,1): EndIf 


  If MP_KeyDown(#PB_Key_Space)
    Pattern$ = "Grafikdateien |*.jpg;*.bmp"
    directory$ = "C:\Programme\PureBasic\media\"
    File.s = OpenFileRequester("Bitte Datei zum Laden auswählen", directory$, Pattern$, 0)
    If File.s = ""
       MessageRequester("Information", "Der Requester wurde abgebrochen.", 0)
       ;End 
    EndIf
    If Textur : MP_FreeTexture (Textur) : EndIf 
    Textur = MP_LoadTexture(File.s)
    ;MP_EntitySetTexture (mesh, Textur,0) 
    MP_EntitySetTexture (mesh, Textur,0,1) 
    ;MP_MaterialEmissiveColor (Textur,155,15,15,15) 
    
    
    
  EndIf ;#Space



  If MP_KeyDown(#PB_Key_Return)

    Pattern$ = "3D Mesh Dateien|*.x;*.3ds;*.b3d|.x Dateien (*.x)|*.x|3DS Dateien (*.3ds)|*.3ds|B3D Dateien (*.b3d)|*.b3d"
    directory$ = "C:\Programme\PureBasic\media\"
    File.s = OpenFileRequester("Bitte Datei zum Laden auswählen", directory$, Pattern$, 0)
    If File.s

      SetWindowTitle(0, File.s) 
      
      MP_FreeEntity (mesh) 
      mesh = MP_LoadMesh (File.s)
      max.f = MP_MeshGetHeight(mesh) ; find Maximum of Mesh
             
      If MP_MeshGetWidth(mesh) > max
        max = MP_MeshGetWidth(mesh) 
      EndIf

      If MP_MeshGetDepth(mesh) > max
        max = MP_MeshGetDepth(mesh) 
      EndIf

      scale.f = 3 / max ; 
      MP_ScaleEntity (mesh,scale,scale,scale) ; Auf Bildschirm maximieren / maximum to Screen
      x.f=0 : y.f=0 : z.f=4 ; Mesh Koordinaten 
      
      
     
    EndIf
  EndIf ;#Space

  MP_DrawText (2,2,"Triangles: "+Str(MP_CountTriangles(Mesh))+"  Vertices: "+Str(MP_CountVertices(Mesh))) 

  MP_PositionEntity (mesh,0,0,z)
  MP_RotateEntity (mesh,x,y,0)

  MP_RenderWorld()

    MP_Flip ()

Wend

; IDE Options = PureBasic 5.00 (Windows - x86)
; CursorPosition = 108
; FirstLine = 67
; UseIcon = ..\mp3d.ico
; Executable = C:\mp_mediaview.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
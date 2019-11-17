;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP Fishes!
;// File Title: MP_Fishes.pb
;// Created On: 19.12.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// pseudo-fish meshs 
;// 
;////////////////////////////////////////////////////////////////

;Funny variables

Structure TFish
  
  Entity.i
  Yaw.f
  Rot.f
  Speed.f
  
EndStructure

;Create a fish!
Procedure CreateFish()
	mesh = MP_CreateMesh()
	
	v0 = MP_AddVertex(mesh, 1, 0, 0)
	v1 = MP_AddVertex(mesh, 0, -0.5, 0)
	v2 = MP_AddVertex(mesh, 0, 0.5, 0)
	v3 = MP_AddVertex(mesh, -1, 0, -0.5)
	v4 = MP_AddVertex(mesh, -1, 0, 0.5)
	v5 = MP_AddVertex(mesh, -2, 0.5, 0)
	v6 = MP_AddVertex(mesh, MP_RandomFloat(-2.5, -1), MP_RandomFloat(1, 1.2), 0)
	v7 = MP_AddVertex(mesh, -2, -0.5, 0)
	v8 = MP_AddVertex(mesh, -3, -0.8, 0)
	v9 = MP_AddVertex(mesh, -3.5, -0.5, 0)
	v10 = MP_AddVertex(mesh, -3.5, 1.5, 0)
	v11 = MP_AddVertex(mesh, -1, MP_RandomFloat(0.5, -1), 0)
	
	;Head
	MP_AddTriangle (mesh, v3, v2, v0)
	MP_AddTriangle (mesh, v0, v2, v4)
	MP_AddTriangle (mesh, v1, v3, v0)
	MP_AddTriangle (mesh, v0, v4, v1)
	MP_AddTriangle (mesh, v3, v5, v2)
	MP_AddTriangle (mesh, v2, v5, v4)

	;Fin
	MP_AddTriangle (mesh, v5, v6, v2)
	MP_AddTriangle (mesh, v2, v6, v5)
	
	;Body
	MP_AddTriangle (mesh, v3, v7, v5)
	MP_AddTriangle (mesh, v5, v7, v4)
	MP_AddTriangle (mesh, v3, v1, v7)
	MP_AddTriangle (mesh, v7, v1, v4)
	
	;Back-fin
	MP_AddTriangle (mesh, v7, v10, v5)
	MP_AddTriangle (mesh, v5, v10, v7)
	MP_AddTriangle (mesh, v7, v9, v10)
	MP_AddTriangle (mesh, v10,v9, v7)
	MP_AddTriangle (mesh, v8, v9, v7)
	MP_AddTriangle (mesh, v7, v9, v8)
	
	;Under-fin
	MP_AddTriangle (mesh, v11, v7, v1)
	MP_AddTriangle (mesh, v1, v7, v11)

  MP_EntitySetNormals (Mesh)
	
	;Color fish!
	For i = 0 To 11
	    MP_VertexSetColor(mesh, i ,RGB(MP_RandomInt(0, 255),MP_RandomInt(0, 255),MP_RandomInt(0, 255)))
	Next
	
	ProcedureReturn mesh
EndProcedure

;Animate a fish!
Procedure AnimateFish(mesh, an.f)

	MP_VertexSetZ(mesh, 10, Sin(an*0.017453)*0.5)
	MP_VertexSetZ(mesh, 9, Sin(an*0.017453)*0.5)
	MP_VertexSetZ(mesh, 8, Sin(an*0.017453)*0.5)
	MP_VertexSetZ(mesh, 6, Cos(an*0.017453)*-0.2)
	MP_VertexSetZ(mesh, 5, Cos(an*0.017453)*-0.2)
	MP_VertexSetZ(mesh, 7, Cos(an*0.017453)*-0.2)
	MP_VertexSetZ(mesh, 11, Cos(an*0.017453)*-0.2)
		
	MP_VertexSetZ(mesh, 3, -0.5+Cos(an*0.017453)*-0.1)
	MP_VertexSetZ(mesh, 4, 0.5+Cos(an*0.017453)*-0.1)
	MP_VertexSetZ(mesh, 2, Sin(an*0.017453)*-0.1)
	MP_VertexSetZ(mesh, 1, Sin(an*0.017453)*-0.1)

EndProcedure

Dim fishes.TFish(119)

MP_Graphics3D (800,600,0,2) ; Erstelle ein WindowsFenster #Window = 0

SetWindowTitle(0, "Fishes! with Purbasic and MP3D Engine") 

camera=MP_CreateCamera() ; Kamera erstellen
MP_CameraSetPerspective(camera, 90) 
MP_PositionEntity(camera,0,50,-50)
MP_RotateEntity (camera, 45, 0, 0)

light=MP_CreateLight(1)

MP_AmbientSetLight (RGB(64,64,255))
MP_Fog (RGB(64,64,255),10,100)

;Create 120 fishes!
For i = 0 To 119
  fishes(i)\Entity = CreateFish()
	fishes(i)\Yaw = MP_RandomFloat(-1, 1)
	fishes(i)\Speed = MP_RandomFloat(0.1, 0.5)
	MP_PositionEntity (fishes(i)\Entity, MP_RandomInt(-50, 50), MP_RandomInt(-50, 50), MP_RandomInt(-50, 50))
	MP_RotateEntity (fishes(i)\Entity, 0, MP_RandomInt(0, 360), MP_RandomInt(-45, 45))
Next

MP_CatchV2M(?theTune1) ; LoadSong and go
MP_PlayV2M()


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc or close

    If Not MP_IsPlayingV2M()     
       MP_PlayV2M(0)
    EndIf

    For i = 0 To 119
		  AnimateFish(fishes(i)\Entity, an + 90*i)
		  MP_MoveEntity( fishes(i)\Entity, fishes(i)\Speed, 0, 0)

      fishes(i)\Rot + fishes(i)\Yaw
		  MP_RotateEntity( fishes(i)\Entity, 0,0,fishes(i)\Rot)
	   
	  Next
	
	  an = an + MP_RandomFloat(10, 20)
	  an = an % 360

    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

DataSection

  theTune1:
  IncludeBinary "synthetic panorama_new.v2m"

EndDataSection
  
  
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 130
; FirstLine = 91
; Folding = 0
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\Fishes.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

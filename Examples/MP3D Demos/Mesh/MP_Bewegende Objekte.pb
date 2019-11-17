;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: Bewegende Objekte2.pb
;// Created On: 26.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Teapot is changed
;// Teekanne wird verändert
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart


MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Teapot is changed with two methods, F1 = Get/SetmeshData and F2 = getSetvertex") ; So soll es heissen

camera=MP_CreateCamera() ; Kamera erstellen

x.f=0 : y.f=0 : z.f = -4 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Kameraposition 
light=MP_CreateLight(1) ; Es werde Licht

cube=MP_CreateTeapot() ; Nen Würfel
;cube=MP_Create3DText ("Times", "MP 3D Engine", 30) ; Oder 3D schrift

For n = 0 To MP_CountVertices(cube)-1

          farbea.l = Random(255)
          farbeb.l = Random(255)
          farbec.l = Random(255)

          MP_VertexSetColor (cube,n,RGB(farbea,farbeb,farbec))
Next

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen
  
  
If MP_KeyDown(#PB_Key_F1)=1
  
  Memory = MP_GetMeshData(cube, #PB_Mesh_Vertex) ; Put Vertex Mesh Memory in a Memory fild
  Laenge = MP_GetMeshInfo (cube, 64) ; Lenghts of Vertex 
  
  For n = 0 To MP_CountVertices(cube)-1
    
    x.f = PeekF(memory + n*Laenge )
    y.f = PeekF(memory + 4 + n*Laenge )
    z.f = PeekF(memory + 8 + n*Laenge )
    
    zufall.f = (Random (1000)-500)/100000
    
    PokeF ((memory + n*Laenge ),x + zufall)
    PokeF ((memory + 4 + n*Laenge ),y + zufall)
    PokeF ((memory + 8 + n*Laenge ),z + zufall)

  Next 
    
  typ = MP_GetMeshInfo (cube, 32) ; vertex Type
  
  MP_SetMeshData(cube,typ,Memory,MP_CountVertices(cube))
  
  FreeMemory(Memory) 
  
EndIf  
  
If MP_KeyDown(#PB_Key_F2)=1
  
  
    For n = 0 To MP_CountVertices(cube)-1
        x.f = MP_VertexGetX (cube,n)
        y.f = MP_VertexGetY (cube,n)
        z.f = MP_VertexGetZ (cube,n)

        zufall.f = (Random (1000)-500)/100000 
        MP_VertexSetX (cube,n, x + zufall)
        MP_VertexSetY (cube,n, y + zufall)
        MP_VertexSetZ (cube,n, z + zufall)

    Next 
    
  EndIf    
    
    
    MP_DrawText (10,10,"Läuft mit "+Str(MP_FPS ())+" FPS") ; Textanzeige an Position x,y, Farbe RGB und Text$
    MP_TurnEntity (cube,0.05,0.5,1) ; Würfel Drehen

    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

End


; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 44
; FirstLine = 40
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
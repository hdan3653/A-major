
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: Two_Textures_on_Mesh.pb
;// Erstellt am: 26.10.2012
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Create two Texture on Mesh
;// Erzeugt zwei Texturen auf einem Mesh
;//
;//
;////////////////////////////////////////////////////////////////


Global Texture2,Mesh0,Mesh1,Mesh2,Mesh3,Mesh4,Mesh5 

Procedure MP_Random()
  
  MP_EntitySetTexture (Mesh0, 0,1 )
  MP_EntitySetTexture (Mesh1, 0,1 )
  MP_EntitySetTexture (Mesh2, 0,1 )
  MP_EntitySetTexture (Mesh3, 0,1 )
  MP_EntitySetTexture (Mesh4, 0,1 )
  MP_EntitySetTexture (Mesh5, 0,1 )
  
  rnd = Random(5)
  
  If rnd = 0
    MP_EntitySetTexture (Mesh0, Texture2,1 )
  ElseIf rnd = 1
    MP_EntitySetTexture (Mesh1, Texture2,1 )
  ElseIf rnd = 2
    MP_EntitySetTexture (Mesh2, Texture2,1 )
  ElseIf rnd = 3
    MP_EntitySetTexture (Mesh3, Texture2,1 )
  ElseIf rnd = 4
    MP_EntitySetTexture (Mesh4, Texture2,1 )
  ElseIf rnd = 5
    MP_EntitySetTexture (Mesh5, Texture2,1 )
  EndIf
    
EndProcedure

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "3D Darstellung eine Würfels") ; Setzt einen Fensternamen

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh0=MP_CreateCube() ; Und jetzt eine Würfel
Mesh1=MP_CreateCube() ; Und jetzt eine Würfel
Mesh2=MP_CreateCube() ; Und jetzt eine Würfel
Mesh3=MP_CreateCube() ; Und jetzt eine Würfel
Mesh4=MP_CreateCube() ; Und jetzt eine Würfel
Mesh5=MP_CreateCube() ; Und jetzt eine Würfel
 
MP_PositionEntity (Mesh0,1,1,6) ; Position des Würfels
MP_PositionEntity (Mesh1,1,0,6) ; Position des Würfels
MP_PositionEntity (Mesh2,0,0,6) ; Position des Würfels
MP_PositionEntity (Mesh3,-1,0,6) ; Position des Würfels
MP_PositionEntity (Mesh4,0,-1,6) ; Position des Würfels
MP_PositionEntity (Mesh5,-1,-1,6) ; Position des Würfels

If CreateImage(0,128, 128) ; Erzeuge 6 unterschiedliche Texturseiten 

    Font = LoadFont(#PB_Any, "Arial"  , 24) 
    StartDrawing(ImageOutput(0))
    Box(0, 0, 64, 64,RGB(255,0,0))
    Box(0, 64, 64, 64,RGB(255,255,0))
    Box(64, 0, 64, 64,RGB(0,255,0))
    Box(64, 64, 64, 64,RGB(0,0,255))
    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(20,45,"MP3D",RGB(0,0,0))
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Texture = MP_ImageToTexture(0) ; Create Texture from image 

FreeImage(0)

If CreateImage(0,128, 128) ; Erzeuge 6 unterschiedliche Texturseiten 

    StartDrawing(ImageOutput(0))
    
    Circle(64, 64, 50, RGB(180,180,0)) 
    
    Circle(64, 64, 43, RGB(255,255,0)) 
    
    Circle(64, 64, 37, RGB(180,180,0)) 
    
    Circle(64, 64, 30, RGB(0,0,0) )

    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Texture2 = MP_ImageToTexture(0)



MP_EntitySetTexture (Mesh0, Texture )
MP_EntitySetTexture (Mesh1, Texture )
MP_EntitySetTexture (Mesh2, Texture )
MP_EntitySetTexture (Mesh3, Texture )
MP_EntitySetTexture (Mesh4, Texture )
MP_EntitySetTexture (Mesh5, Texture )

MP_AddUVtoEntity (Mesh0) 
MP_AddUVtoEntity (Mesh1) 
MP_AddUVtoEntity (Mesh2) 
MP_AddUVtoEntity (Mesh3) 
MP_AddUVtoEntity (Mesh4) 
MP_AddUVtoEntity (Mesh5) 

#D3DTSS_COLOROP = 1
#D3DTOP_MODULATE = 4 
#D3DTOP_ADD = 7

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_TurnEntity (Mesh,0.1,0.1,0.1) ; dreh den Würfel
    
    h + 1
    If h > 60 : h = 0 : g + 1 : MP_Random() : EndIf
    If g > 26 : g = 0 :  EndIf
    
 ;   MP_SetTextureStageState( 1, #D3DTSS_COLOROP, g ) ; All random kinds
    
    MP_SetTextureStageState( 1, #D3DTSS_COLOROP, #D3DTOP_ADD ) 
 ;   MP_SetTextureStageState( 1, #D3DTSS_COLOROP, #D3DTOP_MODULATE ) 
    
 ;   MP_SetTextureStageState( 0, #D3DTSS_COLOROP, #D3DTOP_ADD ) 
 ;   MP_SetTextureStageState( 0, #D3DTSS_COLOROP, #D3DTOP_MODULATE ) 

    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
    
Wend


; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 45
; FirstLine = 17
; Folding = -
; EnableXP
; SubSystem = dx9
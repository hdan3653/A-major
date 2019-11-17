

;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: Picture_to_3D.pb
;// Created On: 19.2.2012
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Highmap Demofile
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Picture to 3D - Choose Space to load the files") ; So soll es heissen

camera=MP_CreateCamera() ; Kamera erstellen

;x.f=0 : y.f=0 : z.f = -40 
;MP_PositionCamera(camera,x.f,y.f,z.f) ; Kameraposition 
light=MP_CreateLight(1) ; Es werde Licht

x.f=0 : y.f=-130 : z.f = 6 ; Start of Mesh

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen

 If MP_KeyDown(#PB_Key_Left)=1  : x-1   : EndIf ;links Debug #PB_Key_Left 
 If MP_KeyDown(#PB_Key_Right)=1 : x+1   : EndIf ;rechts #PB_Key_Right 
 If MP_KeyDown(#PB_Key_Down)=1  : y-1   : EndIf ;Runter #PB_Key_Down 
 If MP_KeyDown(#PB_Key_Up)=1    : y+1   : EndIf ;rauf #PB_Key_Up 
 If MP_KeyDown(#PB_Key_Z)=1     : z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur 
 If MP_KeyDown(#PB_Key_Y)=1     : z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur 
 If MP_KeyDown(#PB_Key_A)=1     : z-0.1 : EndIf ;a #PB_Key_A 
 
 If terrain ; Objekt drehen
    MP_DrawText (2,2,"Triangles: "+Str(MP_CountTriangles(terrain))+"  Vertices: "+Str(MP_CountVertices(terrain)),MP_ARGB(255,255,255,255)) 
    MP_PositionEntity (terrain,0,0,z) 
    MP_RotateEntity (terrain,x,y,0)
 EndIf
 
 If MP_KeyDown(#PB_Key_Space)=1
   
    Pattern$ = "Image File (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
    File$ = OpenFileRequester("Please choose Grayscale Highmap", "", Pattern$, 0)
    If terrain:MP_FreeEntity(terrain):EndIf 
    terrain=MP_LoadTerrain ( File$ , 128, 128 , 0 , 6 )
    
    File$ = OpenFileRequester("Please choose Colormap", "", Pattern$, 0)
    If Texture:MP_FreeTexture(Texture):EndIf
    Texture = MP_LoadTexture(File$)
    MP_EntitySetTexture (terrain, Texture )    
    max.f = MP_MeshGetHeight(terrain) ; find Maximum of Mesh
    If MP_MeshGetWidth(terrain) > max
      max = MP_MeshGetWidth(terrain)
    EndIf
    If MP_MeshGetDepth(terrain) > max
      max = MP_MeshGetDepth(terrain) 
    EndIf
    scale.f = 4 / max ; 
    MP_ScaleEntity (terrain,scale,scale,scale)
    x.f=0 : y.f=-130 : z.f = 6 
 EndIf

    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

End

; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 5
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_HighmapDemo.exe
; SubSystem = dx9
; DisableDebugger
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Alphablendingtest.pb
;// Created On: 19.4.2008
;// Updated On: 3.5.2008
;// Author: Michael Paulwitz
;//
;// Use AlphaBlendingtest Key 1,2,3 and new Texture)
;//
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,480,0,3) 

SetWindowTitle(0, "AlphaBlendingtest: Key 1,2,3,4,5,6,7 and Space to change texture") 

camera=MP_CreateCamera()

light=MP_CreateLight(1)

cube=MP_CreateCube()

If CreateImage(0, 255, 255)

    Font = LoadFont(#PB_Any, "Arial"  , 138) 
    StartDrawing(ImageOutput(0))

    Box(0, 0, 128, 128,RGB(255,0,0))
    Box(128, 0, 128, 128,RGB(0,255,0))
    Box(0, 128, 128, 128,RGB(0,0,255))
    Box(128, 128, 128, 128,RGB(255,255,0))

    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(73,35,"5",RGB(0,0,0))
  
    StopDrawing() 
    
EndIf

If CreateImage(1, 255, 255)

    Font = LoadFont(#PB_Any, "Arial"  , 138) 
    StartDrawing(ImageOutput(1))

    Box(32, 32, 194, 194,RGB(255,255,255))

    DrawingFont(FontID(Font))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(33,35,"11",RGB(0,0,0))
  
    StopDrawing() 
    
EndIf


Textur = MP_ImageToTexture(0) 
Textur2 = MP_ImageToTexture(0) 

MP_CreateTextureAlpha(Textur2, Texture2) 

MP_EntitySetTexture(cube, Textur,0,1) 
MP_EntitySetTexture(cube, Textur,0,1) 

MP_PositionEntity (cube,0,0,2.4)

MP_MeshSetBlendColor(cube, $FFFFFFFF)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage

 If MP_KeyDown(#PB_Key_1)=1 : MP_MeshSetAlpha (cube,0): EndIf ; Normalmodus aktiv
 If MP_KeyDown(#PB_Key_2)=1 : MP_MeshSetAlpha (cube,1): MP_EntitySetTexture(cube, Textur) : EndIf ; Alphamodus 1 ohne Alphakanal
 If MP_KeyDown(#PB_Key_3)=1 : MP_MeshSetAlpha (cube,1): MP_EntitySetTexture(cube, Textur2) : EndIf ; Alphamodus 1
 If MP_KeyDown(#PB_Key_4)=1 : MP_MeshSetAlpha (cube,2): MP_EntitySetTexture(cube, Textur2) : EndIf ; Alphamodus 2
 If MP_KeyDown(#PB_Key_5)=1 : MP_MeshSetAlpha (cube,3): MP_EntitySetTexture(cube, Textur) : EndIf ; Alphamodus 3
 If MP_KeyDown(#PB_Key_6)=1 : MP_MeshSetAlpha (cube,3): MP_EntitySetTexture(cube, Textur2) : EndIf ; Alphamodus 3
 If MP_KeyDown(#PB_Key_7)=1 : MP_MeshSetAlpha (cube,4): MP_EntitySetTexture(cube, Textur2) : EndIf ; Alphamodus 4
 
 
   If MP_KeyDown(#PB_Key_Space)=1 ; Grafikdateien aussuchen
    Pattern$ = "Grafikdateien |*.bmp;*.dds;*.dib;*.hdr;*.jpg;*.pfm;*.png;*.ppm;*.tga"
    directory$ = "C:\Programme\PureBasic\Dreamotion3D\SamplesDM3D\media\"
    File.s = OpenFileRequester("Bitte Datei zum Laden auswählen", directory$, Pattern$, 0)
    If File.s
       Textur2 = MP_LoadTexture(File.s)
       MP_EntitySetTexture (cube, Textur2,0,1) 
    Else
       MP_EntitySetTexture (cube, Textur) 
    EndIf
  EndIf ;#Space

  MP_TurnEntity (cube,0.05,0.5,1) ; Dreht Würfel

  MP_RenderWorld ()
  MP_Flip ()

Wend
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 15
; FirstLine = 27
; UseIcon = ..\mp3d.ico
; Executable = C:\tt.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
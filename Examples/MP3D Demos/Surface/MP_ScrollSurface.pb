;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: Surface erzeugen.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Einfache 3D Darstellung eines Würfels mit Image als Hintergrund
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Create Windows, #Window = 0
SetWindowTitle(0, "Alpha Cube with scrolling Background") 

camera=MP_CreateCamera() ; Create Camera

light=MP_CreateLight(1) ; Create light

Mesh=MP_CreateCube() ; Cretae Cube

Texture = MP_CatchTexture(?Pic, ?Picend-?Pic) ; Make textur from Scroll Image (2280 X 450 Pixel)
Surface  = MP_TextureToSurface(Texture) ; Make a Surface from Textur
MP_FreeTexture(Texture) 


If CreateImage(0, 255, 255) ; Make image -> Original Purebasic procedure

    Height=255 
    x = 128
    y = 128
    StartDrawing(ImageOutput(0))
    For Radius = Height/2 To 10 Step -10
       Circle(x, y, radius ,RGB(Random(255),Random(255),Random(255)))
    Next
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Texture2 = MP_ImageToTexture(0) ; Make Textur from Purebasic Image

MP_EntitySetTexture(Mesh, Texture2) ; Put Texture to Cube 

MP_MeshSetAlpha (Mesh,1) ; Make Alpha Cube

;-

MP_SurfaceSetPosition(Surface,0,0,1) ; Start Surface on Position 0,0

MP_SurfaceSrcRect(Surface,0, 0, 256, 256) ; get 256*256 Pixel from Scroll Image

MP_SurfaceDestRect(Surface,0, 0, 640, 480) ; Strech it on the 640*480 Screen
 
MP_PositionEntity (Mesh,0,0,5) ; Position of the Cube



While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
    yy.f + 0.01
    
    MP_ScrollSurface(Surface, Sin(yy) * 0.9,1)
    
    : MP_ScrollSurface(Surface, 0, 1)

    
    MP_ScrollSurface(Surface, MP_MouseDeltaX()/5, MP_MouseDeltaY()/5)
    
    MP_DrawText (10,10,"FPS = "+Str(MP_FPS()) + "; SurfaceHeigh = "+Str(MP_SurfaceGetHeight(Surface))+"; SurfaceWidth = "+Str(MP_SurfaceGetWidth(Surface))) ; Have i the normal FPS?
    
    MP_TurnEntity (Mesh,0.1,0.1,0.1)  ; Turn the Cube


    MP_RenderWorld() ; Erstelle die Welt

    MP_Flip () ; Stelle Sie dar

Wend

DataSection
  Pic: 
  IncludeBinary "Regensburg_Uferpanorama_08_2006_.jpg"
   PicEnd:
EndDataSection

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 85
; FirstLine = 36
; UseIcon = ..\mp3d.ico
; Executable = C:\Scrollen2.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
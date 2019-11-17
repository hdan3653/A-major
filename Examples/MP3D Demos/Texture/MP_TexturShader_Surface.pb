
;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_TexturShader_Surface.pb
;// Created On: 10.4.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile for Texturshader to Textur to Surface and to Texture Testprogram 
;//  Alpha 3 Version
;// 
;////////////////////////////////////////////////////////////////


If Not MP_Graphics3D (640,480,0,2); Create 3D Fenster/Windows

  End ; Kann Fenster nicht erstellen/Cant Create Windows

EndIf 
SetWindowTitle(0, "MPs Shader to Textur to Surface and to Texture Testprogram") 

camera=MP_CreateCamera() ; Kamera erstellen / Create Camera
light=MP_CreateLight(1) ; Es werde Licht / Light on

Restore DemoShader6
MyEffect.s = ""
Read.s Purestring.s
Repeat
     MyEffect.s + Purestring.s + Chr(10) 
     Read.s Purestring.s
Until Purestring.s  = "End"

MyTextureShader = MP_CreateTextureShader(MyEffect.s) ; Erzeige Texturshader

Texture =  MP_CreateTextureColor(640,480,0) ; Leere Texture für Texturshader erstellen

If Not MP_UseTextureShader(MyTextureShader,Texture)
   MessageRequester("Shader error message", "No Shader effekt, please recompile your shader, it does not work", #PB_MessageRequester_Ok)
EndIf

Surface = MP_TextureToSurface (Texture) ; Lade Hintergrund Surface mit Textur 
MP_SurfaceSetPosition(Surface,0,0,1)
MP_SurfaceDestRect(Surface,0, 0, 640, 480)

Texture2 = MP_SurfaceToTexture (Surface) ; Nur Demo um aus dem Surface eine Textur zu erstellen
Mesh1 = MP_CreateCube()
MP_EntitySetTexture(Mesh1, Texture2) 

x.f=0 : y.f=0 : z.f=4 
MP_PositionEntity (Mesh1,0,0,z) 
    
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow ; Esc abfrage / SC pushed?
    MP_DrawText (10,10,Str(MP_FPS())) ; FPS Anzeige

    MP_TurnEntity (Mesh1,-0.1,-0.1,0)
  
    MP_RenderWorld () 
    MP_Flip () 
Wend 

End


  DataSection

      
    DemoShader6: ; Sinus/Cos Demo
      Data.s "// Sinus/Cos Demo"								                              
      Data.s "// float2 a: POSITION = Texturposition, a.x and a.y "					
      Data.s "// float4 = color (r,g,b,a)"								                 
      Data.s "// r = sin(length(a) * 100.0) * 0.5 + 0.5"								     
      Data.s "// g=sin(a.y * 50.0)"								                               
      Data.s "// b=cos(a.x * 50.0)"								                              
      Data.s "// a=0"								                                           
      Data.s ""								                                                  
      Data.s "float4 Testout(float2 a: POSITION ) : COLOR"								     
      Data.s "  {"											                                         
      Data.s "    return float4(sin(length(a) * 100.0) * 0.5 + 0.5, sin(a.y * 50.0), cos(a.x * 50.0), 4);"
      Data.s ""								                                                  
      Data.s "  };"								                                              
      Data.s "End"
      
  EndDataSection


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 55
; FirstLine = 24
; EnableAsm
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

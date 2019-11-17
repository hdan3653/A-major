;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Glasdemo.pb
;// Created On: 10.4.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Glasdemo
;// 
;////////////////////////////////////////////////////////////////


MP_Graphics3D (640,480,0,2); Create 3D Fenster/Windows
SetWindowTitle(0, "Glasdemo mit 4 Varianten, Taste 1,2,3,4,5") 

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
Textur =  MP_CreateTextureColor(512,512,0) ; Leere Texture für Texturshader erstellen
MP_UseTextureShader (MyTextureShader,Textur)

Restore DemoShader7
MyEffect.s = ""
Read.s Purestring.s
Repeat
     MyEffect.s + Purestring.s + Chr(10) 
     Read.s Purestring.s
Until Purestring.s  = "End"

MyTextureShader = MP_CreateTextureShader(MyEffect.s) ; Erzeige Texturshader
Textur2 =  MP_CreateTextureColor(512,512,0) ; Leere Texture für Texturshader erstellen
MP_UseTextureShader(MyTextureShader,Textur2)

Mesh = MP_CreateCube()

MP_EntitySetTexture(Mesh, Textur) 

MP_PositionEntity (Mesh,0,0,4) 

    
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow ; Esc abfrage / SC pushed?

 If MP_KeyDown(#PB_Key_1)=1 : MP_MeshSetAlpha (Mesh,0): MP_EntitySetTexture(Mesh, Textur) : EndIf ; Normalmodus aktiv
 If MP_KeyDown(#PB_Key_2)=1 : MP_MeshSetAlpha (Mesh,1): MP_EntitySetTexture(Mesh, Textur) : EndIf ; Alphamodus 1 ohne Alphakanal
 If MP_KeyDown(#PB_Key_3)=1 : MP_MeshSetAlpha (Mesh,2): MP_EntitySetTexture(Mesh, Textur) : EndIf ; Alphamodus 1 ohne Alphakanal
 If MP_KeyDown(#PB_Key_4)=1 : MP_MeshSetAlpha (Mesh,1): MP_EntitySetTexture(Mesh, Textur2) : EndIf ; Alphamodus 1
 If MP_KeyDown(#PB_Key_5)=1 : MP_MeshSetAlpha (Mesh,2): MP_EntitySetTexture(Mesh, Textur2) : EndIf ; Alphamodus 2

    MP_TurnEntity (Mesh,-0.1,-0.1,0)
    MP_RenderWorld () 
    MP_Flip () 
Wend 

End

  DataSection
      
    DemoShader6: ; Sinus/Cos Demo
      Data.s "// 4 side Color Demo"                       
      Data.s "float4 Testout("                            
      Data.s "  float2 vTexCoord : POSITION) : COLOR"     
      Data.s "  {"                                        
      Data.s "    float r,g, b, xSq,ySq, a;"              
      Data.s "    xSq = 2.f*vTexCoord.x-1.f; xSq *= xSq;" 
      Data.s "    ySq = 2.f*vTexCoord.y-1.f; ySq *= ySq;" 
      Data.s "    a = sqrt(xSq+ySq);"                    
      Data.s "    if (a > 1.0f) {"                  
      Data.s "        a = 1.0f-(a-1.0f);"            
      Data.s "    }"                                    
      Data.s "    else if (a < 0.2f) {"                  
      Data.s "        a = 0.2f;"                      
      Data.s "    }"                                  
      Data.s "    r = 1-vTexCoord.x;"                   
      Data.s "    g = 1-vTexCoord.y;"                    
      Data.s "    b = vTexCoord.x;" 
      Data.s "    return float4(r, g, b, a);"    ; Demo 1       
      Data.s "  };"                                       
      Data.s "End"
      
    DemoShader7: ; Sinus/Cos Demo
      Data.s "// 4 side Color Demo"                       
      Data.s "float4 Testout("                            
      Data.s "  float2 vTexCoord : POSITION) : COLOR"     
      Data.s "  {"                                        
      Data.s "    float r,g, b, xSq,ySq, a;"              
      Data.s "    xSq = 2.f*vTexCoord.x-1.f; xSq *= xSq;" 
      Data.s "    ySq = 2.f*vTexCoord.y-1.f; ySq *= ySq;" 
      Data.s "    a = sqrt(xSq+ySq);"                    
      Data.s "    if (a > 1.0f) {"                  
      Data.s "        a = 1.0f-(a-1.0f);"            
      Data.s "    }"                                    
      Data.s "    else if (a < 0.2f) {"                  
      Data.s "        a = 0.2f;"                      
      Data.s "    }"                                  
      Data.s "    r = 1-vTexCoord.x;"                   
      Data.s "    g = 1-vTexCoord.y;"                    
      Data.s "    b = vTexCoord.x;" 
       Data.s "    return float4(r, g, b, 0.7);"  ; Demo 2         
      Data.s "  };"                                       
      Data.s "End"
      
  EndDataSection


; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 53
; FirstLine = 24
; UseIcon = ..\mp3d.ico
; Executable = C:\temp\demos\Glasdemo.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem




Structure d3dxvector3
  x.f
  y.f
  z.f
EndStructure   
  
Global xres=800, yres=600
txp=8 : txres=1 << txp : txcp=txp-6 : txcell=1 << txcp-1

MP_Graphics3D (xres,yres,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Planet Shader with 5 passes, light movement with cursor keys") 

;- Kamera
camera=MP_CreateCamera() ; Kamera erstellen
MP_PositionEntity (Camera, 0, 1, 3)
MP_EntityLookAt(Camera,0,0,0)

;- Background

BackTexture = MP_CatchTexture(?MyData1, ?MyData2 - ?MyData1)
Surface = MP_TextureToSurface(BackTexture) 
MP_SurfaceSetPosition(Surface,0,0,1)

;- Sun Mesh
Sun = MP_CreateSphere(8)
MP_PositionEntity (Sun, 0, 0, -1)
MP_ResizeMesh(Sun,0.05,0.05,0.05)
Textur = MP_CreateTextureColor(640, 480, RGB(0,255,255))
MP_EntitySetTexture (Sun, Textur) 

#incl = 1

CompilerIf #incl = 1 
  
  ; EarthMesh with all Texures
Mesh = MP_CatchMesh(?MyData2, ?MyData3 - ?MyData2) ;MP_LoadMesh("sphere.x")
ColorMap = MP_CatchTexture(?MyData3, ?MyData4 - ?MyData3);MP_LoadTexture ("Earth_Diffuse.jpg")
BumpMap = MP_CatchTexture(?MyData4, ?MyData5 - ?MyData4);MP_LoadTexture ("Earth_Night.jpg")
GlowMap = MP_CatchTexture(?MyData5, ?MyData6 - ?MyData5);MP_LoadTexture ("Earth_NormalMap.jpg")
ReflectionMap  = MP_CatchTexture(?MyData6, ?MyData7 - ?MyData6);MP_LoadTexture ("Earth_ReflectionMask.jpg")
CloudMap  = MP_CatchTexture(?MyData7, ?MyData8 - ?MyData7,1);MP_LoadTexture ("Earth_Cloud.png",1)
WaveMap  = MP_CatchTexture(?MyData8, ?MyData9 - ?MyData8);MP_LoadTexture ("WaterRipples.jpg")
AtmosMap  = MP_CatchTexture(?MyData9, ?MyData10 - ?MyData9);MP_LoadTexture ("Earth_Atmos.jpg")

CompilerElse 

Mesh = MP_LoadMesh("sphere.x")
ColorMap = MP_LoadTexture ("Earth_Diffuse.dds")
BumpMap = MP_LoadTexture ("Earth_NormalMap.dds")
GlowMap = MP_LoadTexture ("Earth_Night.dds")
ReflectionMap  = MP_LoadTexture ("Earth_ReflectionMask.dds")
CloudMap  = MP_LoadTexture ("Earth_Cloud.dds")
WaveMap  = MP_LoadTexture ("WaterRipples.dds")
AtmosMap  = MP_LoadTexture ("Earth_Atmos.dds")

CompilerEndIf

;- Shader over Shader
MyShader = MP_CreateMyShader (PeekS(?MyData10, ?MyData11 - ?MyData10))
MP_SetTechniqueMyShader (MyShader,"PlanetShader")
MP_ShaderSetTexture (MyShader,"ColorMap",GlowMap)
MP_ShaderSetTexture (MyShader,"BumpMap",BumpMap)
MP_ShaderSetTexture (MyShader,"GlowMap",ColorMap)
MP_ShaderSetTexture (MyShader,"ReflectionMap",ReflectionMap)
MP_ShaderSetTexture (MyShader,"CloudMap",CloudMap)
MP_ShaderSetTexture (MyShader,"WaveMap",WaveMap)
MP_ShaderSetTexture (MyShader,"AtmosMap",AtmosMap)
MP_ShaderSet_D3DMATRIX (MyShader,"wvp",MP_ShaderGetWorldView (Mesh))
MP_ShaderSet_D3DMATRIX (MyShader,"world",MP_ShaderGetWorld(Mesh))
MP_ShaderSet_Float3(MyShader,"CameraPosition",MP_ShaderGetCamPos(camera)) 
MP_ShaderSetEntity  (MyShader,Mesh)

test.d3dxvector3

t1.f = 0
t2.f = 0
t3.f = 0

time.f = 380

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

      time.f + 0.01   
    
    test\x = Sin(t1)*1.2
    test\y = Cos(t2)*1.2
    test\z = Cos(t1)*Sin(t2)*1.2
    
    
    
  test\X = 1.2*Cos(t2)*Cos(t1)
  test\Y = 1.2*Sin(t1)
  test\Z = 1.2*Sin(t2)*Cos(t1)

    
    MP_PositionEntity (Sun, test\x, test\y, test\z)
    
    MP_RotateEntity (Mesh, time/2, 0, 0)
    MP_ShaderSet_D3DMATRIX (MyShader,"wvp",MP_ShaderGetWorldView (Mesh)) ; The world
    MP_ShaderSet_D3DMATRIX (MyShader,"world",MP_ShaderGetWorld(Mesh))     ; The Mesh
    
    MP_ShaderSetVar_f (MyShader,"time",time) ; Time for animation
    
    MP_ShaderSet_Float3(MyShader,"LightDirection",test ) 
        
    If MP_KeyDown(#PB_Key_Left)=1
       t1.f + 0.1       
    EndIf
    If MP_KeyDown(#PB_Key_Right)=1
       t1.f - 0.1       
    EndIf
    If MP_KeyDown(#PB_Key_Up)=1
       t2.f + 0.1       
    EndIf
    If MP_KeyDown(#PB_Key_Down)=1
       t2.f - 0.1       
       MP_ShaderSetVar_f (MyShader,"t2",t2) 
    EndIf
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend


CompilerIf #incl = 1 
  
  DataSection
    MyData1:
      IncludeBinary "nigthsky.jpg"
    MyData2:
      IncludeBinary "sphere.x"
    MyData3:
      IncludeBinary "Earth_Diffuse.jpg"
    MyData4:
      IncludeBinary "Earth_Night.jpg"
    MyData5:
      IncludeBinary "Earth_NormalMap.jpg"
    MyData6:
      IncludeBinary "Earth_ReflectionMask.jpg"
    MyData7:
      IncludeBinary "Earth_Cloud.png"
    MyData8:
      IncludeBinary "WaterRipples.jpg"
    MyData9:
      IncludeBinary "Earth_Atmos.jpg"
    MyData10:
      IncludeBinary "PlanetShader.fx"
    MyData11:
  EndDataSection
  
CompilerEndIf

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 18
; EnableXP
; UseIcon = ..\..\mp3d.ico
; Executable = C:\MP_PlanetShader.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
;-
;- ProgrammStart

;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Shader.pb
;// Created On: 28.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für mein Shader
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D Vorlage") ; So soll es heissen

camera=MP_CreateCamera() ; Kamera erstellen


x.f=0 : y.f=0 : z.f = -2 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Kameraposition 
light=MP_CreateLight(1) ; Es werde Licht
cube=MP_CreateCube() ; Nen Würfel

If CreateImage(0, 300, 200)
    If StartDrawing(ImageOutput(0))
      Circle(100,100,50,RGB(0,0,255))  ; a nice blue circle...

      Box(150,20,20,20, RGB(0,255,0))  ; and a green box
      
      FrontColor(RGB(255,0,0)) ; Finally, red lines..
      For k=0 To 20
        LineXY(10,10+k*8,200, 0)
      Next
      
      DrawingMode(#PB_2DDrawing_Transparent)
      BackColor(RGB(0,155,155)) ; Change the text back and front colour
      FrontColor(RGB(255,255,255)) 
      DrawText(10,50,"Hello, this is a test")

      StopDrawing()
    EndIf
EndIf

If CreateImage(1, 255, 255)

    StartDrawing(ImageOutput(0))

      x = 255/2
      y = 255/2
      For Radius = 255/2 To 10 Step -10
        Circle(x, y, radius ,RGB(Random(20),Random(20),Random(20)))
      Next

    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
EndIf

Textur1 = MP_ImageToTexture(1)
Textur2 = MP_ImageToTexture(0)

Restore DemoShader
MyEffect.s = ""
Read.s Purestring.s
Repeat
     MyEffect.s + Purestring.s + Chr(10) 
     Read.s Purestring.s
Until Purestring.s  = "End"

MyShader = MP_CreateMyShader (MyEffect)

MP_ShaderSetTexture (MyShader,"Texture1",Textur1)
MP_ShaderSetTexture (MyShader,"Texture2",Textur2)

MP_SetTechniqueMyShader (MyShader,"TwoPassTextureBlend")

MP_ShaderSetEntity  (MyShader,cube)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen

    MP_TurnEntity (cube,0.05,0.5,1) ; Würfel Drehen
    MP_RenderWorld () ; Hier gehts los
        
    MP_Flip () ; 
Wend


End

  DataSection

    DemoShader: ; Sinus/Cos Demo

      Data.s "texture Texture1;"
      Data.s "texture Texture2;"
      Data.s "technique TwoPassTextureBlend"
      Data.s "{"
      Data.s "    pass Pass0"
      Data.s "    {"
      Data.s "		//"
      Data.s "		// For the first pass, set everything up For regular"
      Data.s "		// texture mapping."
      Data.s "		//"
      Data.s "        AlphaBlendEnable = False;"
      Data.s "        Texture[0] = <Texture1>;"
      Data.s "        ColorOp[0]   = SelectArg1;"
      Data.s "        ColorArg1[0] = Texture;"
      Data.s "        ColorOp[1]   = Disable;"
      Data.s "    }"
      Data.s "    pass Pass1"
      Data.s "    {"
      Data.s "        AlphaBlendEnable = True;"
      Data.s "        SrcBlend  = One;"
      Data.s "        DestBlend = One;"
      Data.s "        Texture[0] = <Texture2>;"
      Data.s "        ColorOp[0]   = SelectArg1;"
      Data.s "        ColorArg1[0] = Texture;"
      Data.s "        ColorOp[1]   = Disable;"
      Data.s "    }"
      Data.s "}"
      Data.s "End"  

  EndDataSection




; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 26
; FirstLine = 24
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
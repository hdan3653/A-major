
InitSprite()


OpenWindow(0, 0, 0, 800, 600, "Screen", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, WindowWidth(0), WindowHeight(0), 0, 0, 0)

;Sprite3DQuality(1)

Font = FontID(LoadFont(#PB_Any, "Arial", 192))
CreateSprite(1, 256, 256)
StartDrawing(SpriteOutput(1))
  DrawingFont(Font) : DrawingMode(1)
  Box(0,0,256,256,$FF0000)
  DrawText(0,0,"F", $0000FF, 0)
StopDrawing()
;CreateSprite3D(1, 1)
 

Define pd3d.IDirect3DDevice9
EnableASM

CompilerIf  #PB_Compiler_Processor = #PB_Processor_x86
  
  !extrn _PB_Screen_Direct3DDevice ; Get the DX9 device of PB 
  !MOV dword EAX, [_PB_Screen_Direct3DDevice]
  !MOV dword [v_pd3d],EAX

CompilerElse
  
  !extrn PB_Screen_Direct3DDevice ; Get the DX9 device of PB 
  !MOV dword EAX, [PB_Screen_Direct3DDevice]
  !MOV dword [v_pd3d],EAX
  
CompilerEndIf

DisableASM

;pd3d.IDirect3DDevice9 = 
MP_UsePB3D(pd3d)

MP_SetRenderState(22,1) ; Make the Sprite3D looking from two sizes

Sprite = MP_LoadSprite("c:\Programme\PureBasic\Examples\Sources\Data\Geebee2.bmp")
 
Repeat
  
  wire + 1
  
  If Wire > 100
    MP_Wireframe(1)
  Else
    MP_Wireframe(0)
  EndIf
  If Wire > 200 : Wire = 0 : EndIf 
  
  ClearScreen(0)

  #HalfSize = 150

  ;Start3D()
  
  a.f = ElapsedMilliseconds()/1000
     
  ZoomSprite(1,200*Sin(a),200)
  DisplaySprite(1, 400-100*Sin(a), 200)
  
  ;- MP3D Sprite Part
  MP_TurnSprite(Sprite, 1)
  MP_DrawSprite(Sprite, 40, 40,$FF)
  MP_RenderSprite()
  ;- 
  
  
  FlipBuffers()  
  
Until WindowEvent() = #PB_Event_CloseWindow 
; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 39
; FirstLine = 3
; Folding = -
; EnableXP
; Executable = C:\Temp\mp3d_hack.exe
; SubSystem = DX9
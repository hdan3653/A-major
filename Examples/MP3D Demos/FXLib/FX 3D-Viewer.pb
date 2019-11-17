;#*************************************************************#
;*                                                             *
;*          FX ObjectViewer by Epyx / Epyx_FXLib v1.2          *
;*                    MP3D Engine version                      *
;*                                                             *
;#*************************************************************#




XIncludeFile "C:\Program Files\PureBasic\Examples\DirectX For PB4\Source\MP3D_Library.pb"


;- ProgrammStart

MP_Graphics3D (800,600,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "FX ObjectViewer - Space drücken um ein neues Objekt zu laden.") 

camera=MP_CreateCamera() 
light=MP_CreateLight(0) 

EP_InitFXLib()
   
#D3DRS_DIFFUSEMATERIALSOURCE  = 145 ; wie bei mp material
#D3DRS_SPECULARMATERIALSOURCE = 146 ; wie bei mp material
#D3DRS_AMBIENTMATERIALSOURCE  = 147 ; wie bei mp material
#D3DRS_EMISSIVEMATERIALSOURCE = 148 ; wie bei mp material
 
#D3DMCS_MATERIAL    = 0 ;// Color from material is used
#D3DMCS_COLOR1      = 1 ;// Diffuse vertex color is used
#D3DMCS_COLOR2      = 2 ;// Specular vertex color is used
#D3DMCS_FORCE_DWORD = $7FFFFFFF ;// force 32-bit size enum

#D3DRS_ZWRITEENABLE = 14 

 


;Load some 3dBall-GFX 
 EP_Load3DBall(4,"Bobs/Bob64_Snowball.png")
 EP_Load3DBall(3,"Bobs/Bob64_Basketball.png")
 EP_Load3DBall(2,"Bobs/Bob64_BlueChrome.png")
 EP_Load3DBall(1,"Bobs/Bob64_RedChrome.png")
 EP_Load3DBall(0,"Bobs/Bob32_yellowStar.png") 
 EP_Load3DBall(5,"Bobs/Bob64_BlueChrome.png")
 EP_Load3DBall(6,"Bobs/Bob64_Tennisball.png")
 EP_Load3DBall(7,"Bobs/Bob64_PinkPlastik.png")
 EP_Load3DBall(8,"Bobs/Bob64_Bubble.png")
 EP_Load3DBall(9,"Bobs/Bob64_Todesstern.png")

  
  
  
  
ReloadObject:
  


              Pattern$ = "FX Objekte|*.obj;*.vobj|3D Balls (*.obj)|*.obj|Vector Objekt (*.vobj)|*.vobj" :Directory$ = "Objects\" 
              File.s   = OpenFileRequester("Load 3D Object", Directory$, Pattern$,  0) 
              If File
                whatType$ = GetExtensionPart(File.s)
                If UCase(whatType$) = "OBJ"  : Mesh = EP_LoadBallObject(1,File.s) : Object_type = 0 :  EndIf
                If UCase(whatType$) = "VOBJ" : Mesh = EP_LoadVectorObject(File.s) : Object_type = 1 :  EndIf 
              EndIf
              
              
              
     X.f = 0 : Y.f = 0 : Z.f=10.0

     MP_MaterialEmissiveColor (Mesh,155,15,25,25) ; 
     MP_MaterialSpecularColor (Mesh, 255, 255 ,255, 255,20)
     
     

     ;Vector Object
      MP_SetRenderState( #D3DRS_EMISSIVEMATERIALSOURCE, #D3DMCS_COLOR1)
      MP_SetRenderState( #D3DRS_DIFFUSEMATERIALSOURCE , #D3DMCS_COLOR1)
      MP_SetRenderState( #D3DRS_SPECULARMATERIALSOURCE, #D3DMCS_MATERIAL) 
      MP_SetRenderState( #D3DRS_EMISSIVEMATERIALSOURCE, #D3DMCS_COLOR1)
      
     ;3D balls
      MP_SetRenderState(#D3DRS_ZWRITEENABLE, 0) 
     


MP_EntitySetNormals (Mesh) : MP_TurnEntity(Mesh, 0, 186, 0)
MP_PositionEntity (Camera, 0 , 0, -8) 
MP_AmbientSetLight(RGB(0,50,0))
MP_PositionEntity (Mesh,x,y,z)

 


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  
  
    If MP_KeyDown(#PB_Key_Left)=1    : x=x- 0.1 : EndIf ;links Debug #PB_Key_Left
    If MP_KeyDown(#PB_Key_Right)=1   : x=x+ 0.1 : EndIf ;rechts #PB_Key_Right
    If MP_KeyDown(#PB_Key_Down)=1    : y=y- 0.1 : EndIf ;Runter #PB_Key_Down  
    If MP_KeyDown(#PB_Key_Up)=1      : y=y+ 0.1 : EndIf ;rauf #PB_Key_Up
    If MP_KeyDown(#PB_Key_PageUp)=1  : z=z+ 0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur
    If MP_KeyDown(#PB_Key_PageDown)=1: z=z- 0.1 : EndIf ;a #PB_Key_A
    
    If MP_KeyHit(#PB_Key_Space)=1   
        If Object_type = 0 : EP_ClearBallObject(1) : EndIf
        If Object_type = 1 : MP_FreeEntity(Mesh)   : EndIf 
        Goto ReloadObject : 
    EndIf

    
    
    If Object_type = 0 : EP_DrawBallObject(Camera) : EndIf
    
    MP_PositionEntity (Mesh,x,y,z) ; Position des Würfel
    
  
    MP_TurnEntity (Mesh, -0.4,0.2,0.3) 

    
    ;mp_savemesh("c:\test2.x",Mesh)
    
    
    MP_DrawText (5,5, "Cursor Keys")   : MP_DrawText (130,5 ,"- Move Object UP/Down, Right/Left")
    MP_DrawText (5,20,"Page Up / Down"): MP_DrawText (130,20,"- Zoom Object Far/Near")
    MP_DrawText (5,45,"Press Space to load a new object") : MP_DrawText (730,5,"FPS: "+Str(MP_FPS()))    

    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend



















; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 10
; Executable = F:\Downloads\Test\Vector Viewer.exe
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem
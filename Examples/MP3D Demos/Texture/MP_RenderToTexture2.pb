;////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_RenderTotexture2.pb
;// Erstellt am: 3.11.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Use Sprite and 2D Draw on Texture
;// Benutze Sprite and 2D Draw auf Texture
;//
;////////////////////////////////////////////////////////////////


Structure Balls
    x1.f
    y1.f
    x2.f
    y2.f
EndStructure

NewList Ball.Balls() 

For n = 0 To 10
  AddElement(Ball()) 
  Ball()\x1 = Random (224)
  Ball()\y1 = Random (224)
  Ball()\x2 = MP_RandomFloat(-2,2)  
  Ball()\y2 = MP_RandomFloat(-2,2)
Next


MP_Graphics3D (640,480,0,3)  
SetWindowTitle(0, "Use Sprite and 2D Draw on Texture") 
  
  Sprite = MP_CatchSprite(?MyData, ?EndOfMyData - ?MyData); Grafik hat 60 Zeichen mit 16x16
  
  Sprite0 = MP_CatchSprite(?EndOfMyData, ?EndOfMyData2 - ?EndOfMyData); Grafik hat 60 Zeichen mit 16x16
  MP_SpriteSetAnimate(Sprite0,60,0,16,16) 
  
  Texture = MP_CreateTexture(256, 256 ,1 )  
  
  Mesh=MP_CreateCube() ; Und jetzt eine Würfel
  Mesh2=MP_CreateCube() ; Und jetzt eine Würfel
 
  MP_PositionEntity (Mesh,-1,0,4) 
  MP_PositionEntity (Mesh2,1,0,4) 
  
  MP_EntitySetTexture (Mesh, Texture )
  MP_EntitySetTexture (Mesh2, Texture )
  
   MP_MaterialDiffuseColor (Texture,255,128,128,128)
   MP_MaterialAmbientColor (Texture, 255, 155 , 255, 255) ; 
   MP_MaterialEmissiveColor (Texture,155,15,25,25) ; 
   MP_MaterialSpecularColor (Texture, 255, 255 ,255, 255,20) ;
  
  light=MP_CreateLight(1)
  
  camera=MP_CreateCamera() 
  
  ;- Alle Sprite Befehle UND 2D befehle können jetzt auf die Textur gerendert werden
  
 
MP_AmbientSetLight (RGB(0,50,128))

deltafps = 1

MP_MeshSetAlpha (Mesh,2)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen
  
  
  ForEach Ball()
    
      Ball()\x1 + Ball()\x2 * deltafps
      Ball()\y1 + Ball()\y2 * deltafps
        
      If Ball()\x1 > 224
           Ball()\x2 = - Ball()\x2
      EndIf
      If Ball()\y1 > 224
         Ball()\y2 = - Ball()\y2
      EndIf

      If Ball()\x1 < 0
           Ball()\x2 = - Ball()\x2
         EndIf
         
      If Ball()\y1 < 0
         Ball()\y2 = - Ball()\y2
      EndIf
  
      MP_DrawSprite(Sprite, Ball()\x1, Ball()\y1)
  Next      
  
    MP_TextSetColor($FF00FF00) 
    
    MP_DrawText (20,20,"This is a Test txt")
  
    MP_RenderToTexture( Texture , MP_ARGB($20,$2F,$2F,$2F))
        
    MP_DrawBitMapText(Sprite0, 165, 180, "A COOL MP3D 27 DEMO")
        
    MP_TurnEntity (Mesh,0.1,0.1,0.1)
    MP_TurnEntity (Mesh2,0.1,0.1,0.1)
    
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

  Wend
  
DataSection
  MyData:
     IncludeBinary "RedBall.png"
  EndOfMyData:
     IncludeBinary "..\BitmapFont\Spherical.bmp"
  EndOfMyData2:
  
EndDataSection

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 92
; EnableXP
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_RenderToTexture2.exe
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem
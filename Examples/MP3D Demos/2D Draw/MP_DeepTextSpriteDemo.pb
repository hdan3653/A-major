
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_DeepTextSpriteDemo.pb
;// Erstellt am: 3.10.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// DeepSprite und DeepTextDemo
;//
;//
;////////////////////////////////////////////////////////////////

Structure Sprites
    Grad.f
    r.f
    x1.f
    y1.f
    x2.f
    y2.f
    deep.f
EndStructure

NewList Sprites.Sprites() 

For n = 0 To 10
  AddElement(Sprites()) 
  Sprites()\r =  MP_RandomFloat(-2,2)  
  Sprites()\x1 = Random (729)
  Sprites()\y1 = Random (529)
  Sprites()\x2 = MP_RandomFloat(-2,2)  
  Sprites()\y2 = MP_RandomFloat(-2,2)
  Sprites()\deep = 4+n/10  
Next




MP_Graphics3D (640,480,0,1) ; Erstelle ein WindowsFenster #Window = 0
 
SetWindowTitle(0, "Demo von DeepText und DeepSprite") 

camera=MP_CreateCamera() ; Kamera erstellen

light=MP_CreateLight(1) ; Es werde Licht

Mesh=MP_CreateTeapot() ; Und jetzt eine Würfel
MP_ScaleEntity(Mesh, 0.4, 0.4, 0.4) 
MP_TurnEntity (Mesh,10,20,66) ; Ein bischen drehen
MP_PositionEntity (Mesh,0,0,5) ; Position des Würfels


;- Fonts fonts fonts
font1 = MP_LoadFont ("Times",70,1,1); "Fontname",Groesse,bold,italic
font2 = MP_LoadFont ("Helvetia",10,1,0);"Fontname",Groesse,bold,italic
font3 = MP_LoadFont ("Verdana",27,1,0);"Fontname",Groesse,bold,italic

a.f = 0.90
;a.f = 1

mp_vsync(1)

For n = 0 To 20

    hups = MP_CreateCube()
    MP_EntitySetColor (hups,RGB(Random(255),Random(255),Random(255)))
    MP_PositionEntity (hups,10-Random(20),10-Random(20),6+Random(40))

Next n

Sprite = MP_CatchSprite(?pic, ?picend-?pic) 

MP_TransparentSpriteColor(Sprite, $FFFFFF) 

deltafps = 1

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    a.f + 0.2
    
    ForEach Sprites()

        Sprites()\grad + Sprites()\r
        MP_SpriteSetZ(Sprite , Sprites()\deep)
        MP_RotateSprite(Sprite, Sprites()\grad)
        MP_DrawSprite(Sprite, Sprites()\x1, Sprites()\y1)
        
        Sprites()\x1+ (Sprites()\x2 * deltafps)
        Sprites()\y1+ (Sprites()\y2 * deltafps)
        If Sprites()\x1 > 730
           Sprites()\x2 = - Sprites()\x2
        EndIf
        If Sprites()\y1 > 530
           Sprites()\y2 = - Sprites()\y2
        EndIf

        If Sprites()\x1 < -70
           Sprites()\x2 = - Sprites()\x2
        EndIf
        If Sprites()\y1 < -70
           Sprites()\y2 = - Sprites()\y2
        EndIf
        
    Next
     
     MP_TextSetZ (0)    
     
     MP_DrawText (1,1,"Normaltext in Gelb",0,$ffffff00,0,0)

     MP_TextSetZ (2)    

     MP_DrawText (180,180,"Times riesig",font1,$ffff0000,2,35+a)

     MP_TextSetZ (1)    

     MP_DrawText (210,250,"aber blass",font1,$55ff0000,0,66)

     MP_TextSetZ (8)    

     MP_DrawText (380,120,"****** G A N Z K L E I N g e n a u G A N Z K L E I N ******",font2,$ff00f0f0,0,90+a)

     MP_TextSetZ (9)    

     MP_DrawText (400,140,"Mittelmaß in Grün",font3,$ff00ff00,0,180)

     MP_TurnEntity (Mesh,0.1,0.1,0.1) 
     
     MP_DrawText (10,10,"FPS = "+Str(MP_FPS())) ; Have i the normal FPS?
        
     MP_RenderWorld() ; Erstelle die Welt

     MP_Flip () ; Stelle Sie dar

Wend

DataSection
  pic: 
  IncludeBinary "rad.bmp";
  picend:
EndDataSection
; IDE Options = PureBasic 5.22 LTS (Windows - x64)
; CursorPosition = 140
; FirstLine = 87
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\DeepTextDeepSprite.exe
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem
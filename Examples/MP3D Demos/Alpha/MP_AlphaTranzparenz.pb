;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_AlphaTranzparenz.pb
;// Erstellt am: 7.04.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Simple Alpha representation for explanation of the commands MP_MeshAlphaSort and MP_TextureSetColor
;// Einfache Alphadarstellung zur Erklärung der Befehle MP_MeshAlphaSort und MP_TextureSetColor
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3DWindow(30,30, 800,600 ,"Alpha Tranzparenz Demo, To use MeshAlphaSort push F1", #PB_Window_SystemMenu )

camera=MP_CreateCamera()

light=MP_CreateLight(1)

Dim MeshCube(19)

CreateImage(0, 255, 255,32)
  StartDrawing(ImageOutput(0))
    DrawingMode(#PB_2DDrawing_AlphaChannel)
    Box(0, 0, 255, 255, $00000000)
  
    ; The classic Circle-thing :)
    ;
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    Circle( 90,  90, 40, RGBA(255,   0,   0, 128))
    Circle(160,  90, 40, RGBA(  0, 255,   0, 128))
    Circle(125, 160, 40, RGBA(  0,   0, 255, 128))
    
StopDrawing()

Texture = MP_ImageToTexture(0,0,1,1)

Txt = MP_Create3DText ("Arial", "MP 3D",1.5)

MP_PositionEntity (Txt,0,0,14)
MP_TranslateMesh (Txt, -MP_MeshGetWidth(Txt)/2 ,-MP_MeshGetHeight(Txt)/2,-MP_MeshGetDepth(Txt)/2) ; Mittelpunkt des Meshs erzeugen



For n = 0 To 19
  
  MeshCube(n)=MP_CreateCube()
  MP_MeshSetAlpha (MeshCube(n),2)  
  MP_EntitySetTexture (MeshCube(n), Texture)
;  MP_EntitySetZEnable (MeshCube(n),0)

  
Next


MP_AmbientSetLight(RGB(255,255,0))

addi = 1

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow

    count.f + 0.005
    
    count2 + addi
    If count2 > 254
      addi = -1
    EndIf   

    If count2 < 2
      addi = 1
    EndIf   
    
    For n = 0 To 19
      MP_PositionEntity (MeshCube(n),Sin(count+#PI*n/10) * 5,0,Cos(count+#PI*n/10) * 5+14)
      MP_TurnEntity (MeshCube(n),0.1*n+0.1,0.1*n+0.1,0.1*n+0.1)
    Next

    MP_TextureSetColor (Texture, 3, count2,0) 
    
    If MP_KeyDown(#PB_Key_F1)=1 
          MP_MeshAlphaSort()
    EndIf
  
;      MP_TurnEntity (Txt,0,0,1)
        
    MP_RenderWorld()
    MP_Flip ()

Wend
; IDE Options = PureBasic 5.11 beta 1 (Windows - x86)
; CursorPosition = 54
; FirstLine = 19
; EnableXP
; Executable = C:\Alphatest3.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
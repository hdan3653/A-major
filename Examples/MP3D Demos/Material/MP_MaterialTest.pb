;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_MaterialTest.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info:
;// Material Test
;// The texture is Integrated in the Exe
;// Material Test
;// Die Textur ist in der Exe Intergriert
;//
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,2) 

camera=MP_CreateCamera() 
light=MP_CreateLight(0) 

pot1 = MP_CreateTeapot()
MP_MaterialDiffuseColor (pot1,255,255,128,50)
MP_PositionEntity (pot1,-3,0,10) 

pot2 = MP_CreateTeapot()
MP_MaterialDiffuseColor (pot2,255,0,255,0)
MP_MaterialAmbientColor (pot2, 255, 128 , 255, 128) ; 
MP_MaterialSpecularColor (pot2, 255, 128 ,255, 128,40) ; 
MP_PositionEntity (pot2,0,0,10) 

pot3 = MP_CreateTeapot()
MP_MaterialDiffuseColor (pot3,255,128,128,128)
MP_MaterialAmbientColor (pot3, 255, 255 , 255, 255) ; 
MP_MaterialEmissiveColor (pot3,255,25,25,25) ; 
MP_MaterialSpecularColor (pot3, 255, 255 ,255, 255,5) ; 
MP_PositionEntity (pot3,3,0,10) 

x.f=0
y.f=0 
z.f=9 

            
While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage


If MP_KeyDown(#PB_Key_Right)=1 : x=x-1 : EndIf 
If MP_KeyDown(#PB_Key_Left)=1 : x=x+1 : EndIf   
If MP_KeyDown(#PB_Key_Down)=1 : y=y-1 : EndIf 
If MP_KeyDown(#PB_Key_Up)=1 : y=y+1 : EndIf 
If MP_KeyDown(#PB_Key_Z)=1  : z=z-0.1 : EndIf 
If MP_KeyDown(#PB_Key_A)=1  : z=z+0.1 : EndIf 

;MP_PositionCamera(camera,x,y,z) 

MP_DrawText (2,2,"Die Tasten a,y und die Cursortasten bewegen die Kamera") 

    MP_PositionEntity(pot1,-3,0,z)
    MP_RotateEntity(pot1, x, y, 0) 

    MP_PositionEntity(pot2,0,0,z)
    MP_RotateEntity(pot2, x, y, 0) 

    MP_PositionEntity(pot3,3,0,z)
    MP_RotateEntity(pot3, x, y, 0) 

    MP_RenderWorld () 
    MP_Flip () 

Wend 

End 
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 43
; FirstLine = 9
; UseIcon = ..\mp3d.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

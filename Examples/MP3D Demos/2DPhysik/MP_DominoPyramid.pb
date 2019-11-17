;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_DominoPyramid.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic pyramid
;// 2D Physik Pyramide
;//
;//
;////////////////////////////////////////////////////////////////

Global wX = 640
Global wY = 480

;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4MP3D Demo: Pachinko, Space makes more Objects", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

; Cube Color
If CreateImage(0, 6, 40)
  MP_CreateImageColored(0, 0, #Blue,#Blue,#Red,#Green)  
  img = MP_ImageToTexture(0) 
  Sprite = MP_SpriteFromTexture(img)
  FreeImage(0)
EndIf

; Background
If CreateImage(0, 256, 256,32)
  MP_CreateImageColored(0, 0, #Yellow,#Yellow,#Red,#Green)     
  Surface = MP_ImageToSurface(0) 
  FreeImage(0)
  MP_SurfaceSetPosition(Surface,0,0,1)
  MP_SurfaceDestRect(Surface,0, 0, wX, wY)
EndIf

MP_2DPhysicInit()
MP_2DPhysicSetGravity(300)

;	cpSpaceResizeStaticHash(*space, 40.0, 2999)
;	cpSpaceResizeActiveHash(*space, 40.0, 999)

*Body = MP_2DPhysicStaticLine(0, 479, 640, 479,$FF)
MP_2DPhysicBodySetProperties(*Body, 1,1)
         
  
  u.f=0.6
  n=7
  
  For i=1 To n
		xx.f = 320-i*60/2.0 : yy.f = 479-20-(n-i)*52
		For j=0 To i-1
		  
		  *Body = MP_2DPhysicBodyBox(xx+j*60,yy,6,40, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
   	  MP_2DPhysicBodySetProperties(*Body, 0,u)
   	  
 		  *Body = MP_2DPhysicBodyBox(xx+j*60,-23+yy,6,40, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
  	  MP_2DPhysicBodySetAngle(*Body, 90)
   	  MP_2DPhysicBodySetProperties(*Body, 0,u)
         
      If j=(i-1) : Continue : EndIf
      
    	  *Body = MP_2DPhysicBodyBox(j*60+30+xx,-29+yy,6,40, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
        MP_2DPhysicBodySetAngle(*Body, 90)
   	    MP_2DPhysicBodySetProperties(*Body, 0,u)

      Next
     
       *Body = MP_2DPhysicBodyBox(-17+xx,-46+yy,6,40, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
       MP_2DPhysicBodySetProperties(*Body, 0,u)

       *Body = MP_2DPhysicBodyBox((i-1)*60+17+xx,-46+yy,6,40, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
       MP_2DPhysicBodySetProperties(*Body, 0,u)
    	  
 Next
   
Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  Else  
    Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
 
  If MP_KeyDown( #PB_Key_Space)
    ;{ Make Body

    MP_2DPhysicBodyBox(wX/2, 0, 5, 40, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
    obj+1
    ;}
    
  EndIf
  
  MP_2DPhysicUpdate(2)
  
  MP_DrawText(1,1, "FPS: " + Str(MP_FPS()) + " Objekte: " + Str(obj),0,MP_ARGB(255,255,0,255))
  ;- ****  Rendern  ***
  MP_RenderWorld() ; Render World yeh go on
  MP_Flip ()
  
Until MP_KeyDown(#PB_Key_Escape) Or Event=#PB_Event_CloseWindow

MP_2DPhysicEnd()
End

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 44
; FirstLine = 9
; Folding = -
; Executable = C:\MP_BoxPyramid.exe
; SubSystem = dx9
; CurrentDirectory = D:\Documents and Settings\eddy.eded.000\Bureau\zzzzzzz\
; CompileSourceDirectory
; EnableCompileCount = 2451
; EnableBuildCount = 18
; Ꞛꯩ薪ꛨꦟ뫮麲믨閦黪꺫ꫮ뺖鿩Ꞻ軩
; 鯨릢髪꺫ꫮ늆鿩ꚺ苩ꮫꛮ鞚ꯩ궮雩ꢟ
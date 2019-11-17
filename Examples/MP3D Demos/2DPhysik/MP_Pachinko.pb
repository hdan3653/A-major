;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Pachinko.pb
;// Erstellt am: 16.11.2011
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// 2D Physic pachinko
;// 2D Physik Pachinko
;//
;//
;////////////////////////////////////////////////////////////////

Global wX = 640
Global wY = 480

;- ***  Create Window
MP_Graphics3DWindow(0, 0, wX, wY, "Chipmunk4MP3D Demo: Pachinko, Space makes more Objects", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)

; Cube Color
If CreateImage(0, 20, 20)
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
MP_2DPhysicSetGravity(100)

Structure CMunkVect
  x.d
  y.d
EndStructure

   ;{/// STATIC POLYGONS

*Memory = AllocateMemory(3*SizeOf(CMunkVect) )
*pointer.CMunkVect = *Memory 
*pointer\x = 15
*pointer\y = 15
*pointer + SizeOf(CMunkVect)
*pointer\x = 0
*pointer\y = -10
*pointer + SizeOf(CMunkVect)
*pointer\x = -15
*pointer\y = 15

For i=0 To 8
   For j=0 To 5
     
       s.l=j%2
       stagger.f=s*40
       
       *Body = MP_2DPhysicStaticPolygon(i*80+stagger,100+(j*70),3,*Memory,0, RGB(Random(255),Random(255),Random(255)))
       MP_2DPhysicBodySetAngVeloc(*Body, 0.4)

   Next
 Next
 FreeMemory(*Memory)
;}

;{/// FALLING POLYGONS

 NewList Polys.i()

 *Memory = AllocateMemory(5*SizeOf(CMunkVect) )
 *pointer.CMunkVect = *Memory

   For i=0 To 4
     angle.f=-2*#PI*i/5*SizeOf(CMunkVect)
     *pointer\x = 10*Cos(angle)
     *pointer\y = 10*Sin(angle)
     *pointer + SizeOf(CMunkVect)
   Next
   
   For i=0 To 299
     
     AddElement (Polys())
     Polys() = MP_2DPhysicBodyPolygon(Random(640), -20*Random(64),5,*Memory, 0, 1, RGB(Random(255),Random(255),Random(255)))
     MP_2DPhysicBodySetProperties(Polys(), 0,0.4)
     
     obj +1
     
   Next
;}



Repeat
  Event = WindowEvent() 
  
  If Event = #PB_Event_CloseWindow   ; An event was in the queue so process it 
    Break
  Else  
    Delay(1)  ; No event, let the others apps get some CPU time too ! 
  EndIf 
  
  ;{/// FALLING POLYGONS
  
  ForEach (Polys())       ; Process all the elements...
     ;check if object is out of screen
     If MP_2DPhysicBodyGetY (Polys())>500 Or MP_2DPhysicBodyGetX (Polys())>680 Or MP_2DPhysicBodyGetX (Polys())<-20
		   ;reset its position if necessary
       MP_2DPhysicBodySetX (Polys(), Random(640)) 
		   MP_2DPhysicBodySetY (Polys(), -20*Random(32))
     EndIf
  Next
;}
  
  If MP_KeyDown( #PB_Key_Space)
    ;{ Make Body
    AddElement (Polys())
    Polys() = MP_2DPhysicBodyBox(wX/2, -20, 20, 20, Sprite , 1,RGB(Random(255),Random(255),Random(255)))    
    obj +1
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
; CursorPosition = 116
; FirstLine = 76
; Folding = -
; Executable = C:\MP_Pachinko.exe
; SubSystem = dx9
; CurrentDirectory = D:\Documents and Settings\eddy.eded.000\Bureau\zzzzzzz\
; CompileSourceDirectory
; EnableCompileCount = 2382
; EnableBuildCount = 20
; ꚗ髮놊럨ꖞ雫ꚷ雮趶꟨떞軩ꞇ髮떖飮
; 뛨ꞗ髮놆菨ꂞ蛪ꚗ黮醖꟨ꖖ苪ꒃ軮ꖢ
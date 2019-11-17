;///////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_SpritePick.pb
;// Erstellt am: 9.2.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Easy SpritePick Test with sprite and color return
;// Einfacher SpritePick Test 
;//
;//
;////////////////////////////////////////////////////////////////

wX = 640
wY = 480

MP_Graphics3D (wX,wY,0,1)

;MP_VSync(0)

Sprite0 = MP_CatchSprite(?pic, ?picend-?pic) 

angle0.f = 90

MP_AmbientSetLight($333333) 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen



    angle0.f + 15 * MP_VSyncTime() ; Geschwindigkeit bleibt trotz anderer FPS gleich 

    x0 = wX/2-MP_SpriteGetWidth(Sprite0)/2 ; Mitte des Bildschirms
    y0 = wY/2-MP_SpriteGetHeight(Sprite0)/2 ; Mitte des Bildschirms

    
    MP_RotateSprite(Sprite0,angle0)
    
    MP_DrawSprite(Sprite0,x0,y0)  
    
    MP_DrawSprite(Sprite0,x0+200,y0)

    MP_DrawSprite(Sprite0,x0,y0+150)
    
    MP_DrawSprite(Sprite0,x0-200,y0)
    
    MP_DrawSprite(Sprite0,x0,y0-150)
    
         
    x1 = WindowMouseX(0) 
    y1 = WindowMouseY(0) 
 
    color =  MP_PickSprite (Sprite0,x0,y0,x1,y1)
    If Color
         kol +1
         MP_DrawText(1,1,"Coll Sprite Middle R="+Hex(MP_Red(color))+" G="+Hex(MP_Green(color))+" B="+Hex(MP_Blue(color)))
    EndIf
      
    color =  MP_PickSprite (Sprite0,x0+200,y0,x1,y1)
    If Color
         kol +1
         MP_DrawText(1,1,"Coll Sprite right R="+Hex(MP_Red(color))+" G="+Hex(MP_Green(color))+" B="+Hex(MP_Blue(color)))
    EndIf

    color =  MP_PickSprite (Sprite0,x0,y0+150,x1,y1)
    If Color
         kol +1
         MP_DrawText(1,1,"Coll Sprite down R="+Hex(MP_Red(color))+" G="+Hex(MP_Green(color))+" B="+Hex(MP_Blue(color)))
    EndIf

    color = MP_PickSprite (Sprite0,x0-200,y0,x1,y1)
    If Color
         kol +1
         MP_DrawText(1,1,"Coll Sprite left R="+Hex(MP_Red(color))+" G="+Hex(MP_Green(color))+" B="+Hex(MP_Blue(color)))
    EndIf

    color = MP_PickSprite (Sprite0,x0, y0-150,x1,y1)
    If Color
         kol +1
         MP_DrawText(1,1,"Coll Sprite upper R="+Hex(MP_Red(color))+" G="+Hex(MP_Green(color))+" B="+Hex(MP_Blue(color)))
    EndIf

   SetWindowTitle(0,"MP Sprite Coll check "+Str(MP_FPS())+" FPS + "+Str(kol)+" Coll")
   
   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend

DataSection
  pic: 
  IncludeBinary "SpinnerBlock3.bmp";"Bild.png"
   picend:
   
EndDataSection

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 20
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
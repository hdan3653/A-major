;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_Sprite3DBlendmodus.pb
;// Erstellt am: 13.7.2009
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Easys Particle Blendmode
;//
;//
;////////////////////////////////////////////////////////////////


; http://msdn.microsoft.com/en-us/library/windows/desktop/bb172508(v=vs.85).aspx
#D3DBLEND_ZERO            = 1
#D3DBLEND_ONE             = 2
#D3DBLEND_SRCCOLOR        = 3
#D3DBLEND_INVSRCCOLOR     = 4
#D3DBLEND_SRCALPHA        = 5
#D3DBLEND_INVSRCALPHA     = 6
#D3DBLEND_DESTALPHA       = 7
#D3DBLEND_INVDESTALPHA    = 8
#D3DBLEND_DESTCOLOR       = 9
#D3DBLEND_INVDESTCOLOR    = 10
#D3DBLEND_SRCALPHASAT     = 11
#D3DBLEND_BOTHSRCALPHA    = 12
#D3DBLEND_BOTHINVSRCALPHA = 13

MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D Partikel Test,Push 1 and 2 to change") ; So soll es heissen

Particle = MP_CreateParticleEmitter(0) ; Fontaine mit Wind
MP_PositionEntity (Particle,0,0,0) ; Setzt ein Objekt an einen x,y,z Ort
MP_ParticleColorRange (Particle,RGB(255,255,255),RGB(255,255,255)) ; Farbe von RGB Wert zu RGB Wert
MP_ParticleEmissionRate (Particle,200,5,0.05); Maximale Partikel, Ausstoßmenge und Zeiteinheit in s dafür
MP_ParticleTimeToLive(Particle, 3, 6); Partikellebenszeit von s bis s
MP_EntitySetVelocity(Particle,0,5,0,1.5); Ausstossrichtung als x,y,z und Verteilungsstärke
MP_EntitySetWind(Particle, 2, 0 ,0); Wind als x,y,z    

MP_AmbientSetLight(RGB(123,55,134))

;own picture
;Textur = MP_CatchTexture(?logostart,?logostart-?logostop)
;MP_EntitySetTexture(Particle,Textur)

camera=MP_CreateCamera() ; Kamera erstellen

x.f=0 : y.f=0 : z.f = -18 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Kameraposition 

light=MP_CreateLight(1) ; Es werde Licht

cube=MP_CreateCube() ; Nen Würfel

MP_EntitySetColor (cube,RGB(100,100,255)) ; Würfel färben als R,G,B Wert

a = 1
b = 4

MP_ParticleFadeOut(Particle, 1)


While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen
  
  
      If MP_KeyHit(#PB_Key_1)
        a + 1
        If a > 13 
          a = 1
        EndIf  
      EndIf
      
      If MP_KeyHit(#PB_Key_2)
        b + 1
        If b > 13 
          b = 1
        EndIf  
      EndIf
      
     MP_ParticleBlendingMode(Particle, a ,b) ;see 

    MP_DrawText(1,1,"Particle3DBlendingMode, Source = "+Str(a)+ " Destination = "+Str(b))
    
    
    ; Change the particle
    t.f + 1
    If t > 120
        t = 0
        mm + 1
        If mm > 24 : mm = 0 : EndIf
        MP_SetParticleEmitter(Particle,mm)
    EndIf
    
    
    MP_TurnEntity (cube,0.05,0.5,1) ; Würfel Drehen
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

  Wend
  
  End

;DataSection
;  logostart:
; IncludeBinary "c:\color3.bmp" ; Mein MP Bild included
;  logostop:
;EndDataSection
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 50
; FirstLine = 48
; EnableXP
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_Sprite3DBlendmode.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
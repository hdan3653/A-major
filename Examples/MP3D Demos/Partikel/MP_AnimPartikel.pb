;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_AnimPartikel.pb
;// Created On: 7.4.2010
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für zwei animierte PartikelEmmitter
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D Anim Partikel Test") ; So soll es heissen
MP_VSync(0) ; Ab gehts hier

Particle = MP_CreateParticleEmitter(0) ; Fontaine Feuer
MP_PositionEntity (Particle,0,0,0) ; Setzt ein Objekt an einen x,y,z Ort
MP_ParticleColorRange (Particle,RGB(130,130,130),RGB(140,140,140)) ; Farbe von RGB Wert zu RGB Wert
MP_ParticleEmissionRate (Particle,200,1,0.01); Maximale Partikel, Ausstoßmenge und Zeiteinheit in s dafür
MP_ParticleTimeToLive(Particle, 3, 6); Partikellebenszeit von s bis s
MP_EntitySetVelocity(Particle,0,5,0,1.5); Ausstossrichtung als x,y,z und Verteilungsstärke
MP_EntitySetWind(Particle, 2, 0 ,0); Wind als x,y,z    
  
Particle3 = MP_CreateParticleEmitter(0) ;Vulkan aus Rechtecken
MP_PositionEntity (Particle3,-5,0,0) ; Setzt ein Objekt an einen x,y,z Ort
MP_ParticleColorRange (Particle3,RGB(0,0,0),RGB(180,180,180)) ; Farbe von RGB Wert zu RGB Wert
MP_ParticleEmissionRate (Particle3,100,10,0.05);  Maximale Partikel, Ausstoßmenge und Zeiteinheit in s dafür
MP_ParticleTimeToLive(Particle3, 3, 4); Partikellebenszeit von s bis s
MP_EntitySetVelocity(Particle3,0,5,0,2.5); Ausstossrichtung als x,y,z und Verteilungsstärke
MP_EntitySetGravity(Particle3,0,-5,0) ; Gravitatio als x,y,z    

;Eigenes Bild einfügen;
Textur2 = MP_CatchTexture(?logostart2,?logostart2-?logostop2)
MP_ParticleEmitterSetAnimate(Particle3,Textur2,4,15,32,32)


Textur = MP_CatchTexture(?logostart,?logostop-?logostart)
MP_ParticleEmitterSetAnimate(Particle,Textur,16,10,64,64)

MP_ParticleSize(Particle,1,2)
MP_ParticleSize(Particle3, 0.5,1)

camera=MP_CreateCamera() ; Kamera erstellen

x.f=0 : y.f=0 : z.f = -18 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Kameraposition 

light=MP_CreateLight(1) ; Es werde Licht

cube=MP_CreateCube() ; Nen Würfel

MP_EntitySetColor (cube,RGB(100,100,255)) ; Würfel färben als R,G,B Wert

a = 0

MP_ParticleFadeOut(Particle, 1)
MP_ParticleFadeOut(Particle3, 1)



While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen

    
    MP_DrawText (10,10,"FPS: "+Str(MP_FPS ())) ; Textanzeige an Position x,y, Farbe RGB und Text$

    MP_DrawText (10,24,"Textur: "+Str(MP_TextureGetHeight(Textur))+" / "+Str(MP_TextureGetWidth(Textur))) ; Textanzeige an Position x,y, Farbe RGB und Text$
    MP_DrawText (10,38,"Textur2: "+Str(MP_TextureGetHeight(Textur2))+" / "+Str(MP_TextureGetWidth(Textur2))) ; Textanzeige an Position x,y, Farbe RGB und Text$
    
    
    MP_TurnEntity (cube,0.05,0.5,1) ; Würfel Drehen
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

End

DataSection
  logostart:
  IncludeBinary "explosion5.bmp" ; Mein MP Bild included
  logostop:

  logostart2:
  IncludeBinary "partikel_dreh.bmp" ; Mein MP Bild included
  logostop2:
  
  
EndDataSection

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 47
; FirstLine = 41
; Executable = C:\MP_DX9_PartikelDemo3.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
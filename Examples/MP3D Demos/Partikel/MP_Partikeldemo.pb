;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_DX9_Partikel.pb
;// Created On: 22.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile für meine Partikelengine
;// 
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart


MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "3D Partikel Test") ; So soll es heissen
;MP_vsync(0) ; Ab gehts hier

Particle = MP_CreateParticleEmitter(0) ; Fontaine mit Wind
MP_PositionEntity (Particle,3,0,0) ; Setzt ein Objekt an einen x,y,z Ort
MP_ParticleColorRange (Particle,RGB(140,140,140),RGB(130,130,130)) ; Farbe von RGB Wert zu RGB Wert
MP_ParticleEmissionRate (Particle,200,5,0.05); Maximale Partikel, Ausstoßmenge und Zeiteinheit in s dafür
MP_ParticleTimeToLive(Particle, 3, 6); Partikellebenszeit von s bis s
MP_EntitySetVelocity(Particle,0,5,0,1.5); Ausstossrichtung als x,y,z und Verteilungsstärke
MP_EntitySetWind(Particle, 2, 0 ,0); Wind als x,y,z    

Particle2 = MP_CreateParticleEmitter(1) ; Explosion
MP_PositionEntity (Particle2,0,0,-5) ; Setzt ein Objekt an einen x,y,z Ort
MP_ParticleColorRange (Particle2,RGB(0,0,0),RGB(255,0,0)) ; Farbe von RGB Wert zu RGB Wert
MP_ParticleEmissionRate (Particle2,100,100,0.05);  Maximale Partikel, Ausstoßmenge und Zeiteinheit in s dafür
MP_ParticleTimeToLive(Particle2, 0.4, 0.6); Partikellebenszeit von s bis s
MP_ParticleSize (Particle2,2); Partikelgrösse
MP_EntitySetVelocity(Particle2,0,0,0,10); Ausstossrichtung als x,y,z und Verteilungsstärke
  
Particle3 = MP_CreateParticleEmitter(2) ;Vulkan aus MPs
MP_PositionEntity (Particle3,-5,0,0) ; Setzt ein Objekt an einen x,y,z Ort
MP_ParticleColorRange (Particle3,RGB(0,0,0),RGB(255,255,255)) ; Farbe von RGB Wert zu RGB Wert
MP_ParticleEmissionRate (Particle3,100,10,0.05);  Maximale Partikel, Ausstoßmenge und Zeiteinheit in s dafür
MP_ParticleTimeToLive(Particle3, 3, 4); Partikellebenszeit von s bis s
MP_EntitySetVelocity(Particle3,0,5,0,2.5); Ausstossrichtung als x,y,z und Verteilungsstärke
MP_EntitySetGravity(Particle3,0,-5,0) ; Gravitatio als x,y,z    

;Eigenes Bild einfügen;
Textur = MP_CatchTexture(?logostart,?logostart-?logostop)
MP_EntitySetTexture(Particle3,Textur)

camera=MP_CreateCamera() ; Kamera erstellen

x.f=0 : y.f=0 : z.f = -18 
MP_PositionEntity(camera,x.f,y.f,z.f) ; Kameraposition 

light=MP_CreateLight(1) ; Es werde Licht

cube=MP_CreateCube() ; Nen Würfel

MP_EntitySetColor (cube,RGB(100,100,255)) ; Würfel färben als R,G,B Wert

a = 0

MP_ParticleFadeOut(Particle, 1)
MP_ParticleFadeOut(Particle3, 1)
MP_ParticleChangeColor(Particle2, RGB(255,0,25), 3)

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen

    t.f + 1
    If t > 120
        t = 0
        a + 1
        If a > 24 : a = 0 : EndIf
        MP_SetParticleEmitter(Particle,a)
        MP_SetParticleEmitter(Particle2,a+1)
        MP_SetParticleEmitter(Particle3,a+2)       
    EndIf    
    
    MP_DrawText (10,10,"FPS: "+Str(MP_FPS ())) ; Textanzeige an Position x,y, Farbe RGB und Text$
    MP_TurnEntity (cube,0.05,0.5,1) ; Würfel Drehen
    
;      MP_UpdateParticle()
;  MP_RenderBegin()
;  MP_RenderMesh()
;  MP_RenderParticle()
  
  ;MP_RenderParticle()
  
;  MP_RenderEnd()
    
    
    MP_RenderWorld () ; Hier gehts los
    MP_Flip () ; 

Wend

End

DataSection
  logostart:
 IncludeBinary "c:\programme\purebasic\media\mp_logo.png" ; Mein MP Bild included
  logostop:
EndDataSection
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 52
; FirstLine = 50
; Executable = \\Hh\Transfer\MP_DX9_PartikelDemo.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Soundeffekt.pb
;// Created On: 22.4.2010
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile for Soundeffekte 
;// 
;////////////////////////////////////////////////////////////////

MP_Graphics3D (640,480,0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "MP3D SoundDemo") 

MP_Viewport(20,20,420,440)

;Gadgets 
TextGadget    (1,455,15,180,15,"Effektauswahl") 
ComboBoxGadget(2, 455, 30, 176, 21)
AddGadgetItem(2, -1,"Chorus")
AddGadgetItem(2, -1,"Compression")
AddGadgetItem(2, -1,"Distortion")
AddGadgetItem(2, -1,"Echo")
AddGadgetItem(2, -1,"Environmental Reverberation")
AddGadgetItem(2, -1,"Flange")
AddGadgetItem(2, -1,"Gargle")
AddGadgetItem(2, -1,"Parametric Equalizer")
AddGadgetItem(2, -1,"Waves Reverberation")
SetGadgetState(2, 3)
TextGadget    (3,455,55,180,15,"Effektstärke: 50") 
TrackBarGadget(4,455,70,180,20,0,100) 
SetGadgetState(4,50) 
TextGadget    (5,455,95,180,15,"Pan: 0") 
TrackBarGadget(6,455,110,180,20,0,200) 
SetGadgetState(6,100) 
TextGadget    (7,455,135,180,15,"Volume: 100") 
TrackBarGadget(8,455,150,180,20,0,100) 
SetGadgetState(8,10000) 
TextGadget    (9,455,175,180,15,"Frequenz: 44100") 
TrackBarGadget(10,455,190,180,20,0,88200) 
SetGadgetState(10,44100) 

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht

Mesh = MP_Create3DText("","MP 3D")
MP_PositionEntity (Mesh, -MP_MeshGetWidth(Mesh)/2 ,-MP_MeshGetHeight(Mesh)/2,-MP_MeshGetDepth(Mesh)/2)

MP_PositionEntity (Mesh,0,0,5) ; Position des Würfels

Sound = MP_CatchSound(?Music)


#direct = 0

If #direct 

  ;Hiermit verändere ich direkt die Effektparamater von Echo, einfach mal vergleichen

  Structure DSFXEcho
      fWetDryMix.f
      fFeedback.f
      fLeftDelay.f
      fRightDelay.f
      lPanDelay.l 
  EndStructure

  Echo.DSFXEcho
  Echo\fWetDryMix = 50;#DSFXECHO_WETDRYMIX_MAX
  Echo\fFeedback  = 50 ;
  Echo\fLeftDelay = 200 ;
  Echo\fRightDelay= 200;
  Echo\lPanDelay  = 0;

  MP_SoundSetEffect (Sound, 4,50,@Echo)

Else

  MP_SoundSetEffect (Sound, 4,50);,@Echo)

EndIf

MP_PlaySound(Sound,1) 

Effstr = 50 ; Effektstäre 50%
EffWa = 4 ; EchoEffekt

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

  Select  WindowEvent()
    Case #PB_Event_CloseWindow 
      End
    Case #PB_Event_Gadget 
      Select EventGadget() 
        
        Case 2; Effektauswahl
             EffWa = GetGadgetState(2) + 1
             MP_StopSound(Sound) 
             MP_SoundSetEffect (Sound, EffWa  ,Effstr)
             MP_PlaySound(Sound,1) 
        Case 4 ; Effektstärke
             Effstr = GetGadgetState(4)
             SetGadgetText(3,"Effektstärke: "+Str(Effstr))
             MP_StopSound(Sound) 
             MP_SoundSetEffect (Sound, EffWa  ,Effstr)
             MP_PlaySound(Sound,1) 
        Case 6 ; Pan
             Pan = GetGadgetState(6)
             SetGadgetText(5,"Pan: "+Str(Pan-100))
             MP_SoundSetPan(Sound, Pan-100)
        
        Case 8 ; Volumen
             Vol = GetGadgetState(8)
             SetGadgetText(7,"Volume: "+Str(Vol))
             MP_SoundSetVolume(Sound, Vol)
             
        Case 10 ; Frequenz
             Freq = GetGadgetState(10)
             SetGadgetText (9,"Frequenz: "+Str(Freq)) 
             MP_SoundSetFrequency (Sound, Freq)

      EndSelect 
  EndSelect 

    MP_TurnEntity (Mesh,0.1,0.2,0.3) 
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar

Wend


  DataSection
    Music: IncludeBinary "hey.wav"
; IDE Options = PureBasic 5.41 LTS (Windows - x64)
; CursorPosition = 50
; FirstLine = 34
; Executable = C:\MP_Soundeffect.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
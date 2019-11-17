;******************************************************************************
;******************************************************************************
;***                                                                        ***
;***  XMas Run 2 [preview]  by Epyx 09/11                                   ***
;***  Tile-Engine Test  PureBasic 4.51 & MP3d a30                           ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***   Flag  1  - Von unten durchspringbar                                  ***
;***   Flag  2  - Blockt in alle Richtungen                                 ***
;***   Flag  7  - Leiter / Liane zum hoch und runter klettern               ***
;***                                                                        ***
;***   Flag  90 - Wasser Modus                                              ***
;***   Flag 70-79 Coin Stein (wird herrunter gezählt bis 70 )               ***
;***   Flag  60 - Tödliches Teil                                            ***
;***                                                                        ***
;***   Bonus  2 - Coin                                                      ***
;***   Bonus  3 - Info                                                      ***
;***   Bonus  4 - Info                                                      ***
;***   Bonus  7 - Schlüssel Rot                                             ***
;***   Bonus  8 - Schlüssel Gelb                                            ***
;***                                                                        ***
;***   Flag 100 - Startpunkt Spieler                                        ***
;***   Flag 140 - Startpunkt Gegner 1 ( Blob )                              ***
;***   Flag 141 - Startpunkt Gegner 2 ( Fisch )                             ***
;***                                                                        ***
;******************************************************************************
;******************************************************************************




Declare   AddJumpingCoin(X,Y)
Declare   AddSplash(Type, X,Y)
Declare   AddGegner(Type, X,Y)
Declare   AddParticle(Type, X,Y, AX.f, AY.f, DAX.f, DAY.f, AT.f )
Declare   Correct_Z()
Declare.s SetNew_Level(Level)



InitSound()
EP_Init2dMap()
EP_initFXLib()

Var_Joypad = InitJoystick()


;{- Variablen

#Flag_BlockTile1  = 1    ; Spieler wird nur von oben geblockt
#Flag_BlockTile2  = 2    ; Spieler wird von allen Seiten geblockt
#Flag_KletterTile = 7    ; Spieler kann klettern
#Flag_WasserTile  = 90   ; Spieler befindet sich im Wasser
#Flag_JumpTiles   = 89   ; Ein Tile mit dem wert unter dem des Wassers sind alle Tiles bespringbar ( Wasserflag - 1 !!! )

#Flag_GateRed     = 120
#Flag_GateYellow  = 121

#Item_BonusCoin   = 2
#Item_BonusInfo   = 3    ; 3 und 4 sind LevelInfo Aktivator

#Item_KeyRed      = 7
#Item_KeyYellow   = 8

#Flag_StartPunkt  = 100
#Flag_StartEnemy1 = 140


Structure TinyPart_src
  
         Spr.l
           X.f
           Y.f
       Trans.f
       
          AX.f
          AY.f
          AT.f
          
         DAX.f
         DAY.f 
               
EndStructure
Global NewList TinyPat.TinyPart_src()

Structure NMY_src
  
         Spr.l
           X.f
           Y.f
              
          AX.f
       Speed.f       
       
        Anim.l
    AnimLeft.l
   AnimRight.l
   AnimSpeed.f
    
        Face.f
        Base.l 
         Dir.l 
        Type.l
      YTrack.l
EndStructure
Global NewList Enemy.NMY_src()


Global JumpCoin,  Player_1, FX_Beam, FX_Star, Play_Head, SmallTitle, Info_Desk, Thump, Zeit, JumpCoin,Title, BackGround_Layer1, BackGround_Layer3, BackGround_Layer2
Global Dim Gegner(10) : Global Dim BluePA(10) : Global Dim KeyCard(5) : Dim Menu_pos(3)
Global Dim InfoTXT.s(13) : For t = 0 To 12 : InfoTXT(t) = "No info text defined" : Next t : InfoTXT(t) = "                   Press Enter"

Menu_pos(0) = 310 : Menu_pos(1) = 375 : Menu_pos(2) = 440 : Menu_pos(3) = 520

;}



Res = MessageRequester("XMas-Run2","Fullscreen?",#PB_MessageRequester_YesNo)


If Res = 6 ; Yep Fullscreen pleassse
   MP_Graphics3D (800,600,32,0) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0;
   Fullscreen = 1 : ShowCursor_(0)
Else
   MP_Graphics3DWindow(0, 0, 800,600 , "XMas-Run2 by Epyx",   #PB_Window_ScreenCentered) : Fullscreen = 0 
EndIf





StartTime = timeGetTime_()
; Show Title screen and prepare the Game
TitleScreen = MP_CatchSprite(?TitL, ?TitLEnd-?TitL)
MP_DrawSprite(TitleScreen,0,0,255) : MP_RenderWorld () : MP_Flip ()

;Muzax_Menu     = CatchModule(#PB_Any,?MSX3, ?MSX3End-?MSX3)
;If Muzax_Menu<>0 : PlayModule(Muzax_Menu) : EndIf : FirstStart = 0

Muzax_Menu     = CatchMusic(#PB_Any,?MSX3, ?MSX3End-?MSX3)
If Muzax_Menu<>0 : PlayMusic(Muzax_Menu) : EndIf : FirstStart = 0






EP_SetGFXPath("gfx\") ; Den relativen Pfad zu unserer Grafik angeben (damit wird der in der Map gepeicherte Pfad ignoriert)
EP_SetMapArea(0, 00, 25, 19) ; anzeige Bereich definieren

UsePNGImageDecoder()
MP_AmbientSetLight(RGB(0,0,0))


BackGround_Layer1 = MP_CatchSprite(?Back1, ?Back1End-?Back1) : Layer1_Height = MP_SpritegetHeight(BackGround_Layer1)
BackGround_Layer3 = MP_CatchSprite(?Back3, ?Back3End-?Back3)
BackGround_Layer2 = MP_CatchSprite(?Back2, ?Back2End-?Back2) 




Player_1   = MP_CatchSprite(?Player, ?PlayerEnd-?Player) : MP_SpriteSetAnimate(Player_1 ,10, 0 ,30, 32) 
SmallTitle = MP_CatchSprite(?SmTit, ?SmTitEnd-?SmTit)
Info_Desk  = MP_CatchSprite(?TextBG, ?TextBGEnd-?TextBG)
Play_Head  = MP_CatchSprite(?PlayHD, ?PlayHDEnd-?PlayHD)
JumpCoin   = MP_CatchSprite(?JumpCo, ?JumpCoEnd-?JumpCo) : MP_Spritesetanimate(JumpCoin, 4 , 15, 32, 32)
BluePA(0)  = MP_CatchSprite(?BluePA, ?BluePAEnd-?BluePA) : MP_SpriteBlendingMode(BluePA(0), 5, 2)
BluePA(1)  = MP_CatchSprite(?BluePA, ?BluePAEnd-?BluePA) 

Gegner(0)  = MP_CatchSprite(?Gegner, ?GegnerEnd-?Gegner)   : MP_SpriteSetAnimate(Gegner(0),8, 0, 32,32)
Gegner(1)  = MP_CatchSprite(?Gegner2,?Gegner2End-?Gegner2) : MP_SpriteSetAnimate(Gegner(1),8, 0, 32,32)

FX_Beam = MP_CatchSprite(?Beam, ?BeamEnd-?Beam)
FX_Star = MP_CatchSprite(?Star, ?StarEnd-?Star)
Thump   = MP_CatchSprite(?Thump,?ThumpEnd-?Thump)

Title   = MP_CatchSprite(?Tit,?TitEnd-?Tit)

Correct_Z()



Sound_Jump     =  MP_Catchsound(?SFX1)
Sound_Collect  =  MP_Catchsound(?SFX2)
Sound_Splash1  =  MP_Catchsound(?SFX3)
Sound_Splash2  =  MP_Catchsound(?SFX4)
Sound_Aua      =  MP_Catchsound(?SFX5)
Sound_Collect2 =  MP_Catchsound(?SFX6)
Sound_Key      =  MP_Catchsound(?SFX7)

;Muzax_ingame   = CatchModule(#PB_Any,?MSX1, ?MSX1End-?MSX1)
;Muzax_Jingle   = CatchModule(#PB_Any,?MSX2, ?MSX2End-?MSX2)

Muzax_ingame   = CatchMusic(#PB_Any,?MSX1, ?MSX1End-?MSX1)
Muzax_Jingle   = CatchMusic(#PB_Any,?MSX2, ?MSX2End-?MSX2)


Punkte        = 0 
Gravitation.f = 0.4 : JPow.f         = -10.0 : Direction_Speed.f  = 3.0
Gravitation2.f= 0.01: JPow2.f        = -2    : Direction_Speed2.f = 1.0





While WT_Time < 2000 ; wait two seconds
   AkTime    = timeGetTime_() : WT_Time = AkTime-StartTime
   
     If MP_KeyHit(#PB_Key_Escape) : End : EndIf
     If Fullscreen = 0 
     Select WindowEvent()
       Case #PB_Key_Escape ; Programm beenden
           End      
       EndSelect
    EndIf   
   
    MP_DrawSprite(TitleScreen,0,0,255) : MP_RenderWorld () : MP_Flip ()
    Delay(10)
Wend

MP_FreeSprite(TitleScreen) ;Delete the Title Picture, 










MainMenu:

;EP_LoadMap("maps\menu.map") ; Karte Laden

EP_CatchMap(?Mapsmap) ; Karte aus dem Speicher
EP_SetTileGFXCatch (1)
EP_CatchTileGFX(?Graf1,?Graf2-?Graf1)
EP_CatchAnimTile(?Graf2,?Graf3-?Graf2)
EP_CatchAnimTile(?Graf3,?Graf4-?Graf3)
EP_CatchAnimTile(?Graf4,?Graf5-?Graf4)
EP_CatchAnimTile(?Graf5,?Graf6-?Graf5)
EP_CatchAnimTile(?Graf6,?Graf7-?Graf6)
EP_CatchAnimTile(?Graf7,?Graf8-?Graf7)
EP_CatchAnimTile(?Graf8,?Graf9-?Graf8)
EP_CatchAnimTile(?Graf9,?Graf10-?Graf9)
EP_CatchAnimTile(?Graf10,?Graf11-?Graf10)
EP_CatchAnimTile(?Graf11,?Graf12-?Graf11)
EP_CatchAnimTile(?Graf12,?Graf13-?Graf12)
EP_CatchAnimTile(?Graf13,?Graf14-?Graf13)


Maximal_X_Scroller = (EP_GetMapSizeX() * EP_GetTileSize()) - (24*EP_GetTileSize()) 
Correct_Z()

;If Muzax_Menu<>0   : StopModule(Muzax_Ingame) : EndIf
;If Muzax_Jingle<>0 : StopModule(Muzax_Jingle) : EndIf

If Muzax_Menu<>0   : StopMusic(Muzax_Ingame) : EndIf
If Muzax_Jingle<>0 : StopMusic(Muzax_Jingle) : EndIf

;If Muzax_Menu<>0 And FirstStart = 1 : PlayModule(Muzax_Menu) : EndIf : FirstStart = 1

If Muzax_Menu<>0 And FirstStart = 1 : PlayMusic(Muzax_Menu) : EndIf : FirstStart = 1




Menu_point = 0
MenuEnd    = 0
About      = 0 
JLocker    = 1

While MenuEnd = 0
     
     If IsMusic(Muzax_ingame)<>0
        If GetMusicPosition(Muzax_Menu) = 255 : SetMusicPosition(Muzax_Menu,0) : EndIf
     EndIf

     
    If Fullscreen = 0 
     Select WindowEvent()
       Case #PB_Key_Escape ; Programm beenden
           End      
       EndSelect
    EndIf
    
    
    
   If Var_Joypad <> 0 ; Joystick enabled ?? okay activate Joystick movement
       ExamineJoystick(0)
       Var_JoyY = JoystickAxisY(0)
       Var_JoyB = JoystickButton(0,1)
       
       If Var_JoyY <> 0 And JoyLockY = 0 : JoyLockY = JLocker : JLocker + 1 : EndIf
       If Var_JoyY =  0 And JoyLockY <>0 : JoyLockY = 0                     : EndIf
       If Var_JoyB<>0 And JButtonLocked = 0 : JButtonLocked = JLocker : JLocker+1 : EndIf ; Lock JoyButton 
       If Var_JoyB= 0 And JButtonLocked<> 0 : JButtonLocked = 0 : EndIf ; Unlock JoyButton
   EndIf
    
   If About = 0 
        
     If MP_KeyHit(#PB_Key_Escape) : End : EndIf
     If MP_KeyHit(#PB_Key_Up) Or (Var_JoyY   =-1 And JoyLockY<>JMovedY) : MP_Playsound(Sound_Collect2) : Menu_point - 1 : JMovedY = JoyLockY : EndIf
     If MP_KeyHit(#PB_Key_Down) Or (Var_JoyY = 1 And JoyLockY<>JMovedY) : MP_Playsound(Sound_Collect2) : Menu_point + 1 : JMovedY = JoyLockY : EndIf
     If MP_KeyHit(#PB_Key_Return) Or (Var_JoyB<>0 And Locked<>JButtonLocked) : MP_Playsound(Sound_Collect) : Locked = JButtonLocked
       If Menu_point = 0 Or Menu_point = 2 : MenuEnd = 1 : EndIf
       If Menu_point = 1 : About = 1 : EndIf
     EndIf  
      
     If Menu_point < 0 : Menu_point = 0 : EndIf
     If Menu_point > 2 : Menu_point = 2 : EndIf
 
     EP_Text32(0,400,310,"Start the Game",1 )
     EP_Text32(0,400,375,"About the Game",1 )
     EP_Text32(0,400,440,"Exit this Game",1 )
   
   Else
     Menu_point = 3
     
     EP_Text16(0,400 ,300,"Coding and Graphics by Epyx 2011",1 )
     EP_Text16(0,400 ,320,"Music by Tomas Danko , Guardian Angel",1 )
     EP_Text16(0,400 ,340,"               and Dimension X",1)
     EP_Text16(0,400 ,380,"Use Cursor Keys to control Santa",1 )
     EP_Text16(0,400 ,400,"Press Space to Jump             ",1 )
     EP_Text16(0,400 ,420,"Collect all the coins in the Map",1 )
     EP_Text16(0,400 ,460,"This is the example Game of the",1 )
     EP_Text16(0,400 ,480,"mp3d.lib tile engine.         ",1 )
     EP_Text32(0,400, 520,"Back to Menu",1 )
     
     If MP_KeyHit(#PB_Key_Return) Or MP_KeyHit(#PB_Key_Escape) Or (Var_JoyB<>0 And Locked<>JButtonLocked): MP_Playsound(Sound_Collect) : Menu_point = 1 : about = 0 : Locked = JButtonLocked : EndIf 
   EndIf
   
   MP_DrawSprite(BackGround_Layer2, Layer2_X.f ,250) : MP_DrawSprite(BackGround_Layer2, 800 + Layer2_X.f ,250)   
   MP_DrawSprite(BackGround_Layer1,0,-400)
   
   Menu_X + 1 : If Menu_X > Maximal_X_Scroller : Menu_X = 0 : EndIf   
   Layer2_X.f - 0.3 : If Layer2_X.f < -800 : Layer2_X.f + 800 : EndIf
   
   EP_MapPosition (Menu_X, 0)  : EP_DrawMap(); Die Map auf den Bildschirm zeichnen
   
   MP_DrawFrameSprite(Player_1, 120, Menu_pos(Menu_point),  Int(Player_FaceR.f), 255) :
   MP_DrawFrameSprite(Player_1, 655, Menu_pos(Menu_point),  Int(Player_FaceR.f)+5, 255)
   Player_FaceR + 0.15 : If Player_FaceR > 2.8 : Player_FaceR = 0 : EndIf
   
   MP_DrawSprite(Title,35,50)

   MP_RenderWorld ()
   MP_Flip ()

Wend



If Menu_point = 2 : End : EndIf


Level      = 1
Leben      = 3


NextLevel:



Level$ = SetNew_Level(Level)


RoundReset: ;Restart this Level




ClearList(Enemy()) 
ClearList(TinyPat())

;EP_LoadMap(Level$) ; Karte Laden

Select Level
  Case 1
    EP_CatchMap(?MapLevel1)
    EP_CatchTileGFX(?Graf1,?Graf2-?Graf1)
    EP_CatchAnimTile(?Graf2,?Graf3-?Graf2)
    EP_CatchAnimTile(?Graf3,?Graf4-?Graf3)
    EP_CatchAnimTile(?Graf4,?Graf5-?Graf4)
    EP_CatchAnimTile(?Graf5,?Graf6-?Graf5)
    EP_CatchAnimTile(?Graf6,?Graf7-?Graf6)
    EP_CatchAnimTile(?Graf7,?Graf8-?Graf7)
  Case 2
    EP_CatchMap(?MapLevel2)
    EP_CatchTileGFX(?Graf1,?Graf2-?Graf1)
    EP_CatchAnimTile(?Graf2,?Graf3-?Graf2)
    EP_CatchAnimTile(?Graf3,?Graf4-?Graf3)
    EP_CatchAnimTile(?Graf4,?Graf5-?Graf4)
    EP_CatchAnimTile(?Graf5,?Graf6-?Graf5)
    EP_CatchAnimTile(?Graf6,?Graf7-?Graf6)
    EP_CatchAnimTile(?Graf7,?Graf8-?Graf7)
    EP_CatchAnimTile(?Graf8,?Graf9-?Graf8)
    EP_CatchAnimTile(?Graf9,?Graf10-?Graf9)
    EP_CatchAnimTile(?Graf10,?Graf11-?Graf10)
    EP_CatchAnimTile(?Graf11,?Graf12-?Graf11)
    EP_CatchAnimTile(?Graf12,?Graf13-?Graf12)
  Case 3
    EP_CatchMap(?MapLevel3)
    EP_CatchTileGFX(?Graf1,?Graf2-?Graf1)
    EP_CatchAnimTile(?Graf2,?Graf3-?Graf2)
    EP_CatchAnimTile(?Graf3,?Graf4-?Graf3)
    EP_CatchAnimTile(?Graf4,?Graf5-?Graf4)
    EP_CatchAnimTile(?Graf5,?Graf6-?Graf5)
    EP_CatchAnimTile(?Graf6,?Graf7-?Graf6)
    EP_CatchAnimTile(?Graf13,?Graf14-?Graf13)
EndSelect 


Layer1_Mov.f = (Layer1_Height / ((EP_GetMapSizeY()+9)*EP_GetTileSize()) )
Layer2_Mov.f = ((Layer1_Height-400 ) / ((EP_GetMapSizeY()+19)*EP_GetTileSize()) )
Layer3_Mov.f = ((Layer1_Height-450 ) / ((EP_GetMapSizeY()+19)*EP_GetTileSize()) )

Maximal_X_Scroller = (EP_GetMapSizeX() * EP_GetTileSize()) - (25*EP_GetTileSize()) ; Maximale horizontzale grenze des Scrollens
Maximal_Y_Scroller = (EP_GetMapSizeY() * EP_GetTileSize()) - (18*EP_GetTileSize()) ; Maximale vertikale grenze des Scrollens


StartPunkte = EP_CountFlag(#Flag_StartPunkt) ; Den Startpunkt (Flag 100) in der Map suchen. bzw. die Anzahl, ähh also ob zumindest mehr als 0 in der Map sind :)
If StartPunkte>0
  EP_FindFlag(#Flag_StartPunkt,1) ; Den ersten Eintrag finden 
  xx.f = (EP_GetFindResultX()*EP_GetTileSize()) - 380 :  yy.f= (EP_GetFindResultY()*EP_GetTileSize()) - 288
EndIf


; Anzahl der Gegner Typ 1 Auslesen und in Karte Setzen
GegnerStart = EP_CountFlag(140) : For t = 1 To GegnerStart : EP_FindFlag(140,t)
Gxx.f = (EP_GetFindResultX()*EP_GetTileSize()) : Gyy.f = (EP_GetFindResultY()*EP_GetTileSize())
AddGegner(0, Gxx, Gyy) : Next t  

; Anzahl der Gegner Typ 2 Auslesen und in Karte Setzen
GegnerStart = EP_CountFlag(141) : For t = 1 To GegnerStart : EP_FindFlag(141,1) 
Gxx.f = (EP_GetFindResultX()*EP_GetTileSize()) : Gyy.f = (EP_GetFindResultY()*EP_GetTileSize())
AddGegner(1, Gxx, Gyy) : EP_SetMapFlag((Gxx/32), (Gyy/32), 90)  : Next t ; Beim Fisch gegner flag durch wasser Flag ersetzen  

If Muzax_Menu<>0 : StopMusic(Muzax_Menu) : EndIf

If Muzax_ingame<>0
   PlayMusic(Muzax_ingame)
EndIf



For t = 0 To 5 : KeyCard(t) = 0 : Next t
ActualKey  = 0


RoundTimer = timeGetTime_()
Layer2_X.f = 0

LevelGoal  = EP_CountItem(2) ; <- Bonus coins zählen 
Gesammelt  = 0


Runnig_Side   = 0   : Player_Frame.f = 0
Sprite_posX   = 384 : Sprite_posY    = 284


Intro_beam_posY = -300
BeamTrans       = 255 
Intro_Part      = 1
Outro_Part      = 0
ShowPlayer      = 0
Control_enabled = 0
Player_Death    = 0
AuaSound        = 0
JinglePlay      = 0
GameEnd         = 0

Var_JoyX        = 0
Var_JoyY        = 0
Var_JoyB        = 0
JLocker         = 1

Correct_Z()





While GameEnd = 0
  
     AkTime    = timeGetTime_() : FPX = MP_FPS() 

     
     If Intro_Part <> 1 And Outro_Part <> 1
        AKZeit = Zeit - (Aktime - RoundTimer) / 1000
        If AKZeit<0 : Player_Death = 1 : AKZeit = 0 : EndIf
     EndIf
     
     If IsMusic(Muzax_ingame)<>0
        If GetMusicPosition(Muzax_ingame) = 255 : SetMusicPosition(Muzax_ingame,0) : EndIf
     EndIf

     
   If Fullscreen = 0 
     Select WindowEvent()
       Case #PB_Key_Escape ; Programm beenden
           End      
       EndSelect
    EndIf
     
     
     
If MP_Keyhit(#PB_Key_Escape) : Leben = 0 : GameEnd=1 : EndIf ; Zurück ins Hauptmenü
     
     
     
     
  ;Steuerung ############################################################################################
If Control_enabled = 1
  
  
  If Var_Joypad <> 0 ; Joystick enabled ?? okay activate Joystick movement
    
      ExamineJoystick(0)
      Var_JoyX = JoystickAxisX(0)
      Var_JoyY = JoystickAxisY(0)
      Var_JoyB = JoystickButton(0,1)
      
      If Var_JoyB<>0 And JButtonLocked = 0 : JButtonLocked = JLocker : JLocker+1 : EndIf ; Lock JoyButton 
      If Var_JoyB= 0 And JButtonLocked<> 0 : JButtonLocked = 0 : EndIf ; Unlock JoyButton

      
  EndIf
  
  
    
    
    
       
     If MP_KeyDown(#PB_Key_Left) Or Var_JoyX = -1 
       BackUpX.f = XX.f : xx.f - Direction_Speed.f : Runnig_Side =-1 
       If Jump = 0 And Fall = 0 : Player_Frame - 0.1  
       If Player_Frame < 5.0 : Player_Frame = 7.9 : EndIf   : EndIf 
     EndIf
     
     If MP_KeyDown(#PB_Key_Right) Or Var_JoyX=  1
       BackUpX.f = XX.f : xx.f + Direction_Speed.f : Runnig_Side = 1
       If Jump = 0 And Fall = 0 : Player_Frame + 0.1 
       If Player_Frame > 3.0 : Player_Frame - 3.0 : EndIf : EndIf  
     EndIf
     
     
     
     If (MP_KeyDown(#PB_Key_Space) And (Jump=0) And (Fall=0) And Over_Head = 0 And Mitte_Figur <> 7) Or (Var_JoyB <> 0 And (Jump=0) And (Fall=0) And Over_Head = 0 And Mitte_Figur <> 7)
       BackUpY.f = YY.f : Jump=1 : Jump_pow.f=JPow.f 
       If Runnig_Side = 1 : Player_Frame = 3 : EndIf
       If Runnig_Side =-1 : Player_Frame = 4 : EndIf 
       MP_playSound(Sound_Jump)
     EndIf
     
     
     
     If (Mitte_Figur = #Flag_KletterTile Or Unter_Figur = #Flag_KletterTile) ; Liane / Leiter Steuerung       
        If MP_KeyDown(#PB_Key_Up)   Or Var_JoyY = -1 : yy.f - 2 : Player_Frame - 0.05 : EndIf
        If MP_KeyDown(#PB_Key_Down) Or Var_JoyY =  1 : yy.f + 2 : Player_Frame - 0.05 : EndIf
        If Unter_Figur <> #Flag_KletterTile : yy.f - 2 : EndIf 
        If Player_Frame < 8.0 : Player_Frame = 9.9 : EndIf
     EndIf
     
     
     If (Mitte_Figur = #Flag_WasserTile) ; Im Wasser Steuerung
        If Uber_Figur <> 0
           If MP_KeyDown(#PB_Key_Up)   Or Var_JoyY = -1 : Jump_pow.f - 0.1:  EndIf
           If MP_KeyDown(#PB_Key_Down) Or Var_JoyY =  1 : Jump_pow.f + 0.1:  EndIf
        EndIf
        If Mitte_Figur=#Flag_WasserTile And Uber_Figur=#Flag_WasserTile 
          If Jump_pow< -1.0 : Jump_pow = -1.0 : EndIf   
          If Jump_pow>  2.0 : Jump_pow =  2.0 : EndIf   
        EndIf
        If Unter_Figur = 0
          AnMtn.f + 0.03 : If AnMtn.f > 2.0 : AnMtn.f = 0 : EndIf
          If Runnig_Side = 1 : Player_Frame = 10 + AnMtn.f : EndIf
          If Runnig_Side =-1 : Player_Frame = 12 + AnMtn.f : EndIf  
        EndIf    
     EndIf    
     
EndIf 
     
     
     




     
     
     
     
     
     

     If XX < 0 : XX = 0 : EndIf : If YY < 0 : YY = 0 : EndIf     
     If XX>Maximal_X_Scroller : XX = Maximal_X_Scroller : EndIf
     If YY>Maximal_Y_Scroller : YY = Maximal_Y_Scroller : EndIf
     
     
     Player_Face = Int(Player_Frame)
     
     
     
     Layer2_X = 0 - (XX/2) : If Layer2_X < -800 : Layer2_X + 800 : EndIf
     Layer3_X = 0 - (XX/3) : If Layer3_X < -800 : Layer3_X + 800 : EndIf
     
     MP_DrawSprite(BackGround_Layer1,0,(-300)-(yy*Layer1_Mov)) ; Hintergrund Paralax Grafik Ebenen
     MP_DrawSprite(BackGround_Layer3,Layer3_X ,150-(yy*Layer3_Mov)) : MP_DrawSprite(BackGround_Layer3,800 + Layer3_X ,150-(yy*Layer3_Mov))
     MP_DrawSprite(BackGround_Layer2,Layer2_X ,300-(yy*Layer2_Mov)) : MP_DrawSprite(BackGround_Layer2,800 + Layer2_X ,300-(yy*Layer2_Mov))
     
     
    
     
     EP_MapPosition (xx.f, yy.f)  ; Die Position der Map angeben, in Pixel !!  
     
     EP_DrawMap()                 ; Die Map auf den Bildschirm zeichnen
  

     

      XY_Block    = EP_Pixel2Map_Y(Sprite_posY+32)
      Unter_Figur = EP_GetMapFlag(EP_Pixel2Map_X(Sprite_posX+16), XY_Block)                      : 
      Uber_Figur  = EP_GetMapFlag(EP_Pixel2Map_X(Sprite_posX+16), EP_Pixel2Map_Y(Sprite_posY-6)) ;: If Uber_Figur   > 10 : Uber_Figur = 0  : EndIf
      Rechts_Figur= EP_GetMapFlag(EP_Pixel2Map_X(Sprite_posX+30), EP_Pixel2Map_Y(Sprite_posY+16)): 
      Links_Figur = EP_GetMapFlag(EP_Pixel2Map_X(Sprite_posX+2 ), EP_Pixel2Map_Y(Sprite_posY+16)): 
      
      
      
      
      
      
  
      
      

      
      
      If  Rechts_Figur > 119 And Rechts_Figur<130 : If  KeyCard(Rechts_Figur-119) <> Rechts_Figur-119 : Rechts_Figur = #Flag_BlockTile2 : EndIf : EndIf
      If  Links_Figur  > 119 And Links_Figur<130  : If  KeyCard(Links_Figur-119)  <> Links_Figur-119  : Links_Figur  = #Flag_BlockTile2 : EndIf : EndIf
 ;     If  Unter_Figur > 119 And Unter_Figur<130   : If  KeyCard(Unter_Figur-119) <> Unter_Figur-119   : Unter_Figur = #Flag_BlockTile2  : EndIf : EndIf
 ;     If  Uber_Figur  > 119 And Uber_Figur<130    : If  KeyCard(Uber_Figur-119)  <> Uber_Figur-119    : Uber_Figur  = #Flag_BlockTile2  : EndIf : EndIf
        
      
      If Unter_Figur  > #Flag_JumpTiles : Unter_Figur = 0 : EndIf
      If Rechts_Figur > #Flag_JumpTiles : Rechts_Figur = 0: EndIf
      If Links_Figur  > #Flag_JumpTiles : Links_Figur = 0 : EndIf
      
      
      
      
      
      BonusX = EP_Pixel2Map_X(Sprite_posX+16) : BonusY = EP_Pixel2Map_Y(Sprite_posY+16)
      Mitte_Figur = EP_GetMapFlag(BonusX, BonusY)
      Bonus_Figur = EP_GetMapItem(BonusX, BonusY)
      
      

      
      
      
      
      If Rechts_Figur = #Flag_BlockTile2 : XX.f = BackUpX.f : EndIf
      If Links_Figur  = #Flag_BlockTile2 : XX.f = BackUpX.f : EndIf
      If Rechts_Figur = #Flag_BlockTile2 And Runnig_Side = -1 : XX.f - 1.0  : EndIf
      If Links_Figur  = #Flag_BlockTile2 And Runnig_Side =  1 : XX.f + 1.0  : EndIf
      
      
      
      
      
      If (Mitte_Figur = #Flag_WasserTile And LastTile <> #Flag_WasserTile) : LastTile=#Flag_WasserTile : Jump_pow.f= (Jump_pow.f/10.0) : MP_PlaySound(Sound_Splash1) 
        Pa_X = EP_ScreenX2MapX(Sprite_posX) : Pa_Y = EP_ScreenY2MapY(Sprite_posY) : For t = 0 To 8 : AddSplash(1, Pa_X+(Random(10)-Random(20)), Pa_Y+10) : Next t : EndIf       
      If  Mitte_Figur = #Flag_WasserTile And Uber_Figur= #Flag_WasserTile 
           Gravitation.f = Gravitation2.f : JPow.f = JPow2.f : Direction_Speed.f = Direction_Speed2.f 
        ElseIf Mitte_Figur = #Flag_WasserTile And Uber_Figur <> #Flag_WasserTile And Unter_Figur<>#Flag_WasserTile
           Gravitation.f = 0.4 : JPow.f = -10.0 

      EndIf      
      If Mitte_Figur <> #Flag_WasserTile And Uber_Figur <> #Flag_WasserTile And Unter_Figur <> #Flag_WasserTile And LastTile=#Flag_WasserTile
           For t = 0 To 8 : AddSplash(0, Pa_X+(Random(10)-Random(20)), Pa_Y+10) : Next t
           Gravitation.f = 0.4 : JPow.f = -10.0 : Direction_Speed.f = 3.0 : LastTile = 0 : Info_gelesen = 0 : MP_PlaySound(Sound_Splash2)
      EndIf
        
      
      
      
      
      
      If Bonus_Figur > -1
      
         If Bonus_Figur = #Item_BonusCoin ; Goldmünze eingesammelt
            Gesammelt + 1 ; Yup wir haben einen Coin gesammelt
            Punkte + 100 : MP_PlaySound(Sound_Collect)
            
            If Gesammelt = LevelGoal : Outro_Part = 1 : EndIf ; Das Level erfolgreich abgeschlossen
            
         EndIf
         
         ; LevelGoal
          
         If Bonus_Figur = 7 : KeyCard(1) = 1 : ActualKey = 1 : MP_Playsound(Sound_Key) : EndIf
         If Bonus_Figur = 8 : KeyCard(2) = 2 : ActualKey = 2 : MP_Playsound(Sound_Key) : EndIf
         
        

         If Bonus_Figur=7 Or Bonus_Figur=8 Or Bonus_Figur = #Item_BonusCoin 
                 EP_SetMapItem(BonusX, BonusY, -1) ; Bonus wieder löschen
         EndIf  
           
      EndIf
      
      


      
      
      
      
      
      If Jump=1 ; Spieler Springt 
           yy + Jump_pow.f : Jump_pow.f + Gravitation.f
           If Jump_pow>0.0 : Jump_pow=0.0 : Jump=0 : EndIf
           If Uber_Figur=#Flag_BlockTile2 : Jump_pow=0.0 : Jump=0 : Fall=1: EndIf 
           
           If Uber_Figur=>70 And Uber_Figur<80 : Jump_pow=0.0 : Jump=0 : Fall=1: ; Mehrfach Bonus im Stein !!! 
             Punkte + 100 :  BNS_Stein = Uber_Figur : MP_Playsound(Sound_Collect2)
             Pa_X = EP_ScreenX2MapX(Sprite_posX) : Pa_Y = EP_ScreenY2MapY(Sprite_posY) : AddJumpingCoin(Pa_X, Pa_Y-60)           
             
              BNS_Stein -1 : EP_SetMapFlag(EP_Pixel2Map_X(Sprite_posX+16), EP_Pixel2Map_Y(Sprite_posY-6), BNS_Stein)
                 If BNS_Stein <70                    
                   EP_SetMapFlag(EP_Pixel2Map_X(Sprite_posX+16), EP_Pixel2Map_Y(Sprite_posY-6),  2); durch normalen Block-Stein ersetzen
                   EP_SetMapTile(EP_Pixel2Map_X(Sprite_posX+16), EP_Pixel2Map_Y(Sprite_posY-6), 37); Tile ersetzen
                   EP_SetMapItem(EP_Pixel2Map_X(Sprite_posX+16), EP_Pixel2Map_Y(Sprite_posY-6), -1); Itemwert auch löschen, falls es einen gibt  
                 EndIf

           EndIf 
      EndIf
      

      If (Unter_Figur < 1 And Jump=0) Or (Fall = 1) ; Spieler fällt      
           If Runnig_Side = 1 : Player_Frame = 3 : EndIf
           If Runnig_Side =-1 : Player_Frame = 4 : EndIf  
           Fall=1 : yy + Jump_pow.f : Jump_pow.f + Gravitation.f 
           If Jump_pow.f > 30.0 : Jump_pow.f = 30.0 : EndIf ; Die Fall Geschwindigkeit Limitieren (max 30, also nicht größer als ein Tile)
      EndIf
      
      
      If (Unter_Figur>0 And Jump=0) And (Unter_Figur>0 And Fall=1) ; Figur hat nach dem Fallen wieder festen Boden unter den Füßen
        
            If Unter_Figur = 60 : Player_Death = 1 : EndIf ; auf tödliches Teil gesprungen
        
        
            If Jump_pow > 23 : MP_PlaySound(Sound_Aua) : EndIf
            Jump_pow.f=0.0 : Fall=0         
            YY=  (XY_Block*32) - (284+30) ; Die Map unter der Figur kalibrieren ( 30 = Figur Höhe)
            If Runnig_Side = 1 : Player_Frame = 1 : EndIf
            If Runnig_Side =-1 : Player_Frame = 5 : EndIf   
      EndIf
      
      
      
      
      
      
      
      
      
     If Intro_Part = 1 ; Den kleinen Level Intro Start Beam anzeigen 
          MP_DrawSprite(FX_Beam, Sprite_posX, Intro_beam_posY , BeamTrans ) : Intro_beam_posY + 6 
          Pa_X = EP_ScreenX2MapX((Sprite_posX+Random(20))) : Pa_Y = EP_ScreenY2MapY(MP_Randomint(Intro_beam_posY,Intro_beam_posY+285)) : Pa_SiX.f = MP_Randomfloat(-0.5, 0.5)
          AddParticle(FX_Star, Pa_X , Pa_Y , Pa_SiX.f, 0.01, 0, 0.05, -5 ) 
          If Intro_beam_posY > -4 : Intro_beam_posY = -4  : ShowPlayer = 1 : BeamTrans - 10 : EndIf
          If BeamTrans < 0 : BeamTrans= 0 : Intro_Part = 0 : Control_enabled = 1 : EndIf
     EndIf
     
     
     
     If Outro_Part = 1 ; Den kleinen Level Intro Start Beam anzeigen 
           If IsMusic(Muzax_ingame)<>0 : StopMusic(Muzax_ingame) : EndIf ; stop ingame Music
           If Muzax_ingame<>0 And JinglePlay = 0 : ThumpTrans = 0 : Locked = JButtonLocked : TMEBonus = (AKZeit*100) : LFEBonus = (Leben*1000)
              PlayMusic(Muzax_Jingle) : SetMusicPosition(Muzax_Jingle, 0) : JinglePlay = 1: EndIf       
           Control_enabled = 0 ; Kontrolle Sperren        
           MP_DrawSprite(FX_Beam, Sprite_posX, Intro_beam_posY , BeamTrans ) : BeamTrans + 3 
           If BeamTrans > 255 : ShowPlayer = 0 : BeamTrans = 255 : Intro_beam_posY -5 : EndIf 
           Pa_X = EP_ScreenX2MapX((Sprite_posX+Random(20))) : Pa_Y = EP_ScreenY2MapY(MP_Randomint(Intro_beam_posY,Intro_beam_posY+285)) : Pa_SiX.f = MP_Randomfloat(-0.5, 0.5)
           AddParticle(FX_Star, Pa_X , Pa_Y , Pa_SiX.f, -0.01, 0, -0.07, -5 ) 
           If GetMusicPosition(Muzax_Jingle) = 1 And GetMusicRow(Muzax_Jingle) >6 : StopMusic(Muzax_Jingle) : EndIf
           If Intro_beam_posY < -350 
             MP_DrawSprite(Thump, 300, 100 , ThumpTrans ) : ThumpTrans + 5 : 
               If ThumpTrans > 255 : ThumpTrans = 255
                 EP_Text16(0,400, 360 ,"Time Bonus: "+Str(TMEBonus), 1 )
                 EP_Text16(0,400, 390 ,"Life Bonus: "+Str(LFEBonus), 1 )
                  If TMEBonus > 0 : TMEBonus - 100 : Punkte+100 : MP_PlaySound(Sound_Collect2) : Delay(10)    ; 100  Punkte für jede übrig gebliebene Sekunde
                  Else
                    If LFEBonus > 0 : LFEBonus - 1000 : Punkte+1000 : MP_PlaySound(Sound_Collect) : Delay(10) ; 1000 Punkte für jedes Leben
                    Else
                      
                        If Var_Joypad <> 0 ; Joystick enabled ?? okay activate Joystick movement
                            ExamineJoystick(0)
                            Var_JoyB = JoystickButton(0,1)
                            If Var_JoyB<>0 And JButtonLocked = 0 : JButtonLocked = JLocker : JLocker+1 : EndIf ; Lock JoyButton 
                            If Var_JoyB= 0 And JButtonLocked<> 0 : JButtonLocked = 0 : EndIf ; Unlock JoyButton
                        EndIf
                          
                         EP_Text16(0,400, 425 ,"Press Space for next Level", 1 ) 
                         If MP_KeyHit(#PB_Key_Space) : GameEnd = 2 : EndIf 
                         If Var_JoyB<>0 : GameEnd = 2  : EndIf
                         
                    EndIf
                  EndIf
               EndIf             
           EndIf
     EndIf
     
     
     If Player_Death = 1 ; The Player Death, restart the Game
         If AuaSound = 0 : MP_PlaySound(Sound_Aua) : AuaSound = 1 : X_death = Sprite_posX : Y_death.f = Sprite_posY : DeathAdder.f = -4 : EndIf ; args it hurts
         ShowPlayer = 0 : Control_enabled = 0 ; Player cant control         
         If IsMusic(Muzax_ingame)<>0 : StopMusic(Muzax_ingame) : EndIf ; stop ingame Music
         If Muzax_ingame<>0 And JinglePlay = 0 : PlayMusic(Muzax_Jingle) : SetMusicPosition(Muzax_Jingle, 1) : JinglePlay = 1: EndIf
         If GetMusicRow(Muzax_Jingle) > 20 : StopMusic(Muzax_Jingle) : EndIf
                  
         Y_death + DeathAdder.f : DeathAdder.f + 0.1 : If Y_death > 650 : StopMusic(Muzax_Jingle) : GameEnd = 1 : EndIf        
         MP_DrawFrameSprite(Player_1, X_death, Y_death,  Player_Face, 255)         
     EndIf
     
     
     
     
     If ShowPlayer = 1
         MP_DrawFrameSprite(Player_1, Sprite_posX, Sprite_posY,  Player_Face, 255)
     EndIf 
      
      

      
      
      
      EP_Text16(0,10 ,20,"Score: "+Str(Punkte),0 )
      EP_Text16(0,650,20,"Time: " +Str(AKZeit),0 )      
      MP_DrawSprite(SmallTitle, 280,0)
      MP_DrawRectSprite(Play_Head,20, 550, 0,0, (Leben*36), 32, 255)
      
      
      
      



      
      

      ; Tiny Sprite Partikel
      If ListSize(TinyPat()) > 0
          ForEach TinyPat()
            DelMe = 0            
            MP_DrawSprite(TinyPat()\Spr, EP_MapX2ScreenX(TinyPat()\X) , EP_MapY2ScreenY(TinyPat()\Y), TinyPat()\Trans)
            TinyPat()\X     + TinyPat()\AX
            TinyPat()\Y     + TinyPat()\AY
            TinyPat()\Trans + TinyPat()\AT            
            If TinyPat()\DAX <> 0 : TinyPat()\AX + TinyPat()\DAX : EndIf
            If TinyPat()\DAY <> 0 : TinyPat()\AY + TinyPat()\DAY : EndIf
            If TinyPat()\Trans <= 0 : DelMe = 1 : EndIf
            If DelMe = 1 : DeleteElement(TinyPat()) : EndIf                         
          Next
      EndIf
      
      
      
      
     ; Gegner verwaltung
      If ListSize(Enemy()) > 0
          ForEach Enemy()
            DelMe = 0 : Disp_GSP_X = EP_MapX2ScreenX(Enemy()\X) : Disp_GSP_Y = EP_MapY2ScreenY(Enemy()\Y)
            MP_DrawFrameSprite(Enemy()\Spr, Disp_GSP_X , Disp_GSP_Y , (Enemy()\Base+Enemy()\Face)  , 255)
      
            Enemy()\X + Enemy()\AX
            Enemy()\Face + Enemy()\AnimSpeed : If Enemy()\Face > Enemy()\Anim : Enemy()\Face = 0 : EndIf
           
            If MP_Spritepixelcollision(Enemy()\Spr, Disp_GSP_X , Disp_GSP_Y, Player_1, Sprite_posX, Sprite_posY) = 1
                   Player_Death = 1
            EndIf
  
            
            If Enemy()\Dir = 1
                 UGeg     = EP_GetMapFlag( EP_Pixel2Map_X(Disp_GSP_X+32) , Enemy()\YTrack+1 )
                 NGeg     = EP_GetMapFlag( EP_Pixel2Map_X(Disp_GSP_X+32) , Enemy()\YTrack   ) : If NGeg > 99 : NGeg = 0 : EndIf
              Else
                 UGeg  = EP_GetMapFlag(EP_Pixel2Map_X(Disp_GSP_X)   , Enemy()\YTrack+1)
                 NGeg  = EP_GetMapFlag(EP_Pixel2Map_X(Disp_GSP_X)   , Enemy()\YTrack  )    : If NGeg > 99 : NGeg = 0 : EndIf     
            EndIf

            
            
            If Enemy()\Type = 0
               If (UGeg <> 1 And UGeg<>2 And UGeg<>7) Or (NGeg <> -1 And NGeg<>0 And NGeg<>7) 
                   If Enemy()\Dir = 1 
                        Enemy()\Dir  = 0 : Enemy()\AX = (0 - Enemy()\Speed)  
                        Enemy()\Base = Enemy()\AnimRight 
                      Else  
                        Enemy()\Dir = 1 : Enemy()\AX = Enemy()\Speed 
                        Enemy()\Base = Enemy()\AnimLeft 
                   EndIf         
               EndIf
            EndIf
            
            
            If Enemy()\Type = 1
              If (NGeg <> 90 And NGeg<>90) 
                   If Enemy()\Dir = 1 
                        Enemy()\Dir  = 0 : Enemy()\AX = (0 - Enemy()\Speed)  
                        Enemy()\Base = Enemy()\AnimRight 
                      Else  
                        Enemy()\Dir = 1 : Enemy()\AX = Enemy()\Speed 
                        Enemy()\Base = Enemy()\AnimLeft 
                   EndIf         
               EndIf
            EndIf
            
            
            
            
            If DelMe = 1 : DeleteElement(Enemy()) : EndIf
             
             
          Next
      EndIf
      



      MP_DrawText(740,580,"FPS "+Str(FPX))
      MP_RenderWorld ()
      MP_Flip ()
      
      
      
      
      
      
      
      
      ; Info Screen einblenden
      If ((Bonus_Figur = #Item_BonusInfo) And Info_gelesen=0) Or ((Bonus_Figur = #Item_BonusInfo+1) And Info_gelesen=0) ; Info Angesprungen
         StoppTime    = timeGetTime_()  
         MP_PlaySound(Sound_Collect)
         If Var_JoyB<>0 : Locked = JButtonLocked : EndIf
         
            While Not MP_KeyHit(#PB_Key_Return) And Not MP_Keyhit(#PB_Key_Escape) 
              
               AkTime    = timeGetTime_()
               If IsMusic(Muzax_ingame)<>0
                  If GetMusicPosition(Muzax_ingame) = 255 : SetMusicPosition(Muzax_ingame,0) : EndIf
                EndIf
                
                If Var_Joypad <> 0 ; Joystick enabled ?? okay activate Joystick movement
                   ExamineJoystick(0)
                   Var_JoyB = JoystickButton(0,1)
                   If Var_JoyB<>0 And JButtonLocked = 0 : JButtonLocked = JLocker : JLocker+1 : EndIf ; Lock JoyButton 
                   If Var_JoyB= 0 And JButtonLocked<> 0 : JButtonLocked = 0 : EndIf ; Unlock JoyButton
                EndIf
                
                
                EP_Text16(0,10 ,20,"Score: "+Str(Punkte),0 )
                EP_Text16(0,650,20,"Time: " +Str(AKZeit),0 )      
                MP_DrawSprite(SmallTitle, 280,0)
                MP_DrawSprite(Info_Desk, 100,100)
                MP_DrawSprite(BackGround_Layer1,0,(-300)-(yy*Layer1_Mov)) ; Hintergrund Paralax Grafik Ebenen
                MP_DrawSprite(BackGround_Layer3,Layer3_X ,150-(yy*Layer3_Mov)) : MP_DrawSprite(BackGround_Layer3,800 + Layer3_X ,150-(yy*Layer3_Mov))
                MP_DrawSprite(BackGround_Layer2,Layer2_X ,300-(yy*Layer2_Mov)) : MP_DrawSprite(BackGround_Layer2,800 + Layer2_X ,300-(yy*Layer2_Mov))
                EP_DrawMap() 
                MP_DrawRectSprite(Play_Head,20, 550, 0,0, (Leben*36), 32, 255)
                For t = 0 To 13
                  EP_Text16(0,395,165+(t*20),InfoTXT(t),1 )
                Next t   
                
                If JButtonLocked <> Locked And Var_JoyB<>0 : Break : EndIf
              
                MP_RenderWorld ()
                MP_Flip ()
            Wend 
            
            Zeit + ((AkTime - StoppTime)/1000) ; Spielzeit Ausgleich
            Info_gelesen = 1 : Jump_pow = 0.0
            
      EndIf      
      If Bonus_Figur = -1 : Info_gelesen =0 : EndIf ; Zurück setzen  
      
       
  
Wend
  
If GameEnd = 1 ; Spieler hat ein Leben verloren
    If Leben>0 ; Life Control  
       Leben-1
       Goto RoundReset ; Uargs ein Goto, bitte verzeiht mir
    EndIf
    
    If Leben=0 : Goto MainMenu : EndIf
     
EndIf

If GameEnd = 2 ; Spieler hat das Level beendet
       StopMusic(Muzax_Jingle)
       Level + 1
       If Level = 4 : Goto MainMenu : EndIf ; Tjo derzeit gibts nur 3 Level
       Goto NextLevel ; Oh mein Gott, er machts schon wieder :(
EndIf




  
DataSection
  
   Mapsmap:
   IncludeBinary "maps\menu.map"
   MapLevel1:
   IncludeBinary "Maps\Level1.Map"
   MapLevel2:
   IncludeBinary "Maps\Level2.Map"
   MapLevel3:
   IncludeBinary "Maps\Level3.Map"
   
   Graf1:
   IncludeBinary "gfx\XMas_Tiles2.bmp"
   Graf2:
   IncludeBinary "gfx\wellen_anim.bmp"
   Graf3:
   IncludeBinary "gfx\Water_anim.bmp"
   Graf4:
   IncludeBinary "gfx\Coin_Anim.bmp"
   Graf5:
   IncludeBinary "gfx\Frage1.bmp"
   Graf6:
   IncludeBinary "gfx\Frage2.bmp"
   Graf7:
   IncludeBinary "gfx\CoinBlock.bmp"
   Graf8:
   IncludeBinary "gfx\wellen2_Anim.bmp"
   Graf9:
   IncludeBinary "gfx\Key_red.bmp"
   Graf10:
   IncludeBinary "gfx\Key_yellow.bmp"
   Graf11:
   IncludeBinary "gfx\Gate_yellow.bmp"
   Graf12:
   IncludeBinary "gfx\Gate_red.bmp"
   Graf13:
   IncludeBinary "gfx\Xtra_Anim.bmp"
   Graf14:
   
   Player:   
   IncludeBinary "gfx/Player.bmp"
   PlayerEnd:
   
   Font16:
   IncludeBinary "gfx/F16.png"
   Font16End:
   
   Font32:
   IncludeBinary "gfx/F32.png"
   Font32End:
   
   SmTit:
   IncludeBinary "gfx/SmallTitle.png"
   SmTitEnd:
   
   TextBG:
   IncludeBinary "gfx/TxtBG.png"
   TextBGEnd:
   
   PlayHD: 
   IncludeBinary "gfx/Play_head.bmp"
   PlayHDEnd:
   
   JumpCo: 
   IncludeBinary "gfx/JumpCoin.bmp"
   JumpCoEnd:
   
   BluePA: 
   IncludeBinary "gfx/BlueP.png"
   BluePAEnd:
   
   Gegner:  
   IncludeBinary "gfx/Gegner.bmp"
   GegnerEnd:
   
   Gegner2:
   IncludeBinary "gfx/Gegner2.bmp"
   Gegner2End:
   
   
   Beam:   
   IncludeBinary "gfx/Stream.png"
   BeamEnd:
   Star:   
   IncludeBinary "gfx/star.bmp"
   StarEnd:
   Thump:  
   IncludeBinary "gfx/SantaThump.png"
   ThumpEnd:
   
   
   Back1: 
   IncludeBinary "gfx/Back1.jpg"
   Back1End:
   
   Back2:  
   IncludeBinary "gfx/Back2.png"
   Back2End:
      
   Back3:  
   IncludeBinary "gfx/Back3.png"
   Back3End:
         
   Tit:    
   IncludeBinary "gfx/Title.png"
   TitEnd:
   
   TitL:  
   IncludeBinary "gfx/Title.jpg"
   TitLEnd:
   
   
   SFX1: 
   IncludeBinary "sfx\Sample2.wav"
   SFX2:
   IncludeBinary "sfx\get.wav"
   SFX3:
   IncludeBinary "sfx\splash_in.wav"
   SFX4: 
   IncludeBinary "sfx\splash_out.wav"
   SFX5:
   IncludeBinary "sfx\Auu.wav"
   SFX6:
   IncludeBinary "sfx\get2.wav"
   SFX7:
   IncludeBinary "sfx\Key.wav"
   
   
   
   
   MsX1: 
   IncludeBinary "sfx\ingame.xm"
   MsX1End:
   MsX2:   
   IncludeBinary "sfx\jingles_2.mod"
   MsX2End:
   MsX3:   
   IncludeBinary "sfx\jingle.it"
   MsX3End:
   
   
   Tiles: 
   IncludeBinary "gfx\XMas_Tiles2.png"
   
   
EndDataSection
    
    
Procedure AddJumpingCoin(X,Y)
      AddElement(TinyPat() )
      TinyPat()\Spr = JumpCoin
      TinyPat()\X     = X
      TinyPat()\Y     = Y
      TinyPat()\Trans = 255
      TinyPat()\AY    = -3
      TinyPat()\AX    =  MP_Randomfloat(-1.5 , 1.5)
      TinyPat()\AT    = -3
      TinyPat()\DAY   =0.12   
EndProcedure
Procedure AddSplash(Type, X,Y)
      AddElement(TinyPat() )
      TinyPat()\Spr   = BluePA(Type)
      TinyPat()\X     = X
      TinyPat()\Y     = Y
      TinyPat()\Trans = 255
      TinyPat()\AY    = -1 - Random(200)/100
      TinyPat()\AX    =  MP_Randomfloat(-0.5 , 0.5)
      TinyPat()\AT    = -5 - Random(200)/100
      TinyPat()\DAY   =0.1   
EndProcedure
Procedure AddGegner(Type, X,Y)
  AddElement(Enemy() )
      Enemy()\Spr   = Gegner(Type)
      Enemy()\Type  = Type
      Enemy()\X     = X
      Enemy()\Y     = Y
      
      Enemy()\AX    = 1
      Enemy()\Speed = 1 + type    ; Movement speed
      Enemy()\Dir   = 1
      
      Enemy()\AnimLeft  = 0 ; BaseAnim left
      Enemy()\AnimRight = 4 ; BaseAnim Right
      Enemy()\Base = 0
      Enemy()\AnimSpeed = 0.07
      Enemy()\Anim      = 3 ; 4 Anim Faces 0, 1, 2, 3
      Enemy()\Face      = 0 ; Start with Face 0
      
      Enemy()\YTrack    = (Y/32)
      
EndProcedure     
Procedure AddParticle(Type, X,Y, AX.f, AY.f, DAX.f, DAY.f, AT.f )
    
      AddElement(TinyPat() )
      TinyPat()\Spr   = Type
      TinyPat()\X     = X
      TinyPat()\Y     = Y
      
      TinyPat()\Trans = 255
      TinyPat()\AT    = AT
            
      TinyPat()\AY    = AY
      TinyPat()\AX    = AX
      
      TinyPat()\DAX   = DAX
      TinyPat()\DAY   = DAY 
      
EndProcedure 
Procedure Correct_Z()
Protected t
  EP_Freefont16(0)
  EP_Freefont32(0)
  
  MP_EntitySetOrder(Gegner  , 1)
  MP_EntitySetOrder(Player_1, 1)
  MP_EntitySetOrder(FX_Beam , 1)
  MP_EntitySetOrder(FX_Star , 1)
  
  For t = 0 To 10 : MP_EntitySetOrder(Gegner(t) , 1)  : Next t
  
  MP_EntitySetOrder(SmallTitle, 1) 
  MP_EntitySetOrder(Info_Desk, 1) 
  MP_EntitySetOrder(Info_Desk, 1) 
  MP_EntitySetOrder(Play_Head, 1) 
  MP_EntitySetOrder(Thump, 1) 
  MP_EntitySetOrder(JumpCoin, 1)   
  MP_EntitySetOrder(Title, 1)
  
  EP_CatchFont16(0, ?Font16, ?Font16End - ?Font16)
  EP_CatchFont32(0, ?Font32, ?Font32End - ?Font32)
  
  MP_EntitySetOrder(BackGround_Layer2, 0)
  MP_EntitySetOrder(BackGround_Layer3, 0)
  MP_EntitySetOrder(BackGround_Layer1, 0)


EndProcedure
Procedure.s SetNew_Level(Level)
  
  Select Level
    Case 1
      
        InfoTXT.s(0) = "Dem Weihnachtsmann wurde das"
        InfoTXT.s(1) = "Gold gestohlen das er braucht"
        InfoTXT.s(2) = "um die Elfen zu bezahlen die"
        InfoTXT.s(3) = "das Spielzeug fuer Kinder auf"
        InfoTXT.s(4) = "der ganzen welt herstellen!  "
        
        InfoTXT.s(5) = ""
        InfoTXT.s(6) = "Der Dieb hatte es so eilig das "
        InfoTXT.s(7) = "ihm das Gold bei der Flucht aus"
        InfoTXT.s(8) = "Dem Beutel fiel, es liegt nun  "
        InfoTXT.s(9) = "verstreut in der ganzen welt   "
        InfoTXT.s(10) = "herrum.                       "
        InfoTXT.s(11) = ""
        InfoTXT.s(12) = "Hilf dem Weihnachtsman und   "
        InfoTXT.s(13) = "sammel das Gold wieder ein.  "

        Zeit          = 90
        Level$        = "Maps\Level1.map"
      
      Case 2
      
        
        InfoTXT.s(0) = "Die Spur des Ganoven fuehrt in"
        InfoTXT.s(1) = "die Berge. Vor dem Weihnachts"
        InfoTXT.s(2) = "mann liegt eine grosse hoehle"
        InfoTXT.s(3) = "die tief in den Berg hinein"
        InfoTXT.s(4) = "fuehrt, weit hinten im dukeln"
        
        InfoTXT.s(5) = "kann der Weihnachtsmann das  "
        InfoTXT.s(6) = "Gold blitzen sehen das der dieb"
        InfoTXT.s(7) = "beim klettern verloren hat.    "
        InfoTXT.s(8) = "                               "
        InfoTXT.s(9) = "Achtung es scheint als gaebe es "
        InfoTXT.s(10) = "hier tueren an denen man nicht "
        InfoTXT.s(11) = "vorbei kommt.                 "
        InfoTXT.s(12) = "                             "
        InfoTXT.s(13) = "                     Return"

        Zeit          = 200
        Level$        = "Maps\Level2.map"
        
        
      Case 3    
        
        InfoTXT.s(0) = "Na, wer hat es erkannt ??      "
        InfoTXT.s(1) = "Das Design dieses Levels stammt"
        InfoTXT.s(2) = "vom c64 Spiel Giana Sisters und"
        InfoTXT.s(3) = "zwar vom ersten Level.         "
        InfoTXT.s(4) = ""
        
        InfoTXT.s(5) = "War nur mal so zum Spass...    "
        InfoTXT.s(6) = "                               "
        InfoTXT.s(7) = "Achja der Weihnachtsmann hat erst"
        InfoTXT.s(8) = "einmal sein Gold wieder bekommen,"
        InfoTXT.s(9) = "Dies war ja mehr nen engine Test "
        InfoTXT.s(10) = "Den Source Code wird man in der  "
        InfoTXT.s(11) = "neuen MP3d version bekommen.     "
        InfoTXT.s(12) = ""
        InfoTXT.s(13) = "                     Return"

        Zeit          = 75
        Level$        = "Maps\Level3.map"
     
  EndSelect
  
  
  
ProcedureReturn Level$  
EndProcedure


; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 1162
; FirstLine = 1046
; Folding = A+
; EnableXP
; UseIcon = gfx\favicon.ico
; Executable = C:\XMas 2.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
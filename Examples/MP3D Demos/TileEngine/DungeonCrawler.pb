;******************************************************************************
;******************************************************************************
;***                                                                        ***
;***  Dungeon Crawler Game by Epyx 10/11                                    ***
;***  Tile-Engine Test Game     PureBasic 4.51 & MP3d a30                   ***
;***                                                                        ***
;***                                                                        ***
;***  Eine PacMan artige Steuerung                                          ***
;***  Die Figur läuft auch ohne das man in die Richtung drückt weiter,      ***
;***  man kann nur in eine offene richtung wechseln                         ***
;***                                                                        ***
;***                                                                        ***
;***  Das ist nicht wirklich ein Spiel, es ist mehr ein Beispiel wie man    ***
;***  ein Single-Screen Spiel schreibt das Maps beinhaltet die mehr als nur ***
;***  einen Level beinhalten.                                               ***
;***                                                                        ***
;******************************************************************************
;******************************************************************************




InitSound()
EP_Init2dMap()
EP_initFXLib()

#MapY_Start = 23

Res = MessageRequester("Dungeon Crawler","Fullscreen?",#PB_MessageRequester_YesNo)
If Res = 6 ; Yep Fullscreen pleassse
   MP_Graphics3D (800,600,32,0) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0;
   Fullscreen = 1 : ShowCursor_(0)
Else
   MP_Graphics3DWindow(0, 0, 800,600 , "Dungeon Crawler by Epyx",   #PB_Window_ScreenCentered) : Fullscreen = 0 
EndIf
 
 
 
EP_SetGFXPath("gfx\")       ; Den relativen Pfad zu unserer Grafik angeben (damit wird der in der Map gepeicherte Pfad ignoriert)
EP_SetMapArea(0, #MapY_Start, 24, 18) ; Anzeige Bereich definieren ( 24 Tiles in X und 18 Tiles in Y Richtung für den ganzen Screen (800*600) )


UsePNGImageDecoder()
MP_AmbientSetLight(RGB(0,0,0))
 
 
 
EP_LoadMap("maps\SingleScreen.map")      ; Karte Laden (in dieser Map befinden sich mehrere Level)
Player = MP_LOadSprite("gfx\MrCave.bmp") ; Load our Hero
MP_SpriteSetAnimate(Player,8, 10, 32,32) ; and animate him

EP_LoadFont16(0, "gfx\F16.png")





Level      = 0 ; Start Level
Score      = 0 ; Start Score
 




NextLevel:

LVL_StartX = (Level*25) : LVL_StartY = 0 ; Calculate Map Position


StartPunkte = EP_CountFlagArea(20, LVL_StartX, LVL_StartY, 24, 18) ; Den Startpunkt in der Map suchen
If StartPunkte>0
  EP_FindFlagArea(20,1, LVL_StartX, LVL_StartY, 24, 18) ; Den ersten Eintrag finden 
  PlayerPosX.f = ((EP_GetFindResultX()-LVL_StartX) * EP_GetTileSize()) :  PlayerPosY.f = (EP_GetFindResultY()*EP_GetTileSize()) 
EndIf


LevelGoal     = EP_CountItemArea(12, LVL_StartX, LVL_StartY, 24, 18)
Ply_Way       = 0
LevelFinished = 0
Flag_WFigur   = 0
Flag_Figur    = 0
Bonus_Figur   = 0





While LevelFinished = 0
  
  If Fullscreen = 0 
     Select WindowEvent()
       Case #PB_Key_Escape ; Programm beenden
       End      
      EndSelect
  EndIf
  
  
 If MP_KeyHit(#PB_Key_Escape) : End : EndIf ; The end of this little demonstration
    

    
 CHS_X.f = PlayerPosX/32 : CHS_Y.f = PlayerPosY/32
 
 If CHS_X = Int(CHS_X) And CHS_Y = Int(CHS_Y) ; Choose another way only when exactly on a tile

     If MP_KeyDown(#PB_Key_Left)  
       Ply_FlagMap_X  = EP_Pixel2Map_X(PlayerPosX-1) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY+16) 
       Flag_WFigur    = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_WFigur = 20 : Flag_WFigur = 0 : EndIf   
       If Flag_WFigur = 0 :  Ply_Way = 4  : EndIf
     EndIf
     
     If MP_KeyDown(#PB_Key_Right)
       Ply_FlagMap_X  = EP_Pixel2Map_X(PlayerPosX+32) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY+16) 
       Flag_WFigur    = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_WFigur = 20 : Flag_WFigur = 0 : EndIf   
       If Flag_WFigur = 0 :  Ply_Way = 3  : EndIf
     EndIf
     
     If MP_KeyDown(#PB_Key_Up)  
        Ply_FlagMap_X = EP_Pixel2Map_X(PlayerPosX+16) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY-1) 
        Flag_WFigur   = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_Figur = 20 : Flag_Figur = 0 : EndIf   
       If Flag_WFigur = 0 : Ply_Way = 1  : EndIf
     EndIf
     
     If MP_KeyDown(#PB_Key_Down)
        Ply_FlagMap_X = EP_Pixel2Map_X(PlayerPosX+16) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY+32) 
        Flag_WFigur   = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_Figur = 20 : Flag_Figur = 0 : EndIf   
       If Flag_WFigur = 0 : Ply_Way = 2  : EndIf
     EndIf
     
 EndIf 
     

     
     
     
     Ply_Map_X = EP_Pixel2Map_X(PlayerPosX+16) : Ply_Map_Y = EP_Pixel2Map_Y(PlayerPosY+16) ; Read actual map position of the player
     Bonus_Figur = EP_GetMapItem(Ply_Map_X, Ply_Map_Y)
     
     
     If Bonus_Figur = 12                              ; Yeeehaw we found a Item
              Score + 100                             ; add 100 point to your score
              EP_SetMapItem(Ply_Map_X, Ply_Map_Y, -1) ; and delete the Item from our Map
              
              LevelGoal - 1 : If LevelGoal=0 : LevelFinished = 1 : EndIf ; All Coins Collected, jump to next Level
     EndIf
     
     
     
     
     
     
     
     
     
     If Flag_Figur <> 0 : Ply_Way = 0 : Flag_Figur = 0 : EndIf     
     
     If Ply_Way = 1 
       Ply_FlagMap_X = EP_Pixel2Map_X(PlayerPosX+16) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY-1) 
       Flag_Figur    = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_Figur = 20 : Flag_Figur = 0 : EndIf   
       If Flag_Figur = 0 : PlayerPosY - 1  : EndIf
     EndIf
     
     If Ply_Way = 2
       Ply_FlagMap_X = EP_Pixel2Map_X(PlayerPosX+16) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY+32) 
       Flag_Figur    = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_Figur = 20 : Flag_Figur = 0 : EndIf
       If Flag_Figur = 0 : PlayerPosY + 1  : EndIf
     EndIf
     
     If Ply_Way = 3 
       Ply_FlagMap_X = EP_Pixel2Map_X(PlayerPosX+32) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY+16) 
       Flag_Figur    = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_Figur = 20 : Flag_Figur = 0 : EndIf   
       If Flag_Figur = 0 : PlayerPosX + 1  : EndIf
     EndIf
     
     If Ply_Way = 4 
       Ply_FlagMap_X = EP_Pixel2Map_X(PlayerPosX-1) : Ply_FlagMap_Y = EP_Pixel2Map_Y(PlayerPosY+16) 
       Flag_Figur    = EP_GetMapFlag(Ply_FlagMap_X, Ply_FlagMap_Y) : If Flag_Figur = 20 : Flag_Figur = 0 : EndIf   
       If Flag_Figur = 0 : PlayerPosX - 1  : EndIf
     EndIf
     
     
     
     
    EP_Text16(0,10,5,"Score: " +Str(Score),0 )
    EP_Text16(0,420,5,"Dungeon Crawler by Epyx",0 )
     
    MP_DrawSprite(Player, PlayerPosX, PlayerPosY + #MapY_Start, 255)     
    EP_MapPosition (LVL_StartX*32, LVL_StartY*32)  : EP_DrawMap(); Die Map auf den Bildschirm zeichnen
    MP_RenderWorld() : MP_Flip () : Delay(1)
    
Wend



Level + 1 : If Level = 4 : End : EndIf ; There is no Level 4 therefore stopp this PRG
Goto NextLevel
































; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 55
; EnableXP
; UseIcon = gfx\Ikon.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

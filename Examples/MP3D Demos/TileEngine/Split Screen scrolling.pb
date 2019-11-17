;******************************************************************************
;******************************************************************************
;***                                                                        ***
;***   Split Screen Scrolling Map example                                   ***
;***   Für 2 Spieler Dual Games (ja sowas gab es früher ^^)                 ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***   PureBasic 4.51 and MP3d Engine a30                                   ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;******************************************************************************
;******************************************************************************




EP_Init2dMap()




 Res = MessageRequester("Split Screen Scrolling","Fullscreen?",#PB_MessageRequester_YesNo)
 If Res = 6 ; Yep Fullscreen pleassse
    MP_Graphics3D (800,600,32,0) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0;
    Fullscreen = 1 : ShowCursor_(0)
 Else
    MP_Graphics3DWindow(0, 0, 800,600 , "Split Screen Map",   #PB_Window_ScreenCentered) : Fullscreen = 0 
 EndIf







EP_SetGFXPath("gfx\")       ; Den relativen Pfad zu unserer Grafik angeben (damit wird der in der Map gepeicherte Pfad ignoriert)

UsePNGImageDecoder()
MP_AmbientSetLight(RGB(0,0,50))



EP_LoadMap("maps\Level1.map")



; Where is the Center from this Map
Map_Center_X = ((EP_GetMapSizeX() * EP_GetTileSize()) - (24*EP_GetTileSize())) / 2
Map_Center_Y = ((EP_GetMapSizeY() * EP_GetTileSize()) - (9 *EP_GetTileSize())) / 2



While Not MP_KeyHit(#PB_Key_Escape)

   
     If MP_KeyHit(#PB_Key_Escape) : End : EndIf
     If Fullscreen = 0 
     Select WindowEvent()
       Case #PB_Key_Escape ; Programm beenden
           End      
       EndSelect
     EndIf   
    
     
      ;Player 1 Map Movement
      P1_AddX.f + 0.4 : MP_LimitTo360(P1_AddX.f) : P1_AddY.f + 0.5 : MP_LimitTo360(P1_AddY.f)       
      Player_1X.f   = Map_Center_X + Sin((P1_AddX.f * #PI / 180)) * Map_Center_X
      Player_1Y.f   = Map_Center_Y + Sin((P1_AddY.f * #PI / 180)) * Map_Center_Y
    
      
      ;Player 2 Map Movement      
      P2_AddX.f + 0.7 : MP_LimitTo360(P2_AddX.f) : P2_AddY.f + 0.3 : MP_LimitTo360(P2_AddY.f)       
      Player_2X.f   = Map_Center_X + Sin((P2_AddX.f * #PI / 180)) * Map_Center_X
      Player_2Y.f   = Map_Center_Y + Sin((P2_AddY.f * #PI / 180)) * Map_Center_Y
      
      
     
    
       EP_SetMapArea(0, 0, 25, 9) ; Player 1 Map Display Area 
       EP_MapPosition (Player_1X , Player_1Y) ; Position of Player 1 in the Map
       EP_DrawMap() ; Simply draw the Map for Player 1
    
    
       EP_SetMapArea(0, 316, 25, 9) ; The Display Area for the Player 2 Map
       EP_MapPosition (Player_2X , Player_2Y) ; Sets Player 2 Position in the Map
       EP_DrawMap()                 ; Yep finaly draw the Map
       
       MP_Box(0,285,800,35, $0, 1)
       
       
       MP_RenderWorld ()
       MP_Flip ()

Wend































; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 21
; EnableXP
; UseIcon = gfx\Ikon.ico
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

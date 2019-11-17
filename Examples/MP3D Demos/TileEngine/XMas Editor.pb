;******************************************************************************
;******************************************************************************
;***                                                                        ***
;***   XMas Run2 Map Editor v0.83 by Epyx 08/11                             ***
;***   Mit diesem ist es möglich eigene Karten für das Spiel zu erstellen   ***
;***                                                                        ***
;***   Allerdings soll dieser Editor auch ein Beispiel dafür sein wie man   ***
;***   einen Editor für die Tile Engine schreibt, zudem kann man natürlich  ***
;***   auch mit diesem Editor selber Maps für sein eigenes Spiel erstellen  ***
;***                                                                        ***
;***   PureBasic 4.51 and MP3d Engine a30                                   ***
;***                                                                        ***
;***   Der Editor ist auf 32*32 Tilemaps spezialisiert, für andere          ***
;***   Tilegrößen müssen Anpassungen vorgenommen werden.                    ***
;***                                                                        ***
;******************************************************************************
;******************************************************************************


; Linke Maustaste    - Mit dem Aktuellen Tile und allen voreingestellten Werten in die Karte zeichnen
; Rechte Maustaste   - Tile Löschen / leeren
; Mittlere Maustaste - Block Markier Modus, zum Kopieren von Karten Bereichen7
; Mausrad drehen     - Schnelles wechseln der Tile grafik

; F1 - Tile Auswahl Modus
; F2 - Animtile Auswahl Modus
; F3 - Tile Preferences anwählen
; F4 - SinglePaint Modus aktivieren

; Alt - Zeigt das Aktuelle Tile im Zeiger an, man erhält praktisch eine kleine Vorschau

; STRG & B - Block Markier Modus, zum Kopieren von Karten Bereichen
; Strg & C - Markierten Block Kopieren
; Strg & X - Markierten Block Kopieren und Markierten Bereich löschen
; Strg & V - Kopierten Bereich in die Karte Pasten
; Strg & T - Markierten Block Kopieren, dabei aber Transparente Werte ignorieren
; Strg & F - Markierten Bereich mit dem Aktuellen Tilewerten füllen

; SinglePaint Modus_____________________________________________________________

; Im SinglePaint Modus ist es möglich nur einen einzigen Wert in die Karte zu schreiben (ausgenommen AnimTiles)

; Taste 1 - Wählt den Tile Painter an, mit dem man Tiles zeichnen kann ohne die anderen Werte zu verändern
; Taste 2 - Wähtl den Flag Painter an, hier zeichnet man mit dem derzeit aktiven Flagwert in die Karte (Tiles mit dem Flagwert werden durch das Blinkende Schachbrett angezeigt)
; Taste 3 - Wählt den Transparent Painter an, verändert die Transparenz werte in der Karte
; Taste 4 - Wählt den Item Painter an, man kann AnimTiles als Item in die Karte zeichnen

; ItemLayer_____________________________________________________________________

; Der Item Layer ist ein eigener 2. Layer der über der Karte gezeichnet wird, auf diesem Layer
; kann man nur mit AnimTiles zeichnen, in der Regel wird dieser Layer für die Item Bonus teile
; im Spiel verwendet.
; Im Spiel kann man dann gesondert den Wert des Item Layers auslesen und in entsprechende Routinen
; verweisen





#AppTitle$    = "XMasEd" : #AppVersion   = 0.83


MP_Graphics3DWindow(0, 0, 800,600 , #AppTitle$+" v"+StrF(#AppVersion,2),  #PB_Window_ScreenCentered) 


Declare AddButton(ID, XPos, YPos, Width, Height, Face)
Declare Draw_Buttons(MS_X, MS_Y)
Declare CreateGUI()
Declare OpenWindow_CreateNewMap()
Declare OpenWindow_TileProperties()
Declare OpenWindow_TileGFX()
Declare Load_DefaultTileset()
Declare Set_Zorder()





EP_Init2dMap()
EP_SetGFXPath("gfx\") ; Den relativen Pfad zu unserer Grafik angeben (damit wird der in der Map gepeicherte Pfad ignoriert)

; Mal alle Image Decoder aktivieren, bitte daran denken dann im Spiel ebenfalls die benutzen Dekoder 
; zu aktivieren. Wenn ein Exe Packer verwendet wird ist es evtl. sinnvoller nur BMP grafiken zu benutzen
; da die BMP dateien effektiver gepackt werden können ohne extra dekoder ;)
UsePNGImageDecoder()
UseJPEGImageDecoder()
UseJPEG2000ImageDecoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()



;{- Enumerations / Data prepare

Structure Buttons_src
  
          ID.l
           X.l
           Y.l
          X2.l
          Y2.l
          
 Button_Face.l
              
EndStructure
Global   Copy_Plane, Shining,Panel,Bar,BBorder,BBorder2, FlagPaint
AppTitleDeff$ = #AppTitle$+" v"+StrF(#AppVersion,2)

;{ Windows
Enumeration
  #MP3d_Screen_Block = 0
  #Window_0
  #Window_1
  #Window_2
EndEnumeration
;}
;{ Gadgets
Enumeration
  #Frame3D_0
  #Frame3D_1
  #Frame3D_2
  
  #Button_1
  #Button_2
  
  #Button_3
  #Button_4
  #Button_5
  #Button_6
  #Button_7  
  #Button_8 
  #Button_9   
  #Button_12
  #Button_13
  #Button_14
  
  #Text_2
  #Text_4
  #Text_5
  #Text_6
  #Text_7
  #Text_8
  #Text_9
  #Text_10
  #Text_11
  #Text_12
  
  #String_1
  #String_3
  #String_5
  #String_6
  #String_7
  #String_8
  #String_9
  #String_10

  #ListView_1
  #ListView_2
EndEnumeration
;}

Global Dim Choose(5)
Global Dim Button(10) : Global NewList Button_GUI.Buttons_src()
Global Shining, Panel, Bar, BBorder , BBorder2, Shine_Value

;}



EP_CreateMap(100, 100, 32)    ; Eine neue Map erstellen, mit 100*100 tiles zu je 32 Pixeln
Load_DefaultTileset()        ; Tiles aus einer Tilegrafik einlesen und dieser Map zufügen
                             ; Da der Editor zum Spiel XMasRun 2 gehört ist das nun auch das Default TileSet

EP_SetMapArea(0, 96, 24, 14) ; Anzeige Bereich definieren

MP_AmbientSetLight(RGB(0,0,50))





; Maximalen Scroll Bereich ermitteln
MScroll     = EP_GetMapSizeX() * EP_GetTileSize() ; Maximale Breite des Levels in Pixeln
Max_ScrollX = MScroll - ( 24 *  EP_GetTileSize() ); Den Anzeige Bereich vom Maximum abziehen

MScroll     = EP_GetMapSizeY() * EP_GetTileSize() ; Maximale Höhe des Levels in Pixeln
Max_ScrollY = MScroll - ( 14 *  EP_GetTileSize() ); Den Anzeige Bereich vom Maximum abziehen


Base_Y      = 96



CreateGUI()

AddButton(1, 10 , 10, 52, 28, Button(0))
AddButton(2, 70 , 10, 52, 28, Button(1))
AddButton(3, 130, 10, 52, 28, Button(2))
AddButton(4, 280, 10, 52, 28, Button(3))
AddButton(5, 220, 10, 52, 28, Button(7))

AddButton(6, 10, 46, 36, 36, Button(4))
AddButton(7, 52, 46, 36, 36, Button(5))
AddButton(8, 94, 46, 36, 36, Button(6))
AddButton(9,136, 46, 36, 36, Button(8))

;Default Zeichnen Werte
Global Map_DrawTile  = 103
Global Map_DrawFlag  = 1
Global Map_DrawAnim  = -1
Global Map_DrawTrans = 0
Global Map_DrawItem  = -1 ; Item Layer

CopyModus_XStart = 0 : CopyModus_XEnd = 0 
CopyModus_YStart = 0 : CopyModus_YEnd = 0 
Draw_Spr_X = 0 : Draw_Spr_Y = 0

;MP_SpriteblendingMode(Copy_Plane, 8, 7)




SinglePaint = 0
Copy_Modus  = 0
Edit_Fokus  = 0
Modus       = 0
Global Virgin = 0

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder schliessen
FPX = MP_FPS() : If GetForegroundWindow_()=WindowID(0) : Edit_Fokus = 1 : Else : Edit_Fokus = 0 : EndIf



QuadUsed = 1

XX_Quad =  MP_cursorgetPosX() - WindowX(0)      
YY_Quad = (MP_cursorgetPosY() - WindowY(0))-32

ButtonCheck = Draw_Buttons(XX_Quad, YY_Quad)
LM_B_pre    = MP_mousebuttonDown(0)
RM_B_pre    = MP_mousebuttonDown(1)
MM_B_pre    = MP_mousebuttonDown(2)
MM_W_pre    = MP_Mousedeltawheel()

If XX_Quad < 0     : XX_Quad = 0 : QuadUsed = 0 : EndIf : If XX_Quad > 799 : XX_Quad = 799 : QuadUsed = 0 : EndIf
If YY_Quad < Base_Y: YY_Quad = Base_Y : QuadUsed = 0 : EndIf : If YY_Quad > 574 : YY_Quad = 574 : QuadUsed = 0 : EndIf



; InMap Position des Cursors ermitteln
XX_Quad = (XX_Quad / EP_GetTileSize()) * EP_GetTileSize() : YY_Quad = (YY_Quad / EP_GetTileSize()) * EP_GetTileSize()
X_TilePos = (XX_Quad / EP_GetTileSize()) + (Curs_xx/EP_GetTileSize()) : Y_TilePos = ((YY_Quad / EP_GetTileSize()) - 3) + (Curs_YY/EP_GetTileSize())


    Shin_Adder.f + 2.5 : If Shin_Adder > 360 : Shin_Adder-360 : EndIf
    Shine_Value  = 128 + Sin(Shin_Adder * #PI / 180) * 127





If LM_B_pre =1 And Mouse_B1 = 0 ; Linke Maus gedrückt und auch nicht verriegelt ?!
  
  LM_B       = 1           ; Linke Maustaste gedrückt  
  LB_Button  = ButtonCheck ; Was für ein Button wurde gedrückt ?
  
  Mouse_B1   = 1           ; Maus Button verriegeln
  
  
  Select LB_Button
    Case 1 ; Neue Karte erstellen
      
      OpenWindow_CreateNewMap()
      ; Maximalen Scroll Bereich ermitteln
      MScroll     = EP_GetMapSizeX() * EP_GetTileSize() ; Maximale Breite des Levels in Pixeln
      Max_ScrollX = MScroll - ( 24   * EP_GetTileSize() ); Den Anzeige Bereich vom Maximum abziehen    
  
      MScroll     = EP_GetMapSizeY() * EP_GetTileSize() ; Maximale Höhe des Levels in Pixeln
      Max_ScrollY = MScroll - ( 14   * EP_GetTileSize() ); Den Anzeige Bereich vom Maximum abziehen
      Set_Zorder()
      
      Modus = 0 : Virgin = 0
      
    Case 2 ; Karte Laden
      
        Pattern$ = #AppTitle$ + " Mapfile (*.map)|*.map|Alle Dateien (*.*)|*.*"
        File$ = OpenFileRequester(#AppTitle$+" Karte Laden", "", Pattern$, 0)
        
        If File$ <> ""           
          MapLoad = EP_LoadMap(File$) 
          If MapLoad = -1 : MessageRequester(#AppTitle$+" - Load Error","Es ist ein Fehler beim Laden aufgetreten",#MB_ICONERROR)  : EndIf
          If MapLoad = -2 : MessageRequester(#AppTitle$+" - Load Error","Dies ist keine "+AppTitle$+" Karte.",#MB_ICONERROR)  : EndIf
          If MapLoad < -2 : MessageRequester(#AppTitle$+" - Load Error","Unbekannter Fehler aufgetreten.",#MB_ICONERROR)  : EndIf
        
          If MapLoad > 0  ; Laden hat Funktioniert, Editor für diese Map vorbereiten
              ; Maximalen Scroll Bereich ermitteln
              MScroll     = EP_GetMapSizeX() * EP_GetTileSize() ; Maximale Breite des Levels in Pixeln
              Max_ScrollX = MScroll - ( 24 *  EP_GetTileSize() ); Den Anzeige Bereich vom Maximum abziehen    
  
              MScroll     = EP_GetMapSizeY() * EP_GetTileSize() ; Maximale Höhe des Levels in Pixeln
              Max_ScrollY = MScroll - ( 14 *  EP_GetTileSize() ); Den Anzeige Bereich vom Maximum abziehen
              Modus = 0 : Virgin = 0
          EndIf
        EndIf
        Set_Zorder()
        
    Case 3 ; Karte Speichern
      
        Pattern$ = #AppTitle$ + " Mapfile (*.map)|*.map|Alle Dateien (*.*)|*.*"
        File$ = SaveFileRequester(#AppTitle$+" Karte Speichern", "", Pattern$, 0)        
        
        If File$ <> ""
          If GetExtensionPart(File$) = "" : File$+".Map" : EndIf
          MapSave = EP_SaveMap(File$)
          If MapSave < 0 : MessageRequester(#AppTitle$+" - Save Error","Es ist ein Fehler aufgetreten",#MB_ICONERROR)  : EndIf
          Modus = 0 : Virgin = 0
        EndIf  
          
    Case 4 ; Map Editor verlassen
      
      If Virgin <> 0  
           Req = MessageRequester(#AppTitle$+" - Achtung","Die Map wurde verändert, möchten Sie das Programm trotzden beenden.",#PB_MessageRequester_YesNo)
        
           If Req = #PB_MessageRequester_Yes
                  End               
              Else
                  Debug "no"
           EndIf        
      Else
      
           End
        
      EndIf
      
    Case 5 
      
          If Modus <> 0 : Modus = 0 : EndIf
          OpenWindow_TileGFX()
         
    Case 6
          If Modus <> 0 And Modus <> 1 : MP_AmbientSetLight(RGB(0,0,50)) : Modus = 0 : EndIf
          Pick_UP_Line = 0
          Modus + 1 : If Modus = 2 : Modus = 0 : MP_AmbientSetLight(RGB(0,0,50)) : EndIf
         
          
      Case 7
          If Modus <> 0 And Modus <> 2 : MP_AmbientSetLight(RGB(0,0,50)) : Modus = 0 : EndIf
          Pick_UP_Line = 0
          Modus + 2 : If Modus = 4 : Modus = 0 : MP_AmbientSetLight(RGB(0,0,50)) :EndIf
          
      Case 8
            If Modus = 0 Or Modus  = 4 ; also nur Aktivieren wenn default zeichenmodus oder Single Paint modus
                OpenWindow_TileProperties()
            EndIf      
            
      Case 9
           If Modus <> 0 And Modus <> 4 : Modus = 0 : EndIf 
           MP_AmbientSetLight(RGB(25,0,0))
           Modus + 4 : If Modus = 8 : Modus = 0 : MP_AmbientSetLight(RGB(0,0,50)) : EndIf
  EndSelect
  
EndIf







; Tastatur Kommandos
If MP_KeyHit(#PB_Key_F1) = 1 ; Ein Tile auswählen
          If Modus <> 0 And Modus <> 1 : Modus = 0 : EndIf
          Pick_UP_Line = 0
          Modus + 1 : If Modus = 2 : Modus = 0 : EndIf
EndIf
        
If MP_KeyHit(#PB_Key_F2) = 1 ; Ein AnimTile auswählen
          If Modus <> 0 And Modus <> 2 : Modus = 0 : EndIf
          Pick_UP_Line = 0
          Modus + 2 : If Modus = 4 : Modus = 0 : EndIf
EndIf

If MP_KeyHit(#PB_Key_F3) = 1 
          If Modus = 0 Or Modus  = 4 ; also nur Aktivieren wenn default zeichenmodus oder Single Paint modus
             OpenWindow_TileProperties()
          EndIf      
EndIf

If MP_KeyHit(#PB_Key_F4) = 1 ; Ein SinglePaint Modus auswählen
          If Modus <> 0 And Modus <> 4 : Modus = 0 : EndIf 
           MP_AmbientSetLight(RGB(25,0,0))
           Modus + 4 : If Modus = 8 : Modus = 0 : MP_AmbientSetLight(RGB(0,0,50))
          EndIf    
EndIf


If MP_KeyHit(#PB_Key_B) = 1 
  If Modus = 0 Or Modus = 3
        Copy_Modus = 0
        CopyModus_XStart = X_TilePos :  CopyModus_YStart = Y_TilePos
        Modus + 3 : If Modus = 6 : Modus = 0 : EndIf
     EndIf            
EndIf

If MP_KeyDown(#PB_Key_LeftControl) = 1 And MP_Keyhit(#PB_Key_V) = 1
   EP_DrawMapBlock(X_TilePos , Y_TilePos)
EndIf


If MP_KeyDown(#PB_Key_LeftControl) = 1 And MP_Keyhit(#PB_Key_T) = 1
   EP_DrawTransparentMapBlock(X_TilePos , Y_TilePos)
EndIf


If MP_KeyDown(#PB_Key_LeftControl) = 1 And MP_Keyhit(#PB_Key_C) = 1 And Copy_Modus = 1
   Copy_Modus = 0
   EP_GrabMapBlock(CopyModus_XStart, CopyModus_YStart, CopyModus_XEnd, CopyModus_YEnd)
EndIf


If MP_KeyDown(#PB_Key_LeftAlt) = 1    
    EP_TiletoFront(Map_DrawTile)
    EP_DrawTile(XX_Quad, YY_Quad, Map_DrawTile) 
EndIf

If MP_KeyDown(#PB_Key_LeftControl) = 1 And MP_Keyhit(#PB_Key_X) = 1 And Copy_Modus = 1
   Copy_Modus = 0
   EP_GrabMapBlock(CopyModus_XStart, CopyModus_YStart, CopyModus_XEnd, CopyModus_YEnd)
   
   For Y_YBlock = CopyModus_YStart To CopyModus_YEnd
      For X_XBlock = CopyModus_XStart To CopyModus_XEnd
        EP_SetMapTile (X_XBlock, Y_YBlock,-1)
        EP_SetMapFlag (X_XBlock, Y_YBlock, 0)
        EP_SetMapAnim (X_XBlock, Y_YBlock,-1)
        EP_SetMapTrans(X_XBlock, Y_YBlock, 0)
        EP_SetMapItem (X_XBlock, Y_YBlock,-1)
      Next X_XBlock
   Next Y_YBlock         
 EndIf

 If MP_KeyDown(#PB_Key_LeftControl) = 1 And MP_Keyhit(#PB_Key_F) = 1 And Copy_Modus = 1
   Copy_Modus = 0   
   For Y_YBlock = CopyModus_YStart To CopyModus_YEnd
      For X_XBlock = CopyModus_XStart To CopyModus_XEnd
            EP_SetMapTile (X_XBlock, Y_YBlock, Map_DrawTile)
            EP_SetMapFlag (X_XBlock, Y_YBlock, Map_DrawFlag)
            EP_SetMapAnim (X_XBlock, Y_YBlock, Map_DrawAnim)
            EP_SetMapTrans(X_XBlock, Y_YBlock, Map_DrawTrans)
            EP_SetMapItem (X_XBlock, Y_YBlock, Map_DrawItem)
      Next X_XBlock
   Next Y_YBlock         
 EndIf

 
If MP_KeyDown(#PB_Key_LeftControl) = 1 And MP_Keyhit(#PB_Key_B) = 1 
     If Modus = 0 Or Modus = 3
         Copy_Modus = 0
         CopyModus_XStart = X_TilePos :  CopyModus_YStart = Y_TilePos
         Modus + 3 : If Modus = 6 : Modus = 0 : EndIf
     EndIf
 EndIf
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

If Mouse_B1 = 1 ; Maus Button verriegelt
    LM_B_Up    = MP_mousebuttonUP(0)
    If LM_B_Up = 1 : Mouse_B1 = 0 : LM_B = 0 :  ModeChange = 0 : EndIf ; MausButton entriegeln
EndIf














If Modus = 0 ; Map Edit Modus
  
     SetWindowTitle(0,AppTitleDeff$+" - Free Paint Mode")
  
     If MP_KeyDown(#PB_Key_Left) : Curs_xx - EP_GetTileSize()  : If Curs_xx < 0           : Curs_xx = 0           : EndIf : EndIf
     If MP_KeyDown(#PB_Key_Right): Curs_xx + EP_GetTileSize()  : If Curs_xx > Max_ScrollX : Curs_xx = Max_ScrollX : EndIf : EndIf
     If MP_KeyDown(#PB_Key_Up)   : Curs_yy - EP_GetTileSize()  : If Curs_yy < 0           : Curs_yy = 0           : EndIf : EndIf
     If MP_KeyDown(#PB_Key_Down) : Curs_yy + EP_GetTileSize()  : If Curs_yy > Max_ScrollY : Curs_yy = Max_ScrollY : EndIf : EndIf
     
     EP_MapPosition (Curs_xx, Curs_yy)  ; Die Position der Map angeben, in Pixel !!  
     TLS = EP_DrawMap()                 ; Die Map auf den Bildschirm zeichnen
  

     Tile = EP_GetMapTile (X_TilePos, Y_TilePos) ; Tile Auslesen
     Flag = EP_GetMapFlag (X_TilePos, Y_TilePos) ; Flag Auslesen
     Anim = EP_GetMapAnim (X_TilePos, Y_TilePos) ; Animation Tile Auslesen
     Tran = EP_GetMapTrans(X_TilePos, Y_TilePos) ; Transparenz Auslesen
     Item = EP_GetMapItem (X_TilePos, Y_TilePos) ; Item Layer Auslesen

     If Tile = -1 : Tile$ = "Empty" : Else : Tile$ = Str(Tile) : EndIf
     If Anim = -1 : Anim$ = "No"    : Else : Anim$ = Str(Anim) : EndIf
     If Tran =  0 : Tran$ = "No"    : Else : Tran$ = Str(Tran) : EndIf
     If Item = -1 : Item$ = "No"    : Else : Item$ = Str(Item) : EndIf
     
     MP_DrawText(550,15,"Drawn Tiles "+Str(TLS) )
     MP_DrawText(720,15,"FPS "+Str(FPX))

     MP_DrawText(380,15,Str(X_TilePos)+" * "+ Str(Y_TilePos)) : MP_DrawText(470,15,Str(EP_GetMapSizeX())+" * "+ Str(EP_GetMapSizeY()))
     MP_DrawText(380,31,Tile$) : MP_DrawText(480,31,Str(Flag))
     MP_DrawText(380,47,Anim$) : MP_DrawText(480,47,Item$)
     MP_DrawText(380,66,Tran$)
     MP_DrawText(550,32,"Ak. Tile ID:"  + Str(Map_DrawTile) )
     EP_DrawTile(550,50, Map_DrawTile) : MP_EntitySetOrder(Panel,0)
     
     If Copy_Modus = 1
           Set_Zorder()
           MP_drawSprite(Copy_Plane, (EP_MapX2Pixel(Draw_Spr_X)), (EP_MapY2Pixel(Draw_Spr_Y))+Base_Y,155)  
     EndIf
     

     If QuadUsed > 0 And Edit_Fokus=1 ; Das Markierte Tile besonders hervor heben 
       
         If MM_W_pre < 0 : Map_DrawTile - 1 : If Map_DrawTile<0 : Map_DrawTile=EP_GetTileCount() : EndIf : EndIf
         If MM_W_pre > 0 : Map_DrawTile + 1 : If Map_DrawTile>EP_GetTileCount() : Map_DrawTile=0 : EndIf : EndIf
       
         MP_DrawSprite(Shining ,XX_Quad-EP_GetTileSize() , YY_Quad-EP_GetTileSize() , Shine_Value )
        
         If LM_B_pre = 1 And ModeChange = 0
            EP_SetMapTile (X_TilePos, Y_TilePos, Map_DrawTile)
            EP_SetMapFlag (X_TilePos, Y_TilePos, Map_DrawFlag)
            EP_SetMapAnim (X_TilePos, Y_TilePos, Map_DrawAnim)
            EP_SetMapTrans(X_TilePos, Y_TilePos, Map_DrawTrans)
            EP_SetMapItem (X_TilePos, Y_TilePos, Map_DrawItem)           
            
            Virgin = 1
         EndIf
    
         If RM_B_pre = 1 And ModeChange = 0
            EP_SetMapTile (X_TilePos, Y_TilePos,-1)
            EP_SetMapFlag (X_TilePos, Y_TilePos, 0)
            EP_SetMapAnim (X_TilePos, Y_TilePos,-1)
            EP_SetMapTrans(X_TilePos, Y_TilePos, 0)
            EP_SetMapItem (X_TilePos, Y_TilePos,-1)  
            Virgin = 1
         EndIf
         
         If MM_B_pre = 1 And ModeChange = 0
           If Modus = 0 Or Modus = 3
              Copy_Modus = 0
              CopyModus_XStart = X_TilePos :  CopyModus_YStart = Y_TilePos
              Modus + 3 : If Modus = 6 : Modus = 0 : EndIf
           EndIf           
         EndIf
          
          
     EndIf  
     
EndIf






If Modus = 1 ; Choose Tile Modus
     SetWindowTitle(0,AppTitleDeff$+" - Choose a tile and press left mouse button")
  
     TileNumber = 0 : MaXx_Breite = (800 / EP_GetTileSize()) - 1 
  
     If MP_KeyDown(#PB_Key_Up)   : Pick_UP_Line - 1  : If Pick_UP_Line < 0 : Pick_UP_Line = 0 : EndIf : EndIf
     If EP_GetTileCount() > 374
        If MP_KeyDown(#PB_Key_Down) : Pick_UP_Line + 1  : EndIf
     EndIf
     TileNumber + (Pick_UP_Line*(MaXx_Breite+1))
     
     For Y = 0 To 14
       For x = 0 To MaXx_Breite
         If TileNumber <=EP_GetTileCount() : EP_DrawTile(X*EP_GetTileSize() , Base_Y+ Y*EP_GetTileSize() , TileNumber) : EndIf
           TileNumber +1 
       Next X
     Next Y
    
     TileBB_X = (XX_Quad/32) : TileBB_Y = ((YY_Quad/32)-3)+Pick_UP_Line 
     LineY = (TileBB_Y * MaXx_Breite)
     AkTile = (LineY + TileBB_X) + TileBB_Y
  

     If AkTile <=EP_GetTileCount() : MP_DrawSprite(Shining ,XX_Quad-EP_GetTileSize() , YY_Quad-EP_GetTileSize() , Shine_Value ) : EndIf
  
     MP_DrawText(550,15,"Max. Tiles "+Str(EP_GetTileCount()) )
     If AkTile > EP_GetTileCount() : AkTile = EP_GetTileCount() : EndIf
     MP_DrawText(550,32,"Tile ID:"  + Str(AkTile) )
     EP_DrawTile(550,50, Map_DrawTile) : MP_EntitySetOrder(Panel,0)
     
     
     If LM_B =1 And ModeChange = 0 And QuadUsed = 1; Maus gedrückt
       Map_DrawTile  = AkTile 
       Map_DrawAnim  = -1 : Modus = 0 : ModeChange = 1
     EndIf
     
EndIf






If Modus = 2 ; Choose Anim Modus
     SetWindowTitle(0,AppTitleDeff$+" - Choose a animtile and press left mouse button")
  
     TileNumber = 0 : MaXx_Breite = (800 / EP_GetTileSize()) - 1 
  
     If MP_KeyDown(#PB_Key_Up)   : Pick_UP_Line - 1  : If Pick_UP_Line < 0 : Pick_UP_Line = 0 : EndIf : EndIf
     If EP_GetTileCount() > 374
        If MP_KeyDown(#PB_Key_Down) : Pick_UP_Line + 1  : EndIf
     EndIf
     TileNumber + (Pick_UP_Line*(MaXx_Breite+1))
     
     For Y = 0 To 14
       For x = 0 To MaXx_Breite
         If TileNumber <=EP_GetAnimTileCount() : EP_DrawAnimTile(X*32, Base_Y+ Y*32, TileNumber) : EndIf
           TileNumber +1 
       Next X
     Next Y
    
     TileBB_X = (XX_Quad/32) : TileBB_Y = ((YY_Quad/32)-3)+Pick_UP_Line 
     LineY = (TileBB_Y * MaXx_Breite)
     AkTile = (LineY + TileBB_X) + TileBB_Y
  

     If AkTile <=EP_GetAnimTileCount() : MP_DrawSprite(Shining ,XX_Quad-32, YY_Quad-32, Shine_Value ) : EndIf
  
     MP_DrawText(550,15,"Max. Tiles "+Str(EP_GetAnimTileCount()+1) )
     If AkTile > EP_GetAnimTileCount() : AkTile = EP_GetAnimTileCount() : EndIf
     MP_DrawText(550,32,"Tile ID:"  + Str(AkTile) )
     If Map_DrawAnim =>0 
        EP_DrawAnimTile(550,50, Map_DrawAnim) : MP_EntitySetOrder(Panel,0)
     EndIf
     
     If LM_B =1 And ModeChange = 0 And QuadUsed = 1; Maus gedrückt
       Map_DrawAnim  = AkTile : Modus = 0 : ModeChange = 1
     EndIf
     
EndIf







If Modus = 3 ; Copy Mode
      SetWindowTitle(0,AppTitleDeff$+" - Mark an map area and press left mouse button")
      If MP_KeyDown(#PB_Key_Left) : Curs_xx - EP_GetTileSize()  : If Curs_xx < 0           : Curs_xx = 0           : EndIf : EndIf
      If MP_KeyDown(#PB_Key_Right): Curs_xx + EP_GetTileSize()  : If Curs_xx > Max_ScrollX : Curs_xx = Max_ScrollX : EndIf : EndIf
      If MP_KeyDown(#PB_Key_Up)   : Curs_yy - EP_GetTileSize()  : If Curs_yy < 0           : Curs_yy = 0           : EndIf : EndIf
      If MP_KeyDown(#PB_Key_Down) : Curs_yy + EP_GetTileSize()  : If Curs_yy > Max_ScrollY : Curs_yy = Max_ScrollY : EndIf : EndIf
     
      EP_MapPosition (Curs_xx, Curs_yy)  ; Die Position der Map angeben, in Pixel !!  
      TLS = EP_DrawMap()                 ; Die Map auf den Bildschirm zeichnen
  

      Tile = EP_GetMapTile (X_TilePos, Y_TilePos) ; Tile Auslesen
      Flag = EP_GetMapFlag (X_TilePos, Y_TilePos) ; Flag Auslesen
      Anim = EP_GetMapAnim (X_TilePos, Y_TilePos) ; Animation Tile Auslesen
      Tran = EP_GetMapTrans(X_TilePos, Y_TilePos) ; Transparenz Auslesen

      If Tile = -1 : Tile$ = "Empty" : Else : Tile$ = Str(Tile) : EndIf
      If Anim = -1 : Anim$ = "No"    : Else : Anim$ = Str(Anim) : EndIf
      If Tran =  0 : Tran$ = "No"    : Else : Tran$ = Str(Tran) : EndIf
      XX_Korrekt   = 0 : XX_Korrekt2  = 0 : YY_Korrekt   = 0 : YY_Korrekt2  = 0


      If Copy_Modus = 0
        ; Anzeige Korrektur für Negative Werte
         If X_TilePos<=CopyModus_XStart : XX_Korrekt = 32 : XX_Korrekt2 = 2 : EndIf
         If Y_TilePos<=CopyModus_YStart : YY_Korrekt = 32 : YY_Korrekt2 = 2 : EndIf
         
         Copy_width  = (X_TilePos - CopyModus_XStart) + 1
         Copy_height = (Y_TilePos - CopyModus_YStart) + 1 
         MP_ScaleSprite(Copy_Plane,((Copy_width-XX_Korrekt2) * 3200), ((Copy_height-YY_Korrekt2)  * 3200) )
         Set_Zorder()
      EndIf
       
      MP_drawSprite(Copy_Plane, (EP_MapX2Pixel(CopyModus_XStart)+XX_Korrekt), ((EP_MapY2Pixel(CopyModus_YStart))+Base_Y+YY_Korrekt),155)
          
      If QuadUsed > 0 And Edit_Fokus=1        
        If LM_B_pre = 1 ; Maus gedrückt
          
          CopyModus_XEnd = X_TilePos
          CopyModus_YEnd = Y_TilePos 
          
          Draw_Spr_X = CopyModus_XStart 
          Draw_Spr_Y = CopyModus_YStart 
          
          If CopyModus_XEnd < CopyModus_XStart : Swap CopyModus_XEnd , CopyModus_XStart : Draw_Spr_X = CopyModus_XEnd+1 : EndIf
          If CopyModus_YEnd < CopyModus_YStart : Swap CopyModus_YEnd , CopyModus_YStart : Draw_Spr_Y = CopyModus_YEnd+1 : EndIf

          Copy_Modus = 1  : Modus = 0 : ModeChange = 1
        EndIf
      EndIf  

      MP_DrawText(550,15,"Drawn Tiles "+Str(TLS) )
      MP_DrawText(720,15,"FPS "+Str(FPX))

      MP_DrawText(380,15,Str(X_TilePos)+" * "+ Str(Y_TilePos)) : MP_DrawText(470,15,Str(EP_GetMapSizeX())+" * "+ Str(EP_GetMapSizeY()))
      MP_DrawText(380,31,Tile$) : MP_DrawText(480,31,Str(Flag))
      MP_DrawText(380,47,Anim$)
      MP_DrawText(380,66,Tran$)
      If Copy_Modus = 0
          MP_DrawText(550,32,"Den zu Markierenden Bereich" )
          MP_DrawText(550,48,"Markieren und mit Linker Maus-")
          MP_DrawText(550,64,"taste Bestätigen !" )
      EndIf   
       

EndIf





If Modus = 4 ; Single Paint Modus
     SetWindowTitle(0,AppTitleDeff$+" - Press Key 1 - 3 to switch the paint modes")
     If MP_KeyDown(#PB_Key_Left) : Curs_xx - EP_GetTileSize()  : If Curs_xx < 0           : Curs_xx = 0           : EndIf : EndIf
     If MP_KeyDown(#PB_Key_Right): Curs_xx + EP_GetTileSize()  : If Curs_xx > Max_ScrollX : Curs_xx = Max_ScrollX : EndIf : EndIf
     If MP_KeyDown(#PB_Key_Up)   : Curs_yy - EP_GetTileSize()  : If Curs_yy < 0           : Curs_yy = 0           : EndIf : EndIf
     If MP_KeyDown(#PB_Key_Down) : Curs_yy + EP_GetTileSize()  : If Curs_yy > Max_ScrollY : Curs_yy = Max_ScrollY : EndIf : EndIf
     
     If MP_KeyDown(#PB_Key_1) : SinglePaint = 0 : EndIf ; Tile Painter
     If MP_KeyDown(#PB_Key_2) : SinglePaint = 1 : EndIf ; Flasg Painter
     If MP_KeyDown(#PB_Key_3) : SinglePaint = 2 : EndIf ; Transparenz Painter
     If MP_KeyDown(#PB_Key_4) : SinglePaint = 3 : EndIf ; Item Painter
     
     EP_MapPosition (Curs_xx, Curs_yy)  ; Die Position der Map angeben, in Pixel !!  
     TLS = EP_DrawMap()                 ; Die Map auf den Bildschirm zeichnen
  

     Tile = EP_GetMapTile (X_TilePos, Y_TilePos) ; Tile Auslesen
     Flag = EP_GetMapFlag (X_TilePos, Y_TilePos) ; Flag Auslesen
     Anim = EP_GetMapAnim (X_TilePos, Y_TilePos) ; Animation Tile Auslesen
     Tran = EP_GetMapTrans(X_TilePos, Y_TilePos) ; Transparenz Auslesen
     Item = EP_GetMapItem (X_TilePos, Y_TilePos) ; Item Layer Auslesen

     If Tile = -1 : Tile$ = "Empty" : Else : Tile$ = Str(Tile) : EndIf
     If Anim = -1 : Anim$ = "No"    : Else : Anim$ = Str(Anim) : EndIf
     If Tran =  0 : Tran$ = "No"    : Else : Tran$ = Str(Tran) : EndIf
     If Item = -1 : Item$ = "No"    : Else : Item$ = Str(Item) : EndIf

     MP_DrawText(550,15,"Drawn Tiles "+Str(TLS) )
     MP_DrawText(720,15,"FPS "+Str(FPX))
     
     Select SinglePaint
       Case 0 : SPaint$ = "Tile Painter" : EP_DrawTile(550,50, Map_DrawTile) : MP_EntitySetOrder(Panel,0) : MP_DrawText(600,65,"Ak. Tile ID:"  + Str(Map_DrawTile) )
       Case 1 : SPaint$ = "Flag Painter" : MP_DrawText(550,65,"Ak. Flagwert:   " + Str(Map_DrawFlag) )
       Case 2 : SPaint$ = "Tranzparenz"  : MP_DrawText(550,65,"Ak. Transparenzwert:   " + Str(Map_DrawTrans) )
       Case 3 : SPaint$ = "Item Painter" : EP_DrawAnimTile(550,50, Map_DrawItem) : MP_EntitySetOrder(Panel,0) : MP_DrawText(600,65,"Ak. Item Tile ID:"  + Str(Map_DrawItem) )
     EndSelect
     
     
     ; Flag Painter Markierung
     If SinglePaint = 1
       Shin2_Adder.f + 5.5 : If Shin2_Adder > 360 : Shin_Adder2-360 : EndIf
       Shine2_Value  = Sin(Shin2_Adder * #PI / 180) * 20
       
       ST_SP_X = (Curs_xx/32) : ST_SP_Y = (Curs_yy/32) : FP_Trans = 0
       For FP_Y = 0 To 14 ; <- Anzeige Bereichswerte der Karte
         For FP_X = 0 To 24 ; <- Anzeige Bereichswerte der Karte
            FP_MapX = FP_X*EP_GetTileSize()
            FP_MapY = FP_Y*EP_GetTileSize()            
            FP_Trans + 1 : If FP_Trans=2 : FP_Trans = 0 : EndIf            
            If EP_GetMapFlag (ST_SP_X+FP_X, ST_SP_Y+FP_Y ) = Map_DrawFlag             
               MP_DrawSprite(FlagPaint, FP_MapX, Base_Y + FP_MapY, (40+(FP_Trans*5))+Shine2_Value )               
            EndIf   
         Next FP_X
       Next FP_Y   
     EndIf  
     
     
     MP_DrawText(380,15,Str(X_TilePos)+" * "+ Str(Y_TilePos)) : MP_DrawText(470,15,Str(EP_GetMapSizeX())+" * "+ Str(EP_GetMapSizeY()))
     MP_DrawText(380,31,Tile$) : MP_DrawText(480,31,Str(Flag))
     MP_DrawText(380,47,Anim$) : MP_DrawText(480,47,Item$)
     MP_DrawText(380,66,Tran$)
     MP_DrawText(550,40,"Single Paint Modus: "+SPaint$)
     
     
     
     

     
     
     If Copy_Modus = 1
           Set_Zorder()
           MP_drawSprite(Copy_Plane, (EP_MapX2Pixel(Draw_Spr_X)), (EP_MapY2Pixel(Draw_Spr_Y))+Base_Y,155)  
     EndIf
     

     If QuadUsed > 0 And Edit_Fokus=1 ; Das Markierte Tile besonders hervor heben 
       
         If MM_W_pre < 0 : Map_DrawTile - 1 : If Map_DrawTile<0 : Map_DrawTile=EP_GetTileCount() : EndIf : EndIf
         If MM_W_pre > 0 : Map_DrawTile + 1 : If Map_DrawTile>EP_GetTileCount() : Map_DrawTile=0 : EndIf : EndIf
       
         MP_DrawSprite(Shining ,XX_Quad-EP_GetTileSize() , YY_Quad-EP_GetTileSize() , Shine_Value )
        
         If LM_B_pre = 1 And ModeChange = 0
           If SinglePaint = 0 : EP_SetMapTile (X_TilePos, Y_TilePos, Map_DrawTile) : EndIf
           If SinglePaint = 1 : EP_SetMapFlag (X_TilePos, Y_TilePos, Map_DrawFlag) : EndIf
           If SinglePaint = 2 : EP_SetMapTrans(X_TilePos, Y_TilePos, Map_DrawTrans): EndIf
           If SinglePaint = 3 : EP_SetMapItem (X_TilePos, Y_TilePos, Map_DrawItem) : EndIf             
            Virgin = 1
         EndIf
    
         If RM_B_pre = 1 And ModeChange = 0
            If SinglePaint = 0 : EP_SetMapTile (X_TilePos, Y_TilePos,-1) : EndIf
            If SinglePaint = 1 : EP_SetMapFlag (X_TilePos, Y_TilePos, 0) : EndIf
            If SinglePaint = 2 : EP_SetMapTrans(X_TilePos, Y_TilePos, 0) : EndIf
            If SinglePaint = 3 : EP_SetMapItem (X_TilePos, Y_TilePos,-1) : EndIf 
            Virgin = 1
         EndIf
         
         If MM_B_pre = 1 And ModeChange = 0
           If Modus = 0 Or Modus = 3
              Copy_Modus = 0
              CopyModus_XStart = X_TilePos :  CopyModus_YStart = Y_TilePos
              Modus + 3 : If Modus = 6 : Modus = 0 : EndIf
           EndIf           
         EndIf
          
          
     EndIf  
     
EndIf









MP_DrawSprite(Choose(QuadUsed) ,XX_Quad-4, YY_Quad-4) ; Cursor Anzeigen
MP_DrawSprite(Panel ,0,0) ; Panel Anzeigen
MP_DrawSprite(Bar ,0,580) ; Bar Anzeigen









      MP_RenderWorld ()
    MP_Flip ()
  
Wend
  
  
End
















DataSection
   
   Quad1:   
   IncludeBinary "gfx\Editor\Edit_choose0.bmp"
   Quad1end:
   
   Quad2:    
   IncludeBinary "gfx\Editor\Edit_choose1.bmp"
   Quad2end:

   Shine:  
   IncludeBinary "gfx\Editor\Shine.png"
   Shineend:
   
   Panel:  
   IncludeBinary "gfx\Editor\Edit_panel.jpg"
   Panelend:
   
   Bar:    
   IncludeBinary "gfx\Editor\Edit_bar.jpg"
   Barend:
   
   Button1:
   IncludeBinary "gfx\Editor\Button_load.bmp"
   Button1End:
   
   Button2:
   IncludeBinary "gfx\Editor\Button_save.bmp"
   Button2End:
   
   Button3:
   IncludeBinary "gfx\Editor\Button_new.bmp"
   Button3End:
   
   Button4:
   IncludeBinary "gfx\Editor\Button_exit.bmp"
   Button4End:
   
   Button5:
   IncludeBinary "gfx\Editor\Button_ChooseTile.bmp"
   Button5End:
   
   Button6:
   IncludeBinary "gfx\Editor\Button_ChooseAnim.bmp"
   Button6End:
   
   Button7:
   IncludeBinary "gfx\Editor\Button_TilePrefs.bmp"
   Button7End:
   
   Button8: 
   IncludeBinary "gfx\Editor\Button_Setup.bmp"
   Button8End:
   
   Button9:
   IncludeBinary "gfx\Editor\Button_SinglePaint.bmp"
   Button9End:
   
   ButBoard:
   IncludeBinary "gfx\Editor\Button_border.bmp"
   ButBoardEnd:
   ButBoard2:
   IncludeBinary "gfx\Editor\Button_border2.bmp"
   ButBoard2End:
EndDataSection
 
 
 
 




Procedure AddButton(ID, XPos, YPos, Width, Height, Face)
  
  AddElement(Button_GUI())
  Button_GUI()\ID          = ID
  Button_GUI()\X           = XPos
  Button_GUI()\Y           = YPos
  Button_GUI()\X2          = Width
  Button_GUI()\Y2          = Height
  Button_GUI()\Button_Face = Face
  
  
EndProcedure
Procedure Draw_Buttons(MS_X, MS_Y)
Protected Back = -1  
  
  ForEach Button_GUI()
    
     MP_DrawSprite(Button_GUI()\Button_Face ,Button_GUI()\X, Button_GUI()\Y)
     
     If MS_X > Button_GUI()\X And MS_X< (Button_GUI()\X+Button_GUI()\X2) 
       If MS_Y > Button_GUI()\Y And MS_Y < (Button_GUI()\Y+Button_GUI()\Y2) 
         
          Rahmen = BBorder : If Button_GUI()\ID > 5 : Rahmen = BBorder2 : EndIf
         
          MP_DrawSprite(Rahmen ,Button_GUI()\X, Button_GUI()\Y , Shine_Value)
          Back = Button_GUI()\ID
          
       EndIf
     EndIf
     
  Next
  
ProcedureReturn Back  
EndProcedure
Procedure CreateGUI()
Plane_Tex  = MP_CreateTextureColor(1,1, MP_argb(255,255,255,0) )
Copy_Plane = MP_Spritefromtexture(Plane_Tex)  
  
Shining   = MP_CatchSprite(?Shine, ?ShineEnd-?Shine) : MP_SpriteBlendingMode(Shining, 5,6 )
Panel     = MP_CatchSprite(?Panel, ?PanelEnd-?Panel)
Bar       = MP_CatchSprite(?Bar, ?BarEnd-?Bar)
Choose(0) = MP_CatchSprite(?Quad1, ?Quad1End-?Quad1)
Choose(1) = MP_CatchSprite(?Quad2, ?Quad2End-?Quad2)

Button(0) = MP_CatchSprite(?Button3, ?Button3End-?Button3) 
Button(1) = MP_CatchSprite(?Button1, ?Button1End-?Button1)
Button(2) = MP_CatchSprite(?Button2, ?Button2End-?Button2)
Button(3) = MP_CatchSprite(?Button4, ?Button4End-?Button4)

Button(4) = MP_CatchSprite(?Button5, ?Button5End-?Button5)
Button(5) = MP_CatchSprite(?Button6, ?Button6End-?Button6)
Button(6) = MP_CatchSprite(?Button7, ?Button7End-?Button7)
Button(7) = MP_CatchSprite(?Button8, ?Button8End-?Button8)
Button(8) = MP_CatchSprite(?Button9, ?Button9End-?Button9)

BBorder   = MP_CatchSprite(?ButBoard, ?ButBoardEnd-?ButBoard)
BBorder2  = MP_CatchSprite(?ButBoard2, ?ButBoard2End-?ButBoard2)

Plane_Tex2 = MP_CreateTextureColor(32,32, MP_argb(255,0,255,255) )
FlagPaint  = MP_Spritefromtexture(Plane_Tex2)  

EndProcedure
Procedure OpenWindow_CreateNewMap()
Protected Tile_XX, Tile_YY, Tile_Size  
  If OpenWindow(#Window_0, 654, 263, 290, 236, #AppTitle$+"- Create a new Map", #PB_Window_TitleBar|#PB_Window_WindowCentered)

      FrameGadget(#Frame3D_0, 5, 5, 280, 225, "Gadget_0", #PB_Frame_Double)
      ButtonGadget(#Button_1, 20, 190, 85, 25, "Okay")
      ButtonGadget(#Button_2, 190, 190, 85, 25, "Cancel")
      TextGadget(#Text_4, 110, 95, 155, 20, "Map Width ", #PB_Text_Border|#PB_Text_Center)
      StringGadget(#String_5, 25, 95, 75, 20, "100", #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      StringGadget(#String_6, 25, 125, 75, 20,"100", #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      TextGadget(#Text_7, 110, 125, 155, 20, "Map Height", #PB_Text_Border|#PB_Text_Center)
      StringGadget(#String_8, 25, 155, 75, 20, "32", #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      TextGadget(#Text_9, 110, 155, 155, 20, "Tilesize", #PB_Text_Border|#PB_Text_Center)
      TextGadget(#Text_10, 25, 20, 240, 65, "Erstellt eine neue Karte, die vorhandenen Daten werden beim erstellen einer neuen Karte aber gelöscht.")
      
      DisableGadget(#String_8, 1)
      
       
     
Repeat
  Select WindowEvent()
      
    Case #PB_Event_Gadget
      Select EventGadget()

        Case #Button_1
          
          
          
          
          
         If Virgin <> 0  
           Req = MessageRequester(#AppTitle$+" - Achtung","Die Karte wurde noch nicht gespeichert, möchten Sie trotzdem eine neue Karte erstellen.",#PB_MessageRequester_YesNo|#MB_ICONEXCLAMATION)
        
           If Req = #PB_MessageRequester_Yes
                 Tile_XX   = Val(GetGadgetText(#String_5))
                 Tile_YY   = Val(GetGadgetText(#String_6))
                 Tile_Size = Val(GetGadgetText(#String_8))
          
                 If Tile_XX>999 : Tile_XX=999 : EndIf ; Eine Map zu 1000*1000 Tiles ist Riesig und für die meisten Spiele wäre das schon überdimensioniert
                 If Tile_YY>999 : Tile_YY=999 : EndIf ; Zudem gehen große Maps natürlich auch auf den Arbeitsspeicher, eine 1000*1000 benötigt 20000000 Bytes zur verwaltung
                 If Tile_Size> 128 : Tile_Size=128 : EndIf ; Ich denke alles über 64 Pixel Tilegröße wäre unrealistisch
                  
                 EP_CreateMap(Tile_XX, Tile_YY, Tile_Size)  ; Leere Karte erstellen 
                 Load_DefaultTileset()
                 
              Else
                  CloseWindow(#Window_0)
                  Break
           EndIf        
         Else
      

            Tile_XX   = Val(GetGadgetText(#String_5))
            Tile_YY   = Val(GetGadgetText(#String_6))
            Tile_Size = Val(GetGadgetText(#String_8))
          
            If Tile_XX>999 : Tile_XX=999 : EndIf ; Eine Map zu 1000*1000 Tiles ist Riesig und für die meisten Spiele wäre das schon überdimensioniert
            If Tile_YY>999 : Tile_YY=999 : EndIf ; Zudem gehen große Maps natürlich auch auf den Arbeitsspeicher, eine 1000*1000 benötigt 20000000 Bytes zur verwaltung
            If Tile_Size> 128 : Tile_Size=128 : EndIf ; Ich denke alles über 64 Pixel Tilegröße wäre unrealistisch
                  
            EP_CreateMap(Tile_XX, Tile_YY, Tile_Size)  ; Leere Karte erstellen 
            Load_DefaultTileset()            ; Das default TileSet laden
          
          EndIf
          
          CloseWindow(#Window_0)
          Break
          
        Case #Button_2
          CloseWindow(#Window_0)
          Break
      EndSelect

    Case #PB_Event_CloseWindow
      Select EventWindow()
        Case #Window_0
          CloseWindow(#Window_0)
          Break
      EndSelect
  EndSelect
  Delay(10)
ForEver
      
      
      
      
      
      
  EndIf
EndProcedure
Procedure OpenWindow_TileProperties()
Protected Tile_Face, Tile_Flag, Tile_Anim, Tile_Trans  
  
If OpenWindow(#Window_1, 597, 183, 337, 298, #AppTitle$+"- Tile Properties", #PB_Window_SystemMenu|#PB_Window_TitleBar|#PB_Window_WindowCentered)

      FrameGadget(#Frame3D_1, 5, 5, 325, 285, "Gadget_0", #PB_Frame_Double)
      StringGadget(#String_1, 20, 70, 80, 20,Str(Map_DrawTile), #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      TextGadget(#Text_2, 130, 70, 185, 20, "Tile ID  ( Max. " + Str(EP_GetTileCount()) +" ) )", #PB_Text_Border|#PB_Text_Center)
      StringGadget(#String_3, 20, 100, 80, 20, Str(Map_DrawFlag) , #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      TextGadget(#Text_5, 130, 100, 185, 20, "Flag Value", #PB_Text_Border|#PB_Text_Center)
      StringGadget(#String_7, 20, 130, 80, 20, Str(Map_DrawAnim), #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      TextGadget(#Text_6, 130, 130, 185, 20, "Anim Tile ( Max. "+Str(EP_GetAnimTileCount() )+" ) ( -1 = off )", #PB_Text_Border|#PB_Text_Center)
      StringGadget(#String_10, 20, 160, 80, 20, Str(Map_DrawTrans), #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      TextGadget(#Text_8, 130, 160, 185, 20, "Transparenz ( 0 - 255 )", #PB_Text_Border|#PB_Text_Center)
      StringGadget(#String_9, 20, 190, 80, 20, Str(Map_DrawItem), #PB_String_Numeric|#ES_RIGHT|#WS_BORDER)
      TextGadget(#Text_12, 130, 190, 185, 20, "Item Layer", #PB_Text_Border|#PB_Text_Center)
      TextGadget(#Text_11, 20, 15, 295, 50, "Einstellen der Werte für ein Tile, alle gezeichneten Tiles werden dann diese Werte mit in die Karte Schreiben.")
      ButtonGadget(#Button_12, 15, 250, 80, 30, "Okay")
      ButtonGadget(#Button_14, 125, 250, 80, 30, "Reset Values")
      ButtonGadget(#Button_13, 235, 250, 80, 30, "Cancel")
      
Repeat
  Select WindowEvent()
      
    Case #PB_Event_Gadget
      Select EventGadget()

        Case #Button_12
          
                 Tile_Face   = Val(GetGadgetText(#String_1))
                 Tile_Flag   = Val(GetGadgetText(#String_3))
                 Tile_Anim   = Val(GetGadgetText(#String_7))
                 Tile_Trans  = Val(GetGadgetText(#String_10))
                 Tile_Item   = Val(GetGadgetText(#String_9))
          
                 If Tile_Face < -1                : Tile_Face= -1                : EndIf
                 If Tile_Face > EP_GetTileCount() : Tile_Face= EP_GetTileCount() : EndIf
                 
                 If Tile_Anim < -1                : Tile_Anim= -1                : EndIf
                 If Tile_Anim > EP_GetAnimTileCount() : Tile_Anim= EP_GetAnimTileCount() : EndIf
                 
                 If Tile_Trans < 0 : Tile_Trans= 0 : EndIf
                 If Tile_Trans > 255 : Tile_Trans= 255 : EndIf
                 
                 If Tile_Item < -1                : Tile_Item= -1                : EndIf
                 If Tile_Item > EP_GetAnimTileCount() : Tile_Item= EP_GetAnimTileCount() : EndIf
                 
                 Map_DrawTile  = Tile_Face
                 Map_DrawFlag  = Tile_Flag
                 Map_DrawAnim  = Tile_Anim
                 Map_DrawTrans = Tile_Trans
                 Map_DrawItem  = Tile_Item
          
          CloseWindow(#Window_1)
          Break
          
        Case #Button_14  
          
          SetGadgetText(#String_3, " 1")
          SetGadgetText(#String_7, "-1")
          SetGadgetText(#String_10, "0")
          SetGadgetText(#String_9, "-1")
          
        Case #Button_13
          CloseWindow(#Window_1)
          Break
      EndSelect

    Case #PB_Event_CloseWindow
      Select EventWindow()
        Case #Window_1
          CloseWindow(#Window_1)
          Break
      EndSelect
  EndSelect
  
  
   Delay(10) 
ForEver

  EndIf
EndProcedure
Procedure OpenWindow_TileGFX()
Protected t , FileName$ , Pattern$ , File$ , TXT$
  
  If OpenWindow(#Window_2, 450, 200, 613, 288, "Graphic Browser", #PB_Window_TitleBar|#PB_Window_WindowCentered|#PB_Window_SystemMenu)

      FrameGadget(#Frame3D_2, 5, 5, 115, 275, "Gadget_0",#PB_Frame_Double)
      ListViewGadget(#ListView_1, 125, 5, 480, 135)
      ListViewGadget(#ListView_2, 125, 145, 480, 135)
      
      ButtonGadget(#Button_3, 15, 245, 95, 30, "Close")
      ButtonGadget(#Button_4, 15, 10, 95, 30, "Add GFX")
      ButtonGadget(#Button_5, 15, 45, 95, 30, "Refresh GFX")
      ButtonGadget(#Button_6, 15, 175, 95, 30, "Refresh Anim")
      ButtonGadget(#Button_7, 15, 140, 95, 30, "Add Anim")
      ButtonGadget(#Button_8, 15, 80, 95, 30, "Delete GFX")
      ButtonGadget(#Button_9, 15, 210, 95, 30, "Delete Anim")
      
      
      ClearGadgetItems(#ListView_1) : ClearGadgetItems(#ListView_2)
      
      WindowEvent()
      For t =0 To EP_GetTileGFXCount()  
         AddGadgetItem(#ListView_1, -1 , EP_GetTileGFXPath(T) )   
      Next t
      
      For t =0 To EP_GetAnimTileCount()  
         AddGadgetItem(#ListView_2, -1 , EP_GetAnimGFXPath(T) )   
      Next t
       
      
Repeat
  Select WindowEvent()
      
  Case #PB_Event_Gadget
      Select EventGadget()
          
      Case  #Button_4   
        Pattern$ = "Windows Bitmap (*.bmp)|*.bmp|Portable Network Graphics (*.png)|*.png|Joint Photographic Experts Group (*.jpg)|*.jpg|Tagged Image File Format (*.tiff)|*.tiff|Targa Image File (*.tga)|*.tga|JPEG 2000 (*.jp2)|*.jp2|Alle Dateien (*.*)|*.*"
        File$ = OpenFileRequester(#AppTitle$+" - Tile GFX Laden", "", Pattern$, 0)
        If File$ <> "" 
           EP_AddTileGFX(File$)
           ClearGadgetItems(#ListView_1) : For t =0 To EP_GetTileGFXCount() : AddGadgetItem(#ListView_1, -1 , EP_GetTileGFXPath(t)) : Next t          
        EndIf
        
       
      Case  #Button_5
        
        EP_ClearTiles()                               ; Alle Tiles löschen
        For t = 0 To CountGadgetItems(#ListView_1) - 1; Und neu einladen, um aktualisierte Tiles zu bekommen
           SetGadgetState(#ListView_1,t)
           FileName$ = GetGadgetText(#ListView_1) : EP_AddTileGFX(FileName$)           
        Next t
        MessageRequester(#AppTitle$+" - Erledigt","Alle Grafik Tiles wurden neu eingelesen",#PB_MessageRequester_Ok) 
        
        
      Case  #Button_8
        
         Eintrag =  GetGadgetState(#ListView_1)
         If Eintrag > -1
             TXT$ = "Wenn Sie eine Tilegrafik löschen kann es zu Darstellungfehlern in der Karte kommen, deshalb ist diese"+Chr(13)+"Funktion nur zu Beginn und bevor man mit dem erstellen der Karte begonnen hat zu empfehlen."+Chr(13)+Chr(13)+"Möchten Sie trotzdem fortfahren und diese Tile Grafik löschen?"
             Req = MessageRequester(#AppTitle$ + " - Achtung", TXT$ ,#PB_MessageRequester_YesNo|#MB_ICONEXCLAMATION)
             If Req = #PB_MessageRequester_Yes
                RemoveGadgetItem(#ListView_1 , Eintrag)
                
                EP_ClearTiles() : For t = 0 To CountGadgetItems(#ListView_1) - 1; Alles löschen und neu Organisieren
                SetGadgetState(#ListView_1,t) : FileName$ = GetGadgetText(#ListView_1) : EP_AddTileGFX(FileName$) : Next t
             EndIf           
         EndIf
        
        
         
         
         
         
      Case  #Button_7   
        Pattern$ = "Windows Bitmap (*.bmp)|*.bmp|Portable Network Graphics (*.png)|*.png|Joint Photographic Experts Group (*.jpg)|*.jpg|Tagged Image File Format (*.tiff)|*.tiff|Targa Image File (*.tga)|*.tga|JPEG 2000 (*.jp2)|*.jp2|Alle Dateien (*.*)|*.*"
        File$ = OpenFileRequester(#AppTitle$+" - Anim GFX Laden", "", Pattern$, 0)
        
        If File$ <> "" 
           EP_LoadAnimTile(File$)
           ClearGadgetItems(#ListView_2) : For t =0 To EP_GetAnimTileCount() : AddGadgetItem(#ListView_2, -1 , EP_GetAnimGFXPath(t)) : Next t          
        EndIf
        
           
      Case  #Button_6
        EP_ClearAnims()                               ; Alle Tiles löschen
        For t = 0 To CountGadgetItems(#ListView_2) - 1; Und neu einladen, um aktualisierte Tiles zu bekommen
           SetGadgetState(#ListView_2,t)
           FileName$ = GetGadgetText(#ListView_2) : EP_LoadAnimTile(FileName$)           
        Next t
        MessageRequester(#AppTitle$+" - Erledigt","Alle Anim Tiles wurden neu eingelesen",#PB_MessageRequester_Ok) 
         
         
      Case  #Button_9
         Eintrag =  GetGadgetState(#ListView_2)
         If Eintrag > -1
             TXT$ = "Wenn Sie eine TileAnimation löschen kann es zu Darstellungfehlern in der Karte kommen, deshalb ist diese"+Chr(13)+"Funktion nur zu Beginn und bevor man mit dem erstellen der Karte begonnen hat zu empfehlen."+Chr(13)+Chr(13)+"Möchten Sie trotzdem fortfahren und diese Tile Animation löschen?"
             Req = MessageRequester(#AppTitle$ + " - Achtung", TXT$ ,#PB_MessageRequester_YesNo|#MB_ICONEXCLAMATION)
             If Req = #PB_MessageRequester_Yes
                RemoveGadgetItem(#ListView_2 , Eintrag)
                EP_ClearAnims() : For t = 0 To CountGadgetItems(#ListView_2) - 1; Alles löschen und neu Organisieren
                SetGadgetState(#ListView_2,t) : FileName$ = GetGadgetText(#ListView_2) : EP_LoadAnimTile(FileName$) : Next t
             EndIf           
         EndIf 
         
         
         
         
         
         
         
        
        
       Case  #Button_3
        Set_Zorder()
        CloseWindow(#Window_2)
        Break
          
   EndSelect       
   Case #PB_Event_CloseWindow
        
     Select EventWindow()

       Case #Window_2
             Set_Zorder()
             CloseWindow(#Window_2)
             Break
        EndSelect
  EndSelect
  
  
   Delay(10) 
ForEver
         
          
  EndIf
EndProcedure
Procedure Load_DefaultTileset()
  
  EP_AddTileGFX("gfx\XMas_Tiles2.bmp") 
EP_LoadAnimTile("gfx\wellen_anim.bmp") ; Anim Tiles Einlesen
EP_LoadAnimTile("gfx\Water_anim.bmp")  
EP_LoadAnimTile("gfx\Coin_Anim.bmp")
EP_LoadAnimTile("gfx\Frage1.bmp")
EP_LoadAnimTile("gfx\Frage2.bmp")
EP_LoadAnimTile("gfx\CoinBlock.bmp")
EP_LoadAnimTile("gfx\Wellen2_Anim.bmp")
EP_LoadAnimTile("gfx\Key_Red.bmp")
EP_LoadAnimTile("gfx\Key_Yellow.bmp")

EP_LoadAnimTile("gfx\Gate_Yellow.bmp")
EP_LoadAnimTile("gfx\Gate_Red.bmp")
EP_LoadAnimTile("gfx\Xtra_Anim.bmp")


EndProcedure
Procedure Set_Zorder()
  MP_EntitySetOrder(Copy_Plane,1)
  MP_EntitySetOrder(Shining,1)
  MP_EntitySetOrder(Choose(0),1)
  MP_EntitySetOrder(Choose(1),1)
  
  MP_EntitySetOrder(Bar,1)
  MP_EntitySetOrder(Panel,1)
  
  ForEach Button_GUI()
    MP_EntitySetOrder(Button_GUI()\Button_Face,1)
  Next  
  MP_EntitySetOrder(FlagPaint,1)
  MP_EntitySetOrder(BBorder,1)
  MP_EntitySetOrder(BBorder2,1)
EndProcedure

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 1219
; FirstLine = 1044
; Folding = An
; EnableXP
; UseIcon = gfx\Ikon.ico
; Executable = Editor.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
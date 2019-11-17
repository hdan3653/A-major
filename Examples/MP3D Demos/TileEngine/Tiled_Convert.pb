;******************************************************************************
;******************************************************************************
;***                                                                        ***
;***   Konverter für Tiled Map by Epyx                                      ***
;***                                                                        ***
;***   Only Tile values will be converted all Tile flags set to 1           ***
;***   empty fields set the flags to 0                                      ***
;***                                                                        ***
;***                                                                        ***
;***                                                                        ***
;***   PureBasic 4.51 and MP3d Engine a30                                   ***
;***                                                                        ***
;***                                                                        ***
;***   Tiled MapEditor => http://www.mapeditor.org/                         ***
;***                                                                        ***
;***   little bug fixing MPaulwitz                                                                       ***
;***                                                                        ***
;******************************************************************************
;******************************************************************************


EP_Init2dMap()

  Pattern$ = "Tiled Mapfile (*.tmx)|*.tmx|all files (*.*)|*.*"
  File$ = OpenFileRequester("Please load the Map.tmx file", "", Pattern$, 0)
 
  NC = Len(GetExtensionPart(File$))+1 : FL = Len(File$)
  NFile$ = Left(File$, (FL-NC)) +"[Converted].Map"
 
  NewList Textline.s()
  NewList Tilename.s()
 
If ReadFile(0, File$)
     
  While Eof(0) = 0
    AddElement(Textline())
    Textline() = ReadString(0)   
  Wend
   
  CloseFile(0)
   
    Map_Width      = 0
    Map_Height     = 0
    Map_Tilesize   = 0   
    DataEncoding.s = ""
   
    ToFind$ = "orientation="+Chr(34)+"orthogonal"+Chr(34)
   
    ForEach Textline()
     
      X = FindString(Textline(),ToFind$,1)
      If X <> 0       
         ;Kartenbreite auslesen
         TheWidth = FindString(Textline(),"width="+Chr(34),(X+24))
         If TheWidth <> 0 : Width_ST = (TheWidth+7) : Width_ND = FindString(Textline(),Chr(34),Width_ST)     
         Map_Width = Val(Mid(Textline(),Width_ST,(Width_ND-Width_ST)))
         EndIf
         
         ;Kartenhöhe auslesen
         TheHeight = FindString(Textline(),"height="+Chr(34), Width_ND)
         If TheHeight <> 0 : Height_ST = (TheHeight+8): Height_ND = FindString(Textline(),Chr(34),Height_ST) 
         Map_Height = Val(Mid(Textline(),Height_ST,(Height_ND-Height_ST)))
         EndIf
         
         ;Tilegröße auslesen; nur X size
         TheTile = FindString(Textline(),"tilewidth="+Chr(34), Height_ND)
         If TheTile <> 0 : Tile_ST = (TheTile+11): Tile_ND = FindString(Textline(),Chr(34),Tile_ST) 
         Map_Tilesize = Val(Mid(Textline(),Tile_ST,(Tile_ND-Tile_ST)))
         EndIf         
      EndIf
     
      ; Die Tilegrafik Namen auslesen
      TileLine = FindString(Textline(),"<image source="+Chr(34), 1)
      If TileLine <> 0 : TileLine_ST = (TileLine + 15) : TileLine_ND = FindString(Textline(),Chr(34),TileLine_ST)
        AddElement(Tilename())
        Tilename() = Mid(Textline(),TileLine_ST,(TileLine_ND-TileLine_ST))
      EndIf
     
      ; Kodierung der Map Daten auslesen
      DataFormat = FindString(Textline(),"<data encoding="+Chr(34), 1)
      If DataFormat <> 0 : Data_ST = (DataFormat + 16) : Data_ND = FindString(Textline(),Chr(34),Data_ST)
        DataEncoding.s = Mid(Textline(),Data_ST,(Data_ND-Data_ST))
        If DataEncoding.s = "csv" : NextElement(Textline()) : TileItemLine = 0
                   
        ; Irgendwas stimmt nicht, dann alles abbrechen 
        If Map_Width=0 Or Map_Height=0 Or Map_Tilesize=0 Or DataEncoding.s <> "csv"
          Result$ = File$ + Chr(13)+Chr(13)     
          Result$ = Result$ + "witdh = "+Str(Map_Width) + "    height = "+ Str(Map_Height) + Chr(13)
          Result$ = Result$ + "Tiles = "+Str(Map_Tilesize) + "    Encode = "+ DataEncoding.s + Chr(13)
          MessageRequester("Error occured","Cant convert this File"+Chr(13)+Result$)
          End       
        EndIf
       
        ;Neue Map öffnen
         EP_CreateMap(Map_Width, Map_Height, Map_Tilesize)
 
         ForEach Tilename()
             EP_SetTileGFX(Tilename()) ; Den Original Tile Pfad in die Map übernehmen (Achtung evtl. neuen Pfad im Programm angeben)
         Next         
         
        EndIf 
      EndIf

      If DataEncoding.s = "csv"
         Commas = CountString(Textline(),",")
         If Commas > 0 
           For t = 1 To Commas
             Tile = Val(StringField(Textline(),t,","))
             Tile - 1

             EP_SetMapTile((t-1), TileItemLine, Tile) ; Tja the Tile himself ^^
             If Tile <> -1 ; This Tile is used
                EP_SetMapFlag((t-1), TileItemLine,  1)  ; default Tile Flag
              Else
                EP_SetMapFlag((t-1), TileItemLine, -1)  ; Empty Tile
             EndIf   
             EP_SetMapAnim((t-1), TileItemLine, -1)  ; Kein Animations Tile
             EP_SetMapTrans((t-1),TileItemLine,  0)  ; Keine Transparenz bei diesem Tile
             EP_SetMapItem((t-1), TileItemLine, -1)  ; Kein Item-Tile über diesem Tile
             
           Next t     
           
             ;- little Bugfixing start
             t = Commas + 1
           
             Tile = Val(StringField(Textline(),t,","))
             Tile - 1

             EP_SetMapTile((t-1), TileItemLine, Tile) ; Tja the Tile himself ^^
             If Tile <> -1 ; This Tile is used
                EP_SetMapFlag((t-1), TileItemLine,  1)  ; default Tile Flag
              Else
                EP_SetMapFlag((t-1), TileItemLine, -1)  ; Empty Tile
             EndIf   
             EP_SetMapAnim((t-1), TileItemLine, -1)  ; Kein Animations Tile
             EP_SetMapTrans((t-1),TileItemLine,  0)  ; Keine Transparenz bei diesem Tile
             EP_SetMapItem((t-1), TileItemLine, -1)  ; Kein Item-Tile über diesem Tile
             ;- little Bugfixing end

         EndIf
       
         TileItemLine + 1   
       
      EndIf
     
    Next
   
    EP_SaveMap(NFile$)
   
    MessageRequester("Erledigt","the converted map was saved :)") ; ready
   
Else
   MessageRequester("Fehler","Cant open file") ; Error
EndIf

End
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 155
; FirstLine = 107
; EnableXP
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem
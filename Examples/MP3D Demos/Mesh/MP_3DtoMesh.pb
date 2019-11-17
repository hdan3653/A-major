;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: DirectXtoMeshKonverter.pb
;// Created On: 28.10.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// Ver: 1.02
;// Used with my Alphaversion of MP_Directx9 library
;// based on Steven "Dreglor" Garcias DX9 files
;// konvertiert/convert x,y,z,nx,ny,nz,col,u,v, Textur
;////////////////////////////////////////////////////////////////


;- Init 

If MP_Graphics3D (640,480,0,3); Create 3D Fenster/Windows
  If CreateMenu(0, WindowID(0)) ; Menü erstellen/Create Menu 
    MenuTitle("&Datei/File") 
      MenuItem( 1, "&Lade/load 3D Mesh file")  
      MenuBar() 
      MenuItem( 2, "&Ende/End") 
    MenuTitle("&Ogre Mesh speichern/save") 
      MenuItem(3, "Speicher/Save Mesh Sourcecode") 
    MenuTitle("&Hilfe/Help") 
      MenuItem(4, "Über/About 3D to Mesh") 
  EndIf 

Else 

  End ; Kann Fenster nicht erstellen/Cant Create Windows

EndIf 

camera=MP_CreateCamera() ; Kamera erstellen / Create Camera
light=MP_CreateLight(1) ; Es werde Licht / Light on

mesh1 = MP_CreateCube() ; Würfel erstelln / Cretae Cube

max.f = MP_MeshGetHeight(mesh1) ; find Maximum of Mesh
If MP_MeshGetWidth(mesh1) > max
   max = MP_MeshGetWidth(mesh1) 
EndIf

If MP_MeshGetDepth(mesh1) > max
   max = MP_MeshGetDepth(mesh1)
EndIf

scale.f = 3 
MP_ScaleEntity (mesh1,scale,scale,scale) ; Auf Bildschirm maximieren / maximum to Screen

x.f=0 : y.f=0 : z.f=6 ; Mesh Koordinaten 

While Not MP_KeyDown(#PB_Key_Escape) ; Esc abfrage / SC pushed?

 Select WindowEvent()  ; WindowsEvent abfrage 
      Case #PB_Event_Menu 
        Select EventMenu()  ; Welches Menü? / Menuquestion 

          Case 1 ; 3D Objekt als Directx File laden /  
              Pattern$ = "3D Mesh files|*.x;*.3ds;*.b3d|.x file (*.x)|*.x|3DS file (*.3ds)|*.3ds|B3D file (*.b3d)|*.b3d"
              directory$ = "C:\Programme\PureBasic\media\" 
              File.s = OpenFileRequester("Lade Directx Datei / Load Direct x File!", directory$, Pattern$,  0) 
              If File 
                  If mesh1:MP_FreeEntity(mesh1):EndIf ; Altes Mesh löschen / Free old Mesh
                  mesh1=MP_LoadMesh(File.s)            ; Neues Mesh laden  / Load new Mesh
                  TextureMesh.l = MP_EntityGetTexture (mesh1) ; Textur des geladen Mesh finden / Find Mesh Texture 
                  Texturname.s = MP_TextureGetName (TextureMesh) ; Name der Textur / Name of Texture
                 
                  x.f=0 : y.f=0 : z.f=6 ; Mesh Koordinaten 
                 
                  max.f = MP_MeshGetHeight(mesh1) ; find Maximum of Mesh
             
                  If MP_MeshGetWidth(mesh1) > max
                    max = MP_MeshGetWidth(mesh1) 
                  EndIf

                  If MP_MeshGetDepth(mesh1) > max
                    max = MP_MeshGetDepth(mesh1) 
                  EndIf
                  
                  Debug max

                  scale.f = 3 / max ; 

                  MP_ScaleEntity (mesh1,scale,scale,scale) ; Auf Bildschirm maximieren / maximum to Screen
              EndIf
          Case 2 ; Ende 
             End 
          Case 3 ; Ogre Mesh erzeugen / Create Ogre Mesh 
              File.s = SaveFileRequester("Speicher/Save MP3D Mesh Code", "MP3D_Mesh.pb", "MP3D_Mesh Files(*.pb)|*.pb",  0) 

              If CreateFile(1, File.s) ; Erstelle/Create Code
                  Restore StringData
                  Repeat
                    Read.s Purestring.s 
                    WriteStringN(1, Purestring)
                  Until Purestring.s  = "End"

                  WriteStringN(1, "" )         
                  WriteStringN(1, "DataSection" )
                  WriteStringN(1, "   StringSect:")
                  WriteStringN(1, "      Data.s "+Chr(34)+Texturname+Chr(34))
                  WriteStringN(1, "")               
                  WriteStringN(1, "   NumericalData:")
                  WriteStringN(1, "   Data.l "+Str(MP_CountVertices(Mesh1))+","+Str(MP_CountTriangles(Mesh1))+","+Str(max)) ; Zähle/Count Vertices und/and Triangle
                  WriteStringN(1, "")
                  WriteStringN(1, "   Vertice:  ;x,y,z,nx,ny,nz,col,u,v = Vertex + Normal + Col + UV Koordinaten" )
                  For n =  0 To MP_CountVertices(Mesh1)-1
                    vx.s = StrF(MP_VertexGetX (Mesh1, n))
                    vx.s = MP_RemoveNil(vx.s)
                    vy.s = StrF(MP_VertexGetY (Mesh1, n))
                    vy.s = MP_RemoveNil(vy.s)
                    vz.s = StrF(MP_VertexGetZ (Mesh1, n))
                    vz.s = MP_RemoveNil(vz.s)
                    nx.s = StrF(MP_VertexGetNX(Mesh1, n))
                    nx.s = MP_RemoveNil(nx.s)
                    ny.s = StrF(MP_VertexGetNY(Mesh1, n))
                    ny.s = MP_RemoveNil(ny.s)
                    nz.s = StrF(MP_VertexGetNZ(Mesh1, n))
                    nz.s = MP_RemoveNil(nz.s)
                   Col.s = Str(MP_VertexGetColor(Mesh1, n))
                     u.s = StrF(MP_VertexGetU (Mesh1, n)) 
                     u.s = MP_RemoveNil(u.s)
                     v.s = StrF(MP_VertexGetV (Mesh1, n))
                     v.s = MP_RemoveNil(v.s)
                     ;WriteStringN(1, "   Data.f "+vx+","+vy+","+vz+",0,0,0")
                     WriteStringN(1, "   Data.f "+vx+","+vy+","+vz+","+nx+","+ny+","+nz)
                     WriteStringN(1, "   Data.l "+col)
                     ;WriteStringN(1, "   Data.f 0,0")
                     WriteStringN(1, "   Data.f "+u+","+v )
                     SetWindowTitle(0, "Write: "+Str(n)+"/"+Str(MP_CountVertices(Mesh1)-1)+" Vertices") 
                  Next
                  WriteStringN(1, "")
                  WriteStringN(1, "   Triangle: ; Vertice x,y,z verbinden/Create Triangle" )
                  For n =  1 To MP_CountTriangles(Mesh1)
                      corner_0 = MP_EntityGetTriangle(Mesh1,n, 0) ;
                      corner_1 = MP_EntityGetTriangle(Mesh1,n, 2) ;
                      corner_2 = MP_EntityGetTriangle(Mesh1,n, 1) ;
                      

                      
                      WriteStringN(1, "   Data.w "+Str(corner_2)+","+Str(corner_0)+","+Str(corner_1) )
                      SetWindowTitle(0, "Write: "+Str(n)+"/"+Str(MP_CountTriangles(Mesh1))+" Triangle") 
                  Next
                  WriteStringN(1, "EndDataSection")
                  WriteStringN(1, "; IDE Options = PureBasic 4.31 (Windows - x86)")
                  WriteStringN(1, "; EnableAsm")
                  WriteStringN(1, "; SubSystem = dx9")
                  
                  CloseFile(1)
                  MessageRequester("Info", "Ogre Mesh Code erzeugt/created", 0)
                  SetWindowTitle(0, "Ready") 

              Else
                  MessageRequester("Error", "Kann die Datei nicht schreiben/Can't write file", 0)
              EndIf
               
          Case 4 ; Über 
             info.s = "DirectXtoMeshKonverter"+Chr(10)+Chr(10) 
             info.s = info.s + "Mit diesem Programm kann man aus direct x Dateien"+Chr(10) 
             info.s = info.s + "Purebasic Mesh Dateien erzeugen"+Chr(10)+Chr(10)
             info.s = info.s + "With this program you can create PB Meshcode from direct x files"+Chr(10) +Chr(10)
             info.s = info.s + "Bewege/Move Mesh mit/with Cursor Tasten/Keys"+Chr(10) +Chr(10)
             info.s = info.s + "(c) Michael Paulwitz tested with PB 4.31 "+Chr(10) 
             MessageRequester("Info", info.s, 0) 
         EndSelect 
      Case #PB_Event_CloseWindow 
         End 
EndSelect 

 ; nen bishen apielen und das Objekt drehen 
 If MP_KeyDown(#PB_Key_Left)=1 : x=x-1 : EndIf ;links Debug #PB_Key_Left 
 If MP_KeyDown(#PB_Key_Right)=1 : x=x+1 : EndIf ;rechts #PB_Key_Right 
 If MP_KeyDown(#PB_Key_Down)=1 : y=y-1 : EndIf ;Runter #PB_Key_Down 
 If MP_KeyDown(#PB_Key_Up)=1 : y=y+1 : EndIf ;rauf #PB_Key_Up 
 If MP_KeyDown(#PB_Key_Z)=1  : z=z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur 
 If MP_KeyDown(#PB_Key_Y)=1  : z=z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur 
 If MP_KeyDown(#PB_Key_A)=1  : z=z-0.1 : EndIf ;a #PB_Key_A 

 If mesh1 ; Objekt drehen
    MP_DrawText (10,10,"Triangles: "+Str(MP_CountTriangles(Mesh1))+"  Vertices: "+Str(MP_CountVertices(Mesh1))) 
    MP_PositionEntity (Mesh1,0,0,z) 
    MP_RotateEntity (Mesh1,x,y,0) 
 EndIf 

    MP_RenderWorld () 
    MP_Flip () 
Wend 
End

DataSection

StringData:

Data.s "MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0"
Data.s "SetWindowTitle(0, "+Chr(34)+"3D Darstellung eines Mesh Objektes"+Chr(34)+")" 
Data.s "camera=MP_CreateCamera() ; Kamera erstellen"
Data.s "light=MP_CreateLight(1) ; Es werde Licht"
Data.s " "
Data.s "Restore NumericalData"
Data.s "Read.l Vert"
Data.s "Read.l Tria"
Data.s "Read.l Max"
Data.s " "    
Data.s "mesh=MP_CreateMesh ()"
Data.s " "
Data.s "MP_MeshSetData(mesh, #PB_Mesh_Vertex | #PB_Mesh_Normal | #PB_Mesh_Color  | #PB_Mesh_UVCoordinate, ?Vertice, Vert);3)"
Data.s "MP_MeshSetData(mesh, #PB_Mesh_Face, ?Triangle, Tria); 1)"
Data.s " "
Data.s "x.f=0 : y.f=0 : z.f+(max*2)"
Data.s " "
Data.s "Restore StringSect"
Data.s "Read.s Texturname.s" 
Data.s " "
Data.s "If FileSize(Texturname) <> -1"
Data.s "   Textur = MP_LoadTexture(Texturname)"
Data.s "   MP_EntitySetTexture (mesh,Textur)"
Data.s "EndIf"
Data.s " "
Data.s "MP_PositionEntity (mesh,0,0,z) ; Position des Würfels"
Data.s " "
Data.s "Texture2 = MP_CreateTextureColor(255, 255, RGB(180,185,177))" 
Data.s " "
Data.s "If CreateImage(0, 255, 255)"
Data.s "    Font = LoadFont(#PB_Any, "+Chr(34)+"Arial"+Chr(34)+"  , 138)" 
Data.s "    StartDrawing(ImageOutput(0))"
Data.s "    Box(0, 0, 128, 128,RGB(255,0,0))"
Data.s "    Box(128, 0, 128, 128,RGB(0,255,0))"
Data.s "    Box(0, 128, 128, 128,RGB(0,0,255))"
Data.s "    Box(128, 128, 128, 128,RGB(255,255,0))"
Data.s "    DrawingFont(FontID(Font))"
Data.s "    DrawingMode(#PB_2DDrawing_Transparent)"
Data.s "    DrawText(73,35,"+Chr(34)+"5"+Chr(34)+")"
Data.s "    StopDrawing()"
Data.s "    Texture3 = MP_ImageToTexture(0)"
Data.s "EndIf"
Data.s " "
Data.s "While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen"
Data.s " "
Data.s " If MP_KeyDown(#PB_Key_Left)=1 : x=x-1 : EndIf ;links Debug #PB_Key_Left"
Data.s " If MP_KeyDown(#PB_Key_Right)=1 : x=x+1 : EndIf ;rechts #PB_Key_Right" 
Data.s " If MP_KeyDown(#PB_Key_Down)=1 : y=y-1 : EndIf ;Runter #PB_Key_Down"
Data.s " If MP_KeyDown(#PB_Key_Up)=1 : y=y+1 : EndIf ;rauf #PB_Key_Up"
Data.s " If MP_KeyDown(#PB_Key_Z)=1  : z=z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur" 
Data.s " If MP_KeyDown(#PB_Key_Y)=1  : z=z+0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur" 
Data.s " If MP_KeyDown(#PB_Key_A)=1  : z=z-0.1 : EndIf ;a #PB_Key_A" 
Data.s " If MP_KeyDown(#PB_Key_1)=1  : MP_EntitySetTexture (mesh,Texture2) : EndIf ;a #PB_Key_1"
Data.s " If MP_KeyDown(#PB_Key_2)=1  : MP_EntitySetTexture (mesh,Texture3) : EndIf ;a #PB_Key_2"
Data.s " "
Data.s "     MP_PositionEntity (mesh,x,y,z) ; Position des Würfel"
Data.s " "
Data.s "    MP_TurnEntity (mesh,0.7,0.7,0.7) ; Ein bischen drehen"
Data.s "    MP_RenderWorld() ; Erstelle die Welt"
Data.s "    MP_Flip () ; Stelle Sie dar"
Data.s " "
Data.s "Wend"
Data.s " "  
Data.s "End"


; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 141
; FirstLine = 99
; UseIcon = ..\mp3d.ico
; Executable = C:\DirectXtoMeshKonverter.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
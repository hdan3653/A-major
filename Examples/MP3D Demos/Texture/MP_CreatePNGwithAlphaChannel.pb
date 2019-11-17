;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_CreatePNGwithAlphaChannel.pb
;// Erstellt am: 14.12.2010
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// Create a png file with alphachannel. You load a rgb grafic and load a second grafic for greyscales inage.
;// Both images must have the same size Bl
;//
;//
;////////////////////////////////////////////////////////////////


;- ProgrammStart

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "Create Alpha Textur") 

  If CreateMenu(0, WindowID(0)) ; Menü erstellen/Create Menu 
    MenuTitle("load / save grafic")
      MenuBar()
      MenuItem( 1, "Load RGB grafic") 
      MenuItem( 2, "Load Alphachannel") 
      MenuBar()
      MenuItem( 3, "Save png grafic with Alpha Channel") 
      MenuBar()
      MenuItem( 4, "Exit") 
  EndIf
  
  
  Width=256
Height=256 

If CreateImage(0, 640, 480)
  MP_CreateImageColored(0, 0, RGB(0,255,255), RGB(0,255,255), RGB(0,0,255), RGB(0,0,255))     
EndIf
Surface = MP_ImageToSurface(0,0) ; Image = 0, 
FreeImage(0)
MP_SurfaceSetPosition(Surface,0,0,1)
MP_SurfaceDestRect(Surface,0, 0, 640, 480)
  
  
camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht
Mesh=MP_CreatePlane(1,1) 
MP_MeshSetAlpha(Mesh, 2) ; AlphaMode on

MP_PositionEntity (Mesh,0,0,1.4) ; Position of plane

MP_AmbientSetLight(RGB(123,22,200)) 

While Not MP_KeyDown(#PB_Key_Escape)  ; Esc abfrage / SC pushed?

    Select WindowEvent()  ; WindowsEvent abfrage 
      Case #PB_Event_Menu 
        Select EventMenu()  ; Welches Menü? / Menuquestion 
         Case 1 ; Load RGB grafic
              Pattern$ = "Image Files (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              directory$ = "C:\Programme\PureBasic\media\" 
              File.s = OpenFileRequester("Load RGB grafic", directory$, Pattern$,  0) 
              If File
                 MP_FreeTexture (Texture1)
                 Texture1 =  MP_LoadTexture(File.s,1)
                 
                 MP_EntitySetTexture(Mesh, Texture1) 
                 
               EndIf
         Case 2 ; Load Alphachannel grafic
              Pattern$ = "Image Files (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              directory$ = "C:\Programme\PureBasic\media\" 
              File.s = OpenFileRequester("Load Alphachannel grafic", directory$, Pattern$,  0) 
              If File
                 MP_FreeTexture (Texture2)
                 Texture2 =  MP_LoadTexture(File.s)
                 If Not MP_CreateTextureAlpha(Texture1, Texture2)
                    MessageRequester("Cant create alphachannel grafic ", "Important both grafic must have the same size", #PB_MessageRequester_Ok)
                 EndIf  
                 MP_EntitySetTexture(Mesh, Texture1) 
                 
               EndIf
         Case 3 ; Save png grafic with Alpha Channel
              File.s = SaveFileRequester("Save grafic  as PNG", "Textur.png", "Textur Files(*.png)|*.png",  0)
              If File
                 MP_SaveTexture (File, Texture1 , 3)
               EndIf
         Case 4; end
               End
         EndSelect 
      Case #PB_Event_CloseWindow 
         End 
   EndSelect        

   MP_RenderWorld() ; Erstelle die Welt
   MP_Flip () ; Stelle Sie dar

Wend

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 51
; FirstLine = 28
; UseIcon = ..\mp3d.ico
; Executable = C:\MP_CreatePNGwithAlphaChannel.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
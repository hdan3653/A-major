
;- Init 

If MP_Graphics3D (640,480,0,3);MP_Graphics3D (640,480,0,3) 

  If CreateMenu(0, WindowID(0)) ; Menü erstellen 
    MenuTitle("Datei") 
      MenuItem( 1, "&Load DirectX Mesh...") 
      MenuItem( 2, "&Load Textur...") 
      MenuBar() 
      MenuItem( 3, "&End") 
    MenuTitle("JorcefeedbackEffects") 
      MenuItem(4, "X-Achsen Effects on Button 1") 
      MenuItem(5, "Y-Achsen Effects on Button 2") 
      MenuBar() 
      MenuItem(6, "Delete Effects on button 1") 
      MenuItem(7, "Delete Effects on button 2") 
      MenuBar() 
      MenuItem(8, "Make 4 Effects") 
      MenuItem(9,  "1.X-Axe Effect 2 Seconds") 
      MenuItem(10, "2.X-Axe Effect 5 Second") 
      MenuItem(11, "3.Y-Axe Effect 2 Seconds") 
      MenuItem(12, "4.Y-Axe Effect 5 Second") 
    MenuTitle("Hilfe") 
      MenuItem(13, "About your Joystick") 
  EndIf 

Else 

  End 

EndIf 


camera=MP_CreateCamera() ; Kamera erstellen 

light=MP_CreateLight(1) ; Es werde Licht 


mesh1 = MP_Create3DText ("Times", "MP 3D Engine") ; Erstes Mesh erstellen aus Schriftart Times 
MP_translateMesh (mesh1, -MP_MeshGetWidth(mesh1)/2 ,-MP_MeshGetHeight(mesh1)/2,-MP_MeshGetDepth(mesh1)/2) ; Mittelpunkt des Meshs erzeugen


If CreateImage(0, 255, 255) ; Etwas Farbe selber erzeugen 
   MP_CreateImageColored(0,0,RGB($FF,$FF,$00),RGB($FF,$FF,$FF),RGB($FF,$00,$00),RGB($00,$00,$FF)) ; 
   MP_EntitySetTexture (mesh1, MP_ImageToTexture(0)) 
   FreeImage(0) 
EndIf 


x.f=0 
y.f=0 
z.f=6 


While Not MP_KeyDown(#PB_Key_Escape) ; Esc abfrage 

 Select WindowEvent()  ; WindowsEvent abfrage 
      Case #PB_Event_Menu 
        Select EventMenu()  ; Welches Menü? 

          Case 1 ; 3D Objekt als Directx File laden 
              Pattern$ = "Direct x Files(*.x)|*.x" 
              directory$ = "C:\Programme\PureBasic\Dreamotion3D\SamplesDM3D\media\" 
              File.s = OpenFileRequester("Bitte Datei zum Laden auswählen", directory$, Pattern$,  0) 
              If File 
                  If mesh1:MP_FreeEntity(mesh1):EndIf ; Altes Mesh löschen 
                  mesh1=MP_LoadMesh(File.s)            ; Neues Mesh laden 
              EndIf 

          Case 2 ; Textur für Mesh laden 
              Pattern$ = "Grafikdateien |*.jpg;*.bmp;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              File.s = OpenFileRequester("Bitte Grafikdatei zum Laden auswählen", "", Pattern$, 0) 
              If File.s 
                 Textur = MP_LoadTexture(File.s) 
                 MP_EntitySetTexture (mesh1, Textur) 
              EndIf 
          Case 3 ; Ende 
             End 
          Case 4 
             Effekt1 = MP_InitForceFeedBack(1,1,-1,10,1) ; Knopf 1, Axe Y  
             ;DI_InitForcefeedback(Effektart.l,Button.l,Dauer,Stärke,Axe)  
          Case 5 
             Effekt2 = MP_InitForceFeedBack(1,2,-1,10,0)  ; Knopf 2, Axe X  
          Case 6 
              MP_ForcefeedbackEffect(Effekt1,3) ; Effekt löschen :Status =  1 Start, 2 Stop, 3 Löschen 
          Case 7 
              MP_ForcefeedbackEffect(Effekt2,3)  
          Case 8 
             Effekt3 = MP_InitForceFeedBack(1,0,2,10,0) ; Axe X  Effekt erzeugen          
             Effekt4 = MP_InitForceFeedBack(2,0,5,10,0) ; Axe X  
             Effekt5 = MP_InitForceFeedBack(3,0,2,10,1) ; Axe Y  
             Effekt6 = MP_InitForceFeedBack(1,0,5,10,1) ; Axe Y  
          Case 9 
              MP_ForcefeedbackEffect(Effekt3,1) ; Effekt starten 
          Case 10 
              MP_ForcefeedbackEffect(Effekt4,1) 
          Case 11 
              MP_ForcefeedbackEffect(Effekt5,1) 
          Case 12 
              MP_ForcefeedbackEffect(Effekt6,1) 
          Case 13 ; Über 
             info.s = "Forcefeedback Demo mit MP_Engine"+Chr(10)+Chr(10) 
             info.s = info.s + "Joystick found: "+Str(MP_JoystickInfo(1))+Chr(10) 
             info.s = info.s + "Forcefeedback active: "+Str(MP_JoystickInfo(5))+Chr(10) 
             info.s = info.s + "Count of buttons: "+Str(MP_JoystickInfo(3))+Chr(10) 
             info.s = info.s + "Count of Axes: "+Str(MP_JoystickInfo(2))+Chr(10) 
             info.s = info.s + "Count of POVs: "+Str(MP_JoystickInfo(4))+Chr(10) 
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
 If MP_KeyDown(#PB_Key_Z)=1  : z=z-0.1 : EndIf ;y Vertauscht bei y-z bei deutscher tastatur 
 If MP_KeyDown(#PB_Key_A)=1  : z=z+0.1 : EndIf ;a #PB_Key_A 

 If mesh1 ; Objekt drehen 
     MP_PositionEntity (Mesh1,0,0,z) 
     MP_RotateEntity (Mesh1,x,y,0) 
 EndIf 

    MP_RenderWorld () 
    MP_Flip () 
Wend 


; IDE Options = PureBasic 5.24 LTS (Windows - x86)
; CursorPosition = 40
; FirstLine = 38
; EnableAsm
; SubSystem = DX9
; EnableCustomSubSystem
; Manual Parameter S=DX9
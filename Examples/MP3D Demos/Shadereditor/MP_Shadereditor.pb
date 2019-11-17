;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_ShaderEditor.pb
;// Created On: 16.02.2012
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Shadereditor to edit/create Shader
;//
;////////////////////////////////////////////////////////////////



;- Gadget Constants
;
Enumeration
  #Menu
  #Menu_Neu
  #Menu_Oeffnen
  #Menu_Speichern
  #Menu_Beenden
  #Menu_Zurueck
  #Menu_Ausschneiden
  #Menu_Kopieren
  #Menu_Einfuegen
  #Menu_Markieren
  #Menu_Suchen
  #Menu_WeiterSuchen
  
  
  #Button_0
  #Button_1
  #Button_2
  #Button_3
  #Button_4
  #Button_5
  #Button_6
  #Button_7
  #Editor_0
  #TrackBar_0
  #TrackBar_1
  #TrackBar_2
  #Text_0
  #Text_1
  #Text_2
  #Text_3
  #Text_4
  #Text_5
  #OptionG_0
  #OptionG_1
  #OptionG_2
  #Statusbar
  #Vsync_0
  #Vertcol_0
  #Vertcol_1
  #background
  
EndEnumeration

;Global Dim Texture (9)

Var1.f = 0.5
Var2.f = 0.5
Var3.f = 0.5

Dim Mouse.f (2)
Dim Worldmat.f(16)

Global MyEffect.s, Mesh, MyShader, Postprocessing, Dim Texture (9), Such.s, Such2.s, SuchPosition.i,CheckBox.i, File.s, Pos_z.f
Pos_z.f = 4
Procedure checkFloatInput(gadget)
    SendMessage_(GadgetID(gadget),#EM_GETSEL,@start,0)
    txt$ = GetGadgetText(gadget)
    *p.Character = @txt$
    While *p\c = '.' Or (*p\c >= '0' And *p\c <= '9')
        If *p\c = '.'
            pointcount+1
            If pointcount > 1 : *p + SizeOf(Character) : start-1 : Continue : EndIf
        EndIf
        new$ + Chr(*p\c) : *p + SizeOf(Character)
    Wend
    SetGadgetText(gadget,new$)
    SendMessage_(GadgetID(gadget),#EM_SETSEL,start,start)
EndProcedure

Procedure ChangeVertexColor (mesh)
    For n = 0 To MP_CountVertices(mesh)-1 Step 8
      
      MP_VertexSetColor(mesh, n ,MP_ARGB (255, 0,0,0))
      MP_VertexSetColor(mesh, n+1 ,MP_ARGB (255, 255,0,0))
      MP_VertexSetColor(mesh, n+2 ,MP_ARGB (255, 0,255,0))
      MP_VertexSetColor(mesh, n+3 ,MP_ARGB (255, 0,0,255))
      MP_VertexSetColor(mesh, n+4 ,MP_ARGB (255, 255,255,0))
      MP_VertexSetColor(mesh, n+5 ,MP_ARGB (255, 255,0,255))
      MP_VertexSetColor(mesh, n+6 ,MP_ARGB (255, 0, 255,255))
      MP_VertexSetColor(mesh, n+7 ,MP_ARGB (255, 255, 255,255))

    Next 
 EndProcedure
 
 Procedure ClearVertexColor (mesh)
    For n = 0 To MP_CountVertices(mesh)-1 
      
      MP_VertexSetColor(mesh, n ,MP_ARGB (255, 255,255,255))

    Next 
 EndProcedure
 
Procedure ChangeSize (mesh)
      max.f = MP_MeshGetHeight(mesh) ; find Maximum of Mesh
      If MP_MeshGetWidth(mesh) > max : max = MP_MeshGetWidth(mesh) : EndIf
      If MP_MeshGetDepth(mesh) > max : max = MP_MeshGetDepth(mesh) : EndIf
      If max > 0 : scale.f = 3 / max : EndIf; 
      MP_ScaleEntity (mesh,scale,scale,scale) ; Auf Bildschirm maximieren / maximum to Screen
      MP_PositionEntity (Mesh,0,0,Pos_z.f)
      MP_EntitySetNormals(Mesh)
               
EndProcedure
 

Procedure StringGadgetCursorX(Gadget) 
  SendMessage_(GadgetID(Gadget),#EM_GETSEL,@Min,@Max) 
  ProcedureReturn Max-SendMessage_(GadgetID(Gadget),#EM_LINEINDEX,SendMessage_(GadgetID(Gadget),#EM_LINEFROMCHAR,Min,0),0)+1 
EndProcedure 

Procedure StringGadgetCursorY(Gadget) 
  SendMessage_(GadgetID(Gadget),#EM_GETSEL,@Min,@Max) 
  ProcedureReturn SendMessage_(GadgetID(Gadget),#EM_LINEFROMCHAR,Min,0)+1 
EndProcedure 

Procedure EditorGadgetLocate(Gadget,x,y) 
  ; Set cursor position 
  REG = GadgetID(Gadget) 
  CharIdx = SendMessage_(REG,#EM_LINEINDEX,y-1,0) 
  LLength = SendMessage_(REG,#EM_LINELENGTH,CharIdx,0) 
  If LLength >= x-1 
    CharIdx + x-1 
  EndIf 
  Range.CHARRANGE 
  Range\cpMin = CharIdx 
  Range\cpMax = CharIdx 
  SendMessage_(REG,#EM_EXSETSEL,0,Range) 
EndProcedure 

Procedure UpdateMenu()

;{ Procedure für Aktuallisierung von Menu´s
; EM_GETSEL gibt den Start- und Endeposision von den selektierten Bereich zurück.
; Ist Ende grösser Start dann könnten die Menu´s Ausschneiden und Kopieren freigegeben werden
;
; WM_GETTEXTLENGHT gibt den länge des Textes zurück.
; Ist die Länge grösser Null dann kann das Menu Alles markieren freigegeben werden.
;
; EM_CANUNDO gibt zurück das Rückgängig möglich ist und somit das Menu Rückgängig
; freigegeben werden kann
;}

  ; Prüfen auf Markierung
  SendMessage_(GadgetID(#Editor_0), #EM_GETSEL, @lpStart.l, @lpEnde.l)
;  If lpEnde > lpStart
;    DisableMenuItem(#Menu, #Menu_Ausschneiden, 0)
;    DisableMenuItem(#Menu, #Menu_Kopieren, 0)
;  Else
;    DisableMenuItem(#Menu, #Menu_Ausschneiden, 1)
;    DisableMenuItem(#Menu, #Menu_Kopieren, 1)
;  EndIf
  ; Prüfen Zeichen
;  textlen = SendMessage_(GadgetID(#Edit), #WM_GETTEXTLENGTH, 0, 0)
;  If textlen > 0
;    DisableMenuItem(#Menu, #Menu_Markieren, 0)
;  Else
;    DisableMenuItem(#Menu, #Menu_Markieren, 1)
;  EndIf
;  ; Prüfen auf Rückgängig möglich
;  If SendMessage_(GadgetID(#Edit), #EM_CANUNDO, 0, 0)
;    DisableMenuItem(#Menu, #Menu_Zurueck, 0)
;  Else
;    DisableMenuItem(#Menu, #Menu_Zurueck, 1)
;  EndIf
 

 
EndProcedure

Procedure Datei_Oeffnen()
;Procedure für Datei öffnen
              File.s = OpenFileRequester("Load Shader FX file", directory$+"\"+File, "Shader file (fx)|*.fx",  0) 
              If File
                If ReadFile(0,  File)   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
                  MyEffect.s = ""
                  While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
                    MyEffect.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
                  Wend
                  CloseFile(0)
                  ClearGadgetItems(#Editor_0)                ; schließen der zuvor geöffneten Datei
                  AddGadgetItem(#Editor_0, 0,MyEffect) 
                EndIf
                SetGadgetText(#Text_3, "Shadername: "+GetFilePart(file))
                MP_FreeShader(MyShader)
                SetGadgetText(#Button_7, "Start Shader")
                MyShader = 0
                MP_ShaderSetEntity  (0, Mesh)
              EndIf
EndProcedure

Procedure Datei_Speichern()
  ; Procedure für Speichern
  File.s = SaveFileRequester("Save Shader file", directory$+"\"+File, "Shader files (*.fx)|*.fx",  0)
        If File
           MyEffect.s = GetGadgetText(#Editor_0) 
           If CreateFile(0, File)
               WriteString(0, MyEffect)
               CloseFile(0)
           EndIf
           SetGadgetText(#Text_3, "Shadername: "+GetFilePart(file))
  EndIf
 
EndProcedure

Procedure Datei_Reset()
  ; Procedure für Speichern
   For n = 0 To 9
       MP_FreeTexture (Texture(n))
       Texture(n) = 0
   Next n   
   MP_EntitySetTexture (Mesh, 0)
   MP_FreeShader(MyShader)
   SetGadgetText(#Button_7, "Start Shader")
   MyShader = 0
   Postprocessing = 0
   MP_ShaderSetEntity  (0, Mesh)
   MP_FreeEntity (mesh) 
   Mesh = MP_CreateCube()
   ;ChangeSize (mesh)
   Pos_z.f = 4
   MP_PositionEntity (Mesh,0,0,Pos_z.f)
   MP_RotateEntity(mesh,24,-76,44)
   ChangeVertexColor (mesh)
   MP_AmbientSetLight (0)
EndProcedure

Procedure Open_Suchen(String.s)
  
  Window_0 = OpenWindow(#PB_Any, 5, 5, 428, 160, "Suchfenster",  #PB_Window_TitleBar | #PB_Window_ScreenCentered )
  String_0 = StringGadget(#PB_Any, 80, 10, 236, 20, Such.s)
  Text_1 = TextGadget(#PB_Any, 10, 10, 70, 20, "Suchen nach")
  String_1 = StringGadget(#PB_Any, 80, 40, 236, 20, Such2.s)
  Text_1 = TextGadget(#PB_Any, 10, 40, 70, 20, "Ersetzen mit")
  CheckBox_0 = CheckBoxGadget(#PB_Any, 10, 70, 154, 20, "Gross-/Kleinschreibung")
  Button_0 = ButtonGadget(#PB_Any, 326, 10, 90, 20, "Suchen")
  Button_1 = ButtonGadget(#PB_Any, 326, 40, 90, 20, "Weitersuchen")
  Button_2 = ButtonGadget(#PB_Any, 326, 70, 90, 20, "Ersetzen")
  Button_3 = ButtonGadget(#PB_Any, 326, 100, 90, 20, "Alle Ersetzen")
  Button_4 = ButtonGadget(#PB_Any, 326, 130, 90, 20, "Abbrechen")
  
  Repeat
    EventID = WaitWindowEvent()
    If EventID = #PB_Event_Gadget
      Such = GetGadgetText(String_0)
      Such2 = GetGadgetText(String_1)
      CheckBox = GetGadgetState(CheckBox_0) 
      
      Select EventGadget()
        Case Button_0
          find.FINDTEXTEX
          find\chrg\cpMin+0
          find\chrg\cpMax=SendMessage_(GadgetID(#Editor_0),#WM_GETTEXTLENGTH,0,0)
          find\lpstrText=@Such
          If CheckBox
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN|#FR_MATCHCASE,@find)
          Else   
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN,@find)
          EndIf
          If Not Pos = -1
              SendMessage_(GadgetID(#Editor_0),#EM_EXSETSEL,0,find\chrgText)
          Else
              MessageRequester("Suchen", "Nichts gefunden", #PB_MessageRequester_Ok)
          EndIf
          CloseWindow(Window_0)
          ProcedureReturn
        Case Button_1
          
          SendMessage_(GadgetID(#Editor_0),#EM_EXGETSEL,0,Range.CHARRANGE) ; Get CurrentCursor Position
          find.FINDTEXTEX
          find\chrg\cpMin = Range\cpMin+1
          find\chrg\cpMax=SendMessage_(GadgetID(#Editor_0),#WM_GETTEXTLENGTH,0,0)
          find\lpstrText=@Such
          If CheckBox
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN|#FR_MATCHCASE,@find)
          Else   
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN,@find)
          EndIf
          If Not Pos = -1
            SendMessage_(GadgetID(#Editor_0),#EM_EXSETSEL,0,find\chrgText)
            ;SendMessage_(GadgetID(#Editor_0),#EM_REPLACESEL,1,"dumdumdum") 
          Else
              MessageRequester("Suchen", "Nichts gefunden", #PB_MessageRequester_Ok)
          EndIf
          CloseWindow(Window_0)
          ProcedureReturn
        Case Button_2
          
          SendMessage_(GadgetID(#Editor_0),#EM_EXGETSEL,0,Range.CHARRANGE) ; Get CurrentCursor Position
          find.FINDTEXTEX
          find\chrg\cpMin = Range\cpMin+1
          find\chrg\cpMax=SendMessage_(GadgetID(#Editor_0),#WM_GETTEXTLENGTH,0,0)
          find\lpstrText=@Such
          If CheckBox
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN|#FR_MATCHCASE,@find)
          Else   
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN,@find)
          EndIf
          If Not Pos = -1
            SendMessage_(GadgetID(#Editor_0),#EM_EXSETSEL,0,find\chrgText)
            If SuchPosition
                SendMessage_(GadgetID(#Editor_0),#EM_REPLACESEL,1,Such2) 
            EndIf
            SuchPosition + 1
            ;SendMessage_(GadgetID(#Editor_0),#EM_REPLACESEL,1,"dumdumdum") 
          Else
              MessageRequester("Suchen", "Nichts gefunden", #PB_MessageRequester_Ok)
          EndIf
          CloseWindow(Window_0)
          ProcedureReturn
          
        Case Button_3
          
          Range.CHARRANGE
          Range\cpMin = -1
          find.FINDTEXTEX
          Repeat

             find\chrg\cpMin = Range\cpMin+1
             find\chrg\cpMax=SendMessage_(GadgetID(#Editor_0),#WM_GETTEXTLENGTH,0,0)
             find\lpstrText=@Such
             If CheckBox
                Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN|#FR_MATCHCASE,@find)
             Else   
                Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN,@find)
             EndIf
             If Not Pos = -1
                SendMessage_(GadgetID(#Editor_0),#EM_EXSETSEL,0,find\chrgText)
                SendMessage_(GadgetID(#Editor_0),#EM_REPLACESEL,1,Such2) 
             Else
               Break 
             EndIf
             SendMessage_(GadgetID(#Editor_0),#EM_EXGETSEL,0,Range.CHARRANGE) ; Get CurrentCursor Position
          ForEver
        
          CloseWindow(Window_0)
          ProcedureReturn
        Case Button_4
          CloseWindow(Window_0)
          ProcedureReturn
      EndSelect

    EndIf
  
  ForEver
  
EndProcedure


Procedure Open_WeiterSuchen()
          SendMessage_(GadgetID(#Editor_0),#EM_EXGETSEL,0,Range.CHARRANGE) ; Get CurrentCursor Position
          find.FINDTEXTEX
          find\chrg\cpMin = Range\cpMin+1
          find\chrg\cpMax=SendMessage_(GadgetID(#Editor_0),#WM_GETTEXTLENGTH,0,0)
          find\lpstrText=@Such
          If CheckBox
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN|#FR_MATCHCASE,@find)
          Else   
             Pos = SendMessage_(GadgetID(#Editor_0),#EM_FINDTEXTEX,#FR_DOWN,@find)
          EndIf
          If Not Pos = -1
              SendMessage_(GadgetID(#Editor_0),#EM_EXSETSEL,0,find\chrgText)
          Else
              MessageRequester("Suchen", "Nichts gefunden", #PB_MessageRequester_Ok)
          EndIf
          ProcedureReturn
EndProcedure


;- Start
MP_Graphics3D (933,541,0,2) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Editor to test HLSL Shader V0.6") ; Setzt einen Fensternamen

If CreateMenu(#Menu, WindowID(0))
    MenuTitle("Datei")
      MenuItem(#Menu_Neu, "Neu" )
      MenuItem(#Menu_Oeffnen, "Öffnen")
      MenuItem(#Menu_Speichern, "Speichern")
      MenuBar()
      MenuItem(#Menu_Beenden, "Beenden")
    MenuTitle("Bearbeiten")
      MenuItem(#Menu_Zurueck, "Rückgängig" )
      MenuBar()
      MenuItem(#Menu_Ausschneiden, "Ausschneiden" )
      MenuItem(#Menu_Kopieren, "Kopieren")
      MenuItem(#Menu_Einfuegen, "Einfügen")
      MenuItem(#Menu_Markieren, "Alles markieren" )
    MenuTitle("Suchen")
      MenuItem(#Menu_Suchen, "Suchen" )
      MenuItem(#Menu_WeiterSuchen, "Weitersuchen" + #TAB$ + "F3")
    MenuTitle("Tools")
      MenuItem(#Vsync_0, "Vsync Off" )
      MenuItem(#Vertcol_0, "Coloring mesh vertex" )
      MenuItem(#Vertcol_1, "Clear mesh vertex" )
      MenuItem(#background, "AmbientSetLight" )
EndIf
    
AddKeyboardShortcut( 0, #PB_Shortcut_F3, #Menu_WeiterSuchen)

ButtonGadget(#Button_0, 510, 20, 140, 30, "Load Mesh")
ButtonGadget(#Button_1, 510, 70, 100, 30, "Load Texture Nr:")
SpinGadget(#Button_5, 620, 74, 30, 24, 0, 9 ,  #PB_Spin_Numeric  )
SetGadgetState (#Button_5, 0) ;: SetGadgetText(0, "0")

ButtonGadget(#Button_2, 510, 140, 140, 30, "Load Shader")
ButtonGadget(#Button_3, 510, 190, 140, 30, "Save Shader")
ButtonGadget(#Button_4, 680, 20, 130, 30, "Help")

OptionGadget(#OptionG_0, 680, 70, 130, 20, "Vertex / Pixel Shader")
OptionGadget(#OptionG_1,680, 90, 130, 20, "Postprocessing Shader")
SetGadgetState(#OptionG_0, 1)

;ButtonGadget(#Button_5, 680, 70, 130, 30, "TextureA on Screen")
ButtonGadget(#Button_6, 680, 140, 130, 30, "Reset")
ButtonGadget(#Button_7, 680, 190, 130, 30, "Start Shader")
EditorGadget(#Editor_0, 510, 270, 400, 220)
TextGadget(#Text_0, 820, 20, 40, 20, "Var1")
TrackBarGadget(#TrackBar_0, 825, 40, 30, 180, 0, 100, #PB_TrackBar_Vertical);#PB_TrackBar_Ticks | #PB_TrackBar_Vertical)
SetGadgetState(#TrackBar_0, 50)
TextGadget(#Text_1, 860, 20, 40, 20, "Var2")
TrackBarGadget(#TrackBar_1, 860, 40, 30, 180, 0, 100, #PB_TrackBar_Vertical);#PB_TrackBar_Ticks | #PB_TrackBar_Vertical)
SetGadgetState(#TrackBar_1, 50)      
TextGadget(#Text_2, 900, 20, 40, 20, "Var3")
TrackBarGadget(#TrackBar_2, 895, 40, 30, 180, 0, 100, #PB_TrackBar_Vertical);#PB_TrackBar_Ticks | #PB_TrackBar_Vertical)
SetGadgetState(#TrackBar_2, 50)      
TextGadget(#Text_3, 510, 230, 400, 20, "Shadername: ")

CreateStatusBar(#Statusbar, WindowID(0))
AddStatusBarField(90)
AddStatusBarField(100)
AddStatusBarField(#PB_Ignore )

;SetWindowCallback(@WndProc())

MP_Viewport(20,20,470,470)
;directory$ = "C:\Programme\PureBasic\Examples\MP3D Demos\Texture_Shadereffecte\"


camera=MP_CreateCamera()
light=MP_CreateLight(1)

Mesh = MP_CreateCube()
;ChangeSize (mesh)
MP_PositionEntity (Mesh,0,0,Pos_z.f)
ChangeVertexColor (mesh)
MP_RotateEntity(mesh,24,-76,44)

BackTexture = MP_CreateBackBufferTexture()

While Not abfrage; Not MP_KeyDown(#PB_Key_Escape) ; Esc abfrage / SC pushed?
  
  SetWindowTitle(0,"Editor to test HLSL Shader V0.6     "+Str(MP_FPS())+" FPS")
  

  Select WindowEvent()
      
   Case #PB_Event_Menu
     Select EventMenu()
      Case  #Menu_Neu
            Datei_Reset()
      Case #Menu_Oeffnen
            Datei_Oeffnen()
      Case  #Menu_Speichern    
            Datei_Speichern()
      Case  #Menu_Suchen
        Open_Suchen(MyEffect.s)
      Case  #Menu_WeiterSuchen
        Open_WeiterSuchen()
      Case #Menu_Zurueck
            SendMessage_(GadgetID(#Editor_0), #WM_UNDO, 0, 0) ; API SendMessage_(hwnd, uMsg, wParam, lParam)
      Case #Menu_Ausschneiden
            SendMessage_(GadgetID(#Editor_0), #WM_CUT, 0, 0)
      Case #Menu_Kopieren
            SendMessage_(GadgetID(#Editor_0), #WM_COPY, 0, 0)
      Case #Menu_Einfuegen
            SendMessage_(GadgetID(#Editor_0), #WM_PASTE, 0, 0)
      Case #Menu_Markieren
           SendMessage_(GadgetID(#Editor_0), #EM_SETSEL, 0, -1)          
      Case #Menu_Beenden
           If MessageRequester("  program end", "You want to close the program?:", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
               End  
           EndIf  
      Case #Vsync_0
        If GetMenuItemText(#Menu, #Vsync_0) = "Vsync Off"
          SetMenuItemText(#Menu, #Vsync_0,"Vsync On")
          MP_VSync(0)
        Else
          SetMenuItemText(#Menu, #Vsync_0,"Vsync Off")
          MP_VSync(1)
        EndIf 
      Case #Vertcol_0
        ChangeVertexColor (mesh)   
      Case #Vertcol_1
        ClearVertexColor (mesh)
      Case #background
        MP_AmbientSetLight (ColorRequester())
        
     EndSelect
   Case #PB_Event_Gadget
     
     If EventType()=#PB_EventType_Change
       If EventGadget() = #Text_4
          checkFloatInput(#Text_4)
       EndIf  
     EndIf
     
     Select EventGadget()
         
      Case #Button_0
            Pattern$ = "3D mesh files|*.x;*.3ds;*.b3d|.x files (*.x)|*.x|3DS files (*.3ds)|*.3ds|B3D files (*.b3d)|*.b3d"
            ;directory$ = "C:\Programme\PureBasic\media\"
            File2.s = OpenFileRequester("Load mesh file", directory$+"\"+File2.s, Pattern$, 0)
            If File2.s
                 MP_FreeEntity (mesh) 
                 mesh = MP_LoadMesh (File2.s)
                 ;MP_SaveMesh("c:\test.x",mesh)

                 ChangeSize (mesh)
                ; ChangeVertexColor (mesh)
                 ;MP_RotateEntity(mesh,24,-76,44)


            EndIf
               
      Case #Button_1
              Pattern$ = "Image File (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              TexturFile.s = OpenFileRequester("Load Texture", directory$, Pattern$,  0) 
              If TexturFile
                 MP_FreeTexture (Texture(GetGadgetState (#Button_5)))
                 Texture(GetGadgetState (#Button_5)) =  MP_LoadTexture(TexturFile,1,1)
                 If GetGadgetState (#Button_5) = 0
                    MP_EntitySetTexture (mesh, Texture(0))
  MP_MaterialDiffuseColor (Texture(0),255,128,128,128)
   MP_MaterialAmbientColor (Texture(0), 255, 155 , 255, 255) ; 
   MP_MaterialEmissiveColor (Texture(0),155,15,25,25) ; 
 ;  MP_MaterialSpecularColor (Texture(0), 255, 255 ,255, 255,20) ;



                 EndIf 
              EndIf
      Case #Button_2
              Datei_Oeffnen()
      Case #Button_3
              Datei_Speichern()
      Case #Button_4
          If OpenWindow(1, 0, 0, 360, 480, "Help", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
            EditorGadget(22, 10, 10, 340, 460,#PB_Editor_ReadOnly)
            While  Helptxt.s <>  "End"
               Text.s + Helptxt
               Read.s Helptxt.s
            Wend  
            AddGadgetItem(22, 0, Text)
            Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
            CloseWindow(1)
          EndIf
;     Case #Button_5

      Case #Button_6
        Datei_Reset()

      Case #Button_7
        If MyShader 
          MP_FreeShader(MyShader)
          SetGadgetText(#Button_7, "Start Shader")
          MyShader = 0
          Postprocessing = 0
          MP_ShaderSetEntity  (0, Mesh)
        Else
          SetGadgetText(#Button_7, "Stop Shader")
          
          MyEffect.s = GetGadgetText(#Editor_0) 
          MyShader = MP_CreateMyShader (MyEffect.s)
;          Debug"go"
;          Debug MyShader          
;          Debug MP_CompileTextureShader (MyEffect.s, "c:\test.fx") ; Erzeugt den Shader als compiliertes File
;          MyShader = MP_LoadTextureShader ("c:\test.fx")
;          Debug MyShader          
          
          If Not MyShader ; Bei einem Fehler springe an position
             errortxt.s = MP_GetLastError()
             found = FindString(errortxt, "memory(", 1)
             If found
               start = FindString(errortxt, ",", found)
               stop = FindString(errortxt, ")", found)
               ;Debug errortxt
               SetActiveGadget(#Editor_0)
               EditorGadgetLocate(#Editor_0,Val(Mid(errortxt,start + 1, stop - 1 - start)),Val(Mid(errortxt,found + 7, start - 7 - found))) 
               StatusBarText(#StatusBar, 2, "Last error: "+ Mid (errortxt, found+6))  
             EndIf  
           EndIf
           
         If MyShader 
           
           If GetGadgetState(#OptionG_0)  
    
              MP_ShaderSetEntity  (MyShader,Mesh)
              MP_SetTechniqueMyShader (MyShader,"Technique0")
              
           Else    
           
             Postprocessing = 1
             
           EndIf 
           StatusBarText(#StatusBar, 2, "")
         Else
             MP_ShaderSetEntity  (0, Mesh)
             ;MessageRequester("Shader Error", "No Shader loaded")
             SetGadgetText(#Button_7, "Start Shader")
         EndIf
         
        EndIf
         
      Case #TrackBar_0
          Var1.f = GetGadgetState(#TrackBar_0)/100 
      Case #TrackBar_1
          Var2.f = GetGadgetState(#TrackBar_1)/100 
      Case #TrackBar_2
        Var3.f = GetGadgetState(#TrackBar_2)/100
        
      EndSelect 
    
    Case #PB_Event_CloseWindow
           If MessageRequester("  program end", "You want to close the program?:", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
               End  
           EndIf  
       EndSelect 
       
    StatusBarText(#StatusBar, 0, " line = "+Str( StringGadgetCursorY(#Editor_0)))
    StatusBarText(#StatusBar, 1, " pos = "+Str( StringGadgetCursorX(#Editor_0)))
 
    If MP_KeyDown(#PB_Key_Escape) ; Esc abfrage / SC pushed?
      
      If MP_IsScreenActive()
           If GetActiveGadget() = #Editor_0
             SetActiveGadget(#Button_7)
             Delay (100)
           Else   
              If MessageRequester("  program end", "You want to close the program?:", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                End  
              EndIf
           EndIf   
       EndIf    
     EndIf
     
    If GetActiveGadget() <> #Editor_0
 
       If MP_KeyDown(#PB_Key_Left)=1 : MP_TurnEntity (mesh,1,0,0) : EndIf ;links Debug #PB_Key_Left
       If MP_KeyDown(#PB_Key_Right)=1 : MP_TurnEntity (mesh,-1,0,0) : EndIf ;rechts #PB_Key_Right
       If MP_KeyDown(#PB_Key_Down)=1 : MP_TurnEntity (mesh,0,-1,0) : EndIf ;Runter #PB_Key_Down
       If MP_KeyDown(#PB_Key_Up)=1 : MP_TurnEntity (mesh,0,1,0) : EndIf ;rauf #PB_Key_Up
       
       If MP_KeyDown(#PB_Key_A)=1 : Pos_z.f - 0.1: MP_PositionEntity (mesh,0,0,Pos_z.f): EndIf ;Runter #PB_Key_Down
       If MP_KeyDown(#PB_Key_Z)=1 : Pos_z.f + 0.1: MP_PositionEntity (mesh,0,0,Pos_z.f): EndIf ;rauf #PB_Key_Up
    
       If MP_MouseDeltaWheel() > 0
             Pos_z.f - 0.2 : MP_PositionEntity (mesh,0,0,Pos_z.f)
       ElseIf  MP_MouseDeltaWheel() <0 
             Pos_z.f + 0.3 : MP_PositionEntity (mesh,0,0,Pos_z.f)
       EndIf
    
    EndIf
        
    MP_ShaderSet_D3DMATRIX (MyShader,"worldViewProjI",MP_ShaderGetWorldViewI (Mesh))
    MP_ShaderSet_D3DMATRIX (MyShader,"worldViewProj",MP_ShaderGetWorldView (Mesh))
    
    MP_ShaderSet_D3DMATRIX (MyShader,"matWorld",MP_ShaderGetWorld(Mesh))
    MP_ShaderSet_D3DMATRIX (MyShader,"matWorldI",MP_ShaderGetWorldI(Mesh))

    MP_ShaderSet_Float3 (MyShader,"lightDir",MP_ShaderGetLightDirection(Light))
    MP_ShaderSet_D3DMATRIX (MyShader,"matLightWorld", MP_ShaderGetLightWorld(Light))
    
    MP_ShaderSet_D3DMATRIX (MyShader,"matCamView ", MP_ShaderGetView (camera))
    MP_ShaderSet_D3DMATRIX (MyShader,"matCamViewI", MP_ShaderGetViewI (camera))
    MP_ShaderSet_D3DMATRIX (MyShader,"matCamProj", MP_ShaderGetCamProjection(camera))
    MP_ShaderSet_Float3(MyShader,"vecEye",MP_ShaderGetCamPos(camera) )

    MP_ShaderSetTexture(MyShader,"texture0",Texture(0))
    MP_ShaderSetTexture(MyShader,"texture1",Texture(1))
    MP_ShaderSetTexture(MyShader,"texture2",Texture(2))
    MP_ShaderSetTexture(MyShader,"texture3",Texture(3))
    MP_ShaderSetTexture(MyShader,"texture4",Texture(4))
    MP_ShaderSetTexture(MyShader,"texture5",Texture(5))
    MP_ShaderSetTexture(MyShader,"texture6",Texture(6))
    MP_ShaderSetTexture(MyShader,"texture7",Texture(7))
    MP_ShaderSetTexture(MyShader,"texture8",Texture(8))
    MP_ShaderSetTexture(MyShader,"texture9",Texture(9))
    

    MP_ShaderSetVar_f(Myshader,"time",MP_ElapsedMicroseconds()/100000)  
        
    MP_ShaderSetVar_f (MyShader,"Var1",Var1)
    MP_ShaderSetVar_f (MyShader,"Var2",Var2)
    MP_ShaderSetVar_f (MyShader,"Var3",Var3)
    postfx.f = 0
    MP_ShaderSetVar_f (MyShader,"postfx",postfx)
    
    MouseX.i = WindowMouseX(0)
    MP_ShaderSetVar_I (MyShader,"mousex",MouseX)
    
    MouseY.i = WindowMouseY(0)
    MP_ShaderSetVar_I (MyShader,"mousey",MouseY)
    
    Mouse(0) = MouseX / 933 ; Viewportx 20-470
    Mouse(1) = 1 - (MouseY / 511) ; Viewporty 20-470
    MP_ShaderSet_Float3(MyShader,"mouse",@Mouse(0))

    
    MP_RenderWorld ()
    
    If Postprocessing = 1  
      
       MP_BackBufferToTexture (BackTexture)
       
       postfx.f = 1
       MP_ShaderSetVar_f (MyShader,"postfx",postfx)

       MP_SetTechniqueMyShader (MyShader,"postFX")
       MP_ShaderSetTexture (MyShader,"texture0",BackTexture)
       
       MP_UsePixelShader(BackTexture, MyShader)
       ;MP_UseBackbufferShader(BackTexture, MyShader)
       
       MP_TextureToBackBuffer (BackTexture) 
       
    EndIf   
      
    MP_Flip () 
Wend 

;    *D3DDevice\SetSamplerState(0,#D3DSAMP_ADDRESSU,#D3DTADDRESS_WRAP)
;    *D3DDevice\SetSamplerState(0,#D3DSAMP_ADDRESSV,#D3DTADDRESS_WRAP)

;D3DSAMP_ADDRESSU 
;D3DSAMP_ADDRESSV
;      *D3DDevice\SetSamplerState(0, #D3DSAMP_MINFILTER, #D3DTEXF_LINEAR)
;      *D3DDevice\SetSamplerState(0, #D3DSAMP_MAGFILTER, #D3DTEXF_LINEAR)

DataSection
    
Helptxt:

Data.s "                Helpfile"+Chr(10)
Data.s ""+Chr(10)
Data.s "You can move the Mesh with cursor keys and the mouse wheel"+Chr(10)
Data.s "new edit function, fps and vsync functions"+Chr(10)
Data.s ""+Chr(10)
Data.s "Here comes all variables of the Shadereditor"+Chr(10)
Data.s ""+ Chr(10)
Data.s "mesh object:"+ Chr(10)
Data.s "worldViewProj  -> typ matrix -> WorldView Matrix of Mesh"+ Chr(10)
Data.s "worldViewProjI -> typ matrix -> inverse WorldView Matrix of Mesh"+ Chr(10)
Data.s "matWorld       -> typ matrix -> WorldView Matrix of Mesh"+ Chr(10)
Data.s "matWorldI      -> typ matrix -> inverse WorldView Matrix of Mesh"+ Chr(10)
Data.s ""+ Chr(10)
Data.s "light  object:"+ Chr(10)
Data.s "lightDir       -> typ 3 x float -> light direction "+ Chr(10)
Data.s "matLightWorld  -> typ matrix -> World Matrix of light"+ Chr(10)
Data.s ""+ Chr(10)
Data.s "camera  object:"+ Chr(10)
Data.s "matCamView     -> typ matrix -> camera view matrix"+ Chr(10)
Data.s "matCamViewI    -> typ matrix -> inverse camera view matrix"+ Chr(10)
Data.s "matCamProj     -> typ matrix -> camera projections matrix"+ Chr(10)
Data.s "vecEye         -> typ 3 x float -> position of camera"+ Chr(10)
Data.s ""+ Chr(10)
Data.s "texture object:"+ Chr(10)
Data.s "texture0       -> typ texture -> texture"+ Chr(10)
Data.s "texture1       -> typ texture -> texture"+ Chr(10)
Data.s "texture2       -> typ texture -> texture"+ Chr(10)
Data.s "texture3       -> typ texture -> texture"+ Chr(10)
Data.s "texture4       -> typ texture -> texture"+ Chr(10)
Data.s "texture5       -> typ texture -> texture"+ Chr(10)
Data.s "texture6       -> typ texture -> texture"+ Chr(10)
Data.s "texture7       -> typ texture -> texture"+ Chr(10)
Data.s "texture8       -> typ texture -> texture"+ Chr(10)
Data.s "texture9       -> typ texture -> texture"+ Chr(10)
Data.s ""+ Chr(10)
Data.s "time object:"+ Chr(10)
Data.s "time           -> typ float  -> time in ms"+ Chr(10)
Data.s ""+ Chr(10)
Data.s "slider object:"+ Chr(10)
Data.s "Var1           -> typ float(0 To 1) -> see gui of program"+ Chr(10)
Data.s "Var2           -> typ float(0 To 1) -> see gui of program"+ Chr(10)
Data.s "Var3           -> typ float(0 To 1) -> see gui of program"+ Chr(10)
Data.s ""+ Chr(10)+ Chr(10)
Data.s "Intrinsic Functions (DirectX HLSL)"+ Chr(10)
Data.s "http://msdn.microsoft.com/en-us/library/ff471376.aspx"+ Chr(10)
Data.s ""+Chr(10)
Data.s "smalest possibles Shader example:"+Chr(10)
Data.s ""+Chr(10)
Data.s "technique Technique0"+Chr(10)
Data.s "{"+Chr(10)
Data.s "  pass p0"+Chr(10)
Data.s "  {"+Chr(10)
Data.s "	FillMode = wireframe;"+Chr(10)
Data.s "  }"+Chr(10)
Data.s "}"+Chr(10)
Data.s "End"

EndDataSection

  
  

; IDE Options = PureBasic 4.61 Beta 2 (Windows - x86)
; CursorPosition = 240
; FirstLine = 221
; Folding = ---
; UseIcon = C:\Programme\PureBasic\Examples\DirectX For PB4\Source\MP3D Demos\mp3d.ico
; Executable = MP_ShaderEditor.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_ShaderEffecte.pb
;// Created On: 27.04.2010
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Make Shader for TextureChanging, IMPORTANT use the demofile directory 
;// 
;//
;////////////////////////////////////////////////////////////////


;- Gadget Constants
;
Enumeration
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
EndEnumeration

Var1.f = 0.5
Var2.f = 0.5
Var3.f = 0.5


MP_Graphics3D (933,511,0,2) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "Shader for TextureChanging V0.1") ; Setzt einen Fensternamen

ButtonGadget(#Button_0, 510, 20, 140, 30, "Load TextureA")
ButtonGadget(#Button_1, 510, 70, 140, 30, "Load TextureB")
ButtonGadget(#Button_2, 510, 140, 140, 30, "Load Shader")
ButtonGadget(#Button_3, 510, 190, 140, 30, "Save Shader")
ButtonGadget(#Button_4, 680, 20, 130, 30, "Help")
ButtonGadget(#Button_5, 680, 70, 130, 30, "TextureA on Screen")
ButtonGadget(#Button_6, 680, 140, 130, 30, "Compile and Run")
ButtonGadget(#Button_7, 680, 190, 130, 30, "Save New Textur")
EditorGadget(#Editor_0, 510, 250, 400, 220)
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

MP_Viewport(20,20,470,470)
;directory$ = GetPathPart(ProgramFilename())
;directory$ = "C:\Programme\PureBasic\Examples\DirectX For PB4\Source\MP3D Demos\Texture_Shadereffecte\"
;directory$ = "C:\Programme\PureBasic\Examples\MP3D Demos\Texture_Shadereffecte\"

While Not MP_KeyDown(#PB_Key_Escape) ; Esc abfrage / SC pushed?
 Select WindowEvent()
      
   Case #PB_Event_Gadget
     Select EventGadget()
         
      Case #Button_0
              Pattern$ = "Image File (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              ;SetCurrentDirectory(directory$)
              ;directory$ = GetCurrentDirectory();"C:\Programme\PureBasic\media\" 
              TexturFile.s = OpenFileRequester("Load Texture A", directory$, Pattern$,  0) 
              If TexturFile
                 MP_FreeTexture (TextureA)
                 TextureA =  MP_LoadTexture(TexturFile)
                 If DestTexture : MP_FreeTexture ( DestTexture ) : EndIf
                 DestTexture = MP_CreateTexture(MP_TextureGetWidth(TextureA),MP_TextureGetHeight(TextureA))
                 If Surface : MP_FreeSurface (Surface) : EndIf
                 Surface = MP_TextureToSurface(TextureA)
                 MP_SurfaceSetPosition(Surface, 0,0,1) 
                 MP_SurfaceDestRect(Surface, 20,20,490,490) 
              EndIf
      Case #Button_1
              Pattern$ = "Image File (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              ;SetCurrentDirectory(directory$)
              ;directory$ = GetCurrentDirectory();"C:\Programme\PureBasic\media\" 
              TexturFile = OpenFileRequester("Load Texture B", directory$, Pattern$,  0) 
              If TexturFile
                 MP_FreeTexture (TextureB)
                 TextureB =  MP_LoadTexture(TexturFile)
              EndIf
      Case #Button_2
              File.s = OpenFileRequester("Load Shader FX File", directory$, "Shader File (fx)|*.fx",  0) 
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
                SetGadgetText(#Text_3, "Shadername: "+file)
              EndIf
     Case #Button_3
              File.s = SaveFileRequester("Save Shader File", directory$+"\"+File, "Shader Files (*.fx)|*.fx",  0)
              If File
                  MyEffect.s = GetGadgetText(#Editor_0) 
                  If CreateFile(0, File)
                     WriteString(0, MyEffect)
                     CloseFile(0)
                  EndIf
                SetGadgetText(#Text_3, "Shadername: "+file)
              EndIf
      Case #Button_4
            MessageRequester("Help", "will coming soon, pray for it", #PB_MessageRequester_Ok)
      Case #Button_5
            If Surface : MP_FreeSurface (Surface) : EndIf
            Surface = MP_TextureToSurface(TextureA)
            MP_SurfaceSetPosition(Surface, 0,0,1) 
            MP_SurfaceDestRect(Surface, 20,20,490,490) 
      Case #Button_6
        If MyShader : MP_FreeShader(MyShader) : EndIf
        
        MyEffect.s = GetGadgetText(#Editor_0) 
        
        MyShader = MP_CreateMyShader (MyEffect.s)
        If MyShader 
           MP_SetTechniqueMyShader (MyShader,"t1")
           MP_ShaderSetTexture (MyShader,"TextureA",TextureA)
           MP_ShaderSetTexture (MyShader,"TextureB",TextureB)
           MP_ShaderSetVar_f(MyShader,"Var1",Var1.f) 
           MP_ShaderSetVar_f(MyShader,"Var2",Var2.f) 
           MP_ShaderSetVar_f(MyShader,"Var3",Var3.f) 
           StartTime = MP_ElapsedMicroseconds()
           MP_UsePixelShader (DestTexture, MyShader)
           ElapsedTime = MP_ElapsedMicroseconds() - StartTime 
           SetWindowTitle(0, "Shader For TextureChanging V0.1 - Runtime of compiled Shader in ms "+StrF(ElapsedTime/100,2)) 
           If Surface : MP_FreeSurface (Surface) : EndIf
           Surface = MP_TextureToSurface(DestTexture)
           MP_SurfaceSetPosition(Surface, 0,0,1) 
           MP_SurfaceDestRect(Surface, 20,20,490,490)    
        Else
           MessageRequester("Shader Error", MP_GetLastError())
        EndIf
        
      Case #Button_7
        File.s = SaveFileRequester("Save Textur as JPG", "Textur.jpg", "Textur Files(*.jpg)|*.jpg",  0)
        If File
           MP_SaveTexture (File, DestTexture , 1)
         EndIf
      Case #TrackBar_0
          Var1.f = GetGadgetState(#TrackBar_0)/100 
      Case #TrackBar_1
          Var2.f = GetGadgetState(#TrackBar_1)/100 
      Case #TrackBar_2
          Var3.f = GetGadgetState(#TrackBar_2)/100
      EndSelect 
    
  Case #PB_Event_CloseWindow 
         End 
 EndSelect 
  
    MP_RenderWorld () 
    MP_Flip () 
Wend 

; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 67
; FirstLine = 36
; Executable = G:\temp\TexturShader\MP_Shadereffekt.exe
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
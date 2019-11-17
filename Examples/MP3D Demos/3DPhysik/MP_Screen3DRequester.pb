;
; ------------------------------------------------------------
;
;   PureBasic - Common 3D functions
;
;    (c) 2003 - Fantaisie Software
;
; ------------------------------------------------------------
;

#WINDOW_Screen3DRequester = 0

#GADGET_FullScreen        = 1
#GADGET_Windowed          = 2
#GADGET_ScreenModesLabel  = 3
#GADGET_WindowedModes     = 4
#GADGET_Launch            = 5
#GADGET_Cancel            = 6
#GADGET_Logo              = 7
#GADGET_Frame             = 8
#GADGET_ScreenModes       = 9
#GADGET_Antialiasing      = 10
#GADGET_AntialiasingModes = 11
#GADGET_Vsync             = 12
#GADGET_VsyncOn           = 13
#GADGET_VsyncOff          = 14

Global Screen3DRequester_FullScreen, Screen3DRequester_ShowStats

UsePNGImageDecoder()

Procedure MP_Screen3DRequester(Titel.s)

  OpenPreferences(GetHomeDirectory()+"PureBasicDemos3D.prefs")
    FullScreen          = ReadPreferenceLong  ("FullScreen"        , 0)
    FullScreenMode$     = ReadPreferenceString("FullScreenMode"    , "800x600")
    WindowedScreenMode$ = ReadPreferenceString("WindowedScreenMode", "800x600")
    AAMode              = ReadPreferenceLong  ("Antialiasing"      , 0)
    VSyncMode           = ReadPreferenceLong  ("Vsync"      , 1)
    
  If ExamineDesktops()
    ScreenX = DesktopWidth(0)
    ScreenY = DesktopHeight(0)
    ScreenD = DesktopDepth(0)
    ScreenF = DesktopFrequency(0)
  EndIf
  
  If OpenWindow(#WINDOW_Screen3DRequester, 0, 0, 396, 255, "PureBasic - 3D Demos", #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_Invisible)
    
    Top = 6
    
;    ImageGadget  (#GADGET_Logo, 6, Top, 0, 0, LoadImage(0,"Data/PureBasic3DLogo.png"), #PB_Image_Border) : Top+76
;    ImageGadget  (#GADGET_Logo, 6, Top, 0, 0, LoadImage(0,"C:\Programme\PureBasic\Examples\3d\Data\PureBasic3DLogo.png"), #PB_Image_Border) : Top+76
;    ImageGadget  (#GADGET_Logo, 6, Top, 0, 0, LoadImage(0,"Power3.png"), #PB_Image_Border) : Top+76
    ImageGadget  (#GADGET_Logo, 6, Top, 0, 0, CatchImage(0, ?Logo), #PB_Image_Border) : Top+76
    
    
      

    
    FrameGadget(#GADGET_Frame, 6, Top, 384, 130, "", 0) : Top+20
    
    OptionGadget(#GADGET_FullScreen, 70, Top, 100, 20, "Fullscreen")        : Top+25
    OptionGadget(#GADGET_Windowed  , 70, Top, 100, 20, "Windowed")          : Top+25
    TextGadget(#GADGET_Antialiasing, 70, Top+5, 100, 20, "Antialiasing mode") : Top - 50 
    
   
    ComboBoxGadget (#GADGET_ScreenModes  , 190, Top, 150, 21)     : Top+25
    ComboBoxGadget (#GADGET_WindowedModes, 190, Top, 150, 21)     : Top+25
    ComboBoxGadget (#GADGET_AntialiasingModes, 190, Top, 150, 21) : Top+25
    
    TextGadget(#GADGET_Vsync, 70, Top, 100, 20, "VSync") 
    OptionGadget(#GADGET_VsyncOn   , 200, Top, 40, 20, "On")        
    OptionGadget(#GADGET_VsyncOff  , 270, Top, 40, 20, "Off")          : Top+45

    
    ButtonGadget (#GADGET_Launch,   6, Top, 180, 25, "Launch", #PB_Button_Default)
    ButtonGadget (#GADGET_Cancel, 200, Top, 190, 25, "Cancel")
      
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"None")
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"FSAA x2")
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"FSAA x4")
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"FSAA x6")
  
    SetGadgetState(#GADGET_AntialiasingModes,AAMode)
    
    If MP_ExamineScreenModes()
      
      Position = 0
      While MP_NextScreenMode()
        
        Position + 1
        Width       = MP_ScreenModeWidth()
        Height      = MP_ScreenModeHeight()
        Depth       = MP_ScreenModeDepth()
        RefreshRate = MP_ScreenModeRefreshRate()
        
        If Depth > 8
          AddGadgetItem(#GADGET_ScreenModes, -1, Str(Width)+"x"+Str(Height)+"x"+Str(Depth)+"@"+Str(RefreshRate))
          If ScreenX = Width And ScreenY = Height And ScreenD = Depth And ScreenF = RefreshRate
            SetGadgetState(#GADGET_ScreenModes, Position)
            FullScreenMode$ = Str(Width)+"x"+Str(Height)+"x"+Str(Depth)+"@"+Str(RefreshRate)
          EndIf  
        EndIf
       
      Wend        
      
    EndIf
    
    ExamineDesktops()
    NbScreenModes = 7
    
    Restore WindowedScreenDimensions

    Repeat      
      Read.l CurrentWidth
      Read.l CurrentHeight
      
      If CurrentWidth < DesktopWidth(0) And CurrentHeight < DesktopHeight(0)
        AddGadgetItem(#GADGET_WindowedModes, -1, Str(CurrentWidth)+ "x"+Str(CurrentHeight))
        NbScreenModes - 1
      Else
        NbScreenModes = 0
      EndIf
      
    Until NbScreenModes = 0
    
    SetGadgetState(#GADGET_FullScreen, FullScreen)
    SetGadgetState(#GADGET_Windowed  , 1-FullScreen)
    
    SetGadgetState(#GADGET_VsyncOn   , 1-VSyncMode)
    SetGadgetState(#GADGET_VsyncOff  , VSyncMode)

    
    SetGadgetText (#GADGET_ScreenModes  , FullScreenMode$)
    SetGadgetText (#GADGET_WindowedModes, WindowedScreenMode$)
    
    DisableGadget (#GADGET_ScreenModes  , 1-FullScreen)
    DisableGadget (#GADGET_WindowedModes, FullScreen)
    
    HideWindow(#WINDOW_Screen3DRequester, 0)
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event
        
      Case #PB_Event_Gadget
        
        Select EventGadget()
          
        Case #GADGET_Launch
          Quit = 2
          
        Case #GADGET_Cancel
          Quit = 1
          
        Case #GADGET_FullScreen
          DisableGadget(#GADGET_ScreenModes  , 0)
          DisableGadget(#GADGET_WindowedModes, 1)
        
        Case #GADGET_Windowed
          DisableGadget(#GADGET_ScreenModes  , 1)
          DisableGadget(#GADGET_WindowedModes, 0)
          
        Case #GADGET_VsyncOn
    ;      DisableGadget(#GADGET_VsyncOn  , 1)
    ;      DisableGadget(#GADGET_VsyncOff, 0)
        
        Case #GADGET_VsyncOff
    ;      DisableGadget(#GADGET_VsyncOn  , 0)
    ;      DisableGadget(#GADGET_VsyncOff, 1)
                 
        EndSelect
        
      Case #PB_Event_CloseWindow
        Quit = 1
        
      EndSelect
      
    Until Quit > 0
    
    FullScreen          = GetGadgetState(#GADGET_FullScreen)
    FullScreenMode$     = GetGadgetText (#GADGET_ScreenModes)
    WindowedScreenMode$ = GetGadgetText (#GADGET_WindowedModes)
    AAMode              = GetGadgetState(#GADGET_AntialiasingModes)
    VSyncMode           = GetGadgetState(#GADGET_VsyncOn)
    
    CloseWindow(#WINDOW_Screen3DRequester)
      
  EndIf
  
  If Quit = 2 ; Launch button has been pressed
  
    CreatePreferences(GetHomeDirectory()+"PureBasicDemos3D.prefs")
      WritePreferenceLong  ("FullScreen"        , FullScreen)          
      WritePreferenceString("FullScreenMode"    , FullScreenMode$)     
      WritePreferenceString("WindowedScreenMode", WindowedScreenMode$) 
      WritePreferenceLong  ("Antialiasing"      , AAMode) 
      WritePreferenceLong  ("Vsync"      , 1-VSyncMode) 
      
    If FullScreen
      ScreenMode$ = FullScreenMode$
    Else
      ScreenMode$ = WindowedScreenMode$
    EndIf
    
    RefreshRate = Val(StringField(ScreenMode$, 2, "@"))
    
    ScreenMode$ = StringField(ScreenMode$, 1, "@") ; Remove the refresh rate info, so we can parse it easily
    
    ScreenWidth  = Val(StringField(ScreenMode$, 1, "x"))
    ScreenHeight = Val(StringField(ScreenMode$, 2, "x"))
    ScreenDepth  = Val(StringField(ScreenMode$, 3, "x"))
    
    Screen3DRequester_FullScreen = FullScreen ; Global variable, for the Screen3DEvents
    
    If FullScreen
      
      Result = MP_Graphics3D(ScreenWidth, ScreenHeight, ScreenDepth, 0)
    Else
  
     Result = MP_Graphics3DWindow( 0, 0, ScreenWidth, ScreenHeight, Titel,#PB_Window_SystemMenu | #PB_Window_ScreenCentered)
      
        CreateMenu(0, WindowID(0))
          MenuTitle("Project")
          MenuItem(0, "Quit")
    
          MenuTitle("About")
          MenuItem(1, "About...")
  
    EndIf
    
    Select AAMode
      Case 0:
        MP_SetAntialiasing( #PB_AntialiasingMode_None )
      Case 1:
        MP_SetAntialiasing( #PB_AntialiasingMode_x2 )
      Case 2:
        MP_SetAntialiasing( #PB_AntialiasingMode_x4 )
      Case 3:
        MP_SetAntialiasing( #PB_AntialiasingMode_x6 )
    EndSelect
    
    MP_Vsync(VSyncMode)
    
    
  EndIf
     
  ProcedureReturn Result
  
    
  DataSection
    Logo: 
    IncludeBinary "Banner.png"
  EndDataSection


  
  
EndProcedure

DataSection
  WindowedScreenDimensions:
    Data.l  320, 240
    Data.l  512, 384      
    Data.l  640, 480
    Data.l  800, 600     
    Data.l 1024, 768
    Data.l 1280, 1024
    Data.l 1600, 1200
EndDataSection

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 60
; FirstLine = 44
; Folding = -
; EnableXP
; SubSystem = dx9
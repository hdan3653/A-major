;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_LookScreenMode.pb
;// Erstellt am: 29.3.2013
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: you see the possible screen modes
;//
;//
;////////////////////////////////////////////////////////////////

MP_ExamineScreenModes()

While MP_NextScreenMode()
  
  Debug Str(MP_ScreenModeWidth()) + " / " + Str(MP_ScreenModeHeight()) + " / " + Str(MP_ScreenModeDepth()) + " / " +   Str(MP_ScreenModeRefreshRate())
  
Wend


; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; CursorPosition = 3
; EnableXP
; SubSystem = dx9
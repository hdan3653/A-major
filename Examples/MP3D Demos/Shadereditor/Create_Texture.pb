If OpenWindow(0, 100, 90, 300, 300, "Create two Textures")

  If CreateImage(0, 255, 255)
    
    LoadFont(1, "Arial", 20)

    LoadFont(2, "Arial", 30)
    
    StartDrawing(ImageOutput(0))
    
    For k=0 To 255
      FrontColor(RGB(k,0, 255-k))  ; a rainbow, from black to pink
      Line(1, k, 255, 1)
    Next
    
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(1)) 
    FrontColor(RGB(255,255,255)) ; print the text to white !
    DrawText(10, 50, "Only a Test-Texture")
    FrontColor(RGB(255,0,0)) ; print the text to white !
    DrawText(75, 90, "for MP3D !")
    
      Circle(60,200,20,RGB(0,255,255))  ; a nice blue circle...

      Box(100,185,30,30, RGB(0,255,0))  ; and a green box

    Ellipse(185, 200, 30, 15, RGB(255,255,0)) 

    
    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
    
    SaveImage(0, "Demo_Texture_1.bmp")
    
    StartDrawing(ImageOutput(0))
    
    DrawingMode(#PB_2DDrawing_Gradient)      
    BackColor($0000FF)
    GradientColor(0.4, $00FFFF)
    GradientColor(0.6, $FFFF00)
    FrontColor($FF0000)
    
    BoxedGradient(0, 0, 255, 255)
    Box(0, 0, 255, 255)
    
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(1)) 
    FrontColor(RGB(255,0,255)) ; print the text to white !
    BackColor($000000)
    DrawText(10, 50, "Only a Test-Texture")
    FrontColor(RGB(0,255,0)) ; print the text to white !
    DrawText(75, 90, "for MP3D !")

    StopDrawing() ; This is absolutely needed when the drawing operations are finished !!! Never forget it !
 
    SaveImage(0, "Demo_Texture_2.bmp")
    
  EndIf
  
    Repeat
    EventID = WaitWindowEvent()
    
    If EventID = #PB_Event_Repaint
      StartDrawing(WindowOutput(0))
        DrawImage(ImageID(0), 20, 10)
      StopDrawing()    
    EndIf
    
  Until EventID = #PB_Event_CloseWindow  ; If the user has pressed on the close button

  EndIf
  
End   ; All the opened windows are closed automatically by PureBasic

; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
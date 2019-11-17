

Global dy,i,j,s_bg

Procedure DrawScrollTile()
  For i= 0 To 800 Step 64
    For j = 0 To 664 Step 64
      MP_DrawSprite(s_bg,i,j-dy)
    Next
  Next
  dy+1
  If dy>63
    dy=0
  EndIf
EndProcedure

MP_Graphics3DWindow(0,0,800,600," ",$CA1001)

UsePNGImageDecoder()
CreateImage(0,64,64)
StartDrawing(ImageOutput(0))
  Box(0,0,32,32,#Red)
  Box(32,32,32,32,#Blue)
StopDrawing()
t=MP_ImageToTexture(0)
s_bg=MP_SpriteFromTexture(t)

Repeat
  DrawScrollTile();call mp_drawsprite from a procedure ,doesn't work;

  MP_RenderWorld()
  MP_Flip()
Until  WindowEvent()=16 Or MP_KeyDown(#PB_Key_Escape)
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; SubSystem = dx9
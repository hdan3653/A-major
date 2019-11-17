#BUTTON = 6
 Quit.b = #False
rot.l=1 :stopFlag = 1 : wireFrame.b = 0
xs.f = 1:ys.f = 1:zs.f = 1
x.f: y.f :z.f: x0.f: y0.f=1 :z0.f
rotx.f:roty.f=0.5:rotz.f :rotx0.f: roty0.f: rotz0.f
up.f = 1.8: depth.f=0
ExamineDesktops()
MP_Graphics3D (DesktopWidth(0),DesktopHeight(0),0,2) ; Erstelle ein WindowsFenster #Window = 0
SetWindowTitle(0, "PgUp PgD scale mesh..Arrows for rotation, space: stop/rotate,  QA far/near, key_pad R/L/U/D")
MP_DrawText (1,1,"press W _wireFrame, D _ delete triangles")
ButtonGadget(#BUTTON, 0, DesktopHeight(0)-60, 60, 30, "rotate/stop")
MP_Viewport(0,0,DesktopWidth(0),DesktopHeight(0)-60)
light=MP_CreateLight(1)
MP_PositionEntity (light,-6,0,0)
MP_EntityLookAt(light,0,0,3)
MP_LightSetColor(light,RGB(255,255,255))
InitKeyboard()
camera=MP_CreateCamera() ; Kamera erstellen
MP_PositionEntity(camera, 0, 0.5, 0)


Mesh = MP_CreateMesh() ; Erzeuge leeres Mesh
SetActiveGadget(#BUTTON)

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
x.f: y.f :z.f : u.f: v.f: r.f
i.l: j.l
v.f = -0.5 :  u.f=0 :txu.f : txv.f
While u <= 2*#PI
 
   While v<= 0.5
       t+1 ; total number of vertices       
       x = Cos(u) * ( 1 + (v/2 * Cos(u/2)) )
          y = Sin(u) * ( 1 + (v/2 * Cos(u/2)) )
          z = v/2 * Sin(u/2)
       
             MP_AddVertex (Mesh, x, y,z,0,txu,txv)
         txv = txv + 1 ; texture coordinates
         v + 1
       Wend
       txv = 0
        txu = txu + 1/(2*#PI/0.1) ;texture coordinates
        v = -0.5
        u + 0.1
      Wend
      ;Debug t ; here 126 vertices from 0 to 125
      For j=0 To t-3 Step 2
         
        MP_AddTriangle (Mesh,j,j+2,j+1)
        MP_AddTriangle (Mesh,j+1,j+2,j+3 )
         
        Next
      ;connecting the first 2 vertices index with the last 2 vertices (twisted!!!)
      MP_AddTriangle (Mesh, 0,125,1)
      MP_AddTriangle (Mesh, 1,125,124)
      MP_EntitySetNormals(Mesh)
;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

Texture = MP_LoadTexture("c:/Programme/purebasic/Examples/3D/Data/Textures/terrain_texture.jpg")
MP_EntitySetTexture (Mesh, Texture )
MP_MaterialEmissiveColor (Texture,0,255,255,255)
MP_PositionEntity (Mesh,0,0.1,3) ; Position des Meshs
h.f=0:up.f=0.1:depth.f=3
x=90: y=0: z=0 :indx = 126
Repeat
  Event = WindowEvent()
  If Event = #PB_Event_Gadget
    Select EventGadget()
      Case #BUTTON
        If rot = 0
          rot = 1
          rotx= rotx0:roty=roty0:rotz=rotz0 ; restore rotation status
          stopFlag = 1
         
        Else
          rot = 0
          rotx0= rotx:roty0=roty:rotz0=rotz ;back up rotation status
          rotx=0:roty=0:rotz=0
          stopFlag = 0
         
        EndIf
                   
    EndSelect
  EndIf
  If stopFlag=1
    x + rotx
    y + roty
    z + rotz
  EndIf
  MP_DrawText (1,1,"press W _wireFrame, D _ delete triangles") 
  MP_DrawText (1,15,"keyPad keys: up.down.left.right")
  MP_RotateEntity(Mesh, x, y, z)
  MP_RenderWorld() ; Erstelle die Welt
  MP_Flip ()
 
  If MP_KeyDown(#PB_Key_Up)  ; rotate left
    rotx=1:roty=0:rotz=0
    rotx0 = rotx: roty0 = roty :rotz0 = rotz
    x + rotx
    y + roty
    z + rotz
    stopFlag=0
    rot = 0
  ElseIf MP_KeyDown(#PB_Key_Down) ; rotate right
    rotx=-1:roty=0:rotz=0
    rotx0 = rotx: roty0 = roty :rotz0 = rotz
    x + rotx
    y + roty
    z + rotz
    stopFlag=0
    rot = 0
  ElseIf MP_KeyDown(#PB_Key_Right)   ; rotate up
    rotx=0:roty=1:rotz=0
    rotx0 = rotx: roty0 = roty :rotz0 = rotz
    x + rotx
    y + roty
    z + rotz
    stopFlag=0
    rot = 0
  ElseIf MP_KeyDown(#PB_Key_Left) ; rotate down
    rotx=0:roty=-1:rotz=0
    rotx0 = rotx: roty0 = roty :rotz0 = rotz
    x + rotx
    y + roty
    z + rotz
    stopFlag=0
    rot = 0
  EndIf
 
  If MP_KeyDown(#PB_Key_PageUp) ; scale up model
    xs.f + 0.01:ys.f + 0.01:zs.f + 0.01
    MP_ScaleEntity(Mesh,xs,ys,zs)
   
  ElseIf MP_KeyDown(#PB_Key_PageDown) ; scale down model
    xs -0.01:ys -0.01:zs- 0.01
    If xs<0 :xs=0:ys=0:zs=0:EndIf
    MP_ScaleEntity(Mesh,xs,ys,zs)
   
  EndIf
  If MP_KeyDown(#PB_Key_Pad8) ; up move
    up + 0.01
    MP_PositionEntity(Mesh,h,up,depth)
   ElseIf MP_KeyDown(#PB_Key_Pad2) ; down move
    up - 0.01
    MP_PositionEntity(Mesh,h,up,depth)
  ElseIf MP_KeyDown(#PB_Key_Pad6)
    h + 0.01
    MP_PositionEntity(Mesh,h,up,depth)
    ElseIf MP_KeyDown(#PB_Key_Pad4)
    h - 0.01
    MP_PositionEntity(Mesh,h,up,depth)
   
    ElseIf MP_KeyDown(#PB_Key_Q) ; forward move
    depth - 0.01
    MP_PositionEntity(Mesh,h,up,depth)
    ElseIf MP_KeyDown(#PB_Key_A) ; inward move
    depth + 0.01
    MP_PositionEntity(Mesh,h,up,depth)
    ElseIf MP_KeyHit(#PB_Key_W) ; display wire frame for the material
      If wireFrame=0
      MP_Wireframe (1)
      wireFrame ! 1
         ElseIf wireFrame=1
           MP_Wireframe (0)
      EndIf
    ElseIf MP_KeyDown(#PB_Key_D)
      MP_FreeTriangle(Mesh, 1)
       ;indx -1: MP_FreeVertex(Mesh ,indx)
       
  EndIf
   If MP_KeyDown(#PB_Key_Escape)
      Quit = #True
    EndIf
   
   
Until Quit = #True Or Event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 19
; FirstLine = 5
; EnableXP
; SubSystem = dx9
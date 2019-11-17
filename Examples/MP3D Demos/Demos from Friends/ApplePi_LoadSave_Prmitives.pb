
Enumeration
   #MESH
   #LIGHT
   #CAMERA_ONE
   #BUTTON
   #mainwin
 EndEnumeration
 
Global xres=640, yres=480
MP_Graphics3D (xres,yres,0,3)
SetWindowTitle(0, "just exit and the cloud will be saves to dataxyz.asc ")
camera=MP_CreateCamera()

light=MP_CreateLight(2)
MP_LightSetColor (light, RGB(255,255,255))

MP_PositionEntity(camera, 0, 5, 10)
MP_EntityLookAt(camera,0,0,0)

MP_PositionEntity(light, 0, 10, 20)
MP_EntityLookAt(light,0,0,0)


Global Entity= MP_CreatePrimitives (1000020, 1)   
 
Global.f dx, dy, x, y, z
Global wd, ht, i, count, n, iter
Global.f w, leng, tx, ty, tz, tem
Global.f cr, ci, cj, ck, wk, inc, distance
Global mand, zval
Global.f angle
Define.f red, green, blue
;zval = 1 shows entire set
;zval = 0 cuts set in half
;zval = 0 is an interesting effect
wd = 500
ht = 500
;defines the shape of the Julia Set
cr = -0.200
ci = 0.800
cj = 0.000
ck = 0.000
wk = 0.000
;mand = 0 is Julia Set
;mand = 1 is Mandelbrot 3D
mand = 1
;zval = 1 shows entire set
;zval = 0 cuts set in half
;zval = 0 is an interesting effect
zval = 1
iter = 5
inc = 5
;#quat = 1
zval = 1
iter = 5
inc = 5
Procedure.f RandF(Min.f, Max.f, Resolution.i = 10000)
  ProcedureReturn (Min + (Max - Min) * Random(Resolution) / Resolution)
EndProcedure

Quit.b = #False
rot.l=1 :stopFlag = 1
xs.f = 0.3:ys.f = 0.3:zs.f = 0.3
x.f: y.f :z.f: x0.f: y0.f=1 :z0.f
rotx.f:roty.f=1:rotz.f :rotx0.f: roty0.f: rotz0.f
up.f = 2.2: depth.f=0

;==============================================================

;
Procedure.f calcleng( x.f,  y.f,  z.f)
    w.f: kr.f: ki.f: kj.f: kk.f
    w = wk
    n = 0
    If mand = 1  ;full Mandelbrot set
        kr = x
        ki = y
        kj = z
        kk = 0
    Else                ;else draw Julia Set
        kr = cr
        ki = ci
        kj = cj
        kk = ck
    EndIf
   
    While n < iter
        tem = x+x
        x = x*x-y*y-z*z-w*w+kr
        y = tem*y + ki
        z = tem*z + kj
        w = tem*w + kk
       
        n+1
        distance = x*x+y*y+z*z+w*w
       
        If distance > 4
          n = iter
        EndIf
       
    Wend
       
    ;Return distance
    ProcedureReturn distance
 
EndProcedure

zz.f
    foo.l
    iterations = 100000
    count = 0
   
    If zval = 0
        zz = 2.0
    Else
        zz = 4.0
    EndIf
     
      For foo = 0 To iterations
          ;x.f = RandF(0, 1)
          ;y.f = RandF(0, 1)
          x.f = RandF(-2, 2)
          y.f = RandF(-2, 2)
         
          z.f = zz*RandF(0, 1) -2.0
         
          ;calls the quaternion calculation
          leng.f = calcleng(x,y,z)
         
          If leng < 4
              red = (x+Cos(15*leng))*255
              green = (y+Sin(1-leng)*Cos(5*leng))*255
              blue = (z+Sin(0.75*leng))*255
              If red < 0 : red = 0 : EndIf
              If green < 0 : green = 0 : EndIf
              If blue < 0 : blue = 0 : EndIf
              If red > 255 : red = red-255 : EndIf
              If green > 255 : green = green-255 : EndIf
              If blue > 255 : blue = blue-255 : EndIf
                           
              i+1
             
              MP_SetPrimitives(Entity, i,  x, y, z,  MP_ARGB(0,red,green,blue))
              a$=StrF(x)+ "," +StrF(y)+"," +StrF(z)

                         
                           
          EndIf
         
        Next

;==============================================================
MP_PositionEntity(camera, 0, 0, 5)
MP_EntityLookAt(camera,0,0,0)
MP_PositionEntity(light, 0 , 0, 7)
MP_EntityLookAt(light,0,0,0)

xx.f=0 :zz.f=0


MP_SavePrimitives (Entity, "File.pr3d")

MP_FreeEntity (Entity)

Entity = MP_LoadPrimitives ("File.pr3d")

;Entity = MP_CatchPrimitives (?File1, ?File2-?File1)



While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow
 
    MP_PositionEntity(Entity, xx, 0, zz)
    MP_TurnEntity(Entity,0,1,0)
   
  MP_RenderWorld()
   
  MP_Flip ()

Wend
 



;DataSection

;   File1: 
;     IncludeBinary "c:\File.pr3d"
;   File2:     

   
;EndDataSection
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 154
; FirstLine = 143
; Folding = -
; EnableXP
; SubSystem = dx9
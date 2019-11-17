
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_Insectoids.pb
;// Created On: 3.06.2010
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Gamedesign and grafics from BlitzBasic file insectoids.bb
;// 
;//
;////////////////////////////////////////////////////////////////

#width=640
#height=480

Global game_state,game_timer,level_name$,alien_speed
Global num_aliens,num_flying,fly_timer,num_bulls,num_players
Global c_x.f,c_y.f,c_xs.f,c_ys.f,c_dir.f,c_phase.f,rev_dir,c_speed.f,c_xsize.f,c_ysize.f
Global player_image,stars_image,bomb_image,bull_image,stars_scroll,boom_anim,Alien_sprite
Global mini_ship,tmp_image,insectoids_image,boom_sound,cool_sound,kazap_sound,shoot_sound

Structure Alien
  x.f
  y.f
  rot.i
  state.i
  f_x.f
  f_y.f
  dest_y.f
  dest_rot.i
  rot_step.i
  bomb_cnt.i
EndStructure

Structure Player
  x.i
  y.i
  state.i
  lives.i
  ctrl.i
  bang.i
  score.i
EndStructure

Structure Bomb
  x.f
  y.f
  xs.f
  ys.f
EndStructure

Structure Bullet
  x.i
  y.i
EndStructure

Structure Explosion
  x.i
  y.i
  frame.i
EndStructure

Global NewList a.Alien(), NewList bb.Bomb() , NewList p.Player() , NewList b.Bullet() , NewList e.Explosion()

Procedure LoadGraphics()
	
  stars_image=MP_CatchSprite(?stars_image, ?player_image - ?stars_image)
  player_image=MP_CatchSprite(?player_image, ?bull_image - ?player_image) : MP_ScaleSprite(player_image, 75, 75)
	mini_ship=MP_CatchSprite(?player_image, ?bull_image - ?player_image):MP_ScaleSprite(mini_ship, 40, 40)
	bull_image=MP_CatchSprite(?bull_image, ?bomb_image - ?bull_image) : MP_ScaleSprite(bull_image,75,100)
	bomb_image=MP_CatchSprite(?bomb_image, ?Alien_sprite - ?bomb_image): MP_ScaleSprite (bomb_image,50,50)
	Alien_sprite = MP_CatchSprite(?Alien_sprite, ?boom_anim - ?Alien_sprite)
	boom_anim = MP_CatchSprite(?boom_anim, ?insectoids_image - ?boom_anim) : MP_SpriteSetAnimate(boom_anim,15,0,42,36)
	insectoids_image= MP_CatchSprite(?insectoids_image, ?boom_sound - ?insectoids_image): MP_ScaleSprite(Alien_sprite, 65, 65) 
	
EndProcedure

Procedure LoadSounds()
  
  boom_sound=MP_CatchSound(?boom_sound) 
  cool_sound=MP_CatchSound(?cool_sound) 
  kazap_sound=MP_CatchSound(?kazap_sound) 
  shoot_sound=MP_CatchSound(?shoot_sound) 
  
EndProcedure  
  
Procedure UpdateExplosion( *e.Explosion )
  
  *e\frame+1
	If *e\frame=42
	  DeleteElement(e())
	EndIf
EndProcedure

Procedure RenderExplosion( *e.Explosion )
  If *e\frame<0
    ProcedureReturn
  EndIf
  
  MP_DrawFrameSprite(boom_anim,*e\x,*e\y,*e\frame/3,255)
  
EndProcedure

Procedure CreateExplosion( x,y,frame )
	AddElement (e())
	e()\x = x : e()\y = y : e()\frame=frame
EndProcedure

Procedure UpdatePlayer( *p.Player )

	If *p\state <> 1 
	   ProcedureReturn
  EndIf

	Select *p\ctrl
	Case 1 ; Only Keyboard
		l=MP_KeyDown( #PB_Key_Left)
		r=MP_KeyDown( #PB_Key_Right )
		f = MP_KeyHit(#PB_Key_Space)
	Case 2 ; Only Joystick
		jx=MP_JoystickAnalogX() 
		If jx<0 
		  l=1
		ElseIf jx>0
		  r=1
		EndIf  
		f=MP_JoystickButtonDown(0) 
	EndSelect
	If l
		If *p\x > 16 : *p\x-4 : EndIf
	ElseIf r
		   If *p\x < #width-16 : *p\x+4 : EndIf    
	EndIf
	
	If game_state<>2
	   ProcedureReturn 
	EndIf 
	
	If f And num_bulls<3
		MP_PlaySound (shoot_sound)
		AddElement(b())
		b()\x = *p\x : b()\y = *p\y-16
		num_bulls=num_bulls+1
	EndIf
  
	dead=#False	
	
	ForEach a()

    If MP_SpritePixelCollision(player_image,*p\x,*p\y,Alien_sprite,a()\x,a()\y,2)
			dead=#True
			Break
		EndIf

	Next

	ForEach bb()
    If MP_SpritePixelCollision(player_image,*p\x,*p\y,bomb_image,bb()\x,bb()\y,2)
			dead=#True
			Break
		EndIf
	Next
	
	If Not dead
	   ProcedureReturn
	EndIf 
	
	MP_PlaySound ( boom_sound)
	
	CreateExplosion( *p\x,*p\y,k )
	
	*p\bang=1
	*p\state=2
	*p\lives-1
	game_state=3
	
EndProcedure

Procedure RenderPlayer( *p.Player )

	MP_DrawText (#width/2-MP_TextGetWidth(Str(*p\score))/2,4,Str(*p\score))

	For k=1 To *p\lives
		MP_DrawSprite(mini_ship,k*16+8,14)
	Next
	
	If *p\state=1
		MP_DrawSprite (player_image,*p\x,*p\y)
		ProcedureReturn
	EndIf

EndProcedure

Procedure AddPoints( *p.Player,pnts )
	t=*p\score/5000
	*p\score+pnts
	If *p\score/5000<>t
	   *p\lives+1
	EndIf   
EndProcedure

Procedure UpdateBullet( *b.Bullet )
	
	*b\y-5

  ForEach a()
		
    If MP_SpritePixelCollision(bull_image,*b\x,*b\y,Alien_Sprite,a()\x,a()\y,2)
         MP_PlaySound (kazap_sound)
         If a()\state=1
            pnts=25
         ElseIf a()\state=2
           	pnts=50
         Else
         		pnts=100
         EndIf
         AddPoints( FirstElement(p()),pnts )
   			 CreateExplosion( a()\x,a()\y,0 )
 			   DeleteElement (b()) : num_bulls -1
         If a()\state <> 1
            num_flying-1
         EndIf   
         num_aliens-1
         DeleteElement (a())
         ProcedureReturn
    EndIf
	
  Next
	
	If *b\y > 0 
	  ProcedureReturn 
	EndIf  
	
	DeleteElement (b())
	num_bulls-1
	
EndProcedure

Procedure Rainbow( time )
	r=time % 768
	If r>255
	    r=511-r
	EndIf    
	g=(time+256) % 768
	If g>255
	   g=511-g
	EndIf   
	b=(time+512) % 768
	If b>255
	   b=511-b
	EndIf   
	If r<0
	   r=0
	EndIf   
	If g<0
	  g=0
	EndIf
	If b<0
	  b=0
	EndIf  
	ProcedureReturn MP_ARGB(255,r,g,b)
EndProcedure

Procedure RenderGame()

	MP_DrawTiledSprite (stars_image,0,stars_scroll)
	MP_DrawTiledSprite (stars_image,7,stars_scroll*2)
	MP_DrawTiledSprite (stars_image,23,stars_scroll*3)
	stars_scroll=(stars_scroll+1) % MP_SpriteGetHeight( stars_image )
	
	ForEach a()               ; Reset the list index before the first element.
	  MP_RotateSprite(Alien_Sprite, a()\rot) 
	  MP_DrawSprite(Alien_Sprite, a()\x , a()\y ) 
	Next
	
	
	ForEach bb()
	  MP_DrawSprite (bomb_image,bb()\x,bb()\y)
	Next
	
	ForEach p()
		RenderPlayer( p() )
	Next
	
	ForEach b()
		MP_DrawSprite (bull_image,b()\x,b()\y)
	Next
	
	ForEach e()
		RenderExplosion( e() )
	Next
	
	Select game_state
	Case 0
	   MP_DrawSprite (insectoids_image,#width/2-MP_SpriteGetWidth(insectoids_image)/2,#height/3)
	   MP_DrawText(#width/2-90, #height - 30 , "PRESS SPACE TO START")
	Case 1
 	   MP_DrawText(#width/2-MP_TextGetWidth(level_name$)/2, #height/2 , level_name$,0,Rainbow( game_timer*5 ))
	Case 4
	   MP_DrawText(#width/2-MP_TextGetWidth("GAME OVER")/2, #height/2 ,"GAME OVER") 
	EndSelect
	
EndProcedure

Procedure BeginLevel()

	MP_PlaySound (cool_sound)
	
	Read.s level_name$
	If level_name$=""
		Restore levels
		Read.s level_name$
		alien_speed=alien_speed+1
		If alien_speed>6 : alien_speed=6 : EndIf
	EndIf
	
	c_x=#width/2:c_y=104:c_phase=0:c_dir=1
	
	Read.f c_speed
	Read.f c_xsize
	Read.f c_ysize
	
	Repeat
		Read x.i
		If x=999 : Break : EndIf
		Read.i y
		Read.i cnt
		For k=1 To cnt
		  AddElement (a())
			a()\x=c_x
			a()\y=c_y
			a()\rot=0
			a()\state=1
			a()\f_x=x*34
			a()\f_y=y*24
			x+1
		Next
		num_aliens+cnt
	ForEver

	game_state=1
	game_timer=0
	
EndProcedure

Procedure ResetPlayer(*p.player)
  
  *p\x=#width/2
	*p\y=#height-40
	*p\state=1
	
EndProcedure

Procedure CreatePlayer( ctrl )
  
  AddElement(p())
	p()\lives=3
	p()\ctrl=ctrl
	ResetPlayer( p ())
	num_players=num_players+1
	
EndProcedure

Procedure BeginGame()
	
	level=0
	num_bulls=0
	num_aliens=0
	num_flying=0
	game_state=0
	num_players=0
	alien_speed=3
	
	CreatePlayer( 1 )
	
	Restore levels
	
	BeginLevel()
		
EndProcedure

Procedure UpdateFormation()

	c_phase = MP_ModFloat(c_phase+c_speed, 360)
	t.f=Sin( c_phase * 0.017453 )*0.5+0.5
	c_xs=t*c_xsize+1:c_ys=t*c_ysize+1
	
	If game_state<>1 : c_x + c_dir : EndIf
	
EndProcedure

Procedure UpdateFlyTimer()

	If num_aliens>3
		If fly_timer=0 : fly_timer=600 : EndIf
		fly_timer -1
		If fly_timer>120 : ProcedureReturn : EndIf
		If fly_timer % 30<>0 : ProcedureReturn : EndIf
	EndIf
	
	n=Random( num_aliens - num_flying )
	
	ForEach a() 
		If a()\state=1
			If n=0
				a()\dest_y=a()\y
				a()\rot_step=3
				If Random(1) < 0.5 : a()\rot_step=-3 : EndIf
				num_flying+1
				a()\state=2
				ProcedureReturn
			EndIf
			n-1
		EndIf
	Next
	
EndProcedure

Procedure DropBomb( *a.Alien )
  If *a\bomb_cnt=0
     *a\bomb_cnt=Random (50) + 50 
  EndIf   
  *a\bomb_cnt-1
  If *a\bomb_cnt>0
    ProcedureReturn
  EndIf
  
  FirstElement(p()) 
  
  If p()=#Null
    ProcedureReturn
  EndIf
  
  AddElement(bb())
	bb()\x=*a\x
	bb()\y=*a\y
	If *a\x < p()\x
	  bb()\xs=1
	Else
	  bb()\xs=-1
	EndIf  
	bb()\ys=4
EndProcedure

Procedure UpdateBomb( *b.Bomb )
	*b\x+*b\xs
	*b\y+*b\ys
	If *b\y > #height
	   DeleteElement(bb())
	EndIf

EndProcedure

Procedure UpdateAlien( *a.Alien )

	Select *a\state
	Case 1
		If *a\rot<>0
		  If *a\rot>180
		    *a\rot+6
		  Else
		    *a\rot-6
		  EndIf
		  If *a\rot<0 Or *a\rot>=360
		    *a\rot=0
		  EndIf
		EndIf
		dx=c_x+*a\f_x*c_xs - *a\x
		dy=c_y+*a\f_y*c_ys - *a\y
		If dx<-alien_speed 
		  dx=-alien_speed
		ElseIf dx>alien_speed 
		  dx=alien_speed
		EndIf  
		If dy<-alien_speed
		  dy=-alien_speed
		ElseIf dy>alien_speed
		  dy=alien_speed
		EndIf  
		*a\x+dx : *a\y+dy
		If c_dir<0 And *a\x<16 : rev_dir=#True : EndIf
		If c_dir>0 And *a\x>#width-16 : rev_dir=#True : EndIf
	Case 2
	  
	  *a\rot+*a\rot_step
		If *a\rot<0 
		  *a\rot+360 
		ElseIf *a\rot>=360
		  *a\rot-360
		EndIf  
		If *a\rot<90 Or *a\rot>270
			*a\dest_rot=Random(80) + 140
			*a\dest_y+Random( 200 ) + 100
			*a\state=3
		EndIf
		*a\x+Cos( (*a\rot-90) * 0.017453)*alien_speed
		*a\y+Sin( (*a\rot-90) * 0.017453)*alien_speed

		DropBomb( *a )
	Case 3		
		dr=*a\rot-*a\dest_rot
		If Abs(dr)>Abs(*a\rot_step)
			*a\rot+*a\rot_step
			If *a\rot<0 
			  *a\rot+360
			ElseIf *a\rot>=360
			  *a\rot-360
			EndIf  
		EndIf
		*a\x+Cos( (*a\rot-90)* 0.017453 )*alien_speed
		*a\y+Sin( (*a\rot-90) * 0.017453)*alien_speed
		If *a\y>#height
			*a\x=Random(#width/2)+#width/4:*a\y=0
			num_flying-1
			*a\state=1
		ElseIf *a\y > *a\dest_y
			*a\rot_step=-*a\rot_step
			*a\state=2
		EndIf
		DropBomb( *a )
	EndSelect
EndProcedure

Procedure EndGame()

	ClearList(p()) ; Player
	ClearList(b()) ; Bullet
	ClearList(a()) ; Alien
	ClearList(bb()) ; Bomb

	game_state=0
	game_timer=0

EndProcedure

Procedure UpdateGame()

	Select game_state
	Case 0
		game_timer=game_timer+1
		If MP_KeyDown(#PB_Key_Space) : BeginGame() : EndIf
	Case 1
		game_timer=game_timer+1
		If game_timer=150 : game_state=2 : EndIf
		UpdateFormation()
	Case 2
		UpdateFlyTimer()
		UpdateFormation()
		If num_aliens=0 : BeginLevel() : EndIf
	Case 3
	  UpdateFormation()
		If num_flying=0 And FirstElement(e())=#Null
		  FirstElement(p()) 
			If p()\lives>0
				ResetPlayer( p() )
				game_state=2
			Else
				game_state=4
				game_timer=0
			EndIf
		EndIf
	Case 4
		UpdateFlyTimer()
		UpdateFormation()
		game_timer+1
		If game_timer=150 : EndGame() : EndIf
	EndSelect
	
	rev_dir=#False
	ForEach a()
		UpdateAlien( a() )
	Next
	If rev_dir
	   c_dir=-c_dir
	 EndIf
	 
	ForEach bb()
		UpdateBomb( bb() )
	Next
	
	ForEach p()
		UpdatePlayer( p() )
	Next
	
	ForEach b() 
		UpdateBullet( b() )
	Next
	
	ForEach e()
		UpdateExplosion( e() )
	Next
EndProcedure


MP_Graphics3D (#width,#height,0,3)
SetWindowTitle(0, "Insectoids 0.2 with MP3D") 



LoadGraphics()
LoadSounds()

game_state=0
game_timer=0

time=MP_ElapsedMicroseconds() 

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

  UpdateGame()
  RenderGame()

  MP_RenderWorld() ; Erstelle die Welt
  MP_Flip () ; Stelle Sie dar

Wend
  
DataSection
  
levels:

Data.s "LEVEL 1"
Data.f 1,0.25,0
Data.i -2,-2,5
Data.i -3,-1,7
Data.i -3,0,7
Data.i -3,1,7
Data.i -3,2,7
Data.I 999

Data.s "LEVEL 2"
Data.f 1,0.25,0.25
Data.i 0,-2,1
Data.i -1,-1,3
Data.i -2,0,5
Data.i -3,1,7
Data.i -4,2,9
Data.i -5,3,11
Data.i 999

Data.s "LEVEL 3"
Data.f 3,0.25,0.5
Data.i -5,-2,11
Data.i -4,-1,9
Data.i -3,0,7
Data.i -4,1,9
Data.i -5,2,11
Data.i 999

Data.s "LEVEL 4"
Data.f 2,0,1
Data.i -5,-1,11
Data.i -5,0,11
Data.i -5,1,11
Data.i -5,2,11
Data.i -5,3,11
Data.i -5,4,11
Data.i -5,5,11
Data.i 999

Data.s "LEVEL 5"
Data.f 1,0.25,0.125
Data.i -3,-2,7
Data.i -4,-1,9
Data.i -5,0,11
Data.i -5,1,11
Data.i -5,2,11
Data.i -5,3,11
Data.i -5,4,11
Data.i -5,5,11
Data.i -5,6,11
Data.i -5,7,11
Data.i 999

Data.s "LEVEL 6"
Data.f 1,0.25,0.125
Data.i -7,-2,15
Data.i -7,-1,15
Data.i -7,0,15
Data.i -7,1,15
Data.i -7,2,15
Data.i -7,3,15
Data.i -7,4,15
Data.i -7,5,15
Data.i -7,6,15
Data.i -7,7,15
Data.i -7,8,15
Data.i -7,9,15
Data.i -7,10,15
Data.i -7,11,15
Data.i 999

Data.s ""

stars_image:
  IncludeBinary "graphics\stars.bmp" 
player_image:
  IncludeBinary "graphics\player.bmp"
bull_image:
  IncludeBinary "graphics\bullet.bmp" 
bomb_image:
  IncludeBinary "graphics\bbomb.bmp"
Alien_sprite:
  IncludeBinary "graphics\alien.bmp"
boom_anim:
  IncludeBinary "graphics\explosion.bmp"
insectoids_image:
  IncludeBinary "graphics\insectoids_logo.bmp" 
boom_sound:
  IncludeBinary "sounds\boom.wav" 
cool_sound:
  IncludeBinary "sounds\cool.wav"
kazap_sound:
  IncludeBinary "sounds\kazap.wav"
shoot_sound:
  IncludeBinary "sounds\shoot.wav"
 
EndDataSection
  
  
  
  
  
  
  
  
  
  
  
  
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 610
; FirstLine = 608
; Folding = ----
; EnableAsm
; UseIcon = ..\mp3d.ico
; Executable = C:\Insectoids.exe
; SubSystem = dx9
; Manual Parameter S=DX9
; EnableCustomSubSystem

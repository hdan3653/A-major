
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine Beispielprogramme
;// Dateiname: MP_PointSprite.pb
;// Erstellt am: 13.10.2008
;// Update am  : 
;// Author: Michael Paulwitz
;// 
;// Info: 
;// How to create you own Point Sprites with moving
;// Wie man selber eigene PointSprites erzeugt mit Bewegung
;//
;//
;////////////////////////////////////////////////////////////////


Macro D3DTS_WORLDMATRIX(index)
     index + 256
EndMacro
  
#D3DRS_LIGHTING = 137
#D3DRS_ZWRITEENABLE = 14 ;/* TRUE to enable z writes */
#D3DRS_ALPHABLENDENABLE = 27 ;/* TRUE to enable alpha blending */
#D3DRS_SRCBLEND = 19 ;/* D3DBLEND */
#D3DRS_DESTBLEND = 20 ;/* D3DBLEND */
#D3DBLEND_ONE = 2
#D3DRS_POINTSPRITEENABLE = 156 ;/* BOOL point texture coord control */
#D3DRS_POINTSCALEENABLE = 157 ;/* BOOL point size scale enable */
#D3DRS_POINTSIZE_MIN = 155 ;/* float point size min threshold */
#D3DRS_POINTSCALE_A = 158 ;/* float point attenuation A value */
#D3DRS_POINTSCALE_B = 159 ;/* float point attenuation B value */
#D3DRS_POINTSCALE_C = 160 ;/* float point attenuation C value */
#D3DTS_WORLD = D3DTS_WORLDMATRIX(0)
#D3DLOCK_DISCARD = $00002000
#D3DPT_POINTLIST = 1
#D3DFVF_XYZ = $002
#D3DFVF_PSIZE = $020
#D3DFVF_DIFFUSE = $040
#D3DFVF_MY_POINTVERTEX = #D3DFVF_XYZ | #D3DFVF_PSIZE | #D3DFVF_DIFFUSE
#D3DUSAGE_POINTS = ($00000040)
#D3DPOOL_MANAGED = 1

Structure PointVertex
  x.f
  y.f
  z.f
  Size.f
  Color.l;d3dcolor
EndStructure

Structure matrix
 m.f[16]
EndStructure

Global *D3DDevice.IDIRECT3DDEVICE9 ; Direct X Device
Global m_pVB.IDIRECT3DVERTEXBUFFER9  ; Buffer zum laden der punkte
Global NewList  PointSprite.PointVertex()
Global identity.matrix
Global Sprite
identity\m[0] = 1 : identity\m[5] = 1 : identity\m[10] = 1 : identity\m[15] = 1

Import "d3dx9.lib"
  
    D3DXMatrixRotationYawPitchRoll (*pOut.MATRIX, Yaw.f, Pitch.f, Roll.f)
    
EndImport    
    
Procedure MP_RenderPointSprites() ; Point Sprite
  
  *D3DDevice\SetRenderState( #D3DRS_LIGHTING, #False)
  ;*D3DDevice\SetRenderState( #D3DRS_ZWRITEENABLE, #False );
  ;*D3DDevice\SetRenderState( #D3DRS_ALPHABLENDENABLE, #True ); Nur wenn Alphablend benötigt wird
  *D3DDevice\SetRenderState( #D3DRS_SRCBLEND,#D3DBLEND_ONE);
  *D3DDevice\SetRenderState( #D3DRS_DESTBLEND,#D3DBLEND_ONE);

	;// Set up the render states For using point sprites...
  *D3DDevice\SetRenderState( #D3DRS_POINTSPRITEENABLE, #True );    // Turn on point sprites
  *D3DDevice\SetRenderState( #D3DRS_POINTSCALEENABLE,  #True );    // Allow sprites to be scaled with distance
  
  one.f = 1
  zero.f = 0
  
  *D3DDevice\SetRenderState( #D3DRS_POINTSIZE_MIN, PeekI(@one)   ); // Float value that specifies the minimum size of point primitives. Point primitives are clamped to this size during rendering. 
  *D3DDevice\SetRenderState( #D3DRS_POINTSCALE_A, PeekI(@zero) ); // Default 1.0
  *D3DDevice\SetRenderState( #D3DRS_POINTSCALE_B, PeekI(@zero)); // Default 0.0
  *D3DDevice\SetRenderState( #D3DRS_POINTSCALE_C, PeekI(@one) ); // Default 0.0
  
  ;// LOCK the vertex buffer, And set up our point sprites IN accordance With 
  ;// our particles that we're keeping track of in our application.
  ;//
  
  VertexMemory = #Null
  If m_pVB\Lock(0, m_dwMaxParticles * SizeOf(PointVertex), @VertexMemory, #D3DLOCK_DISCARD ) 
     ProcedureReturn #False
  EndIf 
 
  zaehler = SizeOf(PointVertex)
  count = 0
  i = 0
  *Pointvert.PointVertex
  
  If ListSize (PointSprite()) 
    
    *Pointvert.PointVertex = VertexMemory 
    
    ForEach PointSprite()
      *Pointvert\x     = PointSprite()\x
      *Pointvert\y     = PointSprite()\y
      *Pointvert\z     = PointSprite()\z
      *Pointvert\Size  = PointSprite()\Size
      *Pointvert\Color = PointSprite()\Color
      *Pointvert + zaehler
    Next
    
	 ;//
 	 ;// Render point sprites...
	 ;//
   
    *D3DDevice\SetStreamSource(0, m_pVB, 0, SizeOf(PointVertex))
    *D3DDevice\SetFVF( #D3DFVF_MY_POINTVERTEX );
  
    ForEach PointSprite() 
   
     *D3DDevice\SetTexture( 0, PeekI(Sprite) );	
     *D3DDevice\SetTransform(#D3DTS_WORLD, identity)
     *D3DDevice\DrawPrimitive( #D3DPT_POINTLIST, count, 1);
     count + 1

     Next ;Until Not NextElement(PointSpritelist()) Or PointSpritelist()\PointSpriteEmitter <> *pointer
  EndIf

  m_pVB\Unlock()

  ;// Reset render states...
	;//
	
  *D3DDevice\SetRenderState( #D3DRS_POINTSPRITEENABLE, #False );
  *D3DDevice\SetRenderState( #D3DRS_POINTSCALEENABLE,  #False );
;  *D3DDevice\SetRenderState( #D3DRS_ZWRITEENABLE, #True );
;  *D3DDevice\SetRenderState( #D3DRS_ALPHABLENDENABLE, #False );
  *D3DDevice\SetRenderState(#D3DRS_LIGHTING, #True)
  
  ProcedureReturn count
  
EndProcedure

MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster mit 3D Funktion #Window = 0
SetWindowTitle(0, "MP3D Point Sprite with Moving") ; Setzt einen Fensternamen

MP_VersionOf(1) 

*D3DDevice.IDIRECT3DDEVICE9 = MP_AddressOf(1)

camera=MP_CreateCamera() ; Kamera erstellen
light=MP_CreateLight(1) ; Es werde Licht


Sprite = MP_CatchTexture(?MyData, ?EndOfMyData - ?MyData)

MaxsizeofPointSprite = 2048
*D3DDevice\CreateVertexBuffer( MaxsizeofPointSprite * SizeOf(PointVertex),#D3DUSAGE_POINTS, #D3DFVF_MY_POINTVERTEX, #D3DPOOL_MANAGED,   @m_pVB, #Null );

AddElement(PointSprite())
PointSprite()\x = 1
PointSprite()\y = 0.5
PointSprite()\z = 0 
PointSprite()\Size = 0.5
PointSprite()\Color = ($FFFFFFFF)

AddElement(PointSprite())
PointSprite()\x = -1
PointSprite()\y = -0.5
PointSprite()\z = 0 
PointSprite()\Size = 0.5
PointSprite()\Color = ($FFFFFFFF)

AddElement(PointSprite())
PointSprite()\x = -1
PointSprite()\y = 0.5
PointSprite()\z = 0 
PointSprite()\Size = 0.5
PointSprite()\Color = ($FFFFFFFF)

AddElement(PointSprite())
PointSprite()\x = 1
PointSprite()\y = -0.5
PointSprite()\z = 0 
PointSprite()\Size = 0.5
PointSprite()\Color = ($FFFFFFFF)

AddElement(PointSprite())
PointSprite()\x = 0
PointSprite()\y = 0
PointSprite()\z = -1 
PointSprite()\Size = 0.5
PointSprite()\Color = ($FFFFFFFF)

AddElement(PointSprite())
PointSprite()\x = 0
PointSprite()\y = 0
PointSprite()\z = 1 
PointSprite()\Size = 0.5
PointSprite()\Color = ($FFFFFFFF)

identity\m[12] = 0 ;x position der matrix
identity\m[13] = 0 ;y position der matrix
identity\m[14] = 0 ;z position der matrix
Yaw.f : Pitch.f : Roll.f

While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Windows Schliessen

    MP_Renderbegin()
    
    Yaw + 0.01
    
    D3DXMatrixRotationYawPitchRoll (identity,Yaw.f, Pitch.f, Roll.f)
    identity\m[12] = 0 ;x position der matrix
    identity\m[13] = 0 ;y position der matrix
    identity\m[14] = 4 ;z position der matrix in der Welt

    MP_RenderPointSprites()
    
    MP_RenderEnd() 

    MP_Flip () ; Stelle Sie dar

Wend

DataSection
  MyData:
     IncludeBinary #PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp"
  EndOfMyData:
EndDataSection

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 152
; FirstLine = 144
; Folding = -
; EnableXP
; SubSystem = dx9
; EnableCustomSubSystem
; Manual Parameter S=DX9
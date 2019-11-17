;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: Create Object.pb
;// Created On: 26.11.2008
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Objekte mit UV Koordinaten versehen
;//
;// http://www.mvps.org/directx/articles/spheremap.htm
;//
;////////////////////////////////////////////////////////////////

;-
;- ProgrammStart


MP_Graphics3D (640,480,0,3) ; Erstelle ein WindowsFenster #Window = 0

;Create Sphere
Sphere1 = MP_CreateSphere(24)
;Create Plane
Plane1 = MP_Createplane (20,12)

;- Create Sphere1 Methodic 1, UV coordinate is calculated from the XY coordinate, with ASin   
max = MP_CountVertices(Sphere1)-1

For n = 0 To max
         color.f = MP_VertexGetV(Sphere1,  n) * 255
         MP_VertexSetColor(Sphere1, n, MP_ARGB(1,color,0,255-color))
Next


MP_SaveMesh("VertexSphere.x",Sphere1)
MP_SaveMesh("Flagge.x",Plane1)
; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 21
; EnableXP
; SubSystem = dx9
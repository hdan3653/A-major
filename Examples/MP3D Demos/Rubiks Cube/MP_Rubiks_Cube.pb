; PB 4.40
; Februar 2010
; Zauberwürfel Version 1.0
; Torsten Malchow
; Windows, MP3D-Lib von MP - Alpha 21


;{ Enumeration
Enumeration 
	#material
	
  #oben
  #unten
  #links
  #rechts
  #vorn
  #hinten
  
  #gelb
  #gruen
  #rot
  #blau
  #weiss
  #orange
  

EndEnumeration

;}

;{ Variablen
	EnableExplicit
	; Allgemein
	Global i.i
	Global j.i
	Global k.i
	Global l.i
	
	Global mische.i
	Global anzahl.i = 50

	Global programmstart.i
	
	; Fenster und Screengrösse
	Global fx.i
	Global fy.i
	
	
	; 3D
	Global x.i
	Global y.i
	Global z.i
	Global n.i
	Global MouseX.i
	Global MouseY.i
	
	Global deltaTurn.l = 1
	; drehen
	Global vald_mesh.l
	Global kante.l
	Global position_aktuell.l
	
	Structure wurfeldata
		meshnummer.l	; Rückgabenummer von der Erstellung des Mesh 
		farbe.l			; Farbe des Mesh
		wahl.i			; Zu was kann man das Mesh auswählen 1=Wahl der Kante   2=drehen der Kante
		aktiviert.i		; Mesh ausgewählt zum drehen 1=ja
	EndStructure
	
	Global Dim daten.wurfeldata(54)
	Global Dim daten_mellan.wurfeldata(54)
	
	
	; Kamera
	Global camera.i
	
	; Texture
	Global Dim aTexture.l(14)

	
	; Mesh
	Global Dim mesh.l(61)
	; 1 bis 54 sind die Rechtecke
	; 55 = unten, 56 = oben, 57 = links, 58 = rechts, 59 = hinten, 60 = vorn
	; 61 = Zentrum
	
	Global aImage.i
	Global Dim aColor.l(5)
;}



;{ Prozeduren

	Procedure kopplung()
		; Meshes für den Start koppeln
 	  	For i = 1 To 60
 	  		MP_EntitySetParent(mesh(i), mesh(61))
 	  	Next i
	EndProcedure
	

		
	;}
	
	;{ Drehen
	
		
	Procedure zwischendaten()
		For k = 1 To 54
			With daten_mellan(k)
				\aktiviert = daten(k)\aktiviert
				\farbe = daten(k)\farbe
				\wahl = daten(k)\wahl
			EndWith
		Next k
	EndProcedure
	

	Procedure farbe_setzen(index.i, farbe.l, aktiviert.i)
		Select farbe
			Case #gelb
					MP_EntitySetTexture(daten(index)\meshnummer, aTexture(0+6*aktiviert))
			Case #gruen
					MP_EntitySetTexture(daten(index)\meshnummer, aTexture(1+6*aktiviert))
			Case #blau
					MP_EntitySetTexture(daten(index)\meshnummer, aTexture(2+6*aktiviert))				
			Case #rot
					MP_EntitySetTexture(daten(index)\meshnummer, aTexture(3+6*aktiviert))
			Case #weiss
					MP_EntitySetTexture(daten(index)\meshnummer, aTexture(4+6*aktiviert))
			Case #orange
					MP_EntitySetTexture(daten(index)\meshnummer, aTexture(5+6*aktiviert))	

		EndSelect
	EndProcedure

	Procedure daten_wechseln(quellmesh.i, zielmesh.i)
		With daten_mellan(quellmesh)
			daten(zielmesh)\aktiviert = \aktiviert
			daten(zielmesh)\farbe = \farbe
			daten(zielmesh)\wahl = \wahl
			farbe_setzen(zielmesh, \farbe, \aktiviert)
		EndWith
	EndProcedure
	
	Procedure daten_wechseln_b(zielmesh.i, quellmesh.i)
		With daten_mellan(quellmesh)
			daten(zielmesh)\aktiviert = \aktiviert
			daten(zielmesh)\farbe = \farbe
			daten(zielmesh)\wahl = \wahl
			farbe_setzen(zielmesh, \farbe, \aktiviert)
		EndWith
	EndProcedure
	
	Procedure text()
		If mische = 1
			MP_DrawText (100,40,"Bin beim Mischen")
		Else
			MP_DrawText (10,560,"ESC = Abbruch")
 			MP_DrawText (606,540,"Mit linker Maustaste wählen")
 			MP_DrawText (440,560,"Klick auf Mitte einer Kante wählt sie zum Drehen aus")
 			MP_DrawText (500,580,"Klick auf Ecke dreht die ausgewählte Kante")
 			MP_DrawText (10, 580, "Rechte Maustaste und Maus bewegen = Würfel drehen")
		EndIf
	EndProcedure
	
	Procedure kante_drehen()

		Select kante
			Case #oben
				;{
				Select position_aktuell
					Case 3, 21, 46, 30 
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(56), 0,i,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
    					
							i + deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(56), 0, 0, 0)
						
						zwischendaten()
						
						; Daten im Array ändern
 						daten_wechseln(1, 28)
 						daten_wechseln(2, 29)
 						daten_wechseln(3, 30)
 						daten_wechseln(19, 1)
 						daten_wechseln(20, 2)
 						daten_wechseln(21, 3)
 						daten_wechseln(28, 48)
 						daten_wechseln(29, 47)
 						daten_wechseln(30, 46)
 						daten_wechseln(46, 21)
 						daten_wechseln(47, 20)
 						daten_wechseln(48, 19)
 						
 						daten_wechseln(10, 12)
 						daten_wechseln(11, 15)
 						daten_wechseln(12, 18)
 						daten_wechseln(13, 11)
 						daten_wechseln(15, 17)
 						daten_wechseln(16, 10)
 						daten_wechseln(17, 13)
 						daten_wechseln(18, 16)	
					
					Case 1, 28, 48, 19
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(56), 0, -i,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(56), 0, 0, 0)
						
						zwischendaten()
						
						; Daten im Array ändern
 						daten_wechseln_b(1, 28)
 						daten_wechseln_b(2, 29)
 						daten_wechseln_b(3, 30)
 						daten_wechseln_b(19, 1)
 						daten_wechseln_b(20, 2)
 						daten_wechseln_b(21, 3)
 						daten_wechseln_b(28, 48)
 						daten_wechseln_b(29, 47)
 						daten_wechseln_b(30, 46)
 						daten_wechseln_b(46, 21)
 						daten_wechseln_b(47, 20)
 						daten_wechseln_b(48, 19)
 						
 						daten_wechseln_b(10, 12)
 						daten_wechseln_b(11, 15)
 						daten_wechseln_b(12, 18)
 						daten_wechseln_b(13, 11)
 						daten_wechseln_b(15, 17)
 						daten_wechseln_b(16, 10)
 						daten_wechseln_b(17, 13)
 						daten_wechseln_b(18, 16)
 						
					
				EndSelect
				;}
			
			Case #links
				;{
				Select position_aktuell
					Case 1, 10, 43, 52
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(57), -i,0,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    						MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(57), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
 						daten_wechseln(1, 43)
 						daten_wechseln(4, 40)
 						daten_wechseln(7, 37)
 						daten_wechseln(43, 52)
 						daten_wechseln(40, 49)
 						daten_wechseln(37, 46)
 						daten_wechseln(52, 10)
 						daten_wechseln(49, 13)
 						daten_wechseln(46, 16)
 						daten_wechseln(10, 1)
 						daten_wechseln(13, 4)
 						daten_wechseln(16, 7)
 						
 						daten_wechseln(28, 30)
 						daten_wechseln(29, 33)
 						daten_wechseln(30, 36)
 						daten_wechseln(31, 29)
 						daten_wechseln(33, 35)
 						daten_wechseln(34, 28)
 						daten_wechseln(35, 31)
 						daten_wechseln(36, 34)
					
					Case 7, 16, 37, 46
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(57), i,0,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(57), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
 						daten_wechseln_b(1, 43)
 						daten_wechseln_b(4, 40)
 						daten_wechseln_b(7, 37)
 						daten_wechseln_b(43, 52)
 						daten_wechseln_b(40, 49)
 						daten_wechseln_b(37, 46)
 						daten_wechseln_b(52, 10)
 						daten_wechseln_b(49, 13)
 						daten_wechseln_b(46, 16)
 						daten_wechseln_b(10, 1)
 						daten_wechseln_b(13, 4)
 						daten_wechseln_b(16, 7)
 						
 						daten_wechseln_b(28, 30)
 						daten_wechseln_b(29, 33)
 						daten_wechseln_b(30, 36)
 						daten_wechseln_b(31, 29)
 						daten_wechseln_b(33, 35)
 						daten_wechseln_b(34, 28)
 						daten_wechseln_b(35, 31)
 						daten_wechseln_b(36, 34)

				EndSelect
				;}
			
			Case #rechts
				;{
				Select position_aktuell
					Case 3, 12, 45, 54
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(58), -i,0,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(58), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
 						daten_wechseln(3, 45)
 						daten_wechseln(6, 42)
 						daten_wechseln(9, 39)
 						daten_wechseln(45, 54)
 						daten_wechseln(42, 51)
 						daten_wechseln(39, 48)
 						daten_wechseln(54, 12)
 						daten_wechseln(51, 15)
 						daten_wechseln(48, 18)
 						daten_wechseln(12, 3)
 						daten_wechseln(15, 6)
 						daten_wechseln(18, 9)
 						
 						daten_wechseln(19, 25)
 						daten_wechseln(20, 22)
 						daten_wechseln(21, 19)
 						daten_wechseln(22, 26)
 						daten_wechseln(24, 20)
 						daten_wechseln(25, 27)
 						daten_wechseln(26, 24)
 						daten_wechseln(27, 21)
 						
					Case 9, 18, 39, 48
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(58), i,0,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(58), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
 						daten_wechseln_b(3, 45)
 						daten_wechseln_b(6, 42)
 						daten_wechseln_b(9, 39)
 						daten_wechseln_b(45, 54)
 						daten_wechseln_b(42, 51)
 						daten_wechseln_b(39, 48)
 						daten_wechseln_b(54, 12)
 						daten_wechseln_b(51, 15)
 						daten_wechseln_b(48, 18)
 						daten_wechseln_b(12, 3)
 						daten_wechseln_b(15, 6)
 						daten_wechseln_b(18, 9)
 						
 						daten_wechseln_b(19, 25)
 						daten_wechseln_b(20, 22)
 						daten_wechseln_b(21, 19)
 						daten_wechseln_b(22, 26)
 						daten_wechseln_b(24, 20)
 						daten_wechseln_b(25, 27)
 						daten_wechseln_b(26, 24)
 						daten_wechseln_b(27, 21)

				EndSelect
				;}
			
			Case #unten
				;{
				Select position_aktuell
					Case 7, 25, 34, 54
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(55), 0,-i,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(55), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
 						daten_wechseln(7, 25)
 						daten_wechseln(8, 26)
 						daten_wechseln(9, 27)
 						daten_wechseln(25, 54)
 						daten_wechseln(26, 53)
 						daten_wechseln(27, 52)
 						daten_wechseln(54, 34)
 						daten_wechseln(53, 35)
 						daten_wechseln(52, 36)
 						daten_wechseln(34, 7)
 						daten_wechseln(35, 8)
 						daten_wechseln(36, 9)
 						
 						daten_wechseln(37, 43)
 						daten_wechseln(38, 40)
 						daten_wechseln(39, 37)
 						daten_wechseln(40, 44)
 						daten_wechseln(42, 38)
 						daten_wechseln(43, 45)
 						daten_wechseln(44, 42)
 						daten_wechseln(45, 39)
						
					
					Case 9, 27, 36, 52
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(55), 0,i,0)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn

						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(55), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
 						daten_wechseln_b(7, 25)
 						daten_wechseln_b(8, 26)
 						daten_wechseln_b(9, 27)
 						daten_wechseln_b(25, 54)
 						daten_wechseln_b(26, 53)
 						daten_wechseln_b(27, 52)
 						daten_wechseln_b(54, 34)
 						daten_wechseln_b(53, 35)
 						daten_wechseln_b(52, 36)
 						daten_wechseln_b(34, 7)
 						daten_wechseln_b(35, 8)
 						daten_wechseln_b(36, 9)
 						
 						daten_wechseln_b(37, 43)
 						daten_wechseln_b(38, 40)
 						daten_wechseln_b(39, 37)
 						daten_wechseln_b(40, 44)
 						daten_wechseln_b(42, 38)
 						daten_wechseln_b(43, 45)
 						daten_wechseln_b(44, 42)
 						daten_wechseln_b(45, 39)
		
				EndSelect
				;}
			
			Case #vorn
				;{
				Select position_aktuell
					Case 16, 36, 45, 19
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(60), 0,0,-i)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(60), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
						daten_wechseln(16, 19)
						daten_wechseln(17, 22)
						daten_wechseln(18, 25)
						daten_wechseln(19, 45)
						daten_wechseln(22, 44)
						daten_wechseln(25, 43)
						daten_wechseln(45, 36)
						daten_wechseln(44, 33)
						daten_wechseln(43, 30)
						daten_wechseln(36, 16)
						daten_wechseln(33, 17)
						daten_wechseln(30, 18)
						
						daten_wechseln(1, 3)
						daten_wechseln(2, 6)
						daten_wechseln(3, 9)
						daten_wechseln(4, 2)
						daten_wechseln(6, 8)
						daten_wechseln(7, 1)
						daten_wechseln(8, 4)
						daten_wechseln(9, 7)
					
					Case 18, 25, 43, 30
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(60), 0,0,i)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(60), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
						daten_wechseln_b(16, 19)
						daten_wechseln_b(17, 22)
						daten_wechseln_b(18, 25)
						daten_wechseln_b(19, 45)
						daten_wechseln_b(22, 44)
						daten_wechseln_b(25, 43)
						daten_wechseln_b(45, 36)
						daten_wechseln_b(44, 33)
						daten_wechseln_b(43, 30)
						daten_wechseln_b(36, 16)
						daten_wechseln_b(33, 17)
						daten_wechseln_b(30, 18)
						
						daten_wechseln_b(1, 3)
						daten_wechseln_b(2, 6)
						daten_wechseln_b(3, 9)
						daten_wechseln_b(4, 2)
						daten_wechseln_b(6, 8)
						daten_wechseln_b(7, 1)
						daten_wechseln_b(8, 4)
						daten_wechseln_b(9, 7)

				EndSelect
				;}
			
			Case #hinten
				;{
				Select position_aktuell
					Case 10, 34, 39, 21
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(59), 0,0,-i)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(59), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
						daten_wechseln(21, 39)
						daten_wechseln(24, 38)
						daten_wechseln(27, 37)
						daten_wechseln(10, 21)
						daten_wechseln(11, 24)
						daten_wechseln(12, 27)
						daten_wechseln(28, 12)
						daten_wechseln(31, 11)
						daten_wechseln(34, 10)
						daten_wechseln(37, 28)
						daten_wechseln(38, 31)
						daten_wechseln(39, 34)
						
						daten_wechseln(46, 48)
						daten_wechseln(47, 51)
						daten_wechseln(48, 54)
						daten_wechseln(49, 47)
						daten_wechseln(51, 53)
						daten_wechseln(52, 46)
						daten_wechseln(53, 49)
						daten_wechseln(54, 52)
						
						
					
					Case 12, 27, 37, 28
					  i = 0
						While i <= 90 
							MP_RotateEntity(mesh(59), 0,0,i)
							text()
							MP_RenderWorld() ; Erstelle die Welt
    					MP_Flip () ; Stelle Sie dar
							i+ deltaTurn
						Wend
						; nun haben wir dem Anwender das Drehen schön gezeigt und jetzt zurück
						MP_RotateEntity(mesh(59), 0, 0, 0)
						
						zwischendaten()
						
						; daten in Array ändern
						daten_wechseln_b(21, 39)
						daten_wechseln_b(24, 38)
						daten_wechseln_b(27, 37)
						daten_wechseln_b(10, 21)
						daten_wechseln_b(11, 24)
						daten_wechseln_b(12, 27)
						daten_wechseln_b(28, 12)
						daten_wechseln_b(31, 11)
						daten_wechseln_b(34, 10)
						daten_wechseln_b(37, 28)
						daten_wechseln_b(38, 31)
						daten_wechseln_b(39, 34)
						
						daten_wechseln_b(46, 48)
						daten_wechseln_b(47, 51)
						daten_wechseln_b(48, 54)
						daten_wechseln_b(49, 47)
						daten_wechseln_b(51, 53)
						daten_wechseln_b(52, 46)
						daten_wechseln_b(53, 49)
						daten_wechseln_b(54, 52)
			
				EndSelect
				;}
			
			
		EndSelect
	EndProcedure
	
	Procedure auswahl_back()
		For k = 1 To 54
			With daten(k)			
				If \wahl = 2
					\wahl = 0
				EndIf
				If \aktiviert = 1
					Select \farbe
						Case #gelb
							MP_EntitySetTexture(\meshnummer, aTexture(0))		
							
						Case #gruen
							MP_EntitySetTexture(\meshnummer, aTexture(1))		
								
						Case #blau
							MP_EntitySetTexture(\meshnummer, aTexture(2))
							
						Case #rot
							MP_EntitySetTexture(\meshnummer, aTexture(3))			
								
						Case #weiss
							MP_EntitySetTexture(\meshnummer, aTexture(4))
						
						Case #orange
							MP_EntitySetTexture(\meshnummer, aTexture(5))
		
					EndSelect
					\aktiviert = 0
				EndIf
			EndWith
		Next k

	EndProcedure
	
	Procedure kante_wahl()
			kopplung()
					; Zuerst bereits gewählte löschen
				auswahl_back()
		Select position_aktuell
			Case 2, 20, 29, 47
				; Rechtecke an Seitenmesh koppeln
				For k = 1 To 54
					Select k
						Case 1, 2, 3, 19, 20, 21, 28, 29, 30, 46, 47, 48, 10, 11, 12, 13, 14, 15, 16, 17, 18
							MP_EntitySetParent(daten(k)\meshnummer, mesh(56))
					EndSelect
				Next k
				; nun auswählen
				kante = #oben
				For k = 1 To 54
					With daten(k)
						If k = 1 Or k = 3 Or k = 19 Or k = 21 Or k = 28 Or k = 30 Or k = 46 Or k = 48 
							\wahl = 2
						EndIf
						If k = 1 Or k = 2 Or k = 3 Or k = 19 Or k = 20 Or k = 21 Or k = 28 Or k = 29 Or k = 30 Or k = 46 Or k = 47 Or k = 48
							Select \farbe
								Case #gelb
									MP_EntitySetTexture(\meshnummer, aTexture(6))
								
								Case #gruen
									MP_EntitySetTexture(\meshnummer, aTexture(7))
								
								Case #blau
									MP_EntitySetTexture(\meshnummer, aTexture(8))
								
								Case #rot
									MP_EntitySetTexture(\meshnummer, aTexture(9))
								
								Case #weiss
									MP_EntitySetTexture(\meshnummer, aTexture(10))
								
								Case #orange
									MP_EntitySetTexture(\meshnummer, aTexture(11))
								
								
							EndSelect
							\aktiviert = 1
						EndIf
					EndWith
				Next k
			
			Case 4, 13, 40, 49
				; Rechtecke an Seitenmesh koppeln
				For k = 1 To 54
					Select k
						Case 1, 4, 7, 10, 13, 16, 37, 40, 43, 46, 49, 52, 28, 29, 30, 31, 32, 33, 34, 35, 36
							MP_EntitySetParent(daten(k)\meshnummer, mesh(57))
					EndSelect
				Next k
				
				; nun auswählen
				kante = #links
				For k = 1 To 54
					With daten(k)
						If k = 1 Or k = 7 Or k = 10 Or k = 16 Or k = 37 Or k = 43 Or k = 46 Or k = 52
							\wahl = 2
						EndIf
						If k = 1 Or k = 4 Or k = 7 Or k = 10 Or k = 13 Or k = 16 Or k = 37 Or k = 40 Or k = 43 Or k = 46 Or k = 49 Or k = 52
							Select \farbe
								Case #gelb
									MP_EntitySetTexture(\meshnummer, aTexture(6))
								
								Case #gruen
									MP_EntitySetTexture(\meshnummer, aTexture(7))
								
								Case #blau
									MP_EntitySetTexture(\meshnummer, aTexture(8))
								
								Case #rot
									MP_EntitySetTexture(\meshnummer, aTexture(9))
								
								Case #weiss
									MP_EntitySetTexture(\meshnummer, aTexture(10))
								
								Case #orange
									MP_EntitySetTexture(\meshnummer, aTexture(11))		
								
							EndSelect
							\aktiviert = 1
						EndIf
					EndWith
				Next k
			
			Case 6, 15, 42, 51
				; Rechtecke an Seitenmesh koppeln
				For k = 1 To 54
					Select k
						Case 3, 6, 9, 12, 15, 18, 39, 42, 45, 48, 51, 54, 19, 20, 21, 22, 23, 24, 25, 26, 27
							MP_EntitySetParent(daten(k)\meshnummer, mesh(58))
					EndSelect
				Next k
				
				; nun auswählen
				kante = #rechts
				For k = 1 To 54
					With daten(k)
						If k = 3 Or k = 9 Or k = 12 Or k = 18 Or k = 39 Or k = 45 Or k = 48 Or k = 54
							\wahl = 2
						EndIf
						If k = 3 Or k = 6 Or k = 9 Or k = 12 Or k = 15 Or k = 18 Or k = 39 Or k = 42 Or k = 45 Or k = 48 Or k = 51 Or k = 54
							Select \farbe
								Case #gelb
									MP_EntitySetTexture(\meshnummer, aTexture(6))
								
								Case #gruen
									MP_EntitySetTexture(\meshnummer, aTexture(7))
								
								Case #blau
									MP_EntitySetTexture(\meshnummer, aTexture(8))
								
								Case #rot
									MP_EntitySetTexture(\meshnummer, aTexture(9))
								
								Case #weiss
									MP_EntitySetTexture(\meshnummer, aTexture(10))
								
								Case #orange
									MP_EntitySetTexture(\meshnummer, aTexture(11))						
								
							EndSelect
							\aktiviert = 1
						EndIf
					EndWith
				Next k
			
			Case 8, 26, 35, 53
				; Rechtecke an Seitenmesh koppeln
				For k = 1 To 54
					Select k
						Case 7, 8, 9, 25, 26, 27, 34, 35, 36, 52, 53, 54, 37, 38, 39, 40, 41, 42, 43, 44, 45
							MP_EntitySetParent(daten(k)\meshnummer, mesh(55))
					EndSelect
				Next k
				
				; nun auswählen
				kante = #unten
				For k = 1 To 54
					With daten(k)
						If k = 7 Or k = 9 Or k = 25 Or k = 27 Or k = 34 Or k = 36 Or k = 52 Or k = 54
							\wahl = 2
						EndIf
						If k = 7 Or k = 8 Or k = 9 Or k = 25 Or k = 26 Or k = 27 Or k = 34 Or k = 35 Or k = 36 Or k = 52 Or k = 53 Or k = 54
							Select \farbe
								Case #gelb
									MP_EntitySetTexture(\meshnummer, aTexture(6))
								
								Case #gruen
									MP_EntitySetTexture(\meshnummer, aTexture(7))
								
								Case #blau
									MP_EntitySetTexture(\meshnummer, aTexture(8))
								
								Case #rot
									MP_EntitySetTexture(\meshnummer, aTexture(9))
								
								Case #weiss
									MP_EntitySetTexture(\meshnummer, aTexture(10))
								
								Case #orange
									MP_EntitySetTexture(\meshnummer, aTexture(11))
								
								
							EndSelect
							\aktiviert = 1
						EndIf
					EndWith
				Next k
			
			Case 11, 24, 31, 38
				; Rechtecke an Seitenmesh koppeln
				For k = 1 To 54
					Select k
						Case 10, 11, 12, 21, 24, 27, 28, 31, 34, 37, 38, 39, 46, 47, 48, 49, 50, 51, 52, 53, 54
							MP_EntitySetParent(daten(k)\meshnummer, mesh(59))
					EndSelect
				Next k
				
				; nun auswählen
				kante = #hinten
				For k = 1 To 54
					With daten(k)
						If k = 10 Or k = 12 Or k = 21 Or k = 27 Or k = 28 Or k = 34 Or k = 37 Or k = 39
							\wahl = 2
						EndIf
						If k = 10 Or k = 11 Or k = 12 Or k = 21 Or k = 24 Or k = 27 Or k = 28 Or k = 31 Or k = 34 Or k = 37 Or k = 38 Or k = 39
							Select \farbe
								Case #gelb
									MP_EntitySetTexture(\meshnummer, aTexture(6))
								
								Case #gruen
									MP_EntitySetTexture(\meshnummer, aTexture(7))
								
								Case #blau
									MP_EntitySetTexture(\meshnummer, aTexture(8))
								
								Case #rot
									MP_EntitySetTexture(\meshnummer, aTexture(9))
								
								Case #weiss
									MP_EntitySetTexture(\meshnummer, aTexture(10))
								
								Case #orange
									MP_EntitySetTexture(\meshnummer, aTexture(11))
								
							EndSelect
							\aktiviert = 1
						EndIf
					EndWith
				Next k
			
			Case 17, 22, 33, 44
				; Rechtecke an Seitenmesh koppeln
				For k = 1 To 54
					Select k
						Case 16, 17, 18, 19, 22, 25, 30, 33, 36, 43, 44, 45, 1, 2, 3, 4, 5, 6, 7, 8, 9
							MP_EntitySetParent(daten(k)\meshnummer, mesh(60))
					EndSelect
				Next k

				
				; nun auswählen
				kante = #vorn
				For k = 1 To 54
					With daten(k)
						If k = 16 Or k = 18 Or k = 19 Or k = 25 Or k = 30 Or k = 36 Or k = 43 Or k = 45
							\wahl = 2
						EndIf
						If k = 16 Or k = 17 Or k = 18 Or k = 19 Or k = 22 Or k = 25 Or k = 30 Or k = 33 Or k = 36 Or k = 43 Or k = 44 Or k = 45
							Select \farbe
								Case #gelb
									MP_EntitySetTexture(\meshnummer, aTexture(6))
								
								Case #gruen
									MP_EntitySetTexture(\meshnummer, aTexture(7))
								
								Case #blau
									MP_EntitySetTexture(\meshnummer, aTexture(8))
								
								Case #rot
									MP_EntitySetTexture(\meshnummer, aTexture(9))
								
								Case #weiss
									MP_EntitySetTexture(\meshnummer, aTexture(10))
								
								Case #orange
									MP_EntitySetTexture(\meshnummer, aTexture(11))
								
								
							EndSelect
							\aktiviert = 1
						EndIf
					EndWith
				Next k
		EndSelect
	EndProcedure
	
	Procedure mesh_wahl()
		For k = 1 To 54 
			If vald_mesh = daten(k)\meshnummer
				position_aktuell = k
				If daten(k)\wahl = 1 ; Kante wählen
					kante_wahl()
					
				ElseIf daten(k)\wahl = 2 ; Kante drehen
					kante_drehen()
				EndIf
				Break
			EndIf
		Next k
	EndProcedure
	
	Procedure mischen()
		Protected oldL.i = -1
		For j = 1 To anzahl
			l = Int(Random(11) + 1)
			Select l
				Case 1,2
  				If oldL = 1 Or oldL = 2
  				  j-1
  				  Continue
  				EndIf
					kante = #oben
					position_aktuell = 2
  				kante_wahl()
					If l = 1
  					position_aktuell = 1
          Else
  					position_aktuell = 3
  				EndIf					  
  				kante_drehen()
				Case 3,4
  				If oldL = 3 Or oldL = 4
  				  j-1
  				  Continue
  				EndIf				
  				kante = #unten
					position_aktuell = 8
					kante_wahl()
					If l = 3
					  position_aktuell = 7
					Else
					  position_aktuell = 9
					EndIf
					kante_drehen()
					
				Case 5,6
  				If oldL = 5 Or oldL = 6
  				  j-1
  				  Continue
  				EndIf				
  				kante = #links
					position_aktuell = 4
					kante_wahl()
					If l = 4
					  position_aktuell = 1
					Else
					  position_aktuell = 7
					EndIf
					kante_drehen()
				
				Case 7,8
  				If oldL = 7 Or oldL = 8
  				  j-1
  				  Continue
  				EndIf
  				kante = #rechts
					position_aktuell = 6
					kante_wahl()
					If l = 4
					  position_aktuell = 3
					Else
					  position_aktuell = 9
					EndIf
					kante_drehen()
				
				Case 9,10
  				If oldL = 9 Or oldL = 10
  				  j-1
  	  		  Continue
  				EndIf			
					kante = #vorn
					position_aktuell = 17
					kante_wahl()
					If l = 4
					  position_aktuell = 16
					Else
					  position_aktuell = 18
					EndIf
					kante_drehen()
				
				Case 11,12
  				If oldL = 11 Or oldL = 12
  				  j-1
  				  Continue
  				EndIf
  				kante = #hinten
					position_aktuell = 11
					kante_wahl()
					If l = 11
					  position_aktuell = 10
					Else
					  position_aktuell = 12
					EndIf
					kante_drehen()		
				
			EndSelect
			oldL = l
			MP_DrawText (100,40,"Bin beim Mischen")
			MP_RenderWorld()
			MP_Flip()
		Next j
	EndProcedure

	
	
	;}
	
;}


;- MAIN:  Fenster und Screen
	
  fx = 800
  fy = 600
  MP_Graphics3DWindow(0,0, fx,fy , "Rubicks Cube" , 0)   
 
;- Bilder erstellen
	aImage = CreateImage(#PB_Any, 128, 128)
	For n = 0 To 5
	  Read.l aColor(n)
	  StartDrawing(ImageOutput(aImage))
	    Box(0,0,128,128,$000000)
	    Box(3, 3, 124, 124, aColor(n))
	  StopDrawing()
	  
	  aTexture(n) = MP_ImageToTexture(aImage)

	  StartDrawing(ImageOutput(aImage))
	    Box(0,0,128,128,$000000)
	    Box(10, 10, 107, 107, aColor(n))
	  StopDrawing()
	  aTexture(n+6) = MP_ImageToTexture(aImage)
	Next n
	FreeImage(aImage)
  
;}

;{ 3D erstellen
	
	; Kamera
	camera = MP_CreateCamera()
  MP_CameraSetRange(camera, 10, 200)
    
  MP_PositionEntity(camera, 0, 0, -100)
	MP_EntityLookAt(camera, 0, 0, 0)
    
	; Mesh erstellen
	    ; Rechtecke aussen
 	    For i = 1 To 54
 	    	mesh (i) = MP_CreateRectangle(10, 10, 0)
 	    Next i
 	    
	    ; Würfel Kanten, Zentrum
	    For i = 55 To 61
	    	mesh(i) = MP_CreateCube()
	    Next i
 	    
	    ;} End Mesh 
	    
	    ;{ Entity -----------------------------------------------------------------------------------------------------
	    ; erstellen
	    	For i = 1 To 9
	    		MP_EntitySetTexture(mesh(i), aTexture(0))
	    		MP_EntitySetTexture(mesh(i+9), aTexture(1))
	    		MP_EntitySetTexture(mesh(i+18), aTexture(3))
	    		MP_EntitySetTexture(mesh(i+27), aTexture(5))
	    		MP_EntitySetTexture(mesh(i+36), aTexture(2))
	    		MP_EntitySetTexture(mesh(i+45), aTexture(4))
	    	Next i

			;{ Position und Liste erstellen ##################################################
			For i = 1 To 54
					daten(i)\aktiviert = 0
			Next i
			
			
			;{ vorn --------------------------------------------------------
    	    MP_PositionEntity(mesh(1), -10, 10, -15)	; vorn oben links
    	    With daten(1) 
    	    	\meshnummer = mesh(1)
    	    	\farbe = #gelb
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(2), 0, 10, -15)	; vorn oben mitte
    	    With daten(2) 
    	    	\meshnummer = mesh(2)
    	    	\farbe = #gelb
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(3), 10, 10, -15)	; vorn oben rechts
    	    With daten(3) 
    	    	\meshnummer = mesh(3)
    	    	\farbe = #gelb
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(4), -10, 0, -15)	; vorn mitte links
    	    With daten(4) 
    	    	\meshnummer = mesh(4)
    	    	\farbe = #gelb
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(5), 0, 0, -15)		; vorn mitte
    	    With daten(5) 
    	    	\meshnummer = mesh(5)
    	    	\farbe = #gelb
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(6), 10, 0, -15)	; vorn mitte rechts
    	    With daten(6) 
    	    	\meshnummer = mesh(6)
    	    	\farbe = #gelb
    	    	\wahl = 1
    	    EndWith
    	    MP_PositionEntity(mesh(7), -10, -10, -15)	; vorn unten links
    	    With daten(7) 
    	    	\meshnummer = mesh(7)
    	    	\farbe = #gelb
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(8), 0, -10, -15)	; vorn unten mitte
    	    With daten(8) 
    	    	\meshnummer = mesh(8)
    	    	\farbe = #gelb
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(9), 10, -10, -15)	; vorn unten rechts
			With daten(9) 
    	    	\meshnummer = mesh(9)
    	    	\farbe = #gelb
    	    	\wahl = 0
    	    EndWith
    	    ;}
    	    
    	    ;{ oben -----------------------------------------------------------------
    	    
    	    MP_RotateEntity(mesh(10), 90, 0, 0)
    	    MP_PositionEntity(mesh(10), -10, 15, 10)	; oben hinten links
    	    With daten(10) 
    	    	\meshnummer = mesh(10)
    	    	\farbe = #gruen
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(11), 90, 0, 0)
    	    MP_PositionEntity(mesh(11), 0, 15, 10)		; oben hinten mitte
    	    With daten(11) 
    	    	\meshnummer = mesh(11)
    	    	\farbe = #gruen
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(12), 90, 0, 0)
    	    MP_PositionEntity(mesh(12), 10, 15, 10)	; oben hinten rechts
    	    With daten(12) 
    	    	\meshnummer = mesh(12)
    	    	\farbe = #gruen
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(13), 90, 0, 0)
    	    MP_PositionEntity(mesh(13), -10, 15, 0)	; oben mitte links
    	    With daten(13) 
    	    	\meshnummer = mesh(13)
    	    	\farbe = #gruen
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(14), 90, 0, 0)
    	    MP_PositionEntity(mesh(14), 0, 15, 0)	; oben mitte
    	    With daten(14) 
    	    	\meshnummer = mesh(14)
    	    	\farbe = #gruen
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(15), 90, 0, 0)
    	    MP_PositionEntity(mesh(15), 10, 15, 0)	; oben mitte rechts
    	    With daten(15) 
    	    	\meshnummer = mesh(15)
    	    	\farbe = #gruen
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(16), 90, 0, 0)
    	    MP_PositionEntity(mesh(16), -10, 15, -10)	; oben vorn links
    	    With daten(16) 
    	    	\meshnummer = mesh(16)
    	    	\farbe = #gruen
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(17), 90, 0, 0)
    	    MP_PositionEntity(mesh(17), 0, 15, -10)	; oben vorn mitte
    	    With daten(17) 
    	    	\meshnummer = mesh(17)
    	    	\farbe = #gruen
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(18), 90, 0, 0)
    	    MP_PositionEntity(mesh(18), 10, 15, -10)	; oben vorn rechts
			With daten(18) 
    	    	\meshnummer = mesh(18)
    	    	\farbe = #gruen
    	    	\wahl = 0
    	    EndWith
    	    ;}
    	    
    	    ;{ rechts -----------------------------------------------------------
    	    
    	    MP_RotateEntity(mesh(19), 0, 90, 0)
    	    MP_PositionEntity(mesh(19), 15, 10, -10)	; rechts vorn oben
    	    With daten(19) 
    	    	\meshnummer = mesh(19)
    	    	\farbe = #rot
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(20), 0, 90, 0)
    	    MP_PositionEntity(mesh(20), 15, 10, 0)	; rechts mitte oben
    	    With daten(20) 
    	    	\meshnummer = mesh(20)
    	    	\farbe = #rot
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(21), 0, 90, 0)
    	    MP_PositionEntity(mesh(21), 15, 10, 10)	; rechts hinten oben
    	    With daten(21) 
    	    	\meshnummer = mesh(21)
    	    	\farbe = #rot
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(22), 0, 90, 0)
    	    MP_PositionEntity(mesh(22), 15, 0, -10)	; rechts vorn mitte
    	    With daten(22) 
    	    	\meshnummer = mesh(22)
    	    	\farbe = #rot
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(23), 0, 90, 0)
    	    MP_PositionEntity(mesh(23), 15, 0, 0)	; rechts mitte
    	    With daten(23) 
    	    	\meshnummer = mesh(23)
    	    	\farbe = #rot
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(24), 0, 90, 0)
    	    MP_PositionEntity(mesh(24), 15, 0, 10)		; rechts hinten mitte
    	    With daten(24) 
    	    	\meshnummer = mesh(24)
    	    	\farbe = #rot
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(25), 0, 90, 0)
    	    MP_PositionEntity(mesh(25), 15, -10, -10)	; rechts vorn unten
    	    With daten(25) 
    	    	\meshnummer = mesh(25)
    	    	\farbe = #rot
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(26), 0, 90, 0)
    	    MP_PositionEntity(mesh(26), 15, -10, 0)	; rechts mitte unten
    	    With daten(26) 
    	    	\meshnummer = mesh(26)
    	    	\farbe = #rot
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(27), 0, 90, 0)
    	    MP_PositionEntity(mesh(27), 15, -10, 10)	; rechts hinten unten
    	    With daten(27) 
    	    	\meshnummer = mesh(27)
    	    	\farbe = #rot
    	    	\wahl = 0
    	    EndWith
    	    ;}
    	    
    	    ;{ links -------------------------------------------------------------
			
			MP_RotateEntity(mesh(28), 0, 90, 0)
			MP_PositionEntity(mesh(28), -15, 10, 10)	; links hinten oben
    	    With daten(28) 
    	    	\meshnummer = mesh(28)
    	    	\farbe = #orange
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(29), 0, 90, 0)
    	    MP_PositionEntity(mesh(29), -15, 10, 0)	; links mitte oben
    	    With daten(29) 
    	    	\meshnummer = mesh(29)
    	    	\farbe = #orange
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(30), 0, 90, 0)	
    	    MP_PositionEntity(mesh(30), -15, 10, -10)	; links vorn oben
	    	With daten(30) 
    	    	\meshnummer = mesh(30)
    	    	\farbe = #orange
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(31), 0,90, 0)
	    	MP_PositionEntity(mesh(31), -15, 0, 10)	; links hinten mitte
    	    With daten(31) 
    	    	\meshnummer = mesh(31)
    	    	\farbe = #orange
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(32), 0, 90 ,0)
    	    MP_PositionEntity(mesh(32), -15, 0, 0)	; links mitte
    	    With daten(32) 
    	    	\meshnummer = mesh(32)
    	    	\farbe = #orange
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(33), 0, 90, 0)
    	    MP_PositionEntity(mesh(33), -15, 0, -10)	; links vorn mitte
    	    With daten(33) 
    	    	\meshnummer = mesh(33)
    	    	\farbe = #orange
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(34), 0, 90, 0)
    	    MP_PositionEntity(mesh(34), -15, -10, 10)	; links hinten unten
    	    With daten(34) 
    	    	\meshnummer = mesh(34)
    	    	\farbe = #orange
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(35), 0, 90, 0)
    	    MP_PositionEntity(mesh(35), -15, -10, 0) ; links mitte unten
    	    With daten(35) 
    	    	\meshnummer = mesh(35)
    	    	\farbe = #orange
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(36), 0, 90, 0)
    	    MP_PositionEntity(mesh(36), -15, -10, -10); links vorn unten
    	    With daten(36) 
    	    	\meshnummer = mesh(36)
    	    	\farbe = #orange
    	    	\wahl = 0
    	    EndWith
    	    ;}
    	    
    	    ;{ unten -------------------------------------------------------------
    	    
    	    MP_RotateEntity(mesh(37), 90, 0, 0)
    	    MP_PositionEntity(mesh(37), -10, -15, 10)	; unten hinten links
    	    With daten(37) 
    	    	\meshnummer = mesh(37)
    	    	\farbe = #blau
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(38), 90, 0, 0)
    	    MP_PositionEntity(mesh(38), 0, -15, 10)	; unten hinten mitte
    	    With daten(38) 
    	    	\meshnummer = mesh(38)
    	    	\farbe = #blau
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(39), 90, 0, 0)
    	    MP_PositionEntity(mesh(39), 10, -15, 10)	; unten hinten rechts
    	    With daten(39) 
    	    	\meshnummer = mesh(39)
    	    	\farbe = #blau
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(40), 90, 0, 0)
    	    MP_PositionEntity(mesh(40), -10, -15, 0)	; unten mitte links
    	    With daten(40) 
    	    	\meshnummer = mesh(40)
    	    	\farbe = #blau
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(41), 90, 0, 0)
    	    MP_PositionEntity(mesh(41), 0, -15, 0)	; unten mitte
    	    With daten(41) 
    	    	\meshnummer = mesh(41)
    	    	\farbe = #blau
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(42), 90, 0, 0)
    	    MP_PositionEntity(mesh(42), 10, -15, 0)	; unten mitte rechts
    	    With daten(42) 
    	    	\meshnummer = mesh(42)
    	    	\farbe = #blau
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(43), 90, 0, 0)
    	    MP_PositionEntity(mesh(43), -10, -15, -10); unten vorn links
			With daten(43) 
    	    	\meshnummer = mesh(43)
    	    	\farbe = #blau
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(44), 90, 0, 0)
    	    MP_PositionEntity(mesh(44), 0, -15, -10)	; unten vorn mitte
    	    With daten(44) 
    	    	\meshnummer = mesh(44)
    	    	\farbe = #blau
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_RotateEntity(mesh(45), 90, 0, 0)
    	    MP_PositionEntity(mesh(45), 10, -15, -10)	; unten vorn rechts
    	    With daten(45) 
    	    	\meshnummer = mesh(45)
    	    	\farbe = #blau
    	    	\wahl = 0
    	    EndWith
    	    ;}
    	    
    	    ;{ hinten --------------------------------------------------------------
    	    
    	    MP_PositionEntity(mesh(46), -10, 10, 15)	; hinten oben links
    	    With daten(46) 
    	    	\meshnummer = mesh(46)
    	    	\farbe = #weiss
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(47), 0, 10, 15)		; hinten oben mitte
    	    With daten(47) 
    	    	\meshnummer = mesh(47)
    	    	\farbe = #weiss
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(48), 10, 10, 15)	; hinten oben rechts
    	    With daten(48) 
    	    	\meshnummer = mesh(48)
    	    	\farbe = #weiss
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(49), -10, 0, 15)	; hinten mitte links
    	    With daten(49) 
    	    	\meshnummer = mesh(49)
    	    	\farbe = #weiss
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(50), 0, 0, 15)		; hinten mitte
    	    With daten(50) 
    	    	\meshnummer = mesh(50)
    	    	\farbe = #weiss
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(51), 10, 0, 15)		; hinten mitte rechts
    		With daten(51) 
    	    	\meshnummer = mesh(51)
    	    	\farbe = #weiss
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(52), -10, -10, 15)	; hinten unten links
   	    	With daten(52) 
    	    	\meshnummer = mesh(52)
    	    	\farbe = #weiss
    	    	\wahl = 0
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(53), 0, -10, 15)	; hinten unten mitte
   	    	With daten(53) 
    	    	\meshnummer = mesh(53)
    	    	\farbe = #weiss
    	    	\wahl = 1
    	    EndWith
    	    
    	    MP_PositionEntity(mesh(54), 10, -10, 15) 	; hinten unten rechts
	    	With daten(54) 
    	    	\meshnummer = mesh(54)
    	    	\farbe = #weiss
    	    	\wahl = 0
    	    EndWith
    	    ;}
    	    ;}
	    	
	    	; einmal komplette Daten kopieren
	    	For k = 1 To 54
	    		With daten_mellan(k)
	    			\meshnummer = daten(k)\meshnummer
	    			\farbe = daten(k)\farbe
	    			\aktiviert = daten(k)\aktiviert
	    			\wahl = daten(k)\wahl
	    		EndWith
	    	Next k

	    ;}
	
		;{ Kopplungen -------------------------------------------------------------------------------------------------
		kopplung()
    

    MP_RotateEntity (mesh(61),26,26,0) 
    programmstart = 1

;}

;{ Schleife
	While Not MP_KeyDown(#PB_Key_Escape) And Not WindowEvent() = #PB_Event_CloseWindow; Esc abfrage oder Window Schliessen

 		; Auswählen
 		If MP_MouseButtonDown(0) ; Linke Maustaste gedrückt?
   		 	If GetFocus_()=WindowID(0) ; Fenster aktiv? 
         	vald_mesh = MP_PickCamera (camera ,WindowMouseX(0) ,WindowMouseY(0))
				 If vald_mesh
             mesh_wahl()    	
				EndIf
			EndIf
		EndIf
    	
    ; Würfel bewegen
  	If MP_MouseButtonDown(1)
		  x = -MP_MouseDeltaX()/2
   		y = -MP_MouseDeltaY()/2
  	EndIf
  
    MP_TurnEntity(mesh(61), x, y, 0)
    
    text()	
 		
    MP_RenderWorld() ; Erstelle die Welt
    MP_Flip () ; Stelle Sie dar
		

		If programmstart
			; mischen gewünscht
			If MessageRequester("Mischen gewünscht", "Klick auf ja, wenn der Würfel ein wenig durcheinandergebracht werden soll", #PB_MessageRequester_YesNo | #MB_ICONQUESTION) = #PB_MessageRequester_Yes
				deltaTurn = 20
				mischen()
				deltaTurn = 5
			EndIf
				
			programmstart = 0
		EndIf
		
	Wend

	End
;}
DataSection
  Colors: ; Yellow,  Green,  Blue,  Red,  White, Orange
  Data.l $00FFFF,  $00FF00, $0000FF, $FF0000, $FFFFFF, $0179EF

EndDataSection


; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 1114
; FirstLine = 1032
; Folding = 6-----
; EnableAsm
; SubSystem = dx9
; DisableDebugger
; CompileSourceDirectory
; Manual Parameter S=DX9
; EnableCustomSubSystem
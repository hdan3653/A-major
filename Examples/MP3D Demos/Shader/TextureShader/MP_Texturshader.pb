;-
;- ProgrammStart
;////////////////////////////////////////////////////////////////
;//
;// Project Title: MP 3D Engine
;// File Title: MP_TexturShader.pb
;// Created On: 14.1.2009
;// Updated On: 
;// Author: Michael Paulwitz
;// OS:Windows
;// 
;// Demofile for Texturshader 
;// 
;////////////////////////////////////////////////////////////////

If CreatePopupMenu(0)
  MenuItem( 1, "Easy Color Demo")
  MenuItem( 2, "4 side Color Demo")
  MenuItem( 3, "Color Demo with Lines")
  MenuItem( 4, "Mandelbrot Demo")
  MenuItem( 5, "Mandelbrot Demo with Var")
  MenuItem( 6, "Sinus/Cos Demo")
  MenuItem( 7, "Easy Sin Cos 2 Demo")
  MenuItem( 8, "Noise Shader")
  MenuItem( 9, "Circle Shader")
  MenuItem( 10, "Circle Shader with Noise Shader and Var")
  MenuBar()
  MenuItem( 20, "Quit")
EndIf

If MP_Graphics3D (940,497,0,2); Create 3D Fenster/Windows
 

      SetWindowTitle(0, "MPs Shader Textur Testprogram V 0.2") 
      Editor_0 = EditorGadget(#PB_Any, 550, 210, 380, 280)
      GadgetToolTip(Editor_0, "Write you own Shader")
      Button_0 = ButtonGadget(#PB_Any, 800, 170, 120, 30, "Start")
      GadgetToolTip(Button_0, "Start the compiled Shader")
      Button_1 = ButtonGadget(#PB_Any, 550, 10, 120, 20, "Load Textur Left")
      GadgetToolTip(Button_1, "Load Texture for the left Mesh")
      Button_2 = ButtonGadget(#PB_Any, 550, 40, 120, 20, "Load Textur Right")
      GadgetToolTip(Button_2, "Load Texture for the right Mesh")
      Button_3 = ButtonGadget(#PB_Any, 550, 70, 120, 20, "Save Textur Right")
      GadgetToolTip(Button_3, "Save Texture for the right Mesh, the result of the shader")
      Button_4 = ButtonGadget(#PB_Any, 550, 120, 120, 20, "Load Demo Shader")
      GadgetToolTip(Button_4, "Demo Examples of Shaders to load")
      Button_5 = ButtonGadget(#PB_Any, 550, 150, 120, 20, "Load Shader")
      GadgetToolTip(Button_5, "Load a Textur Shader as ASCII fx file")
      Button_6 = ButtonGadget(#PB_Any, 550, 180, 120, 20, "Save Shader")
      GadgetToolTip(Button_6, "Save a Textur Shader as ASCII fx file")
      Button_7 = ButtonGadget(#PB_Any, 680, 180, 100, 20, "Compile")
      GadgetToolTip(Button_7, "Compile the Shader from the Editor Gadget")
      Text_0 = TextGadget(#PB_Any, 740, 10, 220, 20, "Left      Mesh      Shader.Variable")
      Text_1 = TextGadget(#PB_Any, 680, 30, 50, 20, "Cube")
      Radio_0 = OptionGadget(#PB_Any, 740, 30, 20, 20, "")
      GadgetToolTip(Radio_0, "Change Mesh to Cube")
      Radio_1 = OptionGadget(#PB_Any, 740, 60, 20, 20, "")
      GadgetToolTip(Radio_1, "Change Mesh to Sphere")
      Radio_2 = OptionGadget(#PB_Any, 740, 90, 20, 20, "")
      GadgetToolTip(Radio_2, "Change Mesh to Teapot")
      SetGadgetState(Radio_0 , 1)
      Text_2 = TextGadget(#PB_Any, 680, 60, 60, 20, "Sphere")
      Radio_3 = OptionGadget(#PB_Any, 780, 30, 20, 20, "")
      GadgetToolTip(Radio_3, "Change Mesh to Cube")
      Radio_4 = OptionGadget(#PB_Any, 780, 60, 20, 20, "")
      GadgetToolTip(Radio_4, "Change Mesh to Sphere")
      Radio_5 = OptionGadget(#PB_Any, 780, 90, 20, 20, "")
      GadgetToolTip(Radio_5, "Change Mesh to Teapot")
      SetGadgetState(Radio_3 , 1)
      Text_3 = TextGadget(#PB_Any, 680, 90, 40, 20, "Teapot")
      Text_4 = TextGadget(#PB_Any, 680, 120, 40, 20, "Move")
      Text_5 = TextGadget(#PB_Any, 680, 150, 100, 20, "Cycle Bkgr.")
      CheckBox_0 = CheckBoxGadget(#PB_Any, 740, 120, 40, 20, "")
      GadgetToolTip(CheckBox_0, "Move the left Mesh")
      CheckBox_1 = CheckBoxGadget(#PB_Any, 780, 120, 40, 20, "")
      GadgetToolTip(CheckBox_1, "Move the right Mesh")
      CheckBox_2 = CheckBoxGadget(#PB_Any, 740, 150, 40, 20, "")
      GadgetToolTip(CheckBox_2, "Change the Colour of the Background")

      TrackBar_0 = TrackBarGadget(#PB_Any, 810,  30, 100, 20, 0, 20,#PB_TrackBar_Ticks)
      GadgetToolTip(TrackBar_0, "Change the Var1 from 0 (left) to 1( right) for Shader")
      SetGadgetState(TrackBar_0, 10)
      Text_6 = TextGadget(#PB_Any, 910, 30, 40, 20, "Var1")

      TrackBar_1 = TrackBarGadget(#PB_Any, 810,  60, 100, 20, 0, 20,#PB_TrackBar_Ticks)
      GadgetToolTip(TrackBar_1, "Change the Var2 from 0 (left) to 1( right) for Shader")
      SetGadgetState(TrackBar_1, 10)
      Text_7 = TextGadget(#PB_Any, 910, 60, 40, 20, "Var2")

      TrackBar_2 = TrackBarGadget(#PB_Any, 810,  90, 100, 20, 0, 20,#PB_TrackBar_Ticks)
      GadgetToolTip(TrackBar_2, "Change the Var2 from 0 (left) to 1( right) for Shader")
      SetGadgetState(TrackBar_2, 10)
      Text_8 = TextGadget(#PB_Any, 910, 90, 40, 20, "Var3")

      TrackBar_3 = TrackBarGadget(#PB_Any, 810,  120, 100, 20, 0, 20,#PB_TrackBar_Ticks)
      GadgetToolTip(TrackBar_3, "Change the Var4 from 0 (left) to 1( right) for Shader")
      SetGadgetState(TrackBar_3, 10)
      Text_9 = TextGadget(#PB_Any, 910, 120, 40, 20, "Var4")

      MP_Viewport(2,2,535,492)
;      MP_Viewport(RGB(236,233,216),2,2,535,492)
Else 

  End ; Kann Fenster nicht erstellen/Cant Create Windows

EndIf 

camera=MP_CreateCamera() ; Kamera erstellen / Create Camera
light=MP_CreateLight(1) ; Es werde Licht / Light on

Mesh1 = MP_CreateCube()
Textur1 =  MP_CreateTextureColor(512, 512,RGB(Random(255),Random(255),Random(255)))
MP_EntitySetTexture(Mesh1, Textur1) 

Mesh2 = MP_CreateCube()
Textur2 =  MP_CreateTextureColor(512, 512,MP_ARGB(30,255,255,255))
MP_EntitySetTexture(Mesh2, Textur2) 

x.f=0 : y.f=0 : z.f=4 



While Not MP_KeyDown(#PB_Key_Escape) ; Esc abfrage / SC pushed?
 Select WindowEvent()
       Case #PB_Event_Menu
      
        Select EventMenu()  ; To see which menu has been selected

          Case 1 ; Easy Color Demo
          
            Restore DemoShader1
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)                
            AddGadgetItem(Editor_0, 0,MyEffect) 

          Case 2 ; 4 side color

            Restore DemoShader2
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)                
            AddGadgetItem(Editor_0, 0,MyEffect) 
         
          Case 3 ; Texture with lines

            Restore DemoShader3
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)               
            AddGadgetItem(Editor_0, 0,MyEffect) 

          Case 4 ; Mandelbrot

            Restore DemoShader4
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)             
            AddGadgetItem(Editor_0, 0,MyEffect)           

          Case 5 ; Mandelbrot with var

            Restore DemoShader5
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)             
            AddGadgetItem(Editor_0, 0,MyEffect)   
           
           Case 6 ; Sin/Cos Demo

            Restore DemoShader6
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)             
            AddGadgetItem(Editor_0, 0,MyEffect)            

           Case 7 ; Sin/Cos 2 Demo

            Restore DemoShader7
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)             
            AddGadgetItem(Editor_0, 0,MyEffect)
            
           Case 8 ; NoiseShader

            Restore DemoShader8
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)             
            AddGadgetItem(Editor_0, 0,MyEffect)

           Case 9 ; CircleShader

            Restore DemoShader9
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)             
            AddGadgetItem(Editor_0, 0,MyEffect)

           Case 10 ; CircleShader and  NoiseShader and Var

            Restore DemoShader10
            MyEffect.s = ""
            Read.s Purestring.s
            Repeat
                 MyEffect.s + Purestring.s + Chr(10) 
                 Read.s Purestring.s
            Until Purestring.s  = "End"
            ClearGadgetItems(Editor_0)             
            AddGadgetItem(Editor_0, 0,MyEffect)
       
           Case 20 ; Quit
            Quit = 1

        EndSelect
       Case #PB_Event_Gadget
        Select EventGadget()
         
          Case Button_7              

               MyEffect.s = GetGadgetText(Editor_0) 
               MyTextureShader = MP_CreateTextureShader(MyEffect.s)
               Debug MyTextureShader 
               If MyTextureShader
                  MP_Requester("Shader message", "File was successful compiled", 1) 
               Else
                  MessageRequester("TexturShader Error", MP_GetLastError()) 
               EndIf 
         
          Case Button_0
              MyEffect.s = GetGadgetText(Editor_0) 
              StartTime = ElapsedMilliseconds()  
              
              
              Var1.f = GetGadgetState(TrackBar_0)/20 
              MP_TextureShaderSetVar_f(MyTextureShader,"Var1",Var1)
              
              Var2.f = GetGadgetState(TrackBar_1)/20 
              MP_TextureShaderSetVar_f (MyTextureShader,"Var2",Var2)
             
              Var3.f = GetGadgetState(TrackBar_2)/20 
              MP_TextureShaderSetVar_f (MyTextureShader,"Var3",Var3)

              Var4.f = GetGadgetState(TrackBar_3)/20 
              MP_TextureShaderSetVar_f (MyTextureShader,"Var4",Var4)

;             MP_TextureShaderSetVar_i (MyTextureShader,"Tex1",Textur2)
;             MP_TextureShaderSetVar_i (MyTextureShader,"Tex2",Textur2)
              
              If Not MP_UseTextureShader(MyTextureShader,Textur2)
                 MessageRequester("Shader error message", "No Shader effekt, please recompile your shader, it does not work", #PB_MessageRequester_Ok)
              EndIf

              ElapsedTime = ElapsedMilliseconds()-StartTime 
              SetWindowTitle(0, "MPs Shader Textur Testprogram V 0.2 - Shader calculation time in ms "+StrF(ElapsedTime)) 
         
          Case Button_1
              Pattern$ = "Image Files (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              directory$ = "C:\Programme\PureBasic\media\" 
              File.s = OpenFileRequester("Load Textur1", directory$, Pattern$,  0) 
              If File
                 MP_FreeTexture (Textur1)
                 Texture1 =  MP_LoadTexture(File.s)
                 MP_EntitySetTexture(Mesh1, Textur1) 
              EndIf
          Case Button_2
              Pattern$ = "Image Files (bmp,jpg,tga,png,dds,ppm,dib,hdr,pfm|*.bmp;*.jpg;*.tga;*.png;*.dds;*.ppm;*.dib;*.hdr;*.pfm" 
              directory$ = "C:\Programme\PureBasic\media\" 
              File.s = OpenFileRequester("Load Textur3", directory$, Pattern$,  0) 
              If File
                 MP_FreeTexture (Textur2)
                 Texture2 =  MP_LoadTexture(File.s)
                 MP_EntitySetTexture(Mesh2, Textur2) 
              EndIf
          Case Button_3
              File.s = SaveFileRequester("Save Textur as JPG", "Textur.jpg", "Textur Files(*.jpg)|*.jpg",  0)
              If File
                 MP_SaveTexture (File, Textur2 , 1)
              EndIf
          Case Button_4
              ;MessageRequester("Info", "Demo Shader comming soon", #PB_MessageRequester_Ok)
              DisplayPopupMenu(0, WindowID(0))
          Case Button_5
             ; directory$ = "C:\Programme\PureBasic\media\" 
              File.s = OpenFileRequester("Load Shader FX File", "", "Shader File (fx)|*.fx",  0) 
              If File
                If ReadFile(0,  File)   ; wenn die Datei geöffnet werden konnte, setzen wir fort...
                  MyEffect.s = ""
                  While Eof(0) = 0           ; sich wiederholende Schleife bis das Ende der Datei ("end of file") erreicht ist
                    MyEffect.s + ReadString(0) + Chr(10)      ; Zeile für Zeile im Debugger-Fenster anzeigen
                  Wend
                  CloseFile(0)
                  ClearGadgetItems(Editor_0)                ; schließen der zuvor geöffneten Datei
                  AddGadgetItem(Editor_0, 0,MyEffect) 
                EndIf
              EndIf
          Case Button_6
              File.s = SaveFileRequester("Save Shader File", "Shader.fx", "Shader Files (*.fx)|*.fx",  0)
              If File
                  ;Debug file
                  MyEffect.s = GetGadgetText(Editor_0) 
                  If CreateFile(0, File)
                     WriteString(0, MyEffect)
                     CloseFile(0)
                  EndIf
              EndIf
          Case Radio_0
              MP_FreeEntity (Mesh1)
              Mesh1 = MP_CreateCube()
              MP_EntitySetTexture(Mesh1, Textur1) 
          Case Radio_1
              MP_FreeEntity (Mesh1)
              Mesh1 = MP_CreateSphere(20)
              MP_ScaleEntity (Mesh1,0.6,0.6,0.6) 
              MP_EntitySetTexture(Mesh1, Textur1)
          Case Radio_2
              MP_FreeEntity (Mesh1)
              Mesh1 = MP_CreateTeapot()
              MP_ScaleEntity (Mesh1,0.6,0.6,0.6) 
              MP_EntitySetTexture(Mesh1, Textur1) 
          Case Radio_3
              MP_FreeEntity (Mesh2)
              Mesh2 = MP_CreateCube()
              MP_EntitySetTexture(Mesh2, Textur2) 
          Case Radio_4
              MP_FreeEntity (Mesh2)
              Mesh2 = MP_CreateSphere(20)
              MP_ScaleEntity (Mesh2,0.6,0.6,0.6) 
              MP_EntitySetTexture(Mesh2, Textur2)
          Case Radio_5
              MP_FreeEntity (Mesh2)
              Mesh2 = MP_CreateTeapot()
              MP_ScaleEntity (Mesh2,0.6,0.6,0.6) 
              MP_EntitySetTexture(Mesh2, Textur2) 
         EndSelect

       Case #PB_Event_CloseWindow 
         End 
 EndSelect 

    Count + 1
    If count > 256
       count = 0
       Count2 + 1
       If GetGadgetState(CheckBox_2) 
          MP_AmbientSetLight (RGB(Random(256),Random(256),Random(256)))
       Else
          MP_AmbientSetLight (0)
       EndIf   
       If Count2 = 10
          Count2 = 0
          MP_AmbientSetLight (0)
       EndIf 
    EndIf

    MP_PositionEntity (Mesh1,-0.8,0,z) 
    If GetGadgetState(CheckBox_0) : MP_TurnEntity (Mesh1,-0.1,0,0) : EndIf 

    MP_PositionEntity (Mesh2,0.8,0,z) 
    If GetGadgetState(CheckBox_1) : MP_TurnEntity (Mesh2,-0.1,0,0) : EndIf 
  
    MP_DrawText (10,10,"FPS: "+Str(MP_FPS()))
  
    MP_RenderWorld () 
    MP_Flip () 
Wend 

  DataSection

    DemoShader1: 
      Data.s "// Easy Color Demo use Var1/2/3"                            
      Data.s "// float4 = color (r,g,b,a) r,g,b,a = 0-1 float"
      Data.s "// float4(1,0,0,0) = red"                       
      Data.s "// float4(1,1,0,0) = yellow"                    
      Data.s "// float4(0,0,1,0) = blue"                      
      Data.s "// Var1234 comes from Purebasic, Value 0-1"     
      Data.s ""                                                
      Data.s "float Var1;"                                   
      Data.s "float Var2;"                                    
      Data.s "float Var3;"                                    
      Data.s ""                                               
      Data.s "float4 Testout( ) : COLOR"                       
      Data.s "  {"                                             
      Data.s "    return float4(Var1,Var2,Var3,0);"           
      Data.s "  };"                                           
      Data.s "End"
  
    DemoShader2: 
      Data.s "// 4 side Color Demo"                       
      Data.s "float4 Testout("                            
      Data.s "  float2 vTexCoord : POSITION) : COLOR"     
      Data.s "  {"                                        
      Data.s "    float r,g, b, xSq,ySq, a;"              
      Data.s "    xSq = 2.f*vTexCoord.x-1.f; xSq *= xSq;" 
      Data.s "    ySq = 2.f*vTexCoord.y-1.f; ySq *= ySq;" 
      Data.s "    a = sqrt(xSq+ySq);"                    
      Data.s "    if (a > 1.0f) {"                  
      Data.s "        a = 1.0f-(a-1.0f);"            
      Data.s "    }"                                    
      Data.s "    else if (a < 0.2f) {"                  
      Data.s "        a = 0.2f;"                      
      Data.s "    }"                                  
      Data.s "    r = 1-vTexCoord.x;"                   
      Data.s "    g = 1-vTexCoord.y;"                    
      Data.s "    b = vTexCoord.x;"                     
      Data.s "    return float4(r, g, b, a);"           
      Data.s "  };"                                       
      Data.s "End"
      
    DemoShader3: 
      Data.s "// Color Demo with Lines"                             
      Data.s "float4 oCol;"                                         
      Data.s "float4 Testout (float2 vTex : POSITION) : COLOR"	    
      Data.s "{"							 	                                    
      Data.s "    oCol = float4(vTex.x,vTex.x, 0, 0);"			 	      
      Data.s "    // horizontal lines"					 	                   
      Data.s "    if( (0.25 < vTex.y)  && (vTex.y < 0.30) )"	 	     
      Data.s "        {"			 				                               
      Data.s "        oCol.x = 0;"	                        		 			
      Data.s "        oCol.y = 0;"                        			 			
      Data.s "        oCol.z = 0;"			 			                        
      Data.s "        }"			 				                               
      Data.s "    else if( (0.50 < vTex.y) && (vTex.y < 0.55) )"	  	
      Data.s "        oCol.x = 0;"			 		                        
      Data.s "    else if( (0.75 < vTex.y) &&  (vTex.y < 0.80) )"		  
      Data.s "        oCol.x = 0;"			 		                        	
      Data.s "    // vertical lines"			 			                     
      Data.s "    if( (0.40 < vTex.x) && (vTex.x < 0.42) )"		      
      Data.s "        oCol.x = 0;"			 			                       
      Data.s "    else if( (0.50 < vTex.x) && (vTex.x < 0.52) )"	  	
      Data.s "        oCol.x = 0;"			 			                       
      Data.s "    else if( (0.60 < vTex.x) && (vTex.x < 0.62) )"	  	
      Data.s "        oCol.x = 0;"			 			                       
      Data.s "    else if( (0.70 < vTex.x) && (vTex.x < 0.72) )"	  
      Data.s "        oCol.x = 0;"			 			                    
      Data.s "    else if( (0.80 < vTex.x) &&  (vTex.x < 0.82) )"	   	
      Data.s "        oCol.x = 0;"			 			                       
      Data.s "    else if( (0.90 < vTex.x) &&  (vTex.x < 0.92) )"	  	
      Data.s "        oCol.x = 0;"			 			                       
      Data.s "    return oCol;"			 				                          
      Data.s "}"			 					                                       
      Data.s "End"
      		      
    DemoShader4: ; Apfelmännchen
      Data.s "#define Iterations 16"					                                
      Data.s "float2 Pan;"							                                       
      Data.s "float Zoom;"							                                       
      Data.s "float Aspect;    "						                                   
      Data.s "float4 Testout(float2 texCoord :POSITION) : COLOR0"		           
      Data.s "{"								                                              
      Data.s "Pan = float2(0.25f,0);"						                               
      Data.s "Zoom = 3;"							                                        
      Data.s "Aspect = 1;"							                                        
      Data.s "   float2 c = (texCoord - 0.5) * Zoom * float2(1, Aspect) - Pan;"	
      Data.s "   float2 v = 0;"							                                    
      Data.s "   for (int n = 0; n < Iterations; n++)"				                 
      Data.s "   {"								                                              
      Data.s "       v = float2(v.x * v.x - v.y * v.y, v.x * v.y * 2) + c;"	   
      Data.s "   }"		                                                          				
      Data.s "   return (dot(v, v) > 1) ? 1 : 0;"				                       
      Data.s "} "								                                                
      Data.s "End"

    DemoShader5: ; Apfelmännchen with var
      Data.s "// Mandelbrot Demo"                                              
      Data.s "#define Iterations 16"					                                
      Data.s "float2 Pan;"							                                        
      Data.s "float Var1;"							                                        
      Data.s "float Var2;"							                                        
      Data.s "float Var3;"							                                       
      Data.s "float Aspect;    "						                                   
      Data.s "float4 Testout(float2 texCoord :POSITION) : COLOR0"		           
      Data.s "{"								                                               
      Data.s "//Pan = float2(0.25f,0);"						                             
      Data.s "Pan = float2(Var2,Var3);"						                             
      Data.s "Aspect = 1;"							                                       
      Data.s "Var1 = Var1 * 3;"							                                    
      Data.s "   float2 c = (texCoord - 0.5) * Var1 * float2(1, Aspect) - Pan;"	
      Data.s "   float2 v = 0;"							                                    
      Data.s "   for (int n = 0; n < Iterations; n++)"				                  
      Data.s "   {"								                                              
      Data.s "       v = float2(v.x * v.x - v.y * v.y, v.x * v.y * 2) + c;"	    
      Data.s "   }"		                                                          
      Data.s "   return (dot(v, v) > 1) ? 1 : 0;"				                        
      Data.s "} "								                                                
      Data.s "End"     
      
    DemoShader6: ; Sinus/Cos Demo
      Data.s "// Sinus/Cos Demo"								                              
      Data.s "// float2 a: POSITION = Texturposition, a.x and a.y "					
      Data.s "// float4 = color (r,g,b,a)"								                 
      Data.s "// r = sin(length(a) * 100.0) * 0.5 + 0.5"								     
      Data.s "// g=sin(a.y * 50.0)"								                               
      Data.s "// b=cos(a.x * 50.0)"								                              
      Data.s "// a=0"								                                           
      Data.s ""								                                                  
      Data.s "float4 Testout(float2 a: POSITION ) : COLOR"								     
      Data.s "  {"											                                         
      Data.s "    return float4(sin(length(a) * 100.0) * 0.5 + 0.5, sin(a.y * 50.0), cos(a.x * 50.0), 1);"
      Data.s ""								                                                  
      Data.s "  };"								                                              
      Data.s "End"

    DemoShader7: ; Sinus/Cos 2 Demo 
      Data.s "// Easy Sin Cos 2 Demo"	                      				
      Data.s "// float2 a: POSITION = Texturposition, a.x and a.y "  
      Data.s "// float4 = color (r,g,b,a) "					                
      Data.s "// r = sin(a.y*6.0-1)+cos(a.x*6.0-2.5)"					      
      Data.s ""					                                            
      Data.s "float4 Testout(float2 a: POSITION ) : COLOR"					
      Data.s "  {"					                                        
      Data.s "    return float4(sin(a.y*6.0-1)+cos(a.x*6.0-2.5),0,0,0);"
      Data.s "  };"					                                      
      Data.s "End"

    DemoShader8: ; NoiseShader 
      Data.s "// Noise Shader"                            
      Data.s ""                                           
      Data.s "float4 Testout(float2 a: POSITION ) : COLOR"
      Data.s "  {" 
      Data.s "    return (noise(a*0.5)+noise(a)+noise(a*2)+noise(a*3)+noise(a*4)+noise(a*8));" 
      Data.s "  };" 
      Data.s "End"

    DemoShader9: ; Circleshader
      Data.s "// Circle Shader"
      Data.s "float4 Testout(float2 a: POSITION ) : COLOR"
      Data.s "  {"
      Data.s "    return float4(sin(length(a-0.5) * 100.0) * 0.5 + 0.5,0, 0, 1);"
      Data.s "  };"
      Data.s "End"

    DemoShader10: ; Circleshader
      Data.s "// Circle Shader and Noise Shader and Var"
      Data.s ""
      Data.s "float Var1;"
      Data.s "float Var2;"
      Data.s "float Var3;"
      Data.s ""
      Data.s "float4 Testout(float2 a: POSITION ) : COLOR"
      Data.s "  {"
      Data.s "    return float4(sin(length(a-0.5) * 100.0) * 0.5 + 0.5 + noise (a*22*Var1) ,noise (a*44*Var2), noise (a*88*Var3), 1);"
      Data.s "  };"
      Data.s "End"
      
  EndDataSection
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 99
; FirstLine = 84
; EnableAsm
; Executable = C:\MP_Texturshader.exe
; SubSystem = dx9
; DisableDebugger
; Manual Parameter S=DX9
; EnableCustomSubSystem

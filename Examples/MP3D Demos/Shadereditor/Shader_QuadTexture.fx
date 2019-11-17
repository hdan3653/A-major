//-----------------------------------------------------------------------------
//      4 Texturen mischen und bewegen 
//-----------------------------------------------------------------------------


float    time;



texture texture0; // Texture 1 laden
sampler Sampler1 = sampler_state
{  texture   = <texture0>;  };

texture texture1; // Texture 2 laden
sampler Sampler2 = sampler_state
{  texture   = <texture1>;  };

texture texture2; // Texture 3 laden
sampler Sampler3 = sampler_state
{  texture   = <texture2>;  };

texture texture3; // Texture 4 laden
sampler Sampler4 = sampler_state
{  texture   = <texture3>;  };



float4 QuadTex(float2 Tex : TEXCOORD0) : COLOR0
{   float4  Color;   float4  Color2;   float4  Color3;   float4  Color4;
    Color    = tex2D(Sampler1,   float2(Tex.x+cos(time) ,  Tex.y + (2*sin(time) )  )  );    // Texture 1 bewegen
    Color2  = tex2D(Sampler2,   float2(Tex.x,  Tex.y  +  (1*sin(time) )  )  );                   // Texture 2
    Color3  = tex2D(Sampler3,   float2(Tex.x +  (1 *  sin(time)),  Tex.y  )  );                  // Texture 3
    Color4  = tex2D(Sampler4,   float2(Tex.x +  (3 *  sin(time)),  Tex.y  )  );                  // Texture 4
    float4 col = Color*Color2-Color3+Color4;  // Alle miteinander mischen / addieren / subtrahieren
 return  col;  }




technique QuadTexture
{
    pass p1  
    {
        PixelShader = compile ps_2_0 QuadTex();
    }
}

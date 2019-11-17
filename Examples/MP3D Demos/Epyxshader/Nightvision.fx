//////////////////////////////////////
//       Night Vision               //
//          by Epyx                 //
//////////////////////////////////////

texture entSkin1;

// Variablen
int   Screen_height = 480; // Sinus höhe / Linien
float bg            = 0.1; // hintergrund beleuchtung
float hell          = 2.0; // helligkeit der Nachtsicht

sampler postTex = sampler_state
{
   texture = (entSkin1);
};


float4 MyShader( float2 Tex : TEXCOORD0 ) : COLOR0
{
    float4 Color;    
    Color = tex2D( postTex, Tex.xy);
    Color.g = Color.g*(sin(Tex.y*Screen_height)*hell)+bg;
    Color.r = 0;   
    Color.b = 0;  
    return Color;
}


technique PostProcess
{
    pass p1
    {
       VertexShader = null;
        PixelShader = compile ps_2_0 MyShader();
    }

}
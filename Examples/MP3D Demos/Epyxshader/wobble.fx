////////////////////////////////
//       Wobble shader        //
//          by Epyx           //
////////////////////////////////

texture entSkin1;

float Wobb_x = 10.0;
float Wobb_y = 10.0;

sampler postTex = sampler_state
{
   texture = (entSkin1);
};


float4 MyShader( float2 Tex : TEXCOORD0 ) : COLOR0
{
    float4 Color;    
    Tex.y = Tex.y + (sin(Tex.x * Wobb_x )*0.100);
    Tex.x = Tex.x + (cos(Tex.y * Wobb_y )*0.100);
    Color = tex2D( postTex, Tex.xy);
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
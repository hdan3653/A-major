texture entSkin1;

sampler postTex = sampler_state
{
   texture = (entSkin1);
   MinFilter = linear;
   MagFilter = linear;
   MipFilter = linear;
   AddressU = Clamp;
   AddressV = Clamp;
};


float4 MyShader( float2 Tex : TEXCOORD0 ) : COLOR0
{
    float4 Color;
    
    Color = tex2D( postTex, Tex.xy) *3;
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

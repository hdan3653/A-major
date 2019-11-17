float4   g_BaseColor = {0.0f, 0.35f, 1.0f, 1.0f};
texture  TextureA;
sampler  BaseColorSampler = sampler_state
{
    texture = <TextureA>;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
    AddressU = Clamp;
    AddressV = Clamp;
};

float4 PSPlastic(float2 Tex : TEXCOORD0) : COLOR0 
{
   return g_BaseColor * tex2D(BaseColorSampler, Tex.xy);
}

technique Plastic
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSPlastic();
    }
}




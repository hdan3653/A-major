texture TextureA;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};

float4 PSFunky(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = tex2D(Sampler1, Tex);
    Color.xy += Tex;
    Color = tex2D(Sampler1, Color);

    return Color;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSFunky();
    }
}





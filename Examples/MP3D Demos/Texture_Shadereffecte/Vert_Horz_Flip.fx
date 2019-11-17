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

float4 PSVertHorzFlip(float2 Tex : TEXCOORD0) : COLOR
{
    return tex2D(Sampler1, 1.0f - Tex);
}

technique inverse
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSVertHorzFlip();
    }
}






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

float4 PSInverse(float2 Tex : TEXCOORD0) : COLOR
{
    return 1.0f - tex2D(Sampler1, Tex);
}

technique inverse
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSInverse();
    }
}




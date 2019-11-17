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

float4 PSVignetting(float2 Tex : TEXCOORD0) : COLOR
{   
    float4 BaseColor = tex2D(Sampler1, Tex);
    float  DarkTerm  = (1.0 - 2.0 * (float2(.5, .5) - Tex)) + (1.0 - 2.0 * (float2(.5, .5) - Tex));

    return BaseColor * DarkTerm;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSVignetting();
    }
}




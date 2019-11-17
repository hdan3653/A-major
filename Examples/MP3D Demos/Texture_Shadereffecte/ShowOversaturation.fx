float   Brightness = 1.0;
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

float4 PSShowOversaturation(float2 Tex : TEXCOORD0) : COLOR
{   
    float4 BaseColor = tex2D(Sampler1, Tex) * Brightness;

    if (BaseColor.r >= 1.0 || BaseColor.g >= 1.0 || BaseColor.b >= 1.0)
        return float4(1.0, 1.0, 1.0, 1.0);
    return float4(0.0, 0.0, 0.0, 1.0);
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSShowOversaturation();
    }
}



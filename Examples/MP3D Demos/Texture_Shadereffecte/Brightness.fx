// Demo benutzt TextureA und Var1 zur Helligkeitssteuerung

float   Var1;
texture TextureA;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Point;
};

float4 PSBrightness(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = tex2D(Sampler1, Tex);
    return Color * Var1 * 4;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSBrightness();
    }
}




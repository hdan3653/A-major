float2  pixelsize    = {0.001, 0.001};
float2  Offset       = {-0.195, 0.327};
bool    bRotate      = false;
texture Texture1;
texture Texture4;
sampler Sampler1 = sampler_state
{
    texture   = <Texture1>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};
sampler Sampler4 = sampler_state
{
    texture   = <Texture4>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};

float4 PSSignature(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = tex2D(Sampler1, Tex);
    if (bRotate)
        Tex = float2(1.0 - Tex.y, Tex.x);
    float4 Mask  = tex2D(Sampler4, Tex + Offset);
   
    return Color + max(0, (0.85 - Mask));
    return Color * Mask;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSSignature();
    }
}

















































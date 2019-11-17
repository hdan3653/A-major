float3  g_LumConv = {0.213, 0.715, 0.072};
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

float4 PSMonochrome(float2 Tex : TEXCOORD0) : COLOR
{
    return float4(dot((float3)tex2D(Sampler1, Tex), g_LumConv).xxx, 1.0);
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSMonochrome();
    }
}





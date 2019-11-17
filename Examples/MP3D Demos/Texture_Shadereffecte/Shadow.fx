float2  pixelsize    = {0.001, 0.001};
float   Size         = 1.0;
float   Lerp         = 0.5;
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
float4 PSShadow(float2 Tex : TEXCOORD0) : COLOR
{   
    float4 BaseColor = tex2D(Sampler1, Tex);
    float  Scale = 1.0 / 6.0; 
    float4 ShadowTerm = (float4)0.0;
    float2 Offset     = (float2)0.0;
    for (int i = 0; i < 6; i++)
    { 
        Offset.xy = i;
        ShadowTerm += tex2D(Sampler1, Tex.xy + Offset.xy * Size * pixelsize) * Scale;
    }
    return lerp(BaseColor, ShadowTerm, Lerp);
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSShadow();
    }
}






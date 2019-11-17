float   g_fLuminance = 0.09; 
float   intensity    = 0.8;
float   scale        = 0.18;
float   offset       = 0.001;
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

float4 PSToneMap(float2 Tex : TEXCOORD) : COLOR0
{
    float4 Color;

    Color   = tex2D(Sampler1, Tex) * scale / (g_fLuminance + offset);
    Color  *= (1.0f + (Color / (intensity * intensity))) ;
    Color  /= (1.0f + Color);
    Color.a = 1.0f;

    return Color;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSToneMap();
    }
}








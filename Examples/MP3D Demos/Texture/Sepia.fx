float   g_fDesat          = 0.5;         
float   g_fToned          = 1.0;                   
float4  g_SepiaColor1     = {0.2, 0.05, 0.0, 1.0};
float4  g_SepiaColor2     = {1.0, 0.9,  0.5, 1.0};
texture Texture1;
sampler Sampler1 = sampler_state
{
    texture   = <Texture1>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};

float4 PSSepia(float2 Tex : TEXCOORD0) : COLOR
{   
    float4 BaseColor = tex2D(Sampler1, Tex);
    float  SepiaLerp = dot(float3(0.3f, 0.59f, 0.11f), BaseColor);
           BaseColor = lerp(BaseColor, SepiaLerp, g_fDesat);
    // zwischen zwei Sepia-Farben (hell und dunkel) interpolieren
    float4 Sepia     = lerp(g_SepiaColor1, g_SepiaColor2, SepiaLerp);

    return lerp(BaseColor, Sepia, g_fToned);
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSSepia();
    }
}



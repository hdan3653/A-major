// Farben
float4   g_Stone      = {1.0, 0.8, 0.5, 1.0};    // Gestein
float4   g_Diffuse    = {0.8, 0.8, 0.8, 1.0};    // Streufarbe
float4   g_Ambient    = {0.2, 0.2, 0.2, 1.0};    // Umgebungsfarbe

// Faktoren für Musterung
float    g_fStone     = 1.6f;

// Texturen
texture  TextureA;
sampler  NoiseSampler = sampler_state
{
    Texture   = <TextureA>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    AddressW  = Wrap;
    MipFilter = Linear;
    MinFilter = Linear;
    MagFilter = Linear;
};

float4 PSStone(float2 Tex : TEXCOORD0) : COLOR 
{
    float  Noise    = tex3D(NoiseSampler, float3(Tex.xy, cos(Tex.x)) * g_fStone); 
    float  Stone    = abs(0.7 - Noise);
    return g_Stone * (g_Ambient + g_Diffuse * Stone);
}

technique t1
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSStone();
    }
}



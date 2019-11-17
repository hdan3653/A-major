float    FlipPos      = 0.5;
float    BlurScale    = 4.0;
float2   pixelsize    = {0.001, 0.001};
float    g_fDistSpeed = 0.05;
float    g_fDistScale = 0.001;
float    g_fBumpHeight= 0.015;
float2   g_WaveSpeed  = {0.00003, 0.0};
float    timestamp ;

texture  Texture1;
texture  Texture2;

float2 g_Poisson[5] =
{  
    float2( 0.0,      0.0),
    float2( 0.527837,-0.085868),
    float2(-0.419418,-0.616039),
    float2( 0.440453,-0.639399),
    float2(-0.757088, 0.349334)
};

// Filtereinstellungen
sampler BumpSampler = sampler_state
{
    Texture   = <Texture1>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    MipFilter = Linear;
    MinFilter = Linear;
    MagFilter = Linear;   
};
sampler EnvSampler = sampler_state
{
    Texture   = <Texture2>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MinFilter = None;
    MagFilter = None;
};

float4 PSMirror(float2 Tex : TEXCOORD) : COLOR0
{
  
    float4 Color = (float4)0.0;

    if (Tex.y > FlipPos)
    {
        Tex.y = FlipPos + (FlipPos - Tex.y);

        float4 N1 = tex2D(BumpSampler, Tex.xy + g_WaveSpeed.xy * timestamp) * 2.0 - 1.0;
        float4 N2 = tex2D(BumpSampler, Tex.xy * 2.0 + g_WaveSpeed.xy * timestamp) * 2.0 - 1.0;
        float4 N3 = tex2D(BumpSampler, Tex.xy * 3.5 + g_WaveSpeed.xy * timestamp) * 2.0 - 1.0;
        float3 Normal = normalize(N1.xyz + N2.xyz + N3.xyz);
        Normal            = Normal * g_fBumpHeight;  
        for (int i = 0; i < 5; i++)
           Color += tex2D(EnvSampler, Tex + Normal.xy + g_Poisson[i] * BlurScale * pixelsize) * 0.2;
     } else
        Color = tex2D(EnvSampler, Tex);

    return Color;
}

technique Mirror
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSMirror();
    }
}














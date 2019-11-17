float  speed            = 0.00001;
float  speed2           = 0.000004;
float  scratchIntensity = 0.5;
float  sharpness        = 5.0;
float  timestamp        = 0.0;

float  g_fDesat         = 0.45;         
float  g_fToned         = 0.55; 
float4 g_SepiaColor1    = {0.2, 0.05, 0.0, 1.0};
float4 g_SepiaColor2    = {1.0, 0.9,  0.5, 1.0};

texture TextureA;
texture TextureB;	// Noise
sampler2D Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};
sampler2D Sampler4 = sampler_state
{
    texture   = <TextureB>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Point;
};

float4 PSScratch(float2 Tex : TEXCOORD0) : COLOR 
{
    float4 BaseColor = tex2D(Sampler1, Tex);
    float  SepiaLerp = dot(float3(0.3f, 0.59f, 0.11f), BaseColor);
    BaseColor        = lerp(BaseColor, SepiaLerp, g_fDesat);
    float4 Sepia     = lerp(g_SepiaColor1, g_SepiaColor2, SepiaLerp);

    float2 NewCoord  = float2(Tex.x + timestamp * speed2, timestamp * speed);
    float  scratch   = tex2D(Sampler4, NewCoord).x;
    scratch = 2.0 * (scratch - scratchIntensity);
    scratch = 1.0 - abs(1.0 - scratch);
    scratch = min(max(0, scratch * sharpness), 1.0);

    return lerp(BaseColor, Sepia, g_fToned) + float4(scratch.xxx, 0);
}

technique t1 
{
    pass p1
    {
	PixelShader = compile ps_2_0 PSScratch();
    }
}












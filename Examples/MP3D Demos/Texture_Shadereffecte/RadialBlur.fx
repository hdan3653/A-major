float2  pixelsize     = {0.001, 0.001};
float   g_fBlurStart  = 1.0;
float   g_fBlurWidth  = -0.05;
float2  g_BlurCenter  = float2(0.45, 0.26);
float   g_fBloomScale = 1.1;
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
const float2 g_Offsets[10] = 
{
    -0.840144, -0.073580,
    -0.695914,  0.457137,
    -0.203345,  0.620716,
     0.962340, -0.194983,
     0.473434, -0.480026,
     0.519456,  0.767022,
     0.185461, -0.893124,
     0.507431,  0.064425,
     0.896420,  0.412458,
    -0.321940, -0.932615,
};

float4 PSRadialBlur(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 SumColor = 0;
    Tex += pixelsize * 0.5 - g_BlurCenter;

    for (int i = 0; i < 12; i++) 
    {
        float scale = g_fBlurStart + g_fBlurWidth * (i / (float) (12-1));
        SumColor += tex2D(Sampler1, Tex * scale + g_BlurCenter);
    }

    return SumColor / 12.0 * g_fBloomScale;
} 

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSRadialBlur();
    }
}









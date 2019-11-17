float2  g_PixelSize       = {0.0005, 0.0005}; 
float   g_fBlurScale      = 15.0;
float   g_fBloomScale     = 1.2;
float   g_fGlowInt        = 0.6;
float   g_fSceneInt       = 0.5;

texture TextureA;
texture TextureB;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};
sampler Sampler9 = sampler_state
{
    texture   = <TextureB>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};

const float g_fBlurWeights[13] = 
{
    0.002216,  0.008764,  0.026995,  0.064759,  0.120985,  0.176033,
    0.199471,  0.176033,  0.120985,  0.064759,  0.026995,  0.008764,
    0.002216
};
const float2 g_PixelOffsetV[13] =
{
    { 0, -6 }, { 0, -5 }, { 0, -4 }, { 0, -3 }, { 0, -2 }, { 0, -1 },
    { 0,  0 }, { 0,  1 }, { 0,  2 }, { 0,  3 }, { 0,  4 }, { 0,  5 },
    { 0,  6 }
};
const float2 g_PixelOffsetH[13] =
{
    { -6, 0 }, { -5, 0 }, { -4, 0 }, { -3, 0 }, { -2, 0 }, { -1, 0 },
    {  0, 0 }, {  1, 0 }, {  2, 0 }, {  3, 0 }, {  4, 0 }, {  5, 0 },
    {  6, 0 }
};

float4 PSGaussianBlurH(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = (float4)0.0;

    for (int i = 0; i < 13; i++)
        Color += tex2D(Sampler1, Tex + float2(g_fBlurScale * g_PixelSize * g_PixelOffsetH[i])) * g_fBlurWeights[i];

    return Color * g_fBloomScale;
}
float4 PSGaussianBlurV(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = (float4)0.0;

    for (int i = 0; i < 13; i++)
        Color += tex2D(Sampler1, Tex + float2(g_fBlurScale * g_PixelSize * g_PixelOffsetV[i])) * g_fBlurWeights[i];

    return Color * g_fBloomScale;
}  
float4 PSDownFilter(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = 0;

    // 4facher Herunterskalierungsfilter
    float2 PixelCoordsDownFilter[16] =
    {
        { 1.5,  -1.5 }, { 1.5,  -0.5 }, { 1.5,   0.5 }, { 1.5,   1.5 },
        { 0.5,  -1.5 }, { 0.5,  -0.5 }, { 0.5,   0.5 }, { 0.5,   1.5 },
        {-0.5,  -1.5 }, {-0.5,  -0.5 }, {-0.5,   0.5 }, {-0.5,   1.5 },
        {-1.5,  -1.5 }, {-1.5,  -0.5 }, {-1.5,   0.5 }, {-1.5,   1.5 },
    };

    for (int i = 0; i < 16; i++)
    {
        PixelCoordsDownFilter[i] *= g_PixelSize;
        Color += tex2D(Sampler1, Tex + PixelCoordsDownFilter[i].xy );
    }

    return Color / 16;
}
float4 PSUpFilterBloom(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 ColorOrig = tex2D(Sampler1, Tex);
    float4 ColorBlur = tex2D(Sampler9, Tex);

    return float4(g_fSceneInt * ColorOrig.rgb + g_fGlowInt * ColorBlur.rgb, 1.0);
}

technique Bloom
{
    pass p1
    {
        PixelShader = compile ps_2_0 PSUpFilterBloom();
    }
}
technique DownScale
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSDownFilter();
    }
}
technique GaussianBlurH
{
    pass p1  
    {   
        PixelShader = compile ps_2_0 PSGaussianBlurH();
    }
}
technique GaussianBlurV
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSGaussianBlurV();
    }
}







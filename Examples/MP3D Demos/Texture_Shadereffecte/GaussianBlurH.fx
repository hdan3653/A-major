float2  pixelsize    = {0.001, 0.001};
float   g_fBlurScale = 10.0;
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

const float g_fBlurWeights[13] = 
{
    0.002216,  0.008764,  0.026995,  0.064759,  0.120985,  0.176033,
    0.199471,  0.176033,  0.120985,  0.064759,  0.026995,  0.008764,
    0.002216
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
        Color += tex2D(Sampler1, Tex + float2(g_fBlurScale * pixelsize * g_PixelOffsetH[i])) * g_fBlurWeights[i];
    return Color;
}

technique GaussianBlur
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSGaussianBlurH();
    }
}













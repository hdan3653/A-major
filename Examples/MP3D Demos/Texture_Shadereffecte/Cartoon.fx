float2  g_PixelSize  = {0.001, 0.001};
texture TextureA;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Point;
};
const float2 g_Filter3x3[8] = 
{
    -1.0, -1.0,
     0.0, -1.0,
     1.0, -1.0,
    -1.0,  0.0,
     1.0,  0.0,
    -1.0,  1.0,
     0.0,  1.0,
     1.0,  1.0,
};

float4 PSEdgeDetection(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = (float4)0.0;
    float2 NewTex;
    float4 TexColor[8];
    float4 VGradient;
    float4 HGradient;

    for (int i = 0; i < 8; i++)
    {
        NewTex      = Tex + g_Filter3x3[i] * g_PixelSize;
        TexColor[i] = dot(tex2D(Sampler1, NewTex), 0.333333);
    }

    VGradient = -(TexColor[0] + TexColor[5] + 2*TexColor[3]);
    VGradient += (TexColor[2] + TexColor[7] + 2*TexColor[4]);
    HGradient = -(TexColor[0] + TexColor[2] + 2*TexColor[1]);
    HGradient += (TexColor[5] + TexColor[7] + 2*TexColor[6]);

    Color  = 1.0 - sqrt(HGradient * HGradient + VGradient * VGradient);
    Color *= tex2D(Sampler1, Tex); 

    return floor(10.0 * Color) * 0.13;
}

technique GaussianBlur
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSEdgeDetection();
    }
}



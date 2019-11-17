float4  Brightness      = {1.0, 1.0, 1.0, 1.0};
float Var1;
float Var2;
float   Gamma           = 1.0;
float4  SaturationLimit = {0.9, 0.9, 0.9, 1.0};
float   SaturationExp   = 2.0;
float   BlackPoint      = 0.05;
float4  ColorOffset     = {0.0, 0.0, 0.0, 1.0};
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

float4 PSAdjust(float2 Tex : TEXCOORD0) : COLOR0
{
    float Gamma  = Var1*2;
    float SaturationExp= Var2*4;
    float4 Color  = tex2D(Sampler1, Tex);
    float4 Delta  = SaturationLimit - Color;
    float  Median = pow((max(0.0, Delta.r) + max(0.0, Delta.g) + max(0.0, Delta.b)) * 0.333333, SaturationExp);
    Color = saturate(Color - BlackPoint) * (1.0 / (1.0 - BlackPoint));
    return Color * Brightness * (1.0 + Median * (Gamma - 1.0)) + ColorOffset;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSAdjust();
    }
}




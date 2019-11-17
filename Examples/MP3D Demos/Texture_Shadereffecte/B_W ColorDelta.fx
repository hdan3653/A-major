float2  pixelsize      = {0.001, 0.001};
float4  ReferenceColor = {0.1, 0.31, 0.75, 1.0};
float   DeltaExponent  = 3.0;
float   Multiplier     = 4.0;
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

float4 PSBWColorDelta(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 OrigColor = tex2D(Sampler1, Tex);
    return max(0.0, 1.0 - (pow(abs(ReferenceColor.r - OrigColor.r), DeltaExponent) + pow(abs(ReferenceColor.g - OrigColor.g), DeltaExponent) + pow(abs(ReferenceColor.b - OrigColor.b), DeltaExponent)) * Multiplier);
}  

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_3_0 PSBWColorDelta();
    }
}












float   Sharpness  = 3.0;
float   Brightness = 1.0;
float   Offset     = -0.4;
bool    Limiter    = true;
float2  Center     = {.47, .27};
float   Exp        = 4.0;
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

float4 PSVignetting(float2 Tex : TEXCOORD0) : COLOR
{   
    float4 BaseColor = tex2D(Sampler1, Tex);
    float  DarkTerm  = abs(Center.x - Tex.x) + abs(Center.y - Tex.y);
    DarkTerm = Brightness * max(0, 1.0 - Sharpness * pow(DarkTerm, Exp) + Offset);

    if (Limiter)
        DarkTerm = min(1.0, DarkTerm);

    //return DarkTerm;
    return BaseColor * DarkTerm;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSVignetting();
    }
}





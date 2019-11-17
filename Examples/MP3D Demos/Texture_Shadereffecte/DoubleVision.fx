// Bild wird verdoppelt, zweites Bild kleiner 

float Time;
float res = 100; // Anzahl Pixel
int dirty = 20;   // Groesse Pixel

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

float4 PSDoubleVision(float2 Tex : TEXCOORD0) : COLOR
{

    float4 c =tex2D(Sampler1, Tex);   
    if (Tex.x > 0.1)
      if (Tex.x < 0.9)
        if (Tex.y > 0.1)
          if (Tex.y < 0.9)
            c += tex2D(Sampler1, -0.1 + Tex * 1.2 ) * 1.2;
    c /= 2.0f;

    return c;    
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSDoubleVision();
    }
}










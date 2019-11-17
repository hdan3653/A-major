// Benötigt TextureA + TextureB

float   PixelX       = 2.0f;
float   PixelY       = 2.0f;
float2  pixelsize    = {0.001, 0.001};
static  float DeltaX = (PixelX * pixelsize.x);
static  float DeltaY = (PixelY * pixelsize.y);
float   Freq         = 6.0f;

texture TextureA; // Bild
texture TextureB; // Noise

sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};
sampler Sampler6 = sampler_state
{
    texture   = <TextureB>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};

float4 spline(float x, 
              float4 c1,
              float4 c2, 
              float4 c3,  
              float4 c4, 
              float4 c5, 
              float4 c6, 
              float4 c7, 
              float4 c8, 
              float4 c9) 
{
    float w1 = 0, 
          w2 = 0,  
          w3 = 0,  
          w4 = 0,  
          w5 = 0,  
          w6 = 0,  
          w7 = 0,  
          w8 = 0,  
          w9 = 0;

    float tmp = x * 8.0;
    if (tmp <= 1.0) 
    {
        w1 = 1.0 - tmp;
        w2 = tmp;
    }
    else if (tmp <= 2.0) 
    {
        tmp = tmp - 1.0;
        w2  = 1.0 - tmp;
        w3  = tmp;
    }
    else if (tmp <= 3.0) 
    {
        tmp = tmp - 2.0;
        w3  = 1.0 - tmp;
        w4  = tmp;
    }
    else if (tmp <= 4.0) 
    {
        tmp = tmp - 3.0;
        w4  = 1.0 - tmp;
        w5  = tmp;
    }
    else if (tmp <= 5.0) 
    {
        tmp = tmp - 4.0;
        w5 = 1.0 - tmp;
        w6 = tmp;
    }
    else if (tmp <= 6.0) 
    {
        tmp = tmp - 5.0;
        w6  = 1.0 - tmp;
        w7  = tmp;
    }
    else if (tmp <= 7.0) 
    {
        tmp = tmp - 6.0;
        w7  = 1.0 - tmp;
        w8  = tmp;
    }
    else 
    {
        tmp = saturate(tmp - 7.0);
        w8  = 1.0 - tmp;
        w9  = tmp;
    }
    return w1 * c1 + w2 * c2 + w3 * c3 + w4 * c4 + w5 * c5 + w6 * c6 + w7 * c7 + w8 * c8 + w9 * c9;
}

float4 PSFrost(float2 Tex : TEXCOORD0) : COLOR 
{
    float2 ox = float2(DeltaX, 0.0);
    float2 oy = float2(0.0, DeltaY);
    float2 PP = Tex - oy;
    float4 C00 = tex2D(Sampler1, PP - ox);
    float4 C01 = tex2D(Sampler1, PP);
    float4 C02 = tex2D(Sampler1, PP + ox);
    PP = Tex;
    float4 C10 = tex2D(Sampler1, PP - ox);
    float4 C11 = tex2D(Sampler1, PP);
    float4 C12 = tex2D(Sampler1, PP + ox);
    PP = Tex + oy;
    float4 C20 = tex2D(Sampler1, PP - ox);
    float4 C21 = tex2D(Sampler1, PP);
    float4 C22 = tex2D(Sampler1, PP + ox);

    float n = tex3D(Sampler6, Freq * float3(Tex.xy, 0.0)).x;
    n = fmod(n, 0.111111) / 0.111111;
    float4 result = spline(n, C00, C01, C02, C10, C11, C12, C20, C21, C22);

    //float4 result = float4(n, n, n, 1.0);
    // float4 result = lerp(C00, C22, n);
    return result;
}

technique t1
{
    pass p1
    {
	PixelShader = compile ps_2_a PSFrost();
    }
}








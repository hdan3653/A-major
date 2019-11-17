float2  g_PixelSize       = {0.001, 0.001};
float   g_fPixels         = 0.8f;
float   g_fThreshold      = 0.3f;
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

float GetGray(float4 c)
{
    return(dot(c.rgb,((0.33333).xxx)));
}

float4 PSEdgeDetect(float2 Tex : TEXCOORD0) : COLOR 
{
    float2 ox = float2(g_fPixels * g_PixelSize.x,0.0);
    float2 oy = float2(0.0, g_fPixels * g_PixelSize.y);
    float2 PP = Tex - oy;
    float4 CC = tex2D(Sampler1, PP-ox); float g00 = GetGray(CC);
    CC = tex2D(Sampler1,PP);    float g01 = GetGray(CC);
    CC = tex2D(Sampler1,PP+ox); float g02 = GetGray(CC);
    PP = Tex;
    CC = tex2D(Sampler1,PP-ox); float g10 = GetGray(CC);
    CC = tex2D(Sampler1,PP);    float g11 = GetGray(CC);
    CC = tex2D(Sampler1,PP+ox); float g12 = GetGray(CC);
    PP = Tex + oy;
    CC = tex2D(Sampler1,PP-ox); float g20 = GetGray(CC);
    CC = tex2D(Sampler1,PP);    float g21 = GetGray(CC);
    CC = tex2D(Sampler1,PP+ox); float g22 = GetGray(CC);
    float K00 = -1;
    float K01 = -2;
    float K02 = -1;
    float K10 = 0;
    float K11 = 0;
    float K12 = 0;
    float K20 = 1;
    float K21 = 2;
    float K22 = 1;
    float sx = 0;
    float sy = 0;
    sx += g00 * K00;
    sx += g01 * K01;
    sx += g02 * K02;
    sx += g10 * K10;
    sx += g11 * K11;
    sx += g12 * K12;
    sx += g20 * K20;
    sx += g21 * K21;
    sx += g22 * K22; 
    sy += g00 * K00;
    sy += g01 * K10;
    sy += g02 * K20;
    sy += g10 * K01;
    sy += g11 * K11;
    sy += g12 * K21;
    sy += g20 * K02;
    sy += g21 * K12;
    sy += g22 * K22; 
    float dist = sqrt(sx*sx+sy*sy);
    float result = 1;

    if (dist > g_fThreshold) 
    { 
        result = 0; 
    }

    float3 ResColor = tex2D(Sampler1, Tex).rgb * result;

    return float4(floor(10 * ResColor.r) * 0.11, 
                  floor(10 * ResColor.g) * 0.11,
                  floor(10 * ResColor.b) * 0.11,
                  1.0);
}

technique Comic
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSEdgeDetect();
    }
}




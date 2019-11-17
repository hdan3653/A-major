float  threshhold = 0.02;
float2 pixelsize  = {0.001, 0.001};
float2 Offset     = {0.0, 0.0}; 

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

float  getGray(float4 c)
{
    return(dot(c.rgb, ((0.33333).xxx)));
}
    
float4 PSEdgeDetectNvidia(float2 Tex : TEXCOORD0) : COLOR 
{
    float2 ctr  = Tex.xy + Offset;
    float2 ox   = float2(pixelsize.x, 0.0);
    float2 oy   = float2(0.0, pixelsize.y);
    float2 UV00 = ctr - ox - oy;
    float2 UV01 = ctr - oy;
    float2 UV02 = ctr + ox - oy;
    float2 UV10 = ctr - ox;
    float2 UV12 = ctr + ox;
    float2 UV20 = ctr - ox + oy;
    float2 UV21 = ctr + oy;
    float2 UV22 = ctr + ox + oy;
    float4 CC;
    CC = tex2D(Sampler1, UV00); 
    float g00 = getGray(CC);
    CC = tex2D(Sampler1, UV01); 
    float g01 = getGray(CC);
    CC = tex2D(Sampler1, UV02); 
    float g02 = getGray(CC);
    CC = tex2D(Sampler1, UV10); 
    float g10 = getGray(CC);
    CC = tex2D(Sampler1, UV12); 
    float g12 = getGray(CC);
    CC = tex2D(Sampler1, UV20); 
    float g20 = getGray(CC);
    CC = tex2D(Sampler1, UV21); 
    float g21 = getGray(CC);
    CC = tex2D(Sampler1, UV22); 
    float g22 = getGray(CC);
    float sx = 0;
    sx -= g00;
    sx -= g01 * 2;
    sx -= g02;
    sx += g20;
    sx += g21 * 2;
    sx += g22;
    float sy = 0;
    sy -= g00;
    sy += g02;
    sy -= g10 * 2;
    sy += g12 * 2;
    sy -= g20;
    sy += g22;
    float dist = (sx * sx + sy * sy);
    float result = 1;
    if (dist > threshhold) { result = 0; }
    return result.xxxx;
}

technique t1
{
    pass p1
    {
        PixelShader = compile ps_2_0 PSEdgeDetectNvidia();
    }
}



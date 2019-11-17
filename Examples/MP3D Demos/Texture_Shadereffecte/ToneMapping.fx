float  exposure = 0.0;
float  defog    = 0.0;
float  gamma    = 1.0 / 2.2;
float3 FogColor = { 1.0, 1.0, 1.0 };
static float3 DefogColor = (defog * FogColor);

texture   TextureA;
sampler2D ImageSampler = sampler_state 
{
    Texture   = <TextureA>;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};

float4 PSTonemap(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 rgbe = tex2D(ImageSampler, Tex.xy);
    //float expScale = pow(2.0,((rgbe.a * 255)-128.0));
    float3 c = rgbe.rgb; // * expScale;
    c = c - DefogColor;
    c = max(((float3)0), c);
    c *= pow(2.0, exposure);
    // gamma correction - could use texture lookups for this
    c = pow(c, gamma);
    return float4(c.rgb, 1.0);
}

technique t1
{
    pass p1
    {
	PixelShader = compile ps_2_0 PSTonemap();
    }
}





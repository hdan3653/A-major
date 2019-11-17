float   dotsPerBit = 1.0;
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

float4 make_tones(float3 Pos)
{
    float2 delta = Pos.xy - float2(0.5, 0.5);
    float d = dot(delta, delta);
    float rSquared = (Pos.z * Pos.z) / 2.0;
    float n2 = (d < rSquared) ? 1.0 : 0.0;
    return float4(n2, n2, n2, 1.0);
    //return float4(Pos, 1.0);
}

float4 PSTone(float2 Tex : TEXCOORD0) : COLOR 
{
    float4 scnC = tex2D(Sampler1, Tex);
    float  lum  = dot(float3(0.2, 0.7, 0.1), scnC.xyz);
    float3 lx   = float3((dotsPerBit * Tex), lum);
    float4 dotC = make_tones(lx);
    return float4(dotC.xyz, 1.0);
}

technique t1
{
    pass p1
    {
	PixelShader = compile ps_2_a PSTone();
    }
}







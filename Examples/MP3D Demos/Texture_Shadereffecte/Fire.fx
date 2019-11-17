// Benötigt TextureA +TextureB   

// Faktoren (Tweakables)
float2 pixelsize     = {0.001, 0.001};
float  flamability   = 0.0003;
float  pressure      = 0.34;
float  powerBoost    = 0.02;
float  intensity     = 1.0;
float  speed         = 0.0001;
float  noisiness     = 0.6;
float  timestamp     = 0.0;
float  explositivity = 1.0;
bool   bMultiply     = true;
float4 ColorOffset   = float4(0.0, 0.15, -0.08, 0.0);

texture2D TextureA;
texture3D TextureB;

sampler Sampler1 = sampler_state
{
    texture = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};

sampler Flame = sampler_state
{
    texture = <TextureB>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};
texture Texture6;
sampler Noise = sampler_state
{
    texture = <Texture6>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};

float4 PSFire(float2 texCoord: TEXCOORD0) : COLOR0 
{
    float4 BaseColor = tex2D(Sampler1, texCoord);
    texCoord.xy = 3.0 * texCoord.xy - float2(1.0, 1.0);
    float t = frac(timestamp * speed);

    t = pow(t, explositivity);

    // The function f(t) = 6.75 * t * (t * (t - 2) + 1)
    // is a basic third degree pulse function with these properties:
    // The basic idea of this function is a quick rise at the
    // beginning and then a slow smooth decline towards zero
    float size = intensity * 6.75 * t * (t * (t - 2) + 1);

    float dist = length(texCoord) / (0.1 + size);

    // Higher flamability => quicker move away from center
    // Higher pressure => tighter packing
    float n = tex3D(Noise, float3(noisiness * texCoord, flamability * timestamp - pressure * dist));

    float4 flame = tex1D(Flame, size * powerBoost + size * (2 * n - dist));

    //return flame;
    if (bMultiply)
        return float4(flame.r, flame.g, 0.0, 1.0) * BaseColor - ColorOffset;
    return 2.0 * lerp(float4(flame.r, flame.g, 0.0, 1.0), BaseColor, 0.4);
}

technique t1
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSFire();
    }
}
























float4 g_LightDir    = {0.4f, 0.4f, -0.8f, 1.0f};
float3 g_CameraPos   = {0.5f, 0.5f, 0.2f};

// Farben
float  g_fDiffuse    = 0.9f;
float  g_fSpecular   = 0.7f;
float  g_fSpecPower  = 12.0f;
float4 g_DarkWood    = {0.44f, 0.21f, 0.0f, 1.0f};
float4 g_LiteWood    = {0.92f, 0.5f, 0.13f, 1.0f};

// Musterung
float  g_fScale      = 0.5f;
float  g_fFrequency  = 16.0f;
float  g_fNoiseScale = 6.0f;
float  g_fRingScale  = 2.0f;  // wood1 only
float  ringSharpness = 10.0f; // wood4 only

texture TextureA;
sampler NoiseSampler = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    AddressW  = Wrap;
    MipFilter = Linear;
    MinFilter = Linear;
    MagFilter = Linear;
};


float4 PSWood4(float2 Tex : Texcoord0) : COLOR 
{
    float snoise = 2 * tex3D(NoiseSampler, float3(Tex.xy, cos(Tex.x))) - 1;

    // Rings goes along z axis, perturbed with some noise
    float r = frac(g_fFrequency * cos(Tex.x) + g_fNoiseScale * snoise);

    // f(r) = r - r^ringSharpness
    // 0 < r < 1 
    float invMax = pow(ringSharpness, ringSharpness / (ringSharpness - 1)) / (ringSharpness - 1);
    float ring = invMax * (r - pow(r, ringSharpness));

    // Farben mischen
    float  lrp      = ring + snoise;
    float4 BaseColor = lerp(g_DarkWood, g_LiteWood, lrp);
    float3 Normal    = normalize(float3(0.0, 0.0, 1.0));
    float3 ViewDir   = normalize(g_CameraPos - float3(Tex.xy, cos(Tex.x)));
    float3 LightDir  = normalize(-g_LightDir);
    float  Angle     = saturate(dot(Normal, LightDir));                    // N.L
    float3 Reflect   = normalize(2 * Angle * Normal - LightDir); 
    float  Specular  = pow(saturate(dot(ViewDir, Reflect)), g_fSpecPower); // R.V^n   
    float  Shadow    = saturate(4 * Angle);

    // Endfarbe ohne ambiente Beleuchtung
    return (g_fDiffuse  * (0.5 + 0.5 * Angle) * BaseColor) + 
           (g_fSpecular * Specular);
}

technique t1
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSWood4();
    }
}





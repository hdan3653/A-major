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

texture Texture6;
sampler NoiseSampler = sampler_state
{
    texture   = <Texture6>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    AddressW  = Wrap;
    MipFilter = Linear;
    MinFilter = Linear;
    MagFilter = Linear;
};

float4 PSWood1(float2 Tex : Texcoord0) : COLOR 
{
    // Formel aus RenderMonkey
    float snoise = 2 * tex3D(NoiseSampler, float3(Tex.xy, cos(Tex.x))) - 1;
    float ring   = frac(g_fFrequency * cos(Tex.x) + g_fNoiseScale * snoise);
    ring        *= 4 * (1 - ring);

    // zwischen zwei Farben interpolieren
    float  Lerp      = pow(ring, g_fRingScale) + snoise;    // noise addieren
    float4 BaseColor = lerp(g_DarkWood, g_LiteWood, Lerp);
    float3 Normal    = normalize(float3(0.0, 0.0, 1.0));
    float3 ViewDir   = normalize(g_CameraPos - float3(Tex.xy, cos(Tex.x)));
    float3 LightDir  = normalize(-g_LightDir);
    float  Angle     = saturate(dot(Normal, LightDir));                    // N.L
    float3 Reflect   = normalize(2 * Angle * Normal - LightDir); 
    float  Specular  = pow(saturate(dot(ViewDir, Reflect)), g_fSpecPower); // R.V^n
    float  Shadow    = saturate(4 * Angle);

    // Endfarbe ohne ambiente Beleuchtung
    return ((g_fDiffuse  * (0.5 + 0.5 * Angle) * BaseColor) + 
           (g_fSpecular * Specular));
}

float4 PSWood2(float2 Tex : Texcoord0) : COLOR 
{
    // Noisefaktor aus Textur holen
    float snoise = 2 * tex3D(NoiseSampler, float3(Tex.xy, cos(Tex.x))) - 1;

    float ring = frac(g_fFrequency * length(Tex.xy) + g_fNoiseScale * snoise);
    // 4(x-x^2)
    ring *= 4 * (1 - ring);

    float  lrp       = pow(ring, g_fRingScale) + snoise;
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

float4 PSWood3(float2 Tex : Texcoord0) : COLOR 
{
    // Noise-Farbe aus Textur lesen
    float snoise = 2 * tex3D(NoiseSampler, float3(Tex.xy, cos(Tex.x))) - 1;

    // entlang der y-Achse strecken
    Tex.y *= 0.25;
   
    // Ringe auf der z-Achse
    float ring = 0.5 * (1 + sin(5 * sin(g_fFrequency * cos(Tex.x)) + g_fFrequency * (g_fNoiseScale * snoise + 6.28 * length(Tex.xy))));

    float  lrp       = ring + snoise;
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

technique Wood1
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSWood1();
    }
}

technique Wood2
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSWood2();
    }
}

technique Wood3
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSWood3();
    }
}

technique Wood4
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSWood4();
    }
}



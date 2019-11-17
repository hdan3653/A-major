float4   g_LightDir   = {0.0, 0.0, -10.0, 1.0};   // Spotlight: {-1.0, 2.0, -1.0, 1.0};
float3   g_CameraPos  = {0.0, 0.0, 1.0};          // Spot: {0.5, 0.5, 0.1};

// Farben
float4   g_Marble     = {0.0, 0.40, 0.26, 1.0};  // Marmor
float4   g_BlueMarble = {0.06, 0.08, 0.44, 1.0}; // blauer Marmor
float4   g_Veined     = {0.95, 0.91, 0.83, 1.0}; // Farbe der Adern im Marmor
float4   g_Diffuse    = {0.8, 0.8, 0.8, 1.0};    // Streufarbe
float4   g_Ambient    = {0.2, 0.2, 0.2, 1.0};    // Umgebungsfarbe
float    g_fSpecPower = 128.0;                    // Glanzkraft
float    g_fSpecular  = 0.0;                     // Intensität

// Faktoren für Musterung
float    g_fBlueMarble       = 3.0f;
float    g_fBlueMarbleAmpl   = 1.0f;
float    g_fVeinedBlueMarble = 2.5f;
float    g_fVeinedFreq       = 0.6f;
float    g_fVeinedSharpness  = 5.0f;

// Texturen
texture  TextureA;
texture  TextureB; 
sampler  NoiseSampler = sampler_state
{
    Texture   = <TextureA>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    AddressW  = Wrap;
    MipFilter = Linear;
    MinFilter = Linear;
    MagFilter = Linear;
};
sampler  MarbleSampler = sampler_state
{
    Texture   = <TextureB>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};

float4 PSBlueMarble(float2 Tex : TEXCOORD0) : COLOR
{
    float  Noise     = 2.0f * tex3D(NoiseSampler, float3(Tex.xy, cos(Tex.x)) * g_fBlueMarble) - 1.0f;
    float  Marble    = -2.0f * Noise + 0.75f;

    float4 BaseColor = tex1D(MarbleSampler, Marble * g_fBlueMarbleAmpl);
    float3 Normal    = normalize(float3(0.0, 0.0, 1.0));
    float3 ViewDir   = normalize(g_CameraPos - float3(Tex.xy, 0.0));
    float3 LightDir  = normalize(-g_LightDir);                    // inverser Lichtvektor
    float  Angle     = dot(Normal, LightDir);                     // N.L (ohne saturate, weil soft Diffuse!)
    float3 Reflect   = normalize(2 * saturate(Angle) * Normal - LightDir);  // Lichtrefl.vektor
    float  Specular  = pow(saturate(dot(ViewDir, Reflect)), g_fSpecPower);  // R.V^n
    float  Shadow    = saturate(4 * Angle);                       // Self-Shadow

    // Ambient + Shadow * (Diffuse + Specular)
    return (BaseColor * g_Ambient) + 
            Shadow * ( (BaseColor * g_Diffuse * (0.5 + 0.5 * Angle)) + 
                       (g_fSpecular * Specular) );
}

float4 PSVeinedBlueMarble(float2 Tex : TEXCOORD0) : COLOR
{
   float4 Tex2 = g_fVeinedFreq * 
                 ( float4(float3(Tex.xy, cos(Tex.x)) * g_fVeinedBlueMarble, 1.0f) + 
                   g_fBlueMarbleAmpl * tex3D(NoiseSampler, float3(Tex.xy, cos(Tex.x)) * g_fVeinedBlueMarble) );

    // Formel aus RenderMonkey
    float fTurb;
    float fLerp = 0;
    float fFreq = 1;
    for (int i = 0;  i < 2;  i++)
    {
        fTurb  = abs(2.0f * tex3D (NoiseSampler, Tex2) - 1.0f); // signed noise!
        fTurb  = pow(smoothstep (0.8, 1, 1 - fTurb), g_fVeinedSharpness) / fFreq;
        fLerp += (1-fLerp) * fTurb;
        fFreq *= 3;
        Tex2  *= 3;
    }

    // Farben zusammenblenden (x + f * (y - x))
    float4 BaseColor = lerp(g_BlueMarble, g_Veined, fLerp);
    float3 Normal    = normalize(float3(0.0, 0.0, 1.0));
    float3 ViewDir   = normalize(g_CameraPos - float3(Tex.xy, 0.0));
    float3 LightDir  = normalize(-g_LightDir);                    // inverser Lichtvektor
    float  Angle     = dot(Normal, LightDir);                     // N.L (ohne saturate, weil soft Diffuse!)
    float3 Reflect   = normalize(2 * saturate(Angle) * Normal - LightDir);  // Lichtrefl.vektor
    float  Specular  = pow(saturate(dot(ViewDir, Reflect)), g_fSpecPower);  // R.V^n
    float  Shadow    = saturate(4 * Angle);                       // Self-Shadow

    // Ambient + Shadow * (Diffuse + Specular)
    return (BaseColor * g_Ambient) + 
            Shadow * ( (BaseColor * g_Diffuse * (0.5 + 0.5 * Angle)) + 
                       (g_fSpecular * Specular) );
}

technique VeinedBlueMarble
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSVeinedBlueMarble();
    }
}

technique BlueMarble
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSBlueMarble();
    }
}






float2  pixelsize     = {0.001, 0.001};
float   g_fBlurScale  = 20.0; 
float   g_fDistSpeed  = 0.2;
float   g_fDistScale  = 0.015;
texture TextureA;
texture TextureB;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};
sampler Sampler2 = sampler_state
{
    texture   = <TextureB>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};

// Tabellen mit Verschiebungsfaktoren für Blur
const float2 g_Offsets[10] = 
{
    -0.840144, -0.073580,
    -0.695914,  0.457137,
    -0.203345,  0.620716,
     0.962340, -0.194983,
     0.473434, -0.480026,
     0.519456,  0.767022,
     0.185461, -0.893124,
     0.507431,  0.064425,
     0.896420,  0.412458,
    -0.321940, -0.932615,
};

float4 PSDistortionFullScreen(float2 Tex : TEXCOORD0) : COLOR0
{
    // Perturbationstextur gibt die Richtung der Verzerrung an
    // zwei lookups: damit entsteht der Flimmereffekt!
    float3 Perturb1 = 2 * (tex2D(Sampler2, Tex) - 0.5);
    float3 Perturb2 = 2 * (tex2D(Sampler2, Tex + g_fDistSpeed) - 0.5);
    
    // Durchschnitt berechnen
    float2 Offset = (Perturb1 + Perturb2) * 0.5;

    // die neuen Texturkoordinaten
    float2 NewCoords = Tex + (Offset * g_fDistScale);
   
    // Farbe aus der Fullscreen-Textur holen
    float3 Color = tex2D(Sampler1, NewCoords);

    for (int i = 0; i < 10; i++)
        Color += tex2D(Sampler1, NewCoords + (g_fBlurScale * pixelsize * g_Offsets[i]));

    return float4(Color * 0.090909, 1.0);
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSDistortionFullScreen();
    }
}







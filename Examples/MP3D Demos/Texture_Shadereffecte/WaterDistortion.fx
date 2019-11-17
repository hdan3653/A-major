float2  pixelsize    = {0.001, 0.001};
float   g_fDistSpeed = 0.2;
float   g_fDistScale = 0.01;
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

    return float4(Color, 1.0);
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSDistortionFullScreen();
    }
}









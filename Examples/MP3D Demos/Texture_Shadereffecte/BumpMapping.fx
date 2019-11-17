float2  g_PixelSize   = {0.001, 0.001};
float2  g_CameraPos   = {0.0f, 0.5f}; 
float2  g_LightPos    = {1.0f, 0.0f};
float   g_fLightIntensity = 1.0f;
float   g_fSpecPower  = 32.0f;
float   g_fSpecular   = 0.2f;
float   g_fScale      = 0.05;
float   g_fNoise      = 2.0;
texture TextureA;
texture TextureB;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};
sampler Sampler3 = sampler_state
{
    texture   = <TextureB>;
    AddressU  = Wrap;
    AddressV  = Wrap;
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

float4 PSBump(float2 Tex : TEXCOORD0) : COLOR0
{
    float3 Normal   =  normalize(tex2D(Sampler3, g_fNoise * Tex).rbg);
    Normal.xz *=  g_fScale;
    float3 EyeVec    = normalize(float3(g_CameraPos.x, 1.0, g_CameraPos.y) - float3(Tex.x, 0.0, Tex.y));
    float3 LightDir  =  float3(g_LightPos.x, g_fLightIntensity, g_LightPos.y) - float3(Tex.x, 0.0, Tex.y);
    
    float3 BaseColor = tex2D(Sampler1, Tex - Normal.xz).rgb;

    float  ReflAngle = saturate(dot(Normal, EyeVec));
    float  Angle     = saturate(dot(Normal, LightDir));
    float3 SpecRefl  = normalize(2 * Angle * Normal - LightDir);
    float  Specular  = pow(saturate(dot(SpecRefl, EyeVec)), g_fSpecPower);
   
    float3 Color = BaseColor + (Specular *  g_fSpecular); 
   
    return float4(Color, 1.0);
}


technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSBump();
    }
}
























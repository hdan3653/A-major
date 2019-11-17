float2   g_CameraPos   = {0.0f, 0.5f}; 
float2   g_LightPos    = {1.6f, 0.0f};
float    g_fLightRange = 0.4f;
float4   g_Specular    = {1.0f, 0.95f, 0.67f, 1.0f}; 
float    g_fSpecPower  = 64.0f;
float    g_fSpecular   = 0.4f;
texture  TextureA;
sampler  Sampler1 = sampler_state
{
    Texture   = <TextureA>;
    AddressU  = Wrap;
    AddressV  = Wrap;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};

float4 PSLighting(float2 Tex : TEXCOORD0) : COLOR0
{
    float3 EyeVec    = normalize(float3(g_CameraPos.x, 1.0, g_CameraPos.y) - float3(Tex.x, 0.0, Tex.y));
    float3 LightVec  = float3(g_LightPos.x, 1.0, g_LightPos.y) - float3(Tex.x, 0.0, Tex.y);
    float  Att       = min(g_fLightRange / (LightVec * LightVec), 1.0);
    float3 LightDir  = normalize(LightVec);
    float  ReflAngle = saturate(dot(float3(0.0, 1.0, 0.0), EyeVec));
    float  Angle     = saturate(dot(float3(0.0, 1.0, 0.0), LightDir));
    float3 SpecRefl  = normalize(2 * Angle * float3(0.0, 1.0, 0.0) - LightDir);
    float  Specular  = pow(saturate(dot(SpecRefl, EyeVec)), g_fSpecPower);

    float3 Color = tex2D(Sampler1, Tex)  + (g_Specular * Specular *  g_fSpecular); 
   
    return float4(Att * Color, 1.0);
}

technique t1
{
    pass p1
    {
        PixelShader  = compile ps_2_0 PSLighting();
    }
}



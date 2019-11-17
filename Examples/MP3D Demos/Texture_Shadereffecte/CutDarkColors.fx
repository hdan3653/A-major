float   Var1;//g_fBrightThreshold= 0.6;
texture TextureA;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = Linear;
    MagFilter = Linear;
    MinFilter = Linear;
};
float4 g_DownSampleOffsets[8];

float4 PSBrightPass(float2 Tex : TEXCOORD0) : COLOR
{
    float4 Average = {0.0, 0.0, 0.0, 0.0};

    // 4x aus der Textur lesen
    for (int i = 0; i < 2; i++)
    {
        for (int j = 0; j < 2; j++)
        {
            Average += tex2D(Sampler1, Tex + float2(g_DownSampleOffsets[i][j * 2], g_DownSampleOffsets[i][(j * 2) + 1]));        
        }  
    }
    Average *= 0.25;

    float fLuminance = dot(Average.rgb, float3(0.33, 0.34, 0.33));
    fLuminance = max( 0.0f, fLuminance - Var1);//g_fBrightThreshold);
    
    // damit die Helligkeit entweder 0.0 oder 1.0 ist
    Average.rgb *= sign(fLuminance);
    Average.a = 1.0;

    return Average;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSBrightPass();
    }
}



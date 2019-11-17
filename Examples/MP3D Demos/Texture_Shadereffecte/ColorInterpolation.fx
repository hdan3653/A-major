float3  Color1 = {1.0, 0.0, 0.0}; 
float3  Color2 = {0.0, 1.0, 0.0}; 
float3  Color3 = {0.0, 0.0, 1.0}; 
float3  Color4 = {0.7, 0.7, 0.0}; 
float   Brightness = 2.0;
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
float4 PSColorInterpolation(float2 Tex : TEXCOORD) : COLOR0
{ 
    float4 IntColor = float4(lerp(lerp(Color1, Color2, Tex.x), lerp(Color3, Color4, Tex.y), 0.5), 1.0);

    //return IntColor;
    return tex2D(Sampler1, Tex) * IntColor * Brightness;
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSColorInterpolation();
    }
}









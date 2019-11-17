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

float4 PSHorzFlip(float2 Tex : TEXCOORD0) : COLOR
{
    return tex2D(Sampler1, float2(1-Tex.x,Tex.y) );
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSHorzFlip();
    }
}







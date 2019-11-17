// Farben werden vertauscht

float Var1;
float Var2;
float Var3;


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

float4 PSColorChange(float2 Tex : TEXCOORD0) : COLOR
{
  
     return tex2D(Sampler1, Tex) * float4 (Var1*2,Var2*2,Var3*2,1);

}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_3_0 PSColorChange();
    }
}












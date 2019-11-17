float2 pixelsize = {0.001, 0.001};
float2 Scale     = {3, 3};
float  CenterX   = 0.2;
float  CenterY   = 0.6;
int    iterate   = 50;
float3 InColor   = {0.0, 0.0, 0.0};
float3 OutColorA = {1.0, 0.0, 0.3};
float3 OutColorB = {0.2, 1.0, 0.0};
float  Range     = 0.15;
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

float4 PSMandy(float2 Tex : TEXCOORD0) : COLOR0
{
    float2 pos = frac(Tex.xy);
    float real = ((pos.x - 0.5) * Scale.x) - CenterX;
    float imag = ((0.5 - pos.y) * Scale.y) - CenterY;
    float Creal = real;
    float Cimag = imag;
    float r2 = 0;
    float i;
    for (i=0; (i<iterate) && (r2<4.0); i++) {
		float tempreal = real;
		real = (tempreal*tempreal) - (imag*imag) + Creal;
		imag = 2*tempreal*imag + Cimag;
		r2 = (real*real) + (imag*imag);
    }
    float3 finalColor;
    if (r2 < 4) {
       finalColor = InColor;
    } else {
    	finalColor = lerp(OutColorA,OutColorB,frac(i * Range));
    }
    return tex2D(Sampler1, Tex) * (1.0 - float4(finalColor,1));
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_3_0 PSMandy();
    }
}















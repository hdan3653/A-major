// Bild wird verpixelt 

float Time;
float res = 100; // Anzahl Pixel
int dirty = 20;   // Groesse Pixel

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

float4 PSLostPixel(float2 Tex : TEXCOORD0) : COLOR
{
	float4 c = tex2D(Sampler1, Tex);    
	
	int2 t2 = Tex*res;
	Tex=t2/res;	
	
	float x=Tex.x*Tex.y*123456;
	x=fmod(x,13) * fmod(x,123);
	int y = fmod(x,dirty);		
	int z = Time*3 % dirty;		
	if(y==z) c=tex2D(Sampler1, Tex);
	
	return c;    
}

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSLostPixel();
    }
}








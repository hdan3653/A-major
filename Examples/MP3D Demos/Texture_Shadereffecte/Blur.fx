//Tweakables
static const float fScale = 6.0;

// Application fed data:
//float4 vecViewPort = {0,0,0.004,0.004};
float Blurvec = {0.0001}; 

texture TextureA;
sampler ShadowSampler = sampler_state { Texture = <TextureA>; };

#define NUM_TAPS 12

static const float2 fTaps_Poisson[NUM_TAPS] = {
	{-.326,-.406},
	{-.840,-.074},
	{-.696, .457},
	{-.203, .621},
	{ .962,-.195},
	{ .473,-.480},
	{ .519, .767},
	{ .185,-.893},
	{ .507, .064},
	{ .896, .412},
	{-.322,-.933},
	{-.792,-.598}
};

//  blur pixel shader
float4 BlurPS (in float2 inShadow: TEXCOORD0) : COLOR0
{
	float fShadow = 0.0;
        float2 vecViewPort = (Blurvec ,Blurvec);

	for (int i=0; i < NUM_TAPS; i++)
	{
		fShadow += tex2D(ShadowSampler,inShadow + fTaps_Poisson[i]*fScale*vecViewPort).r;
		//fShadow += tex2D(ShadowSampler,inShadow + fTaps_Poisson[i]*fScale*vecViewPort.zw).r;
	}
	fShadow *= 1.0/NUM_TAPS;
	return float4(fShadow,fShadow,fShadow,1.0);
}

technique Blur {
	pass p0	{
		PixelShader = compile ps_2_0 BlurPS();
	}}


//////////////////////////////////////
/////////////Bloom Effect/////////////
//////////////////////////////////////
//////based on the Sylex 3 Bloom//////
//////////wich was written////////////
////////////////by////////////////////
///////Sebastian Leopold (XeXeS)//////
//////////////////////////////////////

float4 vecSkill1= {1, 0.4, 0, 0};

texture entSkin1;

sampler postTex = sampler_state
{
	texture 		= (entSkin1);
	MinFilter	= linear;
	MagFilter	= linear;
	MipFilter	= linear;
	AddressU		= Clamp;
	AddressV		= Clamp;
};

float Luminance = 0.08f;
static const float fMiddleGray = 0.18f;
static const float fWhiteCutoff = 0.8f;

#define NUM 13

float2 PixelOffsets[NUM] =
{
	{ -0.006, -0.006 },
	{ -0.005, -0.005 },
	{ -0.004, -0.004 },
	{ -0.003, -0.003 },
	{ -0.002, -0.002 },
	{ -0.001, -0.001 },
	{  0.000,  0.000 },
	{  0.001,  0.001 },
	{  0.002,  0.002 },	
	{  0.003,  0.003 },
	{  0.004,  0.004 },
	{  0.005,  0.005 },
	{  0.006,  0.006 },
};

static const float BlurWeights[NUM] =
{
	0.002216,
	0.008764,
	0.026995,
	0.064759,
	0.120985,
	0.176033,
	0.199471,
	0.176033,
	0.120985,
	0.064759,
	0.026995,
	0.008764,
	0.002216,
};

float4 Bloom_PS_3_0(float2 texcoord0 : TEXCOORD0) : COLOR
{
	float3 pixel;
	float3 Color = 0;
	
	for(int i = 0; i < NUM; i++)
	{
		pixel = tex2D(postTex,texcoord0 + PixelOffsets[i] * 5.0f)+vecSkill1[1];
		
		pixel *= fMiddleGray / (Luminance + 0.001f);
		pixel *= (1.0f + (pixel / (fWhiteCutoff * fWhiteCutoff)));
		pixel -= 5.0f;
		
		pixel = max(pixel,0.0f);
		pixel /= (10.0f + pixel);
		
		Color += pixel * BlurWeights[i];
	}
	
	Color *= vecSkill1[0];
	
	return float4(Color,1.0) + tex2D(postTex,texcoord0);
}

float4 Bloom_PS_2_0(float2 texcoord0 : TEXCOORD0) : COLOR
{
	float3 pixel;
	float3 Color = 0;
	
	for(int i = 4; i < 9; i++)
	{
		pixel = tex2D(postTex,texcoord0 + PixelOffsets[i] * 5.0f)+vecSkill1[1];
		
		pixel *= fMiddleGray / (Luminance + 0.001f);
		pixel *= (1.0f + (pixel / (fWhiteCutoff * fWhiteCutoff)));
		pixel -= 5.0f;
		
		pixel = max(pixel,0.0f);
		pixel /= (10.0f + pixel);
		
		Color += pixel * BlurWeights[i];
	}
	
	Color *= vecSkill1[0];
	
	return float4(Color,1.0) + tex2D(postTex,texcoord0);
}


technique tech_00
{
	pass pass_00
	{
		VertexShader = null;
		PixelShader = compile ps_3_0 Bloom_PS_3_0();
	}
}

technique tech_01
{
	pass pass_00
	{
		VertexShader = null;
		PixelShader = compile ps_2_0 Bloom_PS_2_0();
	}
}

technique tech_02
{
	pass pass_00
	{
		Texture[0] = <entSkin1>;
	}
}

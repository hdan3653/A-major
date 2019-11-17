texture sceneTexture ;
sampler sceneSample = sampler_state
{
	Texture   = <sceneTexture>;
	AddressU  = Clamp;
	AddressV  = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

texture currentTexture;
sampler currentSample = sampler_state
{
	Texture   = <currentTexture>;
	AddressU  = Clamp;
	AddressV  = Clamp;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

static const int kernelSize = 13;
static const float downSize = 256.0f;

float2 pixelKernel[kernelSize] =
{
    { -6.0f / downSize, 0.0f },
    { -5.0f / downSize, 0.0f },
    { -4.0f / downSize, 0.0f },
    { -3.0f / downSize, 0.0f },
    { -2.0f / downSize, 0.0f },
    { -1.0f / downSize, 0.0f },
    {  0.0f,            0.0f },
    {  1.0f / downSize, 0.0f },
    {  2.0f / downSize, 0.0f },
    {  3.0f / downSize, 0.0f },
    {  4.0f / downSize, 0.0f },
    {  5.0f / downSize, 0.0f },
    {  6.0f / downSize, 0.0f },
};

float2 pixelKernelV[kernelSize] =
{
    { 0.0f, -6.0f / downSize },
    { 0.0f, -5.0f / downSize },
    { 0.0f, -4.0f / downSize },
    { 0.0f, -3.0f / downSize },
    { 0.0f, -2.0f / downSize },
    { 0.0f, -1.0f / downSize },
    { 0.0f,  0.0f            },
    { 0.0f,  1.0f / downSize },
    { 0.0f,  2.0f / downSize },
    { 0.0f,  3.0f / downSize },
    { 0.0f,  4.0f / downSize },
    { 0.0f,  5.0f / downSize },
    { 0.0f,  6.0f / downSize },
};

static const float blurWeights[kernelSize] = 
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

float4 PSBloom(float2 texCoords : TEXCOORD0) : COLOR
{
    float4 color = tex2D(currentSample, texCoords);
    return 4.0f * (color - 0.75);
}

float4 PSBlurH(float2 texCoords : TEXCOORD0) : COLOR
{
    float4 color = 0.0f;
    for(int i = 0; i < kernelSize; i++)
    {    
        color += tex2D(currentSample, texCoords + pixelKernel[i].xy) * blurWeights[i];
	}
    return color;
}

float4 PSBlurV(float2 texCoords : TEXCOORD0) : COLOR
{
    float4 color = 0.0f;
    for(int i = 0; i < kernelSize; i++)
    {    
        color += tex2D(currentSample, texCoords + pixelKernelV[i].xy) * blurWeights[i];
    }
    return color + tex2D(sceneSample, texCoords) - 0.75 ;
}

technique MainTechnique
{
	pass Bloom
	{
		PixelShader	= compile ps_2_0 PSBloom();
	}
	pass BlurH
	{
		PixelShader	= compile ps_2_0 PSBlurH();
	}
	pass BlurV
	{
		PixelShader	= compile ps_2_0 PSBlurV();
	}
}
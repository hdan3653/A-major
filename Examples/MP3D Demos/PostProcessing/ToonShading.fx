////Makes Details invisible and the colors a bit more intensive, which gives the Level a toon like look


float r = 4 ;//"Details" for the rgb values
float g = 4 ;//"Details" for the rgb values
float b = 4 ;//"Details" for the rgb values


Texture TargetMap;
sampler2D smpSource = sampler_state { texture = <TargetMap>; };

float4 dirtyToonPS( float2 Tex : TEXCOORD0 ) : COLOR0 
{		
	half4 Color = tex2D(smpSource,Tex.xy);
	Color.r = round(Color.r*r)/r;
	Color.g = round(Color.g*g)/g;
	Color.b = round(Color.b*b)/b;
	return Color;
}

technique postFX 
{ 
	pass p1 
	{ 
		PixelShader = compile ps_2_0 dirtyToonPS(); 
	} 
}

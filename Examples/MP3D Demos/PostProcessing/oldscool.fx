//Makes the game to look as if it had a very low resolution

texture TargetMap;
sampler2D smpSource = sampler_state { texture = <TargetMap>; };

float Pixelation_x = 100 ;
float Pixelation_y = 100 ;

float4 blockyPS( float2 Tex : TEXCOORD0 ) : COLOR0 
{
	Tex.x = round(Tex.x*Pixelation_x)/Pixelation_x;
	Tex.y = round(Tex.y*Pixelation_y)/Pixelation_y;
	return tex2D(smpSource,Tex.xy);
}

technique postFX 
{ 
	pass p1 
	{ 
		PixelShader = compile ps_2_0 blockyPS(); 
	} 
}


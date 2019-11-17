// Modified Version of the Grass Demo From ATI
// grass.fx
// Modifyt for MP3D by Michael
 
texture   texture0;
float4x4  worldViewProj;
float time;

// Faktoren (Tweakables)
float   g_fAlpha          = 10; 

// float4    windDirection;

sampler GrassSampler= sampler_state 
{
	Texture = <texture0>;
	
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
                AddressU = Clamp;
                AddressV = Clamp;
};





struct VS_OUTPUT
{
    float4 Pos   : POSITION;
    float2 Tex   : TEXCOORD0;
};



//
// V E R T E X - S H A D E R
//

VS_OUTPUT VSGrass(float4 Pos : POSITION,
                  float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;

    Pos.x   += cos(time) * Pos.y * 0.02;
    Pos.z   += cos(time*2) * Pos.y * 0.02;


    Out.Pos   = mul(Pos, worldViewProj);
    Out.Tex   = Tex;

    return Out;
}

VS_OUTPUT VSGrass2(float4 Pos : POSITION,
                  float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;

    Pos.x   += cos(time*2) * Pos.y * 0.02 + 4;
    Pos.z   += cos(time) * Pos.y * 0.02;


    Out.Pos   = mul(Pos, worldViewProj);
    Out.Tex   = Tex;

    return Out;
}

VS_OUTPUT VSGrass3(float4 Pos : POSITION,
                  float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;

    Pos.x   += cos(time*2) * Pos.y * 0.02 - 4;
    Pos.z   += cos(time*2) * Pos.y * 0.02;


    Out.Pos   = mul(Pos, worldViewProj);
    Out.Tex   = Tex;

    return Out;
}

//
// P I X E L - S H A D E R
//

float4 PSGrass(VS_OUTPUT In) : COLOR0
{
    float4 TexColor = tex2D(GrassSampler, In.Tex);
    return float4(TexColor.rgb, g_fAlpha * TexColor.a);
}


// Techniques
technique grass 
{
	pass p0 
	{
                                Lighting         = FALSE;
                                AlphaTestEnable  = TRUE;
                                AlphaFunc        = Greater;

		VertexShader = compile vs_2_0 VSGrass();
		PixelShader = compile ps_2_0 PSGrass ();
	}
	pass p1 
	{
       		VertexShader = compile vs_2_0 VSGrass2();
		PixelShader = compile ps_2_0 PSGrass ();
	}
	pass p2 
	{
       		VertexShader = compile vs_2_0 VSGrass3();
		PixelShader = compile ps_2_0 PSGrass ();
	}
}







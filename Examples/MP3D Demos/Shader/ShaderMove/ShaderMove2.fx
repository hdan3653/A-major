//-----------------------------------------------------------------------------
//           Name: ShaderMove2.fx
//         Author: Michael Paulwitz
//  Last Modified: 28.10.09
//    Description: Dieses Effektfile ist zum testen gedacht. Derzeit bewegt es
//                 einfach nur die Vertexe eines Meshs sinusförmig
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float t1; // Move x derzeit ungenutzt
float t2; // Move y derzeit ungenutzt
float t3; // Move z derzeit ungenutzt

float4x4 worldViewProj : WorldViewProjection; // This matrix will be loaded by the application

float currentAngle;

texture testTexture; // This texture will be loaded by the application

sampler Sampler = sampler_state
{
    Texture   = (testTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//-----------------------------------------------------------------------------
// Vertex Definitions
//-----------------------------------------------------------------------------

// Our sample application will send vertices 
// down the pipeline laid-out like this...

struct VS_INPUT
{
    float3 position	: POSITION;
    float2 texture0     : TEXCOORD0;
};

// Once the vertex shader is finished, it will 
// pass the vertices on to the pixel shader like this...

struct VS_OUTPUT
{
    float4 hposition : POSITION;
    float4 color	 : COLOR0;
    float2 texture0  : TEXCOORD0;
};


//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;

	float4 v = float4( IN.position.x, IN.position.y, IN.position.z, 1.0f );

        v.z  = sin( IN.position.y + currentAngle.x );
        v.z += sin( IN.position.x + currentAngle.x );
        v.z *= IN.position.y * 0.08f;

        //v.y  = sin( IN.position.x + currentAngle.x );
        //v.y += sin( IN.position.z + currentAngle.x );
        //v.y *= IN.position.x * 0.08f;


	OUT.hposition = mul( worldViewProj, v );

        //OUT.hposition = float4(IN.position.x+t1 ,IN.position.y +t2,IN.position.z+t3, 1);

	//OUT.hposition = mul( worldViewProj, float4(IN.position.x+t1 ,IN.position.y+t2 ,IN.position.z+t3, 1) ); //

	//OUT.hposition = mul( worldViewProj, float4(IN.position, 1) ); //

        OUT.color = float4( 1.0, 1.0, 1.0, 1.0 ); // Pass white as a default color
	//OUT.color = float4( 0.0, 1.0, 0.0, 1.0 ); // Pass green to test vertex shader

	OUT.texture0 = IN.texture0;

	return OUT;
}

//-----------------------------------------------------------------------------
// Simple Effect (1 technique with 1 pass)
//-----------------------------------------------------------------------------

technique Technique0
{
    pass Pass0
    {
		Lighting = True;

		Sampler[0] = (Sampler); // Needed by pixel shader

		VertexShader = compile vs_2_0 myvs();
    }
}


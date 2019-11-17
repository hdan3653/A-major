//-----------------------------------------------------------------------------
//           Name: MoveFlagge.fx
//         Author: Michael Paulwitz
//  Last Modified: 10.04.12
//    Description: move Flag 
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProj : WorldViewProjection; // This matrix will be loaded by the application
texture texture0;
float time;
float halvewidh = 10;

sampler Sampler1 = sampler_state 
{ 
texture   = <texture0>;
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
    float2 texture0  : TEXCOORD0;
};


//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;

        float4 v = float4( IN.position.x, IN.position.y, IN.position.z, 1.0f );
        float angle=time*4;
        v.z += sin( v.x+angle) ;
        v.z += sin( v.y /2+angle);
        v.z *= (v.x+halvewidh ) * 0.09f;

        OUT.hposition = mul( v, worldViewProj   );
        OUT.texture0 = IN.texture0;
        return OUT;
}

//-----------------------------------------------------------------------------
// Simple Effect (1 technique with 1 pass)
//-----------------------------------------------------------------------------

technique flag
{
    pass Pass0
    {
		Sampler[0] = (Sampler1); // Needed by pixel shader
		VertexShader = compile vs_2_0 myvs();
    }
}










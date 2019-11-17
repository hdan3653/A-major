//-----------------------------------------------------------------------------
//     Name: Simple_Vertex_Shader_with_moving.fx
//     Author: Michael Pauwlitz
//    Last Modified: 
//    Description: Easy Vertex Shader, Show only the color of the Vertex
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProj : WorldViewProjection; // This matrix will be loaded by the application
float time;

//-----------------------------------------------------------------------------
// Vertex Definitions
//-----------------------------------------------------------------------------

// Our sample application will send vertices 
// down the pipeline laid-out like this...

struct VS_INPUT
{
    float3 position	: POSITION;
    float4 color	 : COLOR0;
};

// Once the vertex shader is finished, it will 
// pass the vertices on to the pixel shader like this...

struct VS_OUTPUT
{
    float4 hposition : POSITION;
    float4 color	 : COLOR0;
};

//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;

	OUT.hposition = mul( float4(IN.position.x *sin(time),IN.position.y*cos(time) ,IN.position.z*tan(time), 1),worldViewProj ); //
                OUT.color =  IN.color ;//; Read vertex Color and show them
	return OUT;
}


//-----------------------------------------------------------------------------
// Simple Effect (1 technique with 1 pass)
//-----------------------------------------------------------------------------

technique Technique0
{
    pass Pass0
    {

                VertexShader = compile vs_2_0 myvs();
		PixelShader  = Null;
    }
}




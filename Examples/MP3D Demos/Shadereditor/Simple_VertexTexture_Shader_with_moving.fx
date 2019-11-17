//-----------------------------------------------------------------------------
//     Name: Simple_VertexTexture_Shader_with_moving.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Easy Vertex Shader, Show only the texture of the mesh
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProj; // This matrix will be loaded by the application
float time;

texture texture0;

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
    float3 position   : POSITION;
    float2 tex0       : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 hposition : POSITION;
    float2 tex0        : TEXCOORD0;
};

//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;
    float4x4 worldVP = worldViewProj; // Wir klaue hier die Weltpotion

    worldVP._41 = worldVP._41 + sin(time);
    worldVP._42 = worldVP._42 + cos(time);
    worldVP._43 = worldVP._43 + sin(time)*cos(time);

    OUT.hposition = mul( float4(IN.position.x ,IN.position.y ,IN.position.z, 1),worldVP); //
    OUT.tex0 = IN.tex0 ;
    return OUT;
}

float4 myps(float2 Tex : TEXCOORD0) : COLOR
{
    return tex2D(Sampler1, Tex);
}

technique moving
{
    pass p1  
    {
        VertexShader = compile vs_2_0 myvs();
        PixelShader = compile ps_2_0 myps();
    }
}

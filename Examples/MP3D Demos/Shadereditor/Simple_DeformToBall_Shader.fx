//-----------------------------------------------------------------------------
//     Name: Simple_DeformToBall_Shader.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Easy Vertex Shader, to defom mesh to ball
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProjI : WorldViewProjection; // This matrix will be loaded by the application
texture texture0;
float time;
float high = 200; // high = Grösse der Kugel 

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
    
    float var = (1+ sin (time))/2; // Wert von 0-1 
    float3 pos = ((var* IN.position)+((1-var)*normalize(IN.position)*high ) );

    OUT.hposition = mul( worldViewProjI, float4(pos, 1) ); //
    OUT.tex0 = IN.tex0 ;
    return OUT;
}

float4 myps(float2 Tex : TEXCOORD0) : COLOR
{
    return tex2D(Sampler1, Tex);
}

technique inverse
{
    pass p1  
    {
        VertexShader = compile vs_2_0 myvs();
        PixelShader = compile ps_2_0 myps();
    }
}





//-----------------------------------------------------------------------------
//     Name: Simple_Vertex_Shader_with_ColorSettings.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Easy Vertex Shader, Show only the color of the Vertex
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProjI : WorldViewProjection; // This matrix will be loaded by the application
float Var1;
float Var2;
float Var3;

//-----------------------------------------------------------------------------
// Vertex Definitions
//-----------------------------------------------------------------------------

// Our sample application will send vertices
// down the pipeline laid-out like this...

struct VS_INPUT
{
    float3 position   : POSITION;
    float4 color    : COLOR0;
};

// Once the vertex shader is finished, it will
// pass the vertices on to the pixel shader like this...

struct VS_OUTPUT
{
    float4 hposition : POSITION;
    float4 color    : COLOR0;
};

//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;

   OUT.hposition = mul( worldViewProjI, float4(IN.position.x ,IN.position.y ,IN.position.z, 1) ); //
                OUT.color =  float4 (IN.color.r*Var1,IN.color.g*Var2,IN.color.b*Var3,IN.color.a) ;  //Read vertex Color and show them
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
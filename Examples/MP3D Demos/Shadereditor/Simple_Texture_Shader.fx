//-----------------------------------------------------------------------------
//     Name: Simple_Texture_Shader.fx

//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Easy Vertex Shader, Show only the texture of the mesh
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProjI : WorldViewProjection; // This matrix will be loaded by the application

texture texture0;
float time;
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


float2 DoTurnTex( float2 postex, float t ) // t = Rad oder t * 0.017453 = Grad
{
  float2 new_postex;
  float middle = float (0.5);
  postex -= 0.5 ;
  // t*= 0.017453; // makes from radiant a grad function
  new_postex.x = sin(atan2(postex.x,postex.y)+t)*0.71+ middle;
  new_postex.y = cos(atan2(postex.x,postex.y)+t)*0.71+ middle;
  return( new_postex );
}




//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;
    OUT.hposition = mul( worldViewProjI, float4(IN.position.x ,IN.position.y ,IN.position.z, 1) ); //
    
    OUT.tex0 = DoTurnTex( IN.tex0,time); // Hier dreht die Texture
    
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




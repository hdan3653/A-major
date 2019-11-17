//-----------------------------------------------------------------------------
//     Name: Simple_Vertex_Shader_with_light_Specular.fx
//     Author: Michael Pauwlitz
//    Last Modified: 
//    Description: Easy Vertex Shader with light, Show only the color of the Vertex
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProj : WorldViewProjection; // This matrix will be loaded by the application
float4x4	matWorld       ; // For calculating normals
float3       	lightDir            ; // Our lights direction
float4 vecEye;
float4 SpecularColor = float4(0,1,0,0);	// Specular color



//-----------------------------------------------------------------------------
// Vertex Definitions
//-----------------------------------------------------------------------------

// Our sample application will send vertices 
// down the pipeline laid-out like this...

struct VS_INPUT
{
    float3 position	: POSITION;
    float4 normal	: NORMAL0 ;
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

VS_OUTPUT myvs( VS_INPUT IN)
{
    VS_OUTPUT OUT;

	OUT.hposition = mul( float4(IN.position.x ,IN.position.y ,IN.position.z, 1) ,worldViewProj); //
	// normalize(a) returns a normalized version of a.
	// in this case, a = vLightDirection
	float3 L = normalize(-lightDir);
	// transform our normal with matInverseWorld, and normalize it
	float3 N = normalize(mul(IN.normal.xyz,matWorld));
               //
              
               float4 PosWorld = mul(OUT.hposition, matWorld);	
               float3 V = normalize(vecEye - PosWorld);

               float Diff = saturate(dot(L, N)); 
               float3 Reflect = normalize(2 * Diff * N - L);  
               float Specular = pow(saturate(dot(Reflect, V)), 20); 
               OUT.color =  IN.color  * Diff  + SpecularColor * Specular; 
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



//-----------------------------------------------------------------------------
//     Name: Simple_Textur_Shader_with_light_Specular.fx
//     Author: Michael Pauwlitz
//    Last Modified: 
//    Description: Easy Texture Shader with light and specular//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProj : WorldViewProjection; // This matrix will be loaded by the application
float4x4	matWorld       ; // For calculating normals
float3       	lightDir            ; // Our lights direction
float4 vecEye;
float4 SpecularColor = float4(0,1,0,0);	// Specular color
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
    float3 position	: POSITION;
    float4 normal	: NORMAL0 ;
    float2 tex0            : TEXCOORD0;
};

// Once the vertex shader is finished, it will 
// pass the vertices on to the pixel shader like this...

struct VS_OUTPUT
{
    float4 hposition : POSITION;
    float2 tex0           : TEXCOORD0;    
    float4 diff	 : COLOR0;
    float4 spec	 : COLOR1;

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

               OUT.diff =  Diff ;
               OUT.spec = Specular ;
               OUT.tex0 = IN.tex0;
               return OUT;
}

float4 myps(VS_OUTPUT IN) : COLOR
{
 
	// Ambient light
	float AmbientColor= 0.8f;
	float4 AmbientIntensity= float4(0.075, 0.075, 0.2, 1.0);
	
	// Diffuse light
	float DiffuseIntensity= 1.0f;
	float4 DiffuseColor= float4(1.0,1.0,1.0, 1.0);
              return AmbientColor* AmbientIntensity + SpecularColor * IN.spec + DiffuseIntensity* DiffuseColor* tex2D(Sampler1, IN.tex0 )*IN.diff;

}

//-----------------------------------------------------------------------------
// Simple Effect (1 technique with 1 pass)
//-----------------------------------------------------------------------------

technique Technique0
{
    pass Pass0
    {

                VertexShader = compile vs_2_0 myvs();
	PixelShader = compile ps_2_0 myps();
    }
}





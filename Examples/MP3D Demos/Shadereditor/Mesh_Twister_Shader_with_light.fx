//-----------------------------------------------------------------------------
//     Name: Mesh_Twister_Shader_with_light.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Mesh Twister Shader with texture
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProj : WorldViewProjection; // This matrix will be loaded by the application
float4x4	matWorld      ; // For calculating normals
float3       	lightDir            ; // Our lights direction
uniform float time;

uniform float height = float(1); 
uniform float angle_deg_max = float(1); 
texture texture0;

sampler Sampler1 = sampler_state 
{ 
texture   = <texture0>;
};


float3 DoTwist( float3 pos, float t )
{
                float st = sin(t);
	float ct = cos(t);
	float3 new_pos;
	
	new_pos.x = pos.x*ct - pos.z*st;
	new_pos.z = pos.x*st + pos.z*ct;
	new_pos.y = pos.y;

	return( new_pos );
}

//-----------------------------------------------------------------------------
// Vertex Definitions
//-----------------------------------------------------------------------------

// Our sample application will send vertices
// down the pipeline laid-out like this...

struct VS_INPUT
{
    float3 position   : POSITION;
    float4 normal	: NORMAL0 ;
    float2 tex0       : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 hposition : POSITION;
    float2 tex0        : TEXCOORD0;
    float4 lightnormal : COLOR0;
};

//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;
    float angle_deg = angle_deg_max*sin(time);
    float angle_rad = angle_deg * 3.14159 / 180.0;
    float ang = (height*0.5 + IN.position.y)/height * angle_rad;
    
    IN.position = DoTwist(IN.position, ang);

    OUT.hposition = mul( float4(IN.position.x ,IN.position.y ,IN.position.z, 1), worldViewProj); //
    OUT.tex0 = IN.tex0 ;
     // normalize(a) returns a normalized version of a.
     // in this case, a = vLightDirection
     float3 L = normalize(-lightDir);
     // transform our normal with matInverseWorld, and normalize it

     IN.normal.xyz= DoTwist(IN.normal.xyz, ang);

     float3 N = normalize(mul(IN.normal.xyz,matWorld      ));
     OUT.lightnormal =  saturate(dot(L, N)); 
     OUT.tex0 = IN.tex0;
    return OUT;
}

float4 myps(VS_OUTPUT IN) : COLOR
{
    return tex2D(Sampler1, IN.tex0 )*(IN.lightnormal*0.9+0.1) ;
}

technique inverse
{
    pass p1  
    {
        VertexShader = compile vs_2_0 myvs();
        PixelShader = compile ps_2_0 myps();
    }
}








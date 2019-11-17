//-----------------------------------------------------------------------------
//           Name: MoveFlaggeNormals.fx
//         Author: Michael Paulwitz
//  Last Modified: 28.10.09
//    Description: move Flag 
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float4x4 worldViewProj : WorldViewProjection; // This matrix will be loaded by the application
float4x4   matWorld      ; // For calculating normals

texture texture0;
float time;
float halvewidh = 10;
float3          lightDir            ; // Our lights direction

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
    float4 normal   : NORMAL0 ;
};


// Once the vertex shader is finished, it will 
// pass the vertices on to the pixel shader like this...

struct VS_OUTPUT
{
    float4 hposition : POSITION;
    float2 texture0  : TEXCOORD0;
    float4 lightnormal : COLOR0;
};


//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;

        float4 v = float4( IN.position.x, IN.position.y, IN.position.z, 1.0f );
        float angle= time *4;

        v.z = sin( v.x+angle) ;
        v.z += sin( v.y /2+angle);
        v.z *= (v.x+halvewidh ) * 0.09f;
        //v.z *= (v.y-6 ) * 0.09f;

        float v2 = sin( v.x+angle-0.5) ;
        v2 += sin( v.y /2+angle);
        v2 *= (v.x-0.5+halvewidh ) * 0.09f;
        //v2 *= (v.y-6 ) * 0.09f;

         float3 poss[3];
                
         poss[0] = v.xyz;
         poss[1] = float3(v.x-0.5,v.y,v2);
         poss[2] = float3(v.x,v.y-0.5,v.z);

         float3 side1 = poss[0] - poss[2];
         float3 side2 = poss[0] - poss[1];
         IN.normal.xyz = cross(side1,side2);

        OUT.hposition = mul( v, worldViewProj   );
        
        float3 L = normalize(-lightDir);
        // transform our normal with matInverseWorld, and normalize it
        float3 N = normalize(mul(IN.normal.xyz,matWorld ));

        OUT.lightnormal =  saturate(dot(L, N)); 

       OUT.texture0 = IN.texture0;
        return OUT;
}

float4 myps(VS_OUTPUT IN) : COLOR
{
    return tex2D(Sampler1, IN.texture0)*(IN.lightnormal*0.8+0.2);
}

//-----------------------------------------------------------------------------
// Simple Effect (1 technique with 1 pass)
//-----------------------------------------------------------------------------

technique flag
{
    pass Pass0
    {
		PixelShader = compile ps_2_0 myps();
		VertexShader = compile vs_2_0 myvs();
    }
}













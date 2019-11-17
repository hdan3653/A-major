// PS 3.0 version Zinvert
uniform float time;
float4 mouse = float4(0.1,0.1,0,0);

//texture entSkin1;
texture Tex01;
sampler postTex = sampler_state
{
//  Texture = <entSkin1>;
  Texture = <Tex01>;
};

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
    float2 p = -1.0 + 2.0 * Tex.xy;
    float2 uv;
   
    float a = atan2(p.y,p.x);
    float r = sqrt(dot(p,p));

    uv.x = .75*time+.1/r;
    uv.y = a/3.1416;

    float3 col =  tex2D(postTex,uv).xyz;

    return float4(col*r,1.0);

}

// ---------------------------------------------
// Vertex Shader

struct VS_INPUT
{
    float3 position	: POSITION;
    float2 texture0     : TEXCOORD0;
};

struct VS_OUTPUT
{
     float4 hposition : POSITION;
     float2 texture0  : TEXCOORD0;
};

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;

    OUT.hposition = float4(IN.position.x ,IN.position.y ,IN.position.z, 1);
    OUT.texture0 = IN.texture0;
    return OUT;
}
// ---------------------------------------------

technique PostProcess
{
    pass p1
    {
       // Lighting = True;
       VertexShader = compile vs_2_0 myvs();
        PixelShader = compile ps_2_0 MyShader();
    }

}
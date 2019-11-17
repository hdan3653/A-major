// PS 3.0 version Multitexture

uniform float time;

texture entSkin1;
sampler postTex = sampler_state
{
  Texture = <entSkin1>;
};

texture Tex01;
sampler NewTex = sampler_state
{
  Texture = <Tex01>;
};


float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{

    float2 p = -1.0 + 2.0 * Tex.xy;
    // a rotozoom
    float2 cst = float2( cos(.5*time), sin(.5*time) );
    
    float2x2 rot = 0.5*cst.x*float2x2(cst.x,-cst.y,cst.y,cst.x);
    
    float3 col1 = tex2D(NewTex,mul(rot,p)).xyz;

    // scroll
    float3 col2 = tex2D(postTex,0.5*p+sin(0.1*time)).xyz;

    // blend layers
    float3 col = col2*col1;

    return float4(col,1.0);

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
       VertexShader = compile vs_3_0 myvs();
        PixelShader = compile ps_3_0 MyShader();
    }

}
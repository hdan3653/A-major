// PS 3.0 version Kaleidoscope

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
    float2 m = -1.0 + 2.0 * mouse.xy; 

    float a1 = atan2(p.y-m.y,p.x-m.x);
    float r1 = sqrt(dot(p-m,p-m));
    float a2 = atan2(p.y+m.y,p.x+m.x);
    float r2 = sqrt(dot(p+m,p+m));

    float2 uv;
    uv.x = 0.2*time + (r1-r2)*0.25;
    uv.y = sin(2.0*(a1-a2));

    float w = r1*r2*0.8;
    float3 col = tex2D(postTex,uv).xyz;

    return float4(col/(.1+w),1.0);

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
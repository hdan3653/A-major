// PS 3.0 version Star

uniform float time;

//texture entSkin1;
texture Tex01;
sampler postTex = sampler_state
{
//  Texture = <entSkin1>;
  Texture = <Tex01>;
};

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
   
    float2 uv;

    float2 p = -1.0 + 2.0 * Tex.xy ;
    float a = atan2(p.y,p.x);
    float r = sqrt(dot(p,p));
    float s = r * (1.0+0.8*cos(time*1.0));

    uv.x =          .02*p.y+.03*cos(-time+a*3.0)/s;
    uv.y = .1*time +.02*p.x+.03*sin(-time+a*3.0)/s;

    float w = .9 + pow(max(1.5-r,0.0),4.0);

    w*=0.6+0.4*cos(time+3.0*a);

    float3 col =  tex2D(postTex,uv).xyz;

    return float4(col*w,1.0);

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
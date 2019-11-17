// PS 3.0 version Motion Blur

uniform float time;

texture entSkin1;
sampler postTex = sampler_state
{
  Texture = <entSkin1>;
};

float3 deform( in float2 p, float scale )
{
    float2 uv;
   
    float mtime = scale+time;
    float a = atan2(p.y,p.x);
    float r = sqrt(dot(p,p));
    float s = r * (1.0+0.5*cos(mtime*1.7));

    uv.x = .1*mtime +.05*p.y+.05*cos(-mtime+a*3.0)/s;
    uv.y = .1*mtime +.05*p.x+.05*sin(-mtime+a*3.0)/s;

    float w = 0.8-0.2*cos(mtime+3.0*a);

    float3 res = tex2D(postTex,uv).xyz*w;
    return  res*res;

}


float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
   
    float2 p = -1.0 + 2.0 * Tex.xy;
    float3 total = float3(0,0,0);
    float w = 0.0;
    for( int i=0; i<20; i++ )
    {
        float3 res = deform(p,w);
        total += res;
        w += 0.02;
    }
    total /= 20.0;

    return float4( 3.0*total,1.0);


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
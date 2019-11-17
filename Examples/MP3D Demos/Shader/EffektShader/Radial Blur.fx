// PS 3.0 version Radial Blur

uniform float time;

texture entSkin1;
sampler postTex = sampler_state
{
  Texture = <entSkin1>;
};


float3 deform( in float2 p )
{
    float2 uv;

    float2 q = float2( sin(1.1*time+p.x),sin(1.2*time+p.y) );

    float a = atan2(q.y,q.x);
    float r = sqrt(dot(q,q));

    uv.x = sin(0.0+1.0*time)+p.x*sqrt(r*r+1.0);
    uv.y = sin(0.6+1.1*time)+p.y*sqrt(r*r+1.0);

    return tex2D(postTex,uv*.5).xyz;
}


float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
   
    float2 p = -1.0 + 2.0 * Tex.xy;
    float2 s = p;

    float3 total = float3(0,0,0);
    float2 d = (float2(0.0,0.0)-p)/40.0;
    float w = 1.0;
    for( int i=0; i<40; i++ )
    {
        float3 res = deform(s);
        res = smoothstep(0.1,1.0,res*res);
        total += w*res;
        w *= .99;
        s += d;
    }
    total /= 40.0;
    float r = 1.5/(1.0+dot(p,p));
    return float4( total*r,1.0);


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
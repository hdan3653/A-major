// PS 2.0 version postprocessing

uniform float time;

texture entSkin1;
sampler postTex = sampler_state
{
  Texture = <entSkin1>;
};

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
   
    float2 q = Tex.xy;
    float2 uv = 0.5 + (q-0.5)*(0.9 + 0.1*sin(0.2*time));

    float3 oricol = tex2D(postTex,float2(q.x,1.0-q.y)).xyz;
    float3 col;

    col.r =  tex2D(postTex,float2(uv.x+0.003,-uv.y)).x;
    col.g =  tex2D(postTex,float2(uv.x+0.000,-uv.y)).y;
    col.b =  tex2D(postTex,float2(uv.x-0.003,-uv.y)).z;

    col = clamp(col*0.5+0.5*col*col*1.2,0.0,1.0);

    col *= 0.5 + 0.5*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y);

    col *= float3(0.8,1.0,0.7);

    col *= 0.9+0.1*sin(10.0*time+uv.y*1000.0);

    col *= 0.97+0.03*sin(110.0*time);

    float comp = smoothstep( 0.2, 0.7, sin(time) );
    col = lerp( col, oricol, clamp(-2.0+2.0*q.x+3.0*comp,0.0,1.0) );

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
       VertexShader = compile vs_2_0 myvs();
        PixelShader = compile ps_2_0 MyShader();
    }

}
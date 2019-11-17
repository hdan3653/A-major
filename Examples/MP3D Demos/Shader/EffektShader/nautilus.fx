// PS 3.0 version Monjori

uniform float time;

float e(float3 c)
{
    c=cos(float3(cos(c.r+time/6.0)*c.r-cos(c.g*3.0+time/5.0)*c.g, cos(time/4.0)*c.b/3.0*c.r-cos(time/7.0)*c.g, c.r+c.g+c.b+time));
    return dot(c*c,float3(1,1,1))-1.0;
}

float4 MyShader (float2 Tex : TEXCOORD, float4 gl_FragCoord : COLOR) : COLOR
{
    float2 c=-0.5  + gl_FragCoord.rg*Tex.xy;
//    float2 c=-1.0+2.0*gl_FragCoord.rg*Tex.xy;
//    float2 c=-1.0+2.0*gl_FragCoord.rg/resolution.xy;
    float3 o=float3(c.r,c.g,0.0),g=float3(c.r,c.g,1.0)/64.0,v=float3(0.5,0.5,0.5);
    float m = 0.4;
//    float m = 1.0-1.5*mouse.x/resolution.x;
    for(int r=0;r<100;r++)
    {
      float h=e(o)-m;
      if(h<0.0)break;
      o+=h*10.0*g;
      v+=h*0.02;
    }
    // light (who needs a normal?)
    v+=e(o+0.1)*float3(0.4,0.7,1.0);

    // ambient occlusion
    float a=0.0;
    for(int r=0;r<100;r++)
       a+=clamp(4.0*(e(o+0.5*float3(cos(1.1*float(r)),cos(1.6*float(r)),cos(1.4*float(r))))-m),0.0,1.0);
    v*=a/100.0;
    return float4(v,1.0);
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
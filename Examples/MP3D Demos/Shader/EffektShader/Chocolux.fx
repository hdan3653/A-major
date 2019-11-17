// PS 3.0 version Chocolux

uniform float time;

float4 MyShader (float2 Tex : TEXCOORD, float4 color : COLOR) : COLOR
{

    float3 s[4];
    s[0]=float3(0,0,0);
    s[3]=float3(sin(time),cos(time),0);
    s[1]=s[3].zxy;
    s[2]=s[3].zzx;

    float t,b,c,h=0.0;
    float3 m,n;
    float3 p=float3(0.2-Tex.x,0.2-Tex.y,0.5);
    float3 d=normalize(0.01*color.rgb-p);
    for(int i=0;i<4;i++)
    {
        t=2.0;
        for(int i=0;i<4;i++)
        {
            b=dot(d,n=s[i]-p);
            c=b*b+.2-dot(n,n);
            if(b-c<t)
            if(c>0.0)
            {
                m=s[i];t=b-c;
            }
        }
    p+=t*d;
    d=reflect(d,n=normalize(p-m));
    h+=pow(n.x*n.x,44.)+n.x*n.x*.2;
    }
    return float4(h,h*h,h*h*h*h,1);

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
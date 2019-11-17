// PS 3.0 version metatunnel.fx

uniform float time;

float h(float3 q)
{
    float f=1.*distance(q,float3(cos(time)+sin(time*.2),.3,2.+cos(time*.5)*.5));
    f*=distance(q,float3(-cos(time*.7),.3,2.+sin(time*.5)));
    f*=distance(q,float3(-sin(time*.2)*.5,sin(time),2.));
    f*=cos(q.y)*cos(q.x)-.1-cos(q.z*7.+time*7.)*cos(q.x*3.)*cos(q.y*4.)*.1;
    return f;
}

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
    float2 p = -1.0 + 2.0 * Tex.xy;
    float3 o=float3(p.x,p.y*1.25-0.3,0.);
    float3 d=float3(p.x+cos(time)*0.3,p.y,1.)/128;
    float4 c=float4(0,0,0,0);
    float t=0.01;
    for(int i=0;i<25;i++)
//    for(int i=0;i<75;i++)
    {
        if(h(o+d*t)<.4)
        {
            t-=5;
            for(int j=0;j<5;j++)
            {
                if(h(o+d*t)<.4)
                    break;
                t+=1;
            }
            float3 e=float3(.01,.0,.0);
            float3 n=float3(.0,.0,.0);
            n.x=h(o+d*t)-h(float3(o+d*t+e.xyy));
            n.y=h(o+d*t)-h(float3(o+d*t+e.yxy));
            n.z=h(o+d*t)-h(float3(o+d*t+e.yyx));
            n=normalize(n);
            c+=max(dot(float3(.0,.0,-5),n),.0)*0.1+max(dot(float3(.0,-5,5),n),.0)*0.1;
            break;
        }
        t+=5.;
    }
    return  c ; //+ float4(.1,.2,.5,1.)*(t*.025);
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
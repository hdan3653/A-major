// PS 3.0 version RoadRibbon.fx

uniform float time;

//Object A (tunnel)
float oa(float3 q)
{
 return cos(q.x)+cos(q.y*1.5)+cos(q.z)+cos(q.y*20.)*.05;
}

//Object B (ribbon)
float ob(float3 q)
{
 return length(max(abs(q-float3(cos(q.z*1.5)*.3,-.5+cos(q.z)*.2,.0))-float3(.125,.02,time+3.),float3(.0,0,0)));
}

//Scene
float o(float3 q)
{
 return min(oa(q),ob(q));
}

//Get Normal
float3 gn(float3 q)
{
 float3 f=float3(.01,0,0);
 return normalize(float3(o(q+f.xyy),o(q+f.yxy),o(q+f.yyx)));
}

//Get mix
float4 mix(float x, float y, float a)
{
 
// Returns the linear blend of x and y, i.e.,
// x * ( 1-a) + y * a
// x, y, a
 return float4 (     x * ( 1-a) + y * a,   x * ( 1-a) + y * a,   x * ( 1-a) + y * a,   x * ( 1-a) + y * a ) ;
}

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
 float2 p = -1.0 + 2.0 * Tex.xy;
 p.x *= 1.3;
 
 float4 c=float4(1,1,1,1);
 float3 org=float3(sin(time)*.5,cos(time*.5)*.25+.25,time),dir=normalize(float3(p.x*1.6,p.y,1.0)),q=org,pp;
 float d=.0;

 //First raymarching
 for(int i=0;i<64;i++)
 {
  d=o(q);
  q+=d*dir;
 }
 pp=q;
 float f=length(q-org)*0.02;

 //Second raymarching (reflection)
 dir=reflect(dir,gn(q));
 q+=dir;
 for(int ii=0;ii<64;ii++)
 {
 d=o(q);
 q+=d*dir;
 }
 c=max(dot(gn(q),float3(.1,.1,.0)),.0)+float4(.3,cos(time*.5)*.5+.5,sin(time*.5)*.5+.5,1.)*min(length(q-org)*.04,1.);

 //Ribbon Color
 if(oa(pp)>ob(pp))c=mix(c,float4(cos(time*.3)*.5+.5,cos(time*.2)*.5+.5,sin(time*.3)*.5+.5,1.),.3);

 //Final Color
 float4 fcolor = ((c+float4(f,f,f,f))+(1.-min(pp.y+1.9,1.))*float4(1.,.8,.7,1.))*min(time*.5,1.);
return float4(fcolor.xyz,1.0);

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
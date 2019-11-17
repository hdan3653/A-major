// PS 3.0 version 704.fx

uniform float time;

static float stime=sin(time);
static float ctime=cos(time);

float inObj(in float3 p){
  float oP=length(p);
  p.x=sin(p.x)+stime;
  p.z=sin(p.z)+ctime;
  return float(min(length(p)-1.5-sin(oP-time*4.0),p.y+3.0));
}

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{

  float2 vPos=+1.0-2.0*Tex.xy;

  //Camera animation
  float3 vuv=float3(stime,1,0);//view up vector
  float3 vrp=float3(sin(time*0.7)*10.0,0,cos(time*0.9)*10.0); //view reference point
  float3 prp=float3(sin(time*0.7)*20.0+vrp.x+20.0,
  stime*4.0+4.0+vrp.y+3.0,
  cos(time*0.6)*20.0+vrp.z+14.0); //camera position

  //Camera setup
  float3 vpn=normalize(vrp-prp);
  float3 u=normalize(cross(vuv,vpn));
  float3 v=cross(vpn,u);
  float3 vcv=(prp+vpn);
  float3 scrCoord=vcv+vPos.x*u+vPos.y*v;
  float3 scp=normalize(scrCoord-prp);

  //Raymarching
  const float3 e = float3(0.1,0,0);
  const float maxd=200.0;

  float s=0.1;
  float3 c,p,n;

  //speed optimization -advance ray (simple raytracing) until plane y=2.5
  float f=-(prp.y-2.5)/scp.y;
  if (f>0.0) p=prp+scp*f;
  else f=maxd;

  for(int i=0;i<256;i++) {
    if (abs(s)<.01||f>maxd) break;
    f+=s;
    p=prp+scp*f;
    s=inObj(p);
  }

  if (f<maxd) {
    if(p.y<-2.5){
     if (frac(p.x*.5)>.5) {
        if (frac(p.z*.5)>.5)
          c=float3(0,0,0);
        else
          c=float3(1,1,1);
         }
      else {
        if (frac(p.z*.5)>.5)
          c = float3(1,1,1);
        else
          c = float3(0,0,0);
      n=float3(0,1,0);
    }}
    else{
      float d=length(p);
      c=float3((sin(d*.25-time*4.0)+1.0)/2.0,
             (stime+1.0)/2.0,
             (sin(d-time*4.0)+1.0)/2.0); //color
       n=normalize(
        float3(s-inObj(p-e.xyy),
             s-inObj(p-e.yxy),
             s-inObj(p-e.yyx)));
    }
    float b=dot(n,normalize(prp-p));
    return float4((b*c+pow(b,54.0))*(1.0-f*.005),1.0);
 }
 else 
     return float4(0,0,0,1);

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
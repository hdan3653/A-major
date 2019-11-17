float4x4 worldViewProjI; float postfx;
#ifdef GL_ES
// precision highp float;
#endif

uniform float2 resolution = float2(933,511) ; // Screensize;
uniform float time;

float3x3 m = float3x3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return frac(sin(n)*43758.5453);
}


float noise( in float3 x )
{
    float3 p = floor(x);
    float3 f = frac(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = lerp(lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
                        lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
                        lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( float3 p )
{
    float f = 0.0;

    f += 0.5000*noise( p ); p = mul (m,p*2.02);
    f += 0.2500*noise( p ); p = mul(m,p*2.03);
    f += 0.1250*noise( p ); p = mul(m,p*2.01);
    f += 0.0625*noise( p );

    return f/0.9375;
}

float2 map( float3 p )
{
   float2 d2 = float2( p.y+0.55, 2.0 );

   p.y -= 0.75*pow(dot(p.xz,p.xz),0.2);
   float2 d1 = float2( length(p) - 1.0, 1.0 );

   if( d2.x<d1.x) d1=d2;
   return d1;
}


float3 appleColor( in float3 pos, in float3 nor, out float2 spe )
{
    spe.x = 1.0;
    spe.y = 1.0;

    float a = atan2(pos.x,pos.z);
    float r = length(pos.xz);

    // red
    float3 col = float3(1.0,0.0,0.0);

    // green
    float f = smoothstep( 0.1, 1.0, fbm(pos*1.0) );
    col = lerp( col, float3(0.8,1.0,0.2), f );

    // dirty
    f = smoothstep( 0.0, 1.0, fbm(pos*4.0) );
    col *= 0.8+0.2*f;

    // frekles
    f = smoothstep( 0.0, 1.0, fbm(pos*48.0) );
    f = smoothstep( 0.7,0.9,f);
    col = lerp( col, float3(0.9,0.9,0.6), f*0.5 );

    // stripes
    f = fbm( float3(a*7.0 + pos.z,3.0*pos.y,pos.x)*2.0);
    f = smoothstep( 0.2,1.0,f);
    f *= smoothstep(0.4,1.2,pos.y + 0.75*(noise(4.0*pos.zyx)-0.5) );
    col = lerp( col, float3(0.4,0.2,0.0), 0.5*f );
    spe.x *= 1.0-0.35*f;
    spe.y = 1.0-0.5*f;

    // top
    f = 1.0-smoothstep( 0.14, 0.2, r );
    col = lerp( col, float3(0.6,0.6,0.5), f );
    spe.x *= 1.0-f;


    float ao = 0.5 + 0.5*nor.y;
    col *= ao*1.2;

    return col;
}

float3 floorColor( in float3 pos, in float3 nor, out float2 spe )
{
    spe.x = 1.0;
    spe.y = 1.0;
    float3 col = float3(0.5,0.4,0.3)*1.7;

    float f = fbm( 4.0*pos*float3(6.0,0.0,0.5) );
    col = lerp( col, float3(0.3,0.2,0.1)*1.7, f );
    spe.y = 1.0 + 4.0*f;

    f = fbm( 2.0*pos );
    col *= 0.7+0.3*f;

    // frekles
    f = smoothstep( 0.0, 1.0, fbm(pos*48.0) );
    f = smoothstep( 0.7,0.9,f);
    col = lerp( col, float3(0.2,0.2,0.2), f*0.75 );

    // fake ao
    f = smoothstep( 0.1, 1.55, length(pos.xz) );
    col *= f*f*1.4;
    col.x += 0.1*(1.0-f);
    return col;
}

float2 intersect( in float3 ro, in float3 rd )
{
    float t=0.0;
    float dt = 0.06;
    float nh = 0.0;
    float lh = 0.0;
    float lm = -1.0;
    for(int i=0;i<100;i++)
    {
        float2 ma = map(ro+rd*t);
        nh = ma.x;
        if(nh>0.0) { lh=nh; t+=dt;  } lm=ma.y;
    }

    if( nh>0.0 ) return float2(-1.0,-1.0);
    t = t - dt*nh/(nh-lh);

    return float2(t,lm);
}

float softshadow( in float3 ro, in float3 rd, float mint, float maxt, float k )
{
    float res = 1.0;
    float dt = 0.1;
    float t = mint;
    for( int i=0; i<30; i++ )
    {
        float h = map(ro + rd*t).x;
        if( h>0.001 )
            res = min( res, k*h/t );
        else
            res = 0.0;
        t += dt;
    }
    return res;
}
float3 calcNormal( in float3 pos )
{
    float3  eps = float3(.001,0.0,0.0);
    float3 nor;
    nor.x = map(pos+eps.xyy).x - map(pos-eps.xyy).x;
    nor.y = map(pos+eps.yxy).x - map(pos-eps.yxy).x;
    nor.z = map(pos+eps.yyx).x - map(pos-eps.yyx).x;
    return normalize(nor);
}

float4 main(float2 gl_FragCoord: TEXCOORD0, float4 gl_FragColor: COLOR ) : COLOR
{
if (postfx == 1) gl_FragCoord.x = gl_FragCoord.x + 0.23;

gl_FragCoord.y = 1 - gl_FragCoord.y; gl_FragCoord = gl_FragCoord * resolution;

    float2 q = gl_FragCoord.xy / resolution.xy;
    float2 p = -1.0 + 2.0 * q;
    p.x *= resolution.x/resolution.y;

    // camera
    float3 ro = 2.5*normalize(float3(cos(0.2*time),1.15+0.4*cos(time*.11),sin(0.2*time)));
    float3 ww = normalize(float3(0.0,0.5,0.0) - ro);
    float3 uu = normalize(cross( float3(0.0,1.0,0.0), ww ));
    float3 vv = normalize(cross(ww,uu));
    float3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    // raymarch
    float3 col = float3(0.96,0.98,1.0);
    float2 tmat = intersect(ro,rd);
    if( tmat.y>0.5 )
    {
        // geometry
        float3 pos = ro + tmat.x*rd;
        float3 nor = calcNormal(pos);
        float3 ref = reflect(rd,nor);
        float3 lig = normalize(float3(1.0,0.8,-0.6));
     
        float con = 1.0;
        float amb = 0.5 + 0.5*nor.y;
        float dif = max(dot(nor,lig),0.0);
        float bac = max(0.2 + 0.8*dot(nor,float3(-lig.x,lig.y,-lig.z)),0.0);
        float rim = pow(1.0+dot(nor,rd),3.0);
        float spe = pow(clamp(dot(lig,ref),0.0,1.0),16.0);

        // shadow
        float sh = softshadow( pos, lig, 0.06, 4.0, 4.0 );

        // lights
        col  = 0.10*con*float3(0.80,0.90,1.00);
        col += 0.70*dif*float3(1.00,0.97,0.85)*float3(sh, (sh+sh*sh)*0.5, sh*sh );
        col += 0.15*bac*float3(1.00,0.97,0.85);
        col += 0.20*amb*float3(0.10,0.15,0.20);


        // color
        float2 pro;
        if( tmat.y<1.5 )
        col *= appleColor(pos,nor,pro);
        else
        col *= floorColor(pos,nor,pro);

        // rim and spec
        col += 0.60*rim*float3(1.0,0.97,0.85)*amb*amb;
        col += 0.60*pow(spe,pro.y)*float3(1,1,1)*pro.x*sh;

        col = 0.3*col + 0.7*sqrt(col);
    }

    col *= 0.25 + 0.75*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15 );

    gl_FragColor = float4(col,1.0);
            return gl_FragColor;

}
// Vertex Shader
struct VS_INPUT
{
    float3 position   : POSITION;
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
    if (postfx == 0) {
      OUT.hposition = mul( worldViewProjI, float4(IN.position.x ,IN.position.y ,IN.position.z, 1) ); 
    } else {
      OUT.hposition = float4(IN.position.x ,IN.position.y ,IN.position.z, 1);
    }    
    OUT.texture0 = IN.texture0;
    return OUT;
}
// ---------------------------------------------
technique Start
{
    pass p1  
    {
        VertexShader = compile vs_3_0 myvs();
        PixelShader = compile ps_3_0 main();
    }
}

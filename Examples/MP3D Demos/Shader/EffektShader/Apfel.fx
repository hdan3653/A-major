// PS 3.0 version Julia

float time ;

float4 MyShader(float2 Tex : TEXCOORD) : COLOR
{

    float2 p = -1.0 + 2.0 * Tex.xy; //  / resolution.xy;
    p.x *= 1;  // resolution.x/resolution.y;

    float zoo = .62+.38*sin(.1*time);
    float coa = cos( 0.1*(1.0-zoo)*time );
    float sia = sin( 0.1*(1.0-zoo)*time );
    zoo = pow( zoo,8.0);
    float2 xy = float2( p.x*coa-p.y*sia, p.x*sia+p.y*coa);
    float2 cc = float2(-.745,.186) + xy*zoo;

    float2 z  = float2(0.0,0.0);
    float2 z2 = z*z;
    float m2;
    float co = 0.0;
    for( int i=0; i<256; i++ )
    {
        z = cc + float2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
        m2 = dot(z,z);
        if( m2>1024.0 ) break;
        co += 1.0;
        }
    co = co + 1.0 - log2(.5*log2(m2));

    co = sqrt(co/256.0);
    return float4( .5+.5*cos(6.2831*co+0.0),
                         .5+.5*cos(6.2831*co+0.4),
                         .5+.5*cos(6.2831*co+0.7),
                         1.0 );

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
        VertexShader = compile vs_3_0 myvs();
        PixelShader = compile ps_3_0 MyShader();
    }

}


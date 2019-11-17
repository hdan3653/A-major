// PS 3.0 version Julia

float time;

float4 MyShader(float2 Tex : TEXCOORD) : COLOR
{
     // ;float4 gl_FragColor; 

     float2 p = -1.0 + 2.0 * Tex.xy;
     float2 cc = float2( cos(.25*time), sin(.25*time*1.423) );

     float dmin = 1000.0;
     float2 z  = p*float2(1.33,1.0);
     for( int i=0; i<64; i++ )
     {
        z = cc + float2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
        float m2 = dot(z,z);
         if( m2>100.0 ) break;
        dmin=min(dmin,m2);
         }

     float color = sqrt(sqrt(dmin))*0.7;
     return float4(color,color,color,1.0);// 


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


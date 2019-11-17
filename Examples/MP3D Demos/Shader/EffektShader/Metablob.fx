// PS 3.0 version Metablob

uniform float time;

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
   
    //the centre point for each blob
    float2 move1;
    move1.x = cos(time)*0.4;
    move1.y = sin(time*1.5)*0.4;
    float2 move2;
    move2.x = cos(time*2.0)*0.4;
    move2.y = sin(time*3.0)*0.4;
    
    //screen coordinates
    float2 p = -1.0 + 2.0 * Tex.xy;
  
    //radius for each blob
    float r1 =(dot(p-move1,p-move1))*8.0;
    float r2 =(dot(p+move2,p+move2))*16.0;

    //sum the meatballs
    float metaball =(1.0/r1+1.0/r2);
    //alter the cut-off power
    float col = pow(metaball,8.0);

    //set the output color
     return float4(col,col,col,1.0);

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
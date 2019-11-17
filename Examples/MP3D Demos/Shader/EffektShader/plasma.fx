// PS 3.0 version

float2 resolution = {800,600}; // muss man vorgeben oder einfach als variable übergeben
float time;

float4 MyShader(float2 Tex : TEXCOORD) : COLOR
{
   float4 Color;

   float x = Tex.x * resolution.x ;
   float y = Tex.y * resolution.y;

   float mov0 = x+y+cos(sin(time)*2.)*100.+sin(x/100.)*1000.;
   float mov1 = y /  resolution.y / 0.2 + time;
   float mov2 = x /  resolution.x / 0.2 ;
   float c1 = abs(sin(mov1+time)/2.+mov2/2.-mov1-mov2+time);
   float c2 = abs(sin(c1+sin(mov0/1000.+time)+sin(y/40.+time)+sin((x+y)/100.)*3.));
   float c3 = abs(sin(c2+cos(mov1+mov2+c2)+cos(mov2)+sin(x/1000.)));
   return Color = float4( c1,c2,c3,1.0);
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
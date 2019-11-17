float4x4 worldViewProjI;
float postfx; 
int Iterations = 256;

float Var1; // Change the zoom
float Var2; // Change coords x
float Var3; // Change coords y

#define ENABLE_MANDELBROT

static float2 Pan = float2(Var2,Var3-0.5);
static float Zoom = (log(Var1) * 6 +0.001);

float Aspect = 1;
float2 JuliaSeed = float2(0.39, -0.2);
float3 ColorScale = float3(4, 5, 6);

float ComputeValue(float2 v, float2 offset)
{
float vxsquare = 0;
float vysquare = 0;

int iteration = 0;
int lastIteration = Iterations;

do
{
vxsquare = v.x * v.x;
vysquare = v.y * v.y;

v = float2(vxsquare - vysquare, v.x * v.y * 2) + offset;

iteration++;

if ((lastIteration == Iterations) && (vxsquare + vysquare) > 4.0)
{
lastIteration = iteration + 1;
}
}
while (iteration < lastIteration);

return (float(iteration) - (log(log(sqrt(vxsquare + vysquare))) / log(2.0))) / float(Iterations);
}

float4 Mandelbrot_PixelShader(float2 texCoord : TEXCOORD0) : COLOR0
{
float2 v = (texCoord - 0.5) * Zoom * float2(1, Aspect) - Pan;

float val = ComputeValue(v, v);

float a = sin(val * ColorScale.x);
float b = sin(val * ColorScale.y);
float c = sin(val * ColorScale.z);

return float4(a,b,c, (a+b+c));
}

float4 Julia_PixelShader(float2 texCoord : TEXCOORD0) : COLOR0
{
float2 v = (texCoord - 0.5) * Zoom * float2(1, Aspect) - Pan;

float val = ComputeValue(v, JuliaSeed);

return float4(sin(val * ColorScale.x), sin(val * ColorScale.y), sin(val * ColorScale.z), 1);
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

#ifdef ENABLE_MANDELBROT
technique Mandelbrot
{
pass
{
Lighting         = FALSE;
AlphaTestEnable  = TRUE;
AlphaFunc        = Greater;
VertexShader = compile vs_3_0 myvs();
PixelShader = compile ps_3_0 Mandelbrot_PixelShader();
}
}
#endif

technique Julia
{
pass
{
VertexShader = compile vs_3_0 myvs();
PixelShader = compile ps_3_0 Julia_PixelShader();
}
}



//-----------------------------------------------------------------------------
//     Name: Shaderkind_Shader_Post.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: shader blue, post shader screen yellow
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float postfx;

float4 PStexture(float2 Tex : TEXCOORD0) : COLOR
{

    if (postfx == 0) {
       return float4(0,0,1,1);
    } else {
       return float4(1,1,0,1);
    }
}

technique inverse
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PStexture();
    }
}

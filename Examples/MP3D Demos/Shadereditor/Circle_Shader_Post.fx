//-----------------------------------------------------------------------------
//     Name: Circle_Shader_Post.fx
//     Author: Michael Pauwlitz
//    Last Modified: 
//    Description: Create Circle
//-----------------------------------------------------------------------------

float4 PSCircle(float2 Tex : TEXCOORD0) : COLOR
{
    return float4(sin(length(Tex -0.5) * 100.0) * 0.5 + 0.5,0, 0, 1);
}

technique circle
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSCircle();
    }
}


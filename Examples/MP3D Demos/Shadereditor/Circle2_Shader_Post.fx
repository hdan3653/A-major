//-----------------------------------------------------------------------------
//     Name: Circle2_Shader_Post.fx
//     Author: Michael Pauwlitz
//    Last Modified: 
//    Description: Create Circle with special post viewport
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

float postfx;

float4 PSCircle(float2 Tex : TEXCOORD0) : COLOR
{
    
   if  (postfx == 0)
    return float4(sin(length(Tex -0.5) * 100.0) * 0.5 + 0.5,0, 0, 1);
    else
    Tex.x = (Tex.x - 0.28)*1.8;
    Tex.y = Tex.y - 0.5;
    return float4(sin(length(Tex) * 100.0) * 0.5 + 0.5,0, 0, 1);


}

technique circle
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSCircle();
    }
}



//-----------------------------------------------------------------------------
//     Name: Fade_Shader_Post.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Texture Fade Shader
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

texture texture0;
texture texture1;
float Var1;

sampler Sampler1 = sampler_state 
{ 
texture   = <texture0>;
};

sampler Sampler2 = sampler_state 
{ 
texture   = <texture1>;
};

float4 PSFade(float2 Tex : TEXCOORD0) : COLOR
{
    return (tex2D(Sampler1, Tex)*Var1) + ( tex2D(Sampler2, Tex)*(1-Var1));
}

technique main
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSFade();
    }
}





//-----------------------------------------------------------------------------
//     Name: Easy_texture_Shader_Post.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Easy PixelShader, Show only the texture0
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

texture texture0;

sampler Sampler1 = sampler_state 
{ 
texture   = <texture0>;
};

float4 PStexture(float2 Tex : TEXCOORD0) : COLOR
{
    return tex2D(Sampler1, Tex);
}

technique inverse
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PStexture();
    }
}




//-----------------------------------------------------------------------------
//     Name: Inverse_texture_Shader_Post.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Easy Vertex Shader, Show only the color of the Vertex
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

texture texture0;

sampler Sampler1 = sampler_state 
{ 
texture   = <texture0>;
};

float4 PSInverse(float2 Tex : TEXCOORD0) : COLOR
{
    return 1.0f - tex2D(Sampler1, Tex);
}

technique inverse
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSInverse();
    }
}




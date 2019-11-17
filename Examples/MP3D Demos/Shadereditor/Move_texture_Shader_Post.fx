//-----------------------------------------------------------------------------
//     Name: Move_texture_shader_post.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Easy Shader to move the texture
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

texture texture0;
float time;

sampler Sampler1 = sampler_state 
{ 
texture   = <texture0>;
};

float4 PSInverse(float2 Tex : TEXCOORD0) : COLOR
{
    return tex2D(Sampler1, float2(Tex.x,Tex.y+(1*sin(time))));
}

technique inverse
{
    pass p1  
    {

        PixelShader = compile ps_2_0 PSInverse();
    }
}





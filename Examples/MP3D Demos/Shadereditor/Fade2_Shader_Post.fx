//-----------------------------------------------------------------------------
//     Name: Fade2_Shader_Post.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Texture Fade2 Shader
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
    if (Var1 > Tex.y) 
       return tex2D(Sampler1, Tex);
    else
       return  tex2D(Sampler2, Tex);


}

technique main
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSFade();
    }
}





//-----------------------------------------------------------------------------
//     Name: Simple_Brightness_contrast_Shader_post.fx
//     Author: Michael Paulwitz
//    Last Modified:
//    Description: Brightness and contrast 
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

texture texture0;
float Var1;
float Var2;


sampler Sampler1 = sampler_state 
{ 
texture   = <texture0>;
};

float4 PSbrightcont(float2 Tex : TEXCOORD0) : COLOR
{
    float brightness= Var1;
    float contrast = Var2;
   float4 color = tex2D(Sampler1, Tex ); 
   return (color + brightness) * (1.0+contrast) / 1.0;

}

technique brightnesscontrast
{
    pass p1  
    {
        PixelShader = compile ps_2_0 PSbrightcont();
    }
}

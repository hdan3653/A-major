#version 				330 core

// input
in 		vec2 			vTexCoord;

// sampler
uniform sampler2D 		sColor;

// Time
uniform float			fTime;

// uniform buffer
layout(std140) uniform 	Material 
{
	vec4 	vColor;
	float 	fRoughness;
	float	fMetallic;
	float 	fSpecular;
	float	fEmission;
};

// output
layout (location = 0) out vec4 vFragColor;

// main
void main( void )
{
	
	vec4 	vColor						 = texture(sColor, vTexCoord) * vColor;
	
			vFragColor			 		 = vec4(vColor.r*0.25, vColor.g*(sin(fTime)*0.5+0.5), vColor.b*0.25, vColor.a);
			
}
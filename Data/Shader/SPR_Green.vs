#version 				330 core

// input
layout (location = 0) in vec4 	vVertex;
layout (location = 2) in vec2 	vTexCoord0;

// uniform buffer
layout(std140) uniform 	Matrices 
{
	mat4 mProjectionMatrix;
	mat4 mWorldViewMatrix;
	mat3 mNormalMatrix;
};

// output
out vec2			vTexCoord;

// main
void main( void )
{

			gl_Position 				 = mProjectionMatrix * mWorldViewMatrix * vVertex;	
			
			vTexCoord					 = vTexCoord0;
	
}
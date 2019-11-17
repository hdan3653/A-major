// PS 3.0 version Sierpinksi

uniform float2 resolution;
uniform float time;
sampler2D tex0;

float4 MyShader (float2 Tex : TEXCOORD) : COLOR
{
	int2 sectors;
	float2 coordOrig = Tex.xy;
	const int lim = 5;
	// Toggle between "carpet" and "tablecloth" every 3 seconds.
	bool doInverseHoles = (fmod(time, 6.0) < 3.0);
	
	/* If you want it to spin, just to prove that it is redrawing
	the carpet every frame: */
	float2 center = float2(0.5, 0.5);
	float2x2 rotation = float2x2(
        float2( cos(time), sin(time)),
        float2(-sin(time), cos(time))
    );
    float2 coordRot = mul(rotation, (coordOrig - center)) + center;
	// rotation can put us out of bounds
	if (coordRot.x < 0.0 || coordRot.x > 1.0 ||
		coordRot.y < 0.0 || coordRot.y > 1.0) {
 		      return float4(0,0,0,0);
	}

	float2 coordIter = coordRot;
	bool isHole = false;
	
	for (int i=0; i < lim; i++) {
		sectors = int2(floor(coordIter.xy * 3.0));
		if (sectors.x == 1 && sectors.y == 1) {
			if (doInverseHoles) {
				isHole = !isHole;
			} else {
  		                                return float4(0,0,0,0);
			}
		}

		if (i + 1 < lim) {
			// map current sector to whole carpet
			coordIter.xy = coordIter.xy * 3.0 - float2(sectors.xy);
		}
	}
	
	// setColor(isHole ? coordOrig : coordRot, isHole);
             	if (isHole)
 		return float4(0,0,0,0);
	else
		return float4(coordRot.x, 0.5, coordRot.y, 1.0);
}


// ---------------------------------------------
// Vertex Shader

struct VS_INPUT
{
    float3 position	: POSITION;
    float2 texture0     : TEXCOORD0;
};

struct VS_OUTPUT
{
     float4 hposition : POSITION;
     float2 texture0  : TEXCOORD0;
};

VS_OUTPUT myvs( VS_INPUT IN )
{
    VS_OUTPUT OUT;

    OUT.hposition = float4(IN.position.x ,IN.position.y ,IN.position.z, 1);
    OUT.texture0 = IN.texture0;
    return OUT;
}
// ---------------------------------------------

technique PostProcess
{
    pass p1
    {
       // Lighting = True;
       VertexShader = compile vs_3_0 myvs();
        PixelShader = compile ps_3_0 MyShader();
    }

}
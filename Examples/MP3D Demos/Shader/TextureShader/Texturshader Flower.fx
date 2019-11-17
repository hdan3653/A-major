// Color Demo with Lines
float time;

//float u( float x ) { return 0.5+0.5*sign(x); }
float u( float x ) { return (x>0.0)?1.0:0.0; }
//float u( float x ) { return abs(x)/x; }

float4 Testout (float2 Tex : POSITION) : COLOR
{
    float2 p = (2.0*Tex.xy - (1,1) ); //-resolution)/resolution.y;

    float a = atan2(p.x,p.y);
    float r = length(p)*.75;

    float w = cos(3.1415927*time-r*2.0);
    float h = 0.5+0.5*cos(12.0*a-w*7.0+r*8.0);
    float d = 0.25+0.75*pow(h,1.0*r)*(0.7+0.3*w);

    float col = u( d-r ) * sqrt(1.0-r/d)*r*2.5;
    col *= 1.25+0.25*cos((12.0*a-w*7.0+r*8.0)/2.0);
    col *= 1.0 - 0.35*(0.5+0.5*sin(r*30.0))*(0.5+0.5*cos(12.0*a-w*7.0+r*8.0));
    return float4(
        col,
        col-h*0.5+r*.2 + 0.35*h*(1.0-r),
        col-h*r + 0.1*h*(1.0-r),
        1.0);
}


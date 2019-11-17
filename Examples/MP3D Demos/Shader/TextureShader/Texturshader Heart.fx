// Color Demo with Lines
float time;

float4 Testout (float2 Tex : POSITION) : COLOR
{
    float2 p = (2.0*Tex.xy - (0,1) ); //-resolution)/resolution.y;

    // animate
    float tt = fmod (time,2.0)/2.0;
    float ss = pow(tt,.2)*0.5 + 0.5;
    ss -= ss*0.2*sin(tt*6.2831*5.0)*exp(-tt*6.0);
    p *= float2(0.5,1.5) + ss*float2(0.5,-0.5);
    float a = atan2(p.x,-p.y)/3.141593;
    float r = length(p);

    // shape
    float h = abs(a);
    float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);

    // color
    float f = step(r,d) * pow(1.0-r/d,0.25);

    return float4 (f,0.0,0.0,1.0);}


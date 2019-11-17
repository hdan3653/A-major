// Easy Sin Cos 2 Demo
// float2 a: POSITION = Texturposition, a.x and a.y 
// float4 = color (r,g,b,a) 
// r = sin(a.y*6.0-1)+cos(a.x*6.0-2.5)

float Var1;
float b;
float c;

float4 Testout(float2 a: POSITION ) : COLOR
  {
  c = 1 - a;
   b = (noise((a+Var1)*8)+1)/2+(noise((c+Var1)*8)+1)/2;

    return float4(b,0,0,0);
  };





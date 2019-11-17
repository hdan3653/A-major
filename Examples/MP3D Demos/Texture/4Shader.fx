// 4 side Color Demo

float4 Col1;  
float4 Col2;  
float4 Col3;  
float4 Col4;  


float4 Testout(  float2 vTexCoord : POSITION) : COLOR
 {
    float r,g, b;
    Col1.r = 1;
    Col2.r = 0;


    r = Col1.r - vTexCoord.x;
    g = 1;
    b = 1;
    return float4(r, g, b, 1);
  };





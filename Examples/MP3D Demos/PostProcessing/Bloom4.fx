Texture2D Texture1;
Texture2D Texture2;
#define SAMPLE_COUNT 15
float2 Offsets[SAMPLE_COUNT];
float4 Offsets2[SAMPLE_COUNT]; float Weights[SAMPLE_COUNT];  float BloomThreshold = 0.25; float BloomIntensity = 1.25; float BaseIntensity = 1; float BloomSaturation = 1; float BaseSaturation = 1;  sampler Sampler { 	Filter = MIN_MAG_MIP_POINT; 	AddressU = Clamp; 	AddressV = Clamp; }; 
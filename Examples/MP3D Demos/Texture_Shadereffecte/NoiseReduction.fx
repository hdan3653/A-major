float   LossyBlurFactor   = 1.05;
bool    bFilterByColor    = false;
bool    bFilterByContrast = true;
bool    bFilterByTone     = false;

float4  FilterColor    = {0.41, 0.54, 0.75, 1.0};
float   ColorFilterExp = 2.0;
float   ColorFilterMult= 1.0;

float2  pixelsize      = {0.001, 0.001};
float   MaxRadius      = 2.0;
float   DeltaExponent  = 1.0;  // 1.0 = linear
float   DeltaTolerance = 0.05;

texture TextureA;
sampler Sampler1 = sampler_state
{
    texture   = <TextureA>;
    AddressU  = Clamp;
    AddressV  = Clamp;
    MipFilter = None;
    MagFilter = None;
    MinFilter = None;
};

const float g_fBlurWeights[13] = 
{
    0.002216,  0.008764,  0.026995,  0.064759,  0.120985,  0.176033,
    0.199471,  0.176033,  0.120985,  0.064759,  0.026995,  0.008764,
    0.002216
};
const float2 g_PixelOffsetH[13] =
{
    { -6, 0 }, { -5, 0 }, { -4, 0 }, { -3, 0 }, { -2, 0 }, { -1, 0 },
    {  0, 0 }, {  1, 0 }, {  2, 0 }, {  3, 0 }, {  4, 0 }, {  5, 0 },
    {  6, 0 }
};
const float2 g_PixelOffsetV[13] =
{
    { 0, -6 }, { 0, -5 }, { 0, -4 }, { 0, -3 }, { 0, -2 }, { 0, -1 },
    { 0,  0 }, { 0,  1 }, { 0,  2 }, { 0,  3 }, { 0,  4 }, { 0,  5 },
    { 0,  6 }
};

float4 PSNoiseReduction(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 CompColor;
    float  Delta        = 0.0;
    float  RadiusX      = 1.0;
    float  RadiusY      = 1.0;
    float  fColorFilter = 1.0;
    float4 Color        = (float4)0.0;
    float4 OrigColor    = tex2D(Sampler1, Tex);
           
    if (bFilterByColor)
        fColorFilter = max(0.0, 1.0 - (pow(abs(FilterColor.r - OrigColor.r), ColorFilterExp) + pow(abs(FilterColor.g - OrigColor.g), ColorFilterExp) + pow(abs(FilterColor.b - OrigColor.b), ColorFilterExp)) * ColorFilterMult);
    if (bFilterByTone)
    {
        float fScaling = (OrigColor.r / FilterColor.r + OrigColor.g / FilterColor.g + OrigColor.b / FilterColor.b) * 0.333333;
        fColorFilter = max(0.0, 1.0 - (pow(abs(FilterColor.r - OrigColor.r * fScaling), ColorFilterExp) + pow(abs(FilterColor.g - OrigColor.g * fScaling), ColorFilterExp) + pow(abs(FilterColor.b - OrigColor.b * fScaling), ColorFilterExp)) * ColorFilterMult);
    }

    // as a test: output FilterMap
    //return fColorFilter;

    if (bFilterByContrast)
    {

    // Filterradius ermitteln
    // nach links gehen
    for (int i = 5; i >= 0; i--)
    {
        CompColor = tex2D(Sampler1, Tex + float2(fColorFilter * MaxRadius * pixelsize * g_PixelOffsetH[i]));
        // Grösste Luminanzabweichung finden
        Delta = max(pow(abs(CompColor.r - OrigColor.r), DeltaExponent), max(pow(abs(CompColor.g - OrigColor.g), DeltaExponent), pow(abs(CompColor.b - OrigColor.b), DeltaExponent)));
        if (Delta > DeltaTolerance)
        { 
            // die Abweichung ist unzulässig -> Radius verkleinern und abbrechen
            RadiusX = max(0.0, (6.0 - ((float)i + 1.0)) / 6.0);
            break;
        }
    }
    // nach rechts gehen
    for (int i = 7; i < 13; i++)
    {
        CompColor = tex2D(Sampler1, Tex + float2(fColorFilter * MaxRadius * pixelsize * g_PixelOffsetH[i]));
        Delta = max(pow(abs(CompColor.r - OrigColor.r), DeltaExponent), max(pow(abs(CompColor.g - OrigColor.g), DeltaExponent), pow(abs(CompColor.b - OrigColor.b), DeltaExponent)));
        if (Delta > DeltaTolerance)
        {
            RadiusX = min(RadiusX, max(0.0, ((float)i - 7.0) / 6.0));
            break;
        }
    }
    // nach oben gehen
    for (int i = 5; i >= 0; i--)
    {
        CompColor = tex2D(Sampler1, Tex + float2(fColorFilter * MaxRadius * pixelsize * g_PixelOffsetV[i]));
        Delta = max(pow(abs(CompColor.r - OrigColor.r), DeltaExponent), max(pow(abs(CompColor.g - OrigColor.g), DeltaExponent), pow(abs(CompColor.b - OrigColor.b), DeltaExponent)));
        if (Delta > DeltaTolerance)
        { 
            RadiusY = max(0.0, (6.0 - ((float)i + 1.0)) / 6.0);
            break;
        }
    }
    // nach unten gehen
    for (int i = 7; i < 13.0; i++)
    {
        CompColor = tex2D(Sampler1, Tex + float2(fColorFilter * MaxRadius * pixelsize * g_PixelOffsetV[i]));
        Delta = max(pow(abs(CompColor.r - OrigColor.r), DeltaExponent), max(pow(abs(CompColor.g - OrigColor.g), DeltaExponent), pow(abs(CompColor.b - OrigColor.b), DeltaExponent)));
        if (Delta > DeltaTolerance)
        {
            RadiusY = min(RadiusY, max(0.0, ((float)i - 7.0) / 6.0));
            break;
        }
    }

    }
    
    for (int i = 0; i < 13; i++)
        Color += tex2D(Sampler1, Tex + float2(fColorFilter * MaxRadius * LossyBlurFactor * RadiusX * pixelsize * g_PixelOffsetH[i])) * g_fBlurWeights[i];
    for (int i = 0; i < 13; i++)
        Color += tex2D(Sampler1, Tex + float2(fColorFilter * MaxRadius * LossyBlurFactor * RadiusY * pixelsize * g_PixelOffsetV[i])) * g_fBlurWeights[i];

    return Color * 0.5;
}  

technique t1
{
    pass p1  
    {
        PixelShader = compile ps_3_0 PSNoiseReduction();
    }
}


























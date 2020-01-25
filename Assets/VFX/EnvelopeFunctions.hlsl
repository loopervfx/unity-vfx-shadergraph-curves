//UNITY_SHADER_NO_UPGRADE
#ifndef MYHLSLINCLUDE_INCLUDED
#define MYHLSLINCLUDE_INCLUDED

// canonical psuedo random noise
// https://stackoverflow.com/questions/12964279/
float rand(float2 co){
    return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
}

// generate random adsr envelope parameters
void adsrRandom_float(float2 uv, out float4 Out)
{
    float4 adsr = (float4)0.0;

    [unroll]
    for (int i=0; i<4; i++)
    {
        adsr[i] = rand(uv.yy + float(i)*0.1);
    }

    Out = normalize(adsr);
}

// a simple envelope function for fast attack and slow decays
// it's maximum, which is 1.0, happens at exactly x = 1 / k
// use k to control the stretching of the function
void impulse_float(float x, float k, out float Out)
{
  float h = k * x;
  Out =  h * exp(1.0 - h);
}

// the adsr function has three arguments
// time, the value to decay to, a float4 with ADSR parameters
// https://www.fsynth.com/documentation/tutorials/env/
void adsr_float(float t, float s, float4 v, out float Out) 
{
  v.xyw = max((float3)2.2e-05, v.xyw);
  // attack term
  float ta = t/v.x;
  // decay / sustain amplitude term
  float td = max(s, 1.0-(t-v.x)*(1.0-s)/v.y);
  // length / release term
  float tr = (1.0 - max(0.0,t-(v.x+v.y+v.z))/v.w);
  Out = max(0.0, min(ta, tr*td));
}

// test to ensure texture coordinate is correct
void everyOther_float(float2 textureSize, float2 texCoord, out float4 Out)
{
     // Default color is fully transparent
   float4 color = (float4)0;

   // Scale to int texture size
   int row = texCoord.y * textureSize.y; 

   // Even or odd? Only even lines are sampled
   if(row % 2)
   {
      //color = tex2D(TexSampler, texCoord);
      color = float4(1.0, 0.0, 0.0, 1.0);
   }
   else
   {
      color = float4(0.0, 0.0, 1.0, 1.0); 
   }

   Out = color;
}


#endif //MYHLSLINCLUDE_INCLUDED
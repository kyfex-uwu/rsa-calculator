sampler2D TextureSampler : register(s0);
texture2D materialTex : register(t1);
sampler2D materialSamp : register(s1);
texture2D bgTex : register(t2);
sampler2D bgSamp : register(s2);


uniform float2 pscale;
uniform float2 cpos;
uniform float time;

float4 texAt(float2 pos, float offsetx, float offsety){
  return tex2D(TextureSampler,pos+float2(offsetx,offsety)*pscale);
}
float4 matAt(float2 pos, float offsetx, float offsety){
  return tex2D(materialSamp,pos+float2(offsetx,offsety)*pscale)+tex2D(bgSamp,pos+float2(offsetx,offsety)*pscale);
}
float2 worldpos(float2 pos){
    return floor(pos/pscale+cpos);
}

float4 main(float4 color : COLOR0, float2 pos : TEXCOORD0) : SV_Target {
  float2 wpos = worldpos(pos);
  float4 templateColor = texAt(pos,0,0);
  if(templateColor.a>0.1){
    if(templateColor.r>0.4){
      return float4(0.4,0.65,0.8,0.9);
    }
    float x=wpos.y+time;
    float4 under = matAt(pos,1.5*cos(x)+2.2*cos(x/3),0);
    return float4(under.rgb*0.3+float3(0.1,0.35,0.7),under.a*0.5);
  }
  return float4(0,0,0,0);
}

technique BasicTech {
    pass Pass0 {
        PixelShader = compile ps_3_0 main();
    }
}
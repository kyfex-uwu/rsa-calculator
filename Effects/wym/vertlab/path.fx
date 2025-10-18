sampler2D layerSamp : register(s0);
texture2D particleTex : register(t1);
sampler2D particleSamp : register(s1);
texture2D bgTex : register(t2);
sampler2D bgSamp : register(s2);

uniform float4 edgecol;
uniform float4 lowcol;
uniform float4 highcol;
uniform float4 pattern;
uniform float stripecutoff;

uniform float2 cpos;
uniform float2 pscale;
uniform float time;
uniform float quiet;

float4 matAt(float2 pos, float offsetx, float offsety) {
    return floor(tex2D(layerSamp, pos + float2(offsetx, offsety) * pscale) * 255)+ tex2D(bgSamp,pos+float2(offsetx,offsety)*pscale);
}

float4 partAt(float2 pos) {
    return tex2D(particleSamp, pos);
}

float2 worldpos(float2 pos) {
    return floor(pos / pscale + cpos);
}

// Simple 3D hash function for pseudo-random generation
float drand(float3 co) {
    co *= 1000.0;
    co = fmod(co, 219.23);
    float3 a = fmod(co * float3(0.1031, 0.1030, 0.0973), 1);
    a += dot(a, a.yzx + 33.33);
    return fmod((a.x + a.y) * a.z, 1);
}

float4 main(float4 color : COLOR0, float2 pos : TEXCOORD0) : SV_Target {
    float4 matval = matAt(pos, 0, 0);
    if (matval.a <= 0.1)
        return tex2D(bgSamp, pos); // transparent part shows background

    float2 wpos = worldpos(pos);
    if (matval.a>1){
    float redNearby = (
        matval.r +
        matAt(pos, 1, 0).r + matAt(pos, -1, 0).r +
        matAt(pos, 0, 1).r + matAt(pos, 0, -1).r +
        matAt(pos, 1, 1).r + matAt(pos, -1, -1).r +
        matAt(pos, -1, 1).r + matAt(pos, 1, -1).r
    ) / 9.0;

    float sparkDensity = saturate(0.1 + 0.9 * redNearby);
      // Distorsion effect on water
    float rippleOffset = 2.0 * cos(wpos.y + time);
    float2 rippleWpos = worldpos(pos + float2(rippleOffset, 0) * pscale);

    float pto = drand(float3(floor(rippleWpos.x), floor(rippleWpos.y), 1));
    float st = floor(time - pto);
    float sv = drand(float3(rippleWpos.x, rippleWpos.y, st));

    float sparkAmount = (sv > 0.4) * (1 - fmod(time - pto, 1)) * sparkDensity;
    float3 sparkColor = float3(0.1,0.35,0.7);
    float3 sparks = sparkAmount * sparkColor;

    float4 bg = (sparkAmount > 0.2)
        ? partAt(pos + float2(rippleOffset, 0) * pscale)
        : partAt(pos);
    if (sparkAmount > 0.2) {
    return float4(sparks, sparkAmount * 0.8); // fade based on strength
    }
    return float4(0, 0, 0, 0); // Fully transparent otherwise // semi-transparent if needed
    }
    return float4(0,0,0,0);
}


technique BasicTech {
    pass Pass0 {
        PixelShader = compile ps_3_0 main();
    }
}

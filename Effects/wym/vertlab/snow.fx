sampler2D TextureSampler : register(s0);

float2 playerPos;    // set from C#
float  playerRadius; // footprint radius in pixels
float  time;
float4 snowColor;    // e.g. (0.9, 0.9, 1.0, 1.0)
float  recoverSpeed; // smaller = slower recovery

// hash noise
float hash21(float2 p) {
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

// patchy snow
float snowMask(float2 uv) {
    float n = hash21(floor(uv * 8.0));
    return smoothstep(0.3, 0.6, n);
}

float4 main(float2 uv : TEXCOORD0) : COLOR0 {
    float4 grass = tex2D(grassTex, uv);

    // procedural snow overlay
    float baseSnow = snowMask(uv * levelSize * 0.1);
    float4 snowLayer = snowColor * baseSnow;

    // distance from player footprint
    float2 worldUV = uv * levelSize;
    float d = length(worldUV - playerPos);

    // carve a circular path
    float footprint = 1.0 - smoothstep(playerRadius, playerRadius * 0.5, d);

    // slow recovery
    float recovery = saturate(1.0 - footprint + time * recoverSpeed * 0.01);

    // apply mask
    snowLayer *= recovery;

    return lerp(grass, snowLayer, snowLayer.a);
}

technique SnowTech {
    pass P0 {
        PixelShader = compile ps_3_0 main();
    }
}
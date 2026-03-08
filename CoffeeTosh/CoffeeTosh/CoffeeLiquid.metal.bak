// CoffeeLiquid.metal — Metaball 2D liquid renderer
//
// All particles contribute to a smooth field.
// Where field > threshold → liquid. Crisp edges.

#include <metal_stdlib>
using namespace metal;

// Must match Swift GPUParticle (32 bytes)
struct Particle {
    float2 position;    // 0
    float2 velocity;    // 8
    float  radius;      // 16
    float  speed;       // 20
    float2 _pad;        // 24
};

// Must match Swift GPUUniforms (64 bytes)
struct Uniforms {
    float2 resolution;       // 0
    float  time;             // 8
    int    particleCount;    // 12
    float  influenceScale;   // 16
    float  threshold;        // 20
    float2 _p1;              // 24
    float4 liquidColor;      // 32
    float4 bgColor;          // 48
};

vertex float4 liquidVertex(uint vid [[vertex_id]]) {
    float2 p[3] = { float2(-1, -1), float2(3, -1), float2(-1, 3) };
    return float4(p[vid], 0, 1);
}

fragment float4 liquidFragment(
    float4 fragPos  [[position]],
    constant Uniforms &u     [[buffer(0)]],
    constant Particle *parts [[buffer(1)]]
) {
    float2 p   = fragPos.xy;
    float3 liq = u.liquidColor.rgb;
    float3 bg  = u.bgColor.rgb;
    int N      = u.particleCount;
    float isc  = u.influenceScale;
    float thr  = u.threshold;

    float field = 0.0;

    for (int i = 0; i < N; i++) {
        float R     = parts[i].radius * isc;
        float2 d    = p - parts[i].position;

        // Velocity stretching for in-flight drops
        float spd = parts[i].speed;
        if (spd > 50.0) {
            float2 dir = parts[i].velocity / spd;
            float ax = dot(d, dir);
            float ay = dot(d, float2(-dir.y, dir.x));
            float stretch = 1.0 + min(spd * 0.0006, 0.4);
            ax /= stretch;
            d = dir * ax + float2(-dir.y, dir.x) * ay;
        }

        float dist2 = dot(d, d);
        float R2    = R * R;

        // Gaussian kernel
        float val = exp(-3.0 * dist2 / R2);
        field += val;
    }

    // Soft 2px edge
    if (field > thr - 0.02) {
        float alpha = smoothstep(thr - 0.02, thr + 0.01, field);
        return float4(mix(bg, liq, alpha), 1.0);
    }

    return float4(bg, 1.0);
}

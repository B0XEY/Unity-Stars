#ifndef StarFunctions_INCLUDED
#define STAR_FUNCTIONS_INCLUDED

float3 hash33(float3 p) {
    p = frac(p * float3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return frac((p.xxy + p.yxx) * p.zyx);
}

#define TWINKLE_SPEED_PRIMARY 2.0
#define TWINKLE_SPEED_SECONDARY 3.7
#define TWINKLE_COLOR_SHIFT 0.15
#define SCINTILLATION_SPEED 5.0

// Static pure white color for base star color
static const float3 PURE_WHITE = float3(1.0, 1.0, 1.0);

float GetEnhancedTwinkle(float3 starPos) {
    // Get base offset for this star
    float offset = frac(dot(starPos, float3(12.9898, 78.233, 45.164)));
    
    // Primary twinkle frequency
    float time1 = _Time.y * TWINKLE_SPEED_PRIMARY + offset * 6.283;
    float twinkle1 = sin(time1) * cos(time1 * 0.7);
    
    // Secondary higher frequency twinkle
    float time2 = _Time.y * TWINKLE_SPEED_SECONDARY + offset * 9.283;
    float twinkle2 = sin(time2 * 1.5) * cos(time2 * 0.3);
    
    // Atmospheric scintillation (very fast, subtle variation)
    float scint = sin(_Time.y * SCINTILLATION_SPEED + offset * 12.283) * 0.1;
    
    // Combine frequencies with distance-based weights
    float combinedTwinkle = twinkle1 * 0.7 + twinkle2 * 0.2 + scint;
    
    // Make twinkle more sharp and sporadic
    return pow(abs(combinedTwinkle), 3.0) * sign(combinedTwinkle);
}

// Enhanced star effects including color temperature variation
float4 GetStarEffects(float3 starPos, float starProp) {
    // Get pulse offset
    float pulseOffset = frac(dot(starPos, float3(12.9898, 78.233, 45.164)));
    float pulseTime = _Time.y * PULSE_SPEED + pulseOffset * 6.283;
    
    // Optimized pulse calculation
    float pulse = sin(pulseTime) * 0.7 + sin(pulseTime * 1.3) * 0.3;
    pulse = pulse * 0.5 + 0.5;
    
    // Enhanced twinkle
    float twinkle = GetEnhancedTwinkle(starPos);
    
    // Calculate color temperature shift based on twinkle
    float tempShift = twinkle * TWINKLE_COLOR_SHIFT;
    
    float effectStrength = lerp(0.2, 1.0, starProp);
    
    return float4(
        lerp(1.0, lerp(0.7, 1.3, pulse), effectStrength),     // Size factor
        lerp(1.0, lerp(0.5, 1.5, twinkle), TWINKLE_AMOUNT * effectStrength), // Brightness factor
        tempShift,    // Temperature shift
        0            // Reserved for future use
    );
}

float3 GetStarColor(float temperature, float colorVariation, float tempShift) {
    // Apply temperature shift from twinkling
    temperature = saturate(temperature + tempShift);
    
    float3 baseColor;
    if (temperature < 0.25)
        baseColor = lerp(_StarColor1, _StarColor2, temperature * 4.0);
    else if (temperature < 0.5)
        baseColor = lerp(_StarColor2, _StarColor3, (temperature - 0.25) * 4.0);
    else if (temperature < 0.75)
        baseColor = lerp(_StarColor3, _StarColor4, (temperature - 0.5) * 4.0);
    else
        baseColor = lerp(_StarColor4, _StarColor5, (temperature - 0.75) * 4.0);
    
    return lerp(PURE_WHITE, baseColor, colorVariation);
}

float3 fixStarDistribution(float3 dir) {
    float3 p = normalize(dir);
    float phi = atan2(p.z, p.x);
    float theta = acos(p.y);
    float v = 1.0 - (theta / PI);
    float correction = sqrt(1.0 - v * v);
    
    return normalize(float3(
        correction * cos(phi),
        v,
        correction * sin(phi)
    ));
}

#endif 
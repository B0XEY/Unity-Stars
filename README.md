# 🌟 Procedural Stars Shader

A high-quality procedural star shader for Unity's Universal Render Pipeline (URP) that generates a dynamic, realistic starfield with physically-based features.


![Unity](https://img.shields.io/badge/Unity-6.0+-ba56ec?style=for-the-badge&logo=Unity)
![Shader Type](https://img.shields.io/badge/Shader-URP-blue?style=for-the-badge&logo=sharp&logoColor=white)



---

## ✨ Overview

Transform your skybox into a vibrant, dynamic starfield with this advanced procedural shader. Perfect for space-themed games, atmospheric scenes, or any project needing a realistic night sky.

## 🎮 Quick Start

1. Create a material using the `"Hidden/FullscreenProceduralStars"` shader
2. Adjust the material properties in the inspector
3. Add to your URP renderer using a custom render feature

---

## 🛠️ Features

### 🌌 Dynamic Star Generation
- **Procedural Placement**: Uses 3D simplex noise for stable, consistent star positioning
- **Uniform Distribution**: Special correction to avoid star clustering at poles
- **Depth-aware**: Stars only appear in skybox regions
- **Micro-star System**: Additional tiny stars for enhanced depth perception

### 🎨 Visual Effects
- **Rich Color Palette**:
  - Bright Blue (`#5CC8FF`)
  - Light Gold (`#E9E5A0`)
  - Pink (`#DF57BC`)
  - Purple (`#A03E99`)
  - Deep Blue (`#3066BE`)
- **Dynamic Effects**:
  - Natural twinkling
  - Smooth pulsing
  - Size variations
  - Scene-based brightness fading

### ⚙️ Customizable Properties

| Property | Range | Description |
|----------|--------|-------------|
| `_StarDensity` | Float | Controls star field density |
| `_StarSize` | Float | Base size of all stars |
| `_BrightnessFade` | Float | Scene brightness-based fading |
| `_StarColorVariation` | 0-2 | Blend between white and color palette |
| `_StarSizeVariation` | 0-10 | Size difference between stars |
| `_StarBrightness` | 0-2 | Overall starfield brightness |
| `_StarDistance` | Float | Star field distance from camera |

---

## 🔧 Technical Implementation

### 🎯 Render Pipeline Integration
The shader seamlessly integrates with Unity's URP through:

- **Render Pass**: Fullscreen post-processing using `"Hidden/FullscreenProceduralStars"`
- **Depth Testing**: Smart depth buffer usage for skybox-only rendering
- **Blending**: Additive blending for realistic star luminance

### ⚡ Performance Optimizations
- Efficient hash functions for stable RNG
- View frustum optimization
- Optimized sphere sampling
- Minimal texture sampling requirements

---

## 📋 Requirements

### Core Dependencies
- Unity Universal Render Pipeline (URP)

### Required Includes
```hlsl
// Core Libraries
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Functions/SimplexNoise.hlsl"
```

---

## 💡 Tips & Best Practices

- Adjust `_StarDensity` and `_StarDistance` together for optimal star distribution
- Use `_StarColorVariation` subtly for more realistic results
- Balance `_StarBrightness` with your scene's overall lighting
- Consider performance when increasing star density in mobile applications 

Shader "Hidden/FullscreenStarFeild"  {
    Properties {
        [Header(Star Distribution)]
        [Space(10)]
        _StarDensity("Star Density", Float) = 1.5
        _StarDistance("Star Distance", Float) = 10000.0
        
        [Space(10)]
        [Header(Star Appearance)]
        [Space(10)]
        _StarSizeVariation("Star Size Variation", Range(0, 10)) = 0.59
        _StarBrightness("Star Brightness", Range(0, 2)) = 1.28
        _StarColorVariation("Star Color Variation", Range(0, 2)) = 0.9
        
        [Space(10)]
        [Header(Star Colors)]
        [Space(10)]
        _StarColor1("Star Color 1", Color) = (0.361, 0.784, 1.000, 1)
        _StarColor2("Star Color 2", Color) = (0.914, 0.898, 0.627, 1)
        _StarColor3("Star Color 3", Color) = (0.875, 0.341, 0.737, 1)
        _StarColor4("Star Color 4", Color) = (0.627, 0.243, 0.600, 1)
        _StarColor5("Star Color 5", Color) = (0.188, 0.400, 0.745, 1)
        
        [Space(10)]
        [Header(Scene Interaction)]
        [Space(10)]
        _BrightnessFade("Brightness Fade", Float) = 22.5
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" }

        Pass {
            Name "Stars"
            ZTest Always Cull Off ZWrite Off
            Blend One One

            HLSLPROGRAM
            #pragma vertex FullScreenTriangleVertex
            #pragma fragment frag
            #pragma target 3.0

            #define EPSILON 0.001
            #define PULSE_SPEED 1.5
            #define TWINKLE_AMOUNT 1.0
            #define STAR_THRESHOLD 0.75

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "ShaderFunctions/SimplexNoise.hlsl"

            TEXTURE2D(_BlitTexture); 
            SAMPLER(sampler_BlitTexture);

            CBUFFER_START(UnityPerMaterial)
                float _StarDensity;
                float _StarSizeVariation;
                float _BrightnessFade;
                float _StarColorVariation;
                float _StarBrightness;
                float _StarDistance;
                float3 _StarColor1;
                float3 _StarColor2;
                float3 _StarColor3;
                float3 _StarColor4;
                float3 _StarColor5;
            CBUFFER_END
            
            #include "ShaderFunctions/StarFunctions.hlsl"

            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            Varyings FullScreenTriangleVertex(uint id : SV_VertexID) {
                Varyings o;
                float2 uv = float2((id << 1) & 2, id & 2);
                o.positionCS = float4(uv * 2 - 1, 0, 1);
                o.uv = uv;
                
                #if UNITY_UV_STARTS_AT_TOP
                o.uv.y = 1.0 - o.uv.y;
                #endif
                
                return o;
            }

            float4 frag(Varyings input) : SV_Target {
                // Early depth test
                float sceneDepth = LinearEyeDepth(SampleSceneDepth(input.uv), _ZBufferParams);
                if (sceneDepth < 10000.0) return 0;

                // Scene brightness check
                float3 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, input.uv).rgb;
                float sceneFade = saturate(1.0 - dot(sceneColor, float3(0.2126, 0.7152, 0.0722)) * _BrightnessFade);
                
                // Calculate view direction in fragment shader for better precision
                float4 clip = float4(input.uv * 2.0 - 1.0, 0.0, 1.0);
                float4 view = mul(unity_CameraInvProjection, clip);
                view.xyz /= view.w;
                float3 viewDir = normalize(view.xyz);
                float3 worldDir = normalize(mul((float3x3)unity_MatrixInvV, viewDir) + EPSILON);
                
                // Get world direction and apply uniform distribution
                float3 correctedDir = fixStarDistribution(worldDir);
                
                // Calculate star position
                float3 starSamplePos = correctedDir * _StarDistance * 0.01;
                float3 starSamplePosFloored = floor(starSamplePos * _StarDensity + EPSILON);
                
                // Generate star properties
                float3 starProps = hash33(starSamplePosFloored);
                float4 starEffects = GetStarEffects(starSamplePosFloored, starProps.z);
                
                // Calculate star size with variation
                float sizeVariation = pow(starProps.x, 0.5);
                float starSize = 0.2 * (1.0 + sizeVariation * _StarSizeVariation) * starEffects.x;
                starSize = lerp(starSize, 0.2 * 0.25, step(0.98, starProps.y));
                
                // Calculate star intensity
                float noiseValue = saturate(SimplexNoise(starSamplePos) * 0.5 + 0.5);
                float starIntensity = smoothstep(STAR_THRESHOLD, 1.0, noiseValue) * sceneFade * _StarBrightness * starEffects.y;
                
                // Calculate star shape
                float d = length(frac(starSamplePos * _StarDensity + EPSILON) - 0.5);
                float star = smoothstep(starSize + EPSILON, EPSILON, d) * starIntensity;
                
                // Get star color with temperature variation from enhanced twinkling
                float3 starColor = GetStarColor(starProps.x, _StarColorVariation, starEffects.z);
            
                float3 polarisPos = normalize(float3(0.0, 0.9, 0.1));
                float angleToBrightStar = acos(dot(correctedDir, polarisPos));
                float brightStarSize = 0.2 * .09;
                float brightStarIntensity = smoothstep(brightStarSize, 0.0, angleToBrightStar) * sceneFade;
                
                // Use same effects system as regular stars
                float4 brightStarEffects = GetStarEffects(polarisPos, 0.8); // High effect strength for more variation
                brightStarIntensity *= brightStarEffects.y; // Apply normal twinkling
                
                // Use normal star color system
                float3 brightStarColor = GetStarColor(0.3, _StarColorVariation, brightStarEffects.z);
                return float4(starColor * star + brightStarColor * brightStarIntensity * 1.5, 1);
            }
            ENDHLSL
        }
    }
}

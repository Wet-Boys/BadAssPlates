// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SineVFX/LivingParticles/LivingParticleMaskedMorphPbrURP"
{
	Properties
	{
		[Toggle(_FLIPMORPHMASK_ON)] _FlipMorphMask("Flip Morph Mask", Float) = 0
		[Toggle(_FLIPEMISSIONMASK_ON)] _FlipEmissionMask("Flip Emission Mask", Float) = 0
		[Toggle(_FLIPOFFSETMASK_ON)] _FlipOffsetMask("Flip Offset Mask", Float) = 0
		_MorphMain("Morph Main", 2D) = "white" {}
		_MorphNormal("Morph Normal", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_ColorTint("Color Tint", Color) = (1,1,1,1)
		_MetallicSmoothness("MetallicSmoothness", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_Normal("Normal", 2D) = "bump" {}
		_Emission("Emission", 2D) = "white" {}
		_FinalColorOne("Final Color One", Color) = (1,0,0,1)
		_FinalColorTwo("Final Color Two", Color) = (0,0,0,0)
		_FinalPower("Final Power", Range( 0 , 20)) = 6
		_FinalMaskMultiply("Final Mask Multiply", Range( 0 , 10)) = 2
		[Toggle(_RAMPENABLED_ON)] _RampEnabled("Ramp Enabled", Float) = 0
		_Ramp("Ramp", 2D) = "white" {}
		_Distance("Distance", Float) = 1
		_DistancePower("Distance Power", Range( 0.2 , 4)) = 1
		_DistanceRemap("Distance Remap", Range( 1 , 4)) = 1
		[Toggle(_OFFSETYLOCK_ON)] _OffsetYLock("Offset Y Lock", Float) = 0
		_OffsetPower("Offset Power", Float) = 0
		[Toggle(_CENTERMASKENABLED_ON)] _CenterMaskEnabled("Center Mask Enabled", Float) = 0
		_CenterMaskMultiply("Center Mask Multiply", Float) = 4
		_CenterMaskSubtract("Center Mask Subtract", Float) = 0.75
		[Toggle(_VERTEXDISTORTIONENABLED_ON)] _VertexDistortionEnabled("Vertex Distortion Enabled", Float) = 0
		_VertexOffsetTexture("Vertex Offset Texture", 2D) = "white" {}
		_VertexDistortionPower("Vertex Distortion Power", Float) = 0.1
		_VertexDistortionTiling("Vertex Distortion Tiling", Float) = 1
		[Toggle(_USEGAMMARENDERING_ON)] _UseGammaRendering("Use Gamma Rendering", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero , One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 999999
			#define ASE_TEXTURE_PARAMS(textureName) textureName
			
			#define _NORMALMAP 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#pragma shader_feature _VERTEXDISTORTIONENABLED_ON
			#pragma shader_feature _CENTERMASKENABLED_ON
			#pragma shader_feature _FLIPOFFSETMASK_ON
			#pragma shader_feature _OFFSETYLOCK_ON
			#pragma shader_feature _USEGAMMARENDERING_ON
			#pragma shader_feature _FLIPMORPHMASK_ON
			#pragma shader_feature _RAMPENABLED_ON
			#pragma shader_feature _FLIPEMISSIONMASK_ON


			sampler2D _VertexOffsetTexture;
			float4 _Affector;
			sampler2D _MorphMain;
			sampler2D _MorphNormal;
			sampler2D _Albedo;
			sampler2D _Normal;
			sampler2D _Ramp;
			sampler2D _Emission;
			sampler2D _MetallicSmoothness;
			CBUFFER_START( UnityPerMaterial )
			float _VertexDistortionPower;
			float _VertexDistortionTiling;
			float _Distance;
			float _DistanceRemap;
			float _DistancePower;
			float _CenterMaskSubtract;
			float _CenterMaskMultiply;
			float _OffsetPower;
			float4 _ColorTint;
			float4 _Albedo_ST;
			float4 _Normal_ST;
			float4 _FinalColorTwo;
			float4 _FinalColorOne;
			float _FinalMaskMultiply;
			float _FinalPower;
			float4 _Emission_ST;
			float _Metallic;
			float4 _MetallicSmoothness_ST;
			float _Smoothness;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				float4 shadowCoord : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			inline float4 TriplanarSamplingSV( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.zy * float2( nsign.x, 1.0 ), 0, 0 ) ) );
				yNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xz * float2( nsign.y, 1.0 ), 0, 0 ) ) );
				zNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0 ) ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar111 = TriplanarSamplingSV( _VertexOffsetTexture, ase_worldPos, ase_worldNormal, 1.0, _VertexDistortionTiling, 1.0, 0 );
				float4 break114 = triplanar111;
				float3 appendResult115 = (float3(break114.x , break114.y , break114.z));
				#ifdef _VERTEXDISTORTIONENABLED_ON
				float3 staticSwitch120 = ( _VertexDistortionPower * (float3( -1,-1,-1 ) + (appendResult115 - float3( 0,0,0 )) * (float3( 1,1,1 ) - float3( -1,-1,-1 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) );
				#else
				float3 staticSwitch120 = temp_cast_0;
				#endif
				float4 appendResult17 = (float4(v.texcoord1.xyzw.w , v.ase_texcoord2.x , v.ase_texcoord2.y , 0.0));
				float DistanceMask45 = ( 1.0 - distance( appendResult17 , _Affector ) );
				float clampResult23 = clamp( (0.0 + (( DistanceMask45 + ( _Distance - 1.0 ) ) - 0.0) * (_DistanceRemap - 0.0) / (_Distance - 0.0)) , 0.0 , 1.0 );
				float ResultMask53 = pow( clampResult23 , _DistancePower );
				#ifdef _FLIPOFFSETMASK_ON
				float staticSwitch225 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch225 = ResultMask53;
				#endif
				float clampResult105 = clamp( ( staticSwitch225 - _CenterMaskSubtract ) , 0.0 , 1.0 );
				#ifdef _CENTERMASKENABLED_ON
				float staticSwitch109 = ( staticSwitch225 - ( clampResult105 * _CenterMaskMultiply ) );
				#else
				float staticSwitch109 = staticSwitch225;
				#endif
				float4 normalizeResult41 = normalize( ( appendResult17 - _Affector ) );
				float4 CenterVector44 = normalizeResult41;
				float3 temp_cast_2 = (1.0).xxx;
				#ifdef _OFFSETYLOCK_ON
				float3 staticSwitch49 = float3(1,0,1);
				#else
				float3 staticSwitch49 = temp_cast_2;
				#endif
				float3 appendResult218 = (float3(v.ase_texcoord2.z , v.ase_texcoord2.w , v.ase_texcoord3.x));
				float3 RotationInRadian216 = -appendResult218;
				float3 break207 = RotationInRadian216;
				#ifdef _FLIPMORPHMASK_ON
				float staticSwitch202 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch202 = ResultMask53;
				#endif
				float2 appendResult177 = (float2(v.texcoord1.xyzw.x , ( v.texcoord1.xyzw.y + (-0.5 + (staticSwitch202 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) )));
				float4 tex2DNode132 = tex2Dlod( _MorphMain, float4( appendResult177, 0, 0.0) );
				float3 gammaToLinear230 = FastSRGBToLinear( tex2DNode132.rgb );
				#ifdef _USEGAMMARENDERING_ON
				float4 staticSwitch229 = float4( gammaToLinear230 , 0.0 );
				#else
				float4 staticSwitch229 = tex2DNode132;
				#endif
				float4 break179 = staticSwitch229;
				float4 appendResult184 = (float4(( break179.r * -1.0 ) , ( break179.g * -1.0 ) , ( break179.b * 1.0 ) , ( break179.a * 1.0 )));
				float4 Morph186 = ( appendResult184 * v.texcoord1.xyzw.z );
				float3 rotatedValue208 = RotateAroundAxis( float3( 0,0,0 ), Morph186.xyz, float3( 0,0,-1 ), break207.z );
				float3 rotatedValue210 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue208, float3( -1,0,0 ), break207.x );
				float3 rotatedValue213 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue210, float3( 0,-1,0 ), break207.y );
				float4 OffsetFinal154 = ( ( float4( staticSwitch120 , 0.0 ) + ( staticSwitch109 * CenterVector44 * _OffsetPower * float4( staticSwitch49 , 0.0 ) ) ) + float4( rotatedValue213 , 0.0 ) );
				
				float3 break206 = RotationInRadian216;
				float4 break191 = tex2Dlod( _MorphNormal, float4( appendResult177, 0, 0.0) );
				float4 appendResult196 = (float4(( break191.r * 1.0 ) , ( break191.g * 1.0 ) , ( break191.b * 1.0 ) , ( break191.a * 1.0 )));
				float4 MorphNormals152 = (float4( 1,1,-1,-1 ) + (appendResult196 - float4( 0,0,0,0 )) * (float4( -1,-1,1,1 ) - float4( 1,1,-1,-1 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 )));
				float3 rotatedValue209 = RotateAroundAxis( float3( 0,0,0 ), MorphNormals152.xyz, float3( 0,0,-1 ), break206.z );
				float3 rotatedValue211 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue209, float3( -1,0,0 ), break206.x );
				float3 rotatedValue212 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue211, float3( 0,-1,0 ), break206.y );
				float3 VertexNormalsFinal222 = rotatedValue212;
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				o.ase_texcoord8 = v.texcoord1.xyzw;
				o.ase_texcoord9 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OffsetFinal154.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = VertexNormalsFinal222;

				float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( vertexInput.positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				o.clipPos = vertexInput.positionCS;

				#ifdef _MAIN_LIGHT_SHADOWS
					o.shadowCoord = GetShadowCoord(vertexInput);
				#endif
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = _WorldSpaceCameraPos.xyz  - WorldSpacePosition;
	
				#if SHADER_HINT_NICE_QUALITY
					WorldSpaceViewDirection = SafeNormalize( WorldSpaceViewDirection );
				#endif

				float2 uv_Albedo = IN.ase_texcoord7.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				
				float2 uv_Normal = IN.ase_texcoord7.xy * _Normal_ST.xy + _Normal_ST.zw;
				
				float4 appendResult17 = (float4(IN.ase_texcoord8.w , IN.ase_texcoord9.x , IN.ase_texcoord9.y , 0.0));
				float DistanceMask45 = ( 1.0 - distance( appendResult17 , _Affector ) );
				float clampResult23 = clamp( (0.0 + (( DistanceMask45 + ( _Distance - 1.0 ) ) - 0.0) * (_DistanceRemap - 0.0) / (_Distance - 0.0)) , 0.0 , 1.0 );
				float ResultMask53 = pow( clampResult23 , _DistancePower );
				#ifdef _FLIPEMISSIONMASK_ON
				float staticSwitch223 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch223 = ResultMask53;
				#endif
				float clampResult88 = clamp( ( staticSwitch223 * _FinalMaskMultiply ) , 0.0 , 1.0 );
				float4 lerpResult37 = lerp( _FinalColorTwo , _FinalColorOne , clampResult88);
				float2 appendResult83 = (float2(clampResult88 , 0.0));
				#ifdef _RAMPENABLED_ON
				float4 staticSwitch81 = tex2D( _Ramp, appendResult83 );
				#else
				float4 staticSwitch81 = lerpResult37;
				#endif
				float2 uv_Emission = IN.ase_texcoord7.xy * _Emission_ST.xy + _Emission_ST.zw;
				
				float2 uv_MetallicSmoothness = IN.ase_texcoord7.xy * _MetallicSmoothness_ST.xy + _MetallicSmoothness_ST.zw;
				float4 tex2DNode90 = tex2D( _MetallicSmoothness, uv_MetallicSmoothness );
				
				float3 Albedo = ( ( _ColorTint * tex2D( _Albedo, uv_Albedo ) ) + float4( 0,0,0,0 ) ).rgb;
				float3 Normal = ( UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f ) + float3( 0,0,0 ) );
				float3 Emission = ( ( staticSwitch81 * IN.ase_color * _FinalPower * tex2D( _Emission, uv_Emission ).r * IN.ase_color.a ) + float4( 0,0,0,0 ) ).rgb;
				float3 Specular = 0.5;
				float Metallic = ( ( _Metallic * tex2DNode90.r ) + 0.0 );
				float Smoothness = ( ( tex2DNode90.a * _Smoothness ) + 0.0 );
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float3 BakedGI = 0;

				InputData inputData;
				inputData.positionWS = WorldSpacePosition;

				#ifdef _NORMALMAP
					inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
				#else
					#if !SHADER_HINT_NICE_QUALITY
						inputData.normalWS = WorldSpaceNormal;
					#else
						inputData.normalWS = normalize(WorldSpaceNormal);
					#endif
				#endif

				inputData.viewDirectionWS = WorldSpaceViewDirection;
				inputData.shadowCoord = IN.shadowCoord;

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif
				
				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 999999
			#define ASE_TEXTURE_PARAMS(textureName) textureName
			
			#define _NORMALMAP 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#pragma shader_feature _VERTEXDISTORTIONENABLED_ON
			#pragma shader_feature _CENTERMASKENABLED_ON
			#pragma shader_feature _FLIPOFFSETMASK_ON
			#pragma shader_feature _OFFSETYLOCK_ON
			#pragma shader_feature _USEGAMMARENDERING_ON
			#pragma shader_feature _FLIPMORPHMASK_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _VertexOffsetTexture;
			float4 _Affector;
			sampler2D _MorphMain;
			sampler2D _MorphNormal;
			CBUFFER_START( UnityPerMaterial )
			float _VertexDistortionPower;
			float _VertexDistortionTiling;
			float _Distance;
			float _DistanceRemap;
			float _DistancePower;
			float _CenterMaskSubtract;
			float _CenterMaskMultiply;
			float _OffsetPower;
			float4 _ColorTint;
			float4 _Albedo_ST;
			float4 _Normal_ST;
			float4 _FinalColorTwo;
			float4 _FinalColorOne;
			float _FinalMaskMultiply;
			float _FinalPower;
			float4 _Emission_ST;
			float _Metallic;
			float4 _MetallicSmoothness_ST;
			float _Smoothness;
			CBUFFER_END


			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			inline float4 TriplanarSamplingSV( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.zy * float2( nsign.x, 1.0 ), 0, 0 ) ) );
				yNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xz * float2( nsign.y, 1.0 ), 0, 0 ) ) );
				zNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0 ) ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar111 = TriplanarSamplingSV( _VertexOffsetTexture, ase_worldPos, ase_worldNormal, 1.0, _VertexDistortionTiling, 1.0, 0 );
				float4 break114 = triplanar111;
				float3 appendResult115 = (float3(break114.x , break114.y , break114.z));
				#ifdef _VERTEXDISTORTIONENABLED_ON
				float3 staticSwitch120 = ( _VertexDistortionPower * (float3( -1,-1,-1 ) + (appendResult115 - float3( 0,0,0 )) * (float3( 1,1,1 ) - float3( -1,-1,-1 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) );
				#else
				float3 staticSwitch120 = temp_cast_0;
				#endif
				float4 appendResult17 = (float4(v.ase_texcoord1.w , v.ase_texcoord2.x , v.ase_texcoord2.y , 0.0));
				float DistanceMask45 = ( 1.0 - distance( appendResult17 , _Affector ) );
				float clampResult23 = clamp( (0.0 + (( DistanceMask45 + ( _Distance - 1.0 ) ) - 0.0) * (_DistanceRemap - 0.0) / (_Distance - 0.0)) , 0.0 , 1.0 );
				float ResultMask53 = pow( clampResult23 , _DistancePower );
				#ifdef _FLIPOFFSETMASK_ON
				float staticSwitch225 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch225 = ResultMask53;
				#endif
				float clampResult105 = clamp( ( staticSwitch225 - _CenterMaskSubtract ) , 0.0 , 1.0 );
				#ifdef _CENTERMASKENABLED_ON
				float staticSwitch109 = ( staticSwitch225 - ( clampResult105 * _CenterMaskMultiply ) );
				#else
				float staticSwitch109 = staticSwitch225;
				#endif
				float4 normalizeResult41 = normalize( ( appendResult17 - _Affector ) );
				float4 CenterVector44 = normalizeResult41;
				float3 temp_cast_2 = (1.0).xxx;
				#ifdef _OFFSETYLOCK_ON
				float3 staticSwitch49 = float3(1,0,1);
				#else
				float3 staticSwitch49 = temp_cast_2;
				#endif
				float3 appendResult218 = (float3(v.ase_texcoord2.z , v.ase_texcoord2.w , v.ase_texcoord3.x));
				float3 RotationInRadian216 = -appendResult218;
				float3 break207 = RotationInRadian216;
				#ifdef _FLIPMORPHMASK_ON
				float staticSwitch202 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch202 = ResultMask53;
				#endif
				float2 appendResult177 = (float2(v.ase_texcoord1.x , ( v.ase_texcoord1.y + (-0.5 + (staticSwitch202 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) )));
				float4 tex2DNode132 = tex2Dlod( _MorphMain, float4( appendResult177, 0, 0.0) );
				float3 gammaToLinear230 = FastSRGBToLinear( tex2DNode132.rgb );
				#ifdef _USEGAMMARENDERING_ON
				float4 staticSwitch229 = float4( gammaToLinear230 , 0.0 );
				#else
				float4 staticSwitch229 = tex2DNode132;
				#endif
				float4 break179 = staticSwitch229;
				float4 appendResult184 = (float4(( break179.r * -1.0 ) , ( break179.g * -1.0 ) , ( break179.b * 1.0 ) , ( break179.a * 1.0 )));
				float4 Morph186 = ( appendResult184 * v.ase_texcoord1.z );
				float3 rotatedValue208 = RotateAroundAxis( float3( 0,0,0 ), Morph186.xyz, float3( 0,0,-1 ), break207.z );
				float3 rotatedValue210 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue208, float3( -1,0,0 ), break207.x );
				float3 rotatedValue213 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue210, float3( 0,-1,0 ), break207.y );
				float4 OffsetFinal154 = ( ( float4( staticSwitch120 , 0.0 ) + ( staticSwitch109 * CenterVector44 * _OffsetPower * float4( staticSwitch49 , 0.0 ) ) ) + float4( rotatedValue213 , 0.0 ) );
				
				float3 break206 = RotationInRadian216;
				float4 break191 = tex2Dlod( _MorphNormal, float4( appendResult177, 0, 0.0) );
				float4 appendResult196 = (float4(( break191.r * 1.0 ) , ( break191.g * 1.0 ) , ( break191.b * 1.0 ) , ( break191.a * 1.0 )));
				float4 MorphNormals152 = (float4( 1,1,-1,-1 ) + (appendResult196 - float4( 0,0,0,0 )) * (float4( -1,-1,1,1 ) - float4( 1,1,-1,-1 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 )));
				float3 rotatedValue209 = RotateAroundAxis( float3( 0,0,0 ), MorphNormals152.xyz, float3( 0,0,-1 ), break206.z );
				float3 rotatedValue211 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue209, float3( -1,0,0 ), break206.x );
				float3 rotatedValue212 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue211, float3( 0,-1,0 ), break206.y );
				float3 VertexNormalsFinal222 = rotatedValue212;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OffsetFinal154.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = VertexNormalsFinal222;

				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				o.clipPos = clipPos;

				return o;
			}

			half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 999999
			#define ASE_TEXTURE_PARAMS(textureName) textureName
			
			#define _NORMALMAP 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#pragma shader_feature _VERTEXDISTORTIONENABLED_ON
			#pragma shader_feature _CENTERMASKENABLED_ON
			#pragma shader_feature _FLIPOFFSETMASK_ON
			#pragma shader_feature _OFFSETYLOCK_ON
			#pragma shader_feature _USEGAMMARENDERING_ON
			#pragma shader_feature _FLIPMORPHMASK_ON


			sampler2D _VertexOffsetTexture;
			float4 _Affector;
			sampler2D _MorphMain;
			sampler2D _MorphNormal;
			CBUFFER_START( UnityPerMaterial )
			float _VertexDistortionPower;
			float _VertexDistortionTiling;
			float _Distance;
			float _DistanceRemap;
			float _DistancePower;
			float _CenterMaskSubtract;
			float _CenterMaskMultiply;
			float _OffsetPower;
			float4 _ColorTint;
			float4 _Albedo_ST;
			float4 _Normal_ST;
			float4 _FinalColorTwo;
			float4 _FinalColorOne;
			float _FinalMaskMultiply;
			float _FinalPower;
			float4 _Emission_ST;
			float _Metallic;
			float4 _MetallicSmoothness_ST;
			float _Smoothness;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			inline float4 TriplanarSamplingSV( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.zy * float2( nsign.x, 1.0 ), 0, 0 ) ) );
				yNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xz * float2( nsign.y, 1.0 ), 0, 0 ) ) );
				zNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0 ) ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar111 = TriplanarSamplingSV( _VertexOffsetTexture, ase_worldPos, ase_worldNormal, 1.0, _VertexDistortionTiling, 1.0, 0 );
				float4 break114 = triplanar111;
				float3 appendResult115 = (float3(break114.x , break114.y , break114.z));
				#ifdef _VERTEXDISTORTIONENABLED_ON
				float3 staticSwitch120 = ( _VertexDistortionPower * (float3( -1,-1,-1 ) + (appendResult115 - float3( 0,0,0 )) * (float3( 1,1,1 ) - float3( -1,-1,-1 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) );
				#else
				float3 staticSwitch120 = temp_cast_0;
				#endif
				float4 appendResult17 = (float4(v.ase_texcoord1.w , v.ase_texcoord2.x , v.ase_texcoord2.y , 0.0));
				float DistanceMask45 = ( 1.0 - distance( appendResult17 , _Affector ) );
				float clampResult23 = clamp( (0.0 + (( DistanceMask45 + ( _Distance - 1.0 ) ) - 0.0) * (_DistanceRemap - 0.0) / (_Distance - 0.0)) , 0.0 , 1.0 );
				float ResultMask53 = pow( clampResult23 , _DistancePower );
				#ifdef _FLIPOFFSETMASK_ON
				float staticSwitch225 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch225 = ResultMask53;
				#endif
				float clampResult105 = clamp( ( staticSwitch225 - _CenterMaskSubtract ) , 0.0 , 1.0 );
				#ifdef _CENTERMASKENABLED_ON
				float staticSwitch109 = ( staticSwitch225 - ( clampResult105 * _CenterMaskMultiply ) );
				#else
				float staticSwitch109 = staticSwitch225;
				#endif
				float4 normalizeResult41 = normalize( ( appendResult17 - _Affector ) );
				float4 CenterVector44 = normalizeResult41;
				float3 temp_cast_2 = (1.0).xxx;
				#ifdef _OFFSETYLOCK_ON
				float3 staticSwitch49 = float3(1,0,1);
				#else
				float3 staticSwitch49 = temp_cast_2;
				#endif
				float3 appendResult218 = (float3(v.ase_texcoord2.z , v.ase_texcoord2.w , v.ase_texcoord3.x));
				float3 RotationInRadian216 = -appendResult218;
				float3 break207 = RotationInRadian216;
				#ifdef _FLIPMORPHMASK_ON
				float staticSwitch202 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch202 = ResultMask53;
				#endif
				float2 appendResult177 = (float2(v.ase_texcoord1.x , ( v.ase_texcoord1.y + (-0.5 + (staticSwitch202 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) )));
				float4 tex2DNode132 = tex2Dlod( _MorphMain, float4( appendResult177, 0, 0.0) );
				float3 gammaToLinear230 = FastSRGBToLinear( tex2DNode132.rgb );
				#ifdef _USEGAMMARENDERING_ON
				float4 staticSwitch229 = float4( gammaToLinear230 , 0.0 );
				#else
				float4 staticSwitch229 = tex2DNode132;
				#endif
				float4 break179 = staticSwitch229;
				float4 appendResult184 = (float4(( break179.r * -1.0 ) , ( break179.g * -1.0 ) , ( break179.b * 1.0 ) , ( break179.a * 1.0 )));
				float4 Morph186 = ( appendResult184 * v.ase_texcoord1.z );
				float3 rotatedValue208 = RotateAroundAxis( float3( 0,0,0 ), Morph186.xyz, float3( 0,0,-1 ), break207.z );
				float3 rotatedValue210 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue208, float3( -1,0,0 ), break207.x );
				float3 rotatedValue213 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue210, float3( 0,-1,0 ), break207.y );
				float4 OffsetFinal154 = ( ( float4( staticSwitch120 , 0.0 ) + ( staticSwitch109 * CenterVector44 * _OffsetPower * float4( staticSwitch49 , 0.0 ) ) ) + float4( rotatedValue213 , 0.0 ) );
				
				float3 break206 = RotationInRadian216;
				float4 break191 = tex2Dlod( _MorphNormal, float4( appendResult177, 0, 0.0) );
				float4 appendResult196 = (float4(( break191.r * 1.0 ) , ( break191.g * 1.0 ) , ( break191.b * 1.0 ) , ( break191.a * 1.0 )));
				float4 MorphNormals152 = (float4( 1,1,-1,-1 ) + (appendResult196 - float4( 0,0,0,0 )) * (float4( -1,-1,1,1 ) - float4( 1,1,-1,-1 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 )));
				float3 rotatedValue209 = RotateAroundAxis( float3( 0,0,0 ), MorphNormals152.xyz, float3( 0,0,-1 ), break206.z );
				float3 rotatedValue211 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue209, float3( -1,0,0 ), break206.x );
				float3 rotatedValue212 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue211, float3( 0,-1,0 ), break206.y );
				float3 VertexNormalsFinal222 = rotatedValue212;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OffsetFinal154.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = VertexNormalsFinal222;

				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 999999
			#define ASE_TEXTURE_PARAMS(textureName) textureName
			
			#define _NORMALMAP 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#pragma shader_feature _VERTEXDISTORTIONENABLED_ON
			#pragma shader_feature _CENTERMASKENABLED_ON
			#pragma shader_feature _FLIPOFFSETMASK_ON
			#pragma shader_feature _OFFSETYLOCK_ON
			#pragma shader_feature _USEGAMMARENDERING_ON
			#pragma shader_feature _FLIPMORPHMASK_ON
			#pragma shader_feature _RAMPENABLED_ON
			#pragma shader_feature _FLIPEMISSIONMASK_ON


			sampler2D _VertexOffsetTexture;
			float4 _Affector;
			sampler2D _MorphMain;
			sampler2D _MorphNormal;
			sampler2D _Albedo;
			sampler2D _Ramp;
			sampler2D _Emission;
			CBUFFER_START( UnityPerMaterial )
			float _VertexDistortionPower;
			float _VertexDistortionTiling;
			float _Distance;
			float _DistanceRemap;
			float _DistancePower;
			float _CenterMaskSubtract;
			float _CenterMaskMultiply;
			float _OffsetPower;
			float4 _ColorTint;
			float4 _Albedo_ST;
			float4 _Normal_ST;
			float4 _FinalColorTwo;
			float4 _FinalColorOne;
			float _FinalMaskMultiply;
			float _FinalPower;
			float4 _Emission_ST;
			float _Metallic;
			float4 _MetallicSmoothness_ST;
			float _Smoothness;
			CBUFFER_END


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			inline float4 TriplanarSamplingSV( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.zy * float2( nsign.x, 1.0 ), 0, 0 ) ) );
				yNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xz * float2( nsign.y, 1.0 ), 0, 0 ) ) );
				zNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0 ) ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 temp_cast_0 = (0.0).xxx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar111 = TriplanarSamplingSV( _VertexOffsetTexture, ase_worldPos, ase_worldNormal, 1.0, _VertexDistortionTiling, 1.0, 0 );
				float4 break114 = triplanar111;
				float3 appendResult115 = (float3(break114.x , break114.y , break114.z));
				#ifdef _VERTEXDISTORTIONENABLED_ON
				float3 staticSwitch120 = ( _VertexDistortionPower * (float3( -1,-1,-1 ) + (appendResult115 - float3( 0,0,0 )) * (float3( 1,1,1 ) - float3( -1,-1,-1 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) );
				#else
				float3 staticSwitch120 = temp_cast_0;
				#endif
				float4 appendResult17 = (float4(v.texcoord1.w , v.texcoord2.x , v.texcoord2.y , 0.0));
				float DistanceMask45 = ( 1.0 - distance( appendResult17 , _Affector ) );
				float clampResult23 = clamp( (0.0 + (( DistanceMask45 + ( _Distance - 1.0 ) ) - 0.0) * (_DistanceRemap - 0.0) / (_Distance - 0.0)) , 0.0 , 1.0 );
				float ResultMask53 = pow( clampResult23 , _DistancePower );
				#ifdef _FLIPOFFSETMASK_ON
				float staticSwitch225 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch225 = ResultMask53;
				#endif
				float clampResult105 = clamp( ( staticSwitch225 - _CenterMaskSubtract ) , 0.0 , 1.0 );
				#ifdef _CENTERMASKENABLED_ON
				float staticSwitch109 = ( staticSwitch225 - ( clampResult105 * _CenterMaskMultiply ) );
				#else
				float staticSwitch109 = staticSwitch225;
				#endif
				float4 normalizeResult41 = normalize( ( appendResult17 - _Affector ) );
				float4 CenterVector44 = normalizeResult41;
				float3 temp_cast_2 = (1.0).xxx;
				#ifdef _OFFSETYLOCK_ON
				float3 staticSwitch49 = float3(1,0,1);
				#else
				float3 staticSwitch49 = temp_cast_2;
				#endif
				float3 appendResult218 = (float3(v.texcoord2.z , v.texcoord2.w , v.ase_texcoord3.x));
				float3 RotationInRadian216 = -appendResult218;
				float3 break207 = RotationInRadian216;
				#ifdef _FLIPMORPHMASK_ON
				float staticSwitch202 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch202 = ResultMask53;
				#endif
				float2 appendResult177 = (float2(v.texcoord1.x , ( v.texcoord1.y + (-0.5 + (staticSwitch202 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) )));
				float4 tex2DNode132 = tex2Dlod( _MorphMain, float4( appendResult177, 0, 0.0) );
				float3 gammaToLinear230 = FastSRGBToLinear( tex2DNode132.rgb );
				#ifdef _USEGAMMARENDERING_ON
				float4 staticSwitch229 = float4( gammaToLinear230 , 0.0 );
				#else
				float4 staticSwitch229 = tex2DNode132;
				#endif
				float4 break179 = staticSwitch229;
				float4 appendResult184 = (float4(( break179.r * -1.0 ) , ( break179.g * -1.0 ) , ( break179.b * 1.0 ) , ( break179.a * 1.0 )));
				float4 Morph186 = ( appendResult184 * v.texcoord1.z );
				float3 rotatedValue208 = RotateAroundAxis( float3( 0,0,0 ), Morph186.xyz, float3( 0,0,-1 ), break207.z );
				float3 rotatedValue210 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue208, float3( -1,0,0 ), break207.x );
				float3 rotatedValue213 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue210, float3( 0,-1,0 ), break207.y );
				float4 OffsetFinal154 = ( ( float4( staticSwitch120 , 0.0 ) + ( staticSwitch109 * CenterVector44 * _OffsetPower * float4( staticSwitch49 , 0.0 ) ) ) + float4( rotatedValue213 , 0.0 ) );
				
				float3 break206 = RotationInRadian216;
				float4 break191 = tex2Dlod( _MorphNormal, float4( appendResult177, 0, 0.0) );
				float4 appendResult196 = (float4(( break191.r * 1.0 ) , ( break191.g * 1.0 ) , ( break191.b * 1.0 ) , ( break191.a * 1.0 )));
				float4 MorphNormals152 = (float4( 1,1,-1,-1 ) + (appendResult196 - float4( 0,0,0,0 )) * (float4( -1,-1,1,1 ) - float4( 1,1,-1,-1 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 )));
				float3 rotatedValue209 = RotateAroundAxis( float3( 0,0,0 ), MorphNormals152.xyz, float3( 0,0,-1 ), break206.z );
				float3 rotatedValue211 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue209, float3( -1,0,0 ), break206.x );
				float3 rotatedValue212 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue211, float3( 0,-1,0 ), break206.y );
				float3 VertexNormalsFinal222 = rotatedValue212;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.texcoord1;
				o.ase_texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OffsetFinal154.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = VertexNormalsFinal222;

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_Albedo = IN.ase_texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				
				float4 appendResult17 = (float4(IN.ase_texcoord1.w , IN.ase_texcoord2.x , IN.ase_texcoord2.y , 0.0));
				float DistanceMask45 = ( 1.0 - distance( appendResult17 , _Affector ) );
				float clampResult23 = clamp( (0.0 + (( DistanceMask45 + ( _Distance - 1.0 ) ) - 0.0) * (_DistanceRemap - 0.0) / (_Distance - 0.0)) , 0.0 , 1.0 );
				float ResultMask53 = pow( clampResult23 , _DistancePower );
				#ifdef _FLIPEMISSIONMASK_ON
				float staticSwitch223 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch223 = ResultMask53;
				#endif
				float clampResult88 = clamp( ( staticSwitch223 * _FinalMaskMultiply ) , 0.0 , 1.0 );
				float4 lerpResult37 = lerp( _FinalColorTwo , _FinalColorOne , clampResult88);
				float2 appendResult83 = (float2(clampResult88 , 0.0));
				#ifdef _RAMPENABLED_ON
				float4 staticSwitch81 = tex2D( _Ramp, appendResult83 );
				#else
				float4 staticSwitch81 = lerpResult37;
				#endif
				float2 uv_Emission = IN.ase_texcoord.xy * _Emission_ST.xy + _Emission_ST.zw;
				
				
				float3 Albedo = ( ( _ColorTint * tex2D( _Albedo, uv_Albedo ) ) + float4( 0,0,0,0 ) ).rgb;
				float3 Emission = ( ( staticSwitch81 * IN.ase_color * _FinalPower * tex2D( _Emission, uv_Emission ).r * IN.ase_color.a ) + float4( 0,0,0,0 ) ).rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero , One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 999999
			#define ASE_TEXTURE_PARAMS(textureName) textureName
			
			#define _NORMALMAP 1

			#pragma enable_d3d11_debug_symbols
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#pragma shader_feature _VERTEXDISTORTIONENABLED_ON
			#pragma shader_feature _CENTERMASKENABLED_ON
			#pragma shader_feature _FLIPOFFSETMASK_ON
			#pragma shader_feature _OFFSETYLOCK_ON
			#pragma shader_feature _USEGAMMARENDERING_ON
			#pragma shader_feature _FLIPMORPHMASK_ON


			sampler2D _VertexOffsetTexture;
			float4 _Affector;
			sampler2D _MorphMain;
			sampler2D _MorphNormal;
			sampler2D _Albedo;
			CBUFFER_START( UnityPerMaterial )
			float _VertexDistortionPower;
			float _VertexDistortionTiling;
			float _Distance;
			float _DistanceRemap;
			float _DistancePower;
			float _CenterMaskSubtract;
			float _CenterMaskMultiply;
			float _OffsetPower;
			float4 _ColorTint;
			float4 _Albedo_ST;
			float4 _Normal_ST;
			float4 _FinalColorTwo;
			float4 _FinalColorOne;
			float _FinalMaskMultiply;
			float _FinalPower;
			float4 _Emission_ST;
			float _Metallic;
			float4 _MetallicSmoothness_ST;
			float _Smoothness;
			CBUFFER_END


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
			};

			inline float4 TriplanarSamplingSV( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.zy * float2( nsign.x, 1.0 ), 0, 0 ) ) );
				yNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xz * float2( nsign.y, 1.0 ), 0, 0 ) ) );
				zNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0 ) ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;

				float3 temp_cast_0 = (0.0).xxx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar111 = TriplanarSamplingSV( _VertexOffsetTexture, ase_worldPos, ase_worldNormal, 1.0, _VertexDistortionTiling, 1.0, 0 );
				float4 break114 = triplanar111;
				float3 appendResult115 = (float3(break114.x , break114.y , break114.z));
				#ifdef _VERTEXDISTORTIONENABLED_ON
				float3 staticSwitch120 = ( _VertexDistortionPower * (float3( -1,-1,-1 ) + (appendResult115 - float3( 0,0,0 )) * (float3( 1,1,1 ) - float3( -1,-1,-1 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) );
				#else
				float3 staticSwitch120 = temp_cast_0;
				#endif
				float4 appendResult17 = (float4(v.ase_texcoord1.w , v.ase_texcoord2.x , v.ase_texcoord2.y , 0.0));
				float DistanceMask45 = ( 1.0 - distance( appendResult17 , _Affector ) );
				float clampResult23 = clamp( (0.0 + (( DistanceMask45 + ( _Distance - 1.0 ) ) - 0.0) * (_DistanceRemap - 0.0) / (_Distance - 0.0)) , 0.0 , 1.0 );
				float ResultMask53 = pow( clampResult23 , _DistancePower );
				#ifdef _FLIPOFFSETMASK_ON
				float staticSwitch225 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch225 = ResultMask53;
				#endif
				float clampResult105 = clamp( ( staticSwitch225 - _CenterMaskSubtract ) , 0.0 , 1.0 );
				#ifdef _CENTERMASKENABLED_ON
				float staticSwitch109 = ( staticSwitch225 - ( clampResult105 * _CenterMaskMultiply ) );
				#else
				float staticSwitch109 = staticSwitch225;
				#endif
				float4 normalizeResult41 = normalize( ( appendResult17 - _Affector ) );
				float4 CenterVector44 = normalizeResult41;
				float3 temp_cast_2 = (1.0).xxx;
				#ifdef _OFFSETYLOCK_ON
				float3 staticSwitch49 = float3(1,0,1);
				#else
				float3 staticSwitch49 = temp_cast_2;
				#endif
				float3 appendResult218 = (float3(v.ase_texcoord2.z , v.ase_texcoord2.w , v.ase_texcoord3.x));
				float3 RotationInRadian216 = -appendResult218;
				float3 break207 = RotationInRadian216;
				#ifdef _FLIPMORPHMASK_ON
				float staticSwitch202 = ( 1.0 - ResultMask53 );
				#else
				float staticSwitch202 = ResultMask53;
				#endif
				float2 appendResult177 = (float2(v.ase_texcoord1.x , ( v.ase_texcoord1.y + (-0.5 + (staticSwitch202 - 0.0) * (0.5 - -0.5) / (1.0 - 0.0)) )));
				float4 tex2DNode132 = tex2Dlod( _MorphMain, float4( appendResult177, 0, 0.0) );
				float3 gammaToLinear230 = FastSRGBToLinear( tex2DNode132.rgb );
				#ifdef _USEGAMMARENDERING_ON
				float4 staticSwitch229 = float4( gammaToLinear230 , 0.0 );
				#else
				float4 staticSwitch229 = tex2DNode132;
				#endif
				float4 break179 = staticSwitch229;
				float4 appendResult184 = (float4(( break179.r * -1.0 ) , ( break179.g * -1.0 ) , ( break179.b * 1.0 ) , ( break179.a * 1.0 )));
				float4 Morph186 = ( appendResult184 * v.ase_texcoord1.z );
				float3 rotatedValue208 = RotateAroundAxis( float3( 0,0,0 ), Morph186.xyz, float3( 0,0,-1 ), break207.z );
				float3 rotatedValue210 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue208, float3( -1,0,0 ), break207.x );
				float3 rotatedValue213 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue210, float3( 0,-1,0 ), break207.y );
				float4 OffsetFinal154 = ( ( float4( staticSwitch120 , 0.0 ) + ( staticSwitch109 * CenterVector44 * _OffsetPower * float4( staticSwitch49 , 0.0 ) ) ) + float4( rotatedValue213 , 0.0 ) );
				
				float3 break206 = RotationInRadian216;
				float4 break191 = tex2Dlod( _MorphNormal, float4( appendResult177, 0, 0.0) );
				float4 appendResult196 = (float4(( break191.r * 1.0 ) , ( break191.g * 1.0 ) , ( break191.b * 1.0 ) , ( break191.a * 1.0 )));
				float4 MorphNormals152 = (float4( 1,1,-1,-1 ) + (appendResult196 - float4( 0,0,0,0 )) * (float4( -1,-1,1,1 ) - float4( 1,1,-1,-1 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 )));
				float3 rotatedValue209 = RotateAroundAxis( float3( 0,0,0 ), MorphNormals152.xyz, float3( 0,0,-1 ), break206.z );
				float3 rotatedValue211 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue209, float3( -1,0,0 ), break206.x );
				float3 rotatedValue212 = RotateAroundAxis( float3( 0,0,0 ), rotatedValue211, float3( 0,-1,0 ), break206.y );
				float3 VertexNormalsFinal222 = rotatedValue212;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = OffsetFinal154.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = VertexNormalsFinal222;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.vertex.xyz );
				o.clipPos = vertexInput.positionCS;
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				float2 uv_Albedo = IN.ase_texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				
				
				float3 Albedo = ( ( _ColorTint * tex2D( _Albedo, uv_Albedo ) ) + float4( 0,0,0,0 ) ).rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=17500
1;387;1906;629;-683.0575;1134.649;1.541025;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;174;-2993.354,-1245.181;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;175;-2992.718,-1074.403;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;17;-2674.528,-1127.697;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;20;-2718.477,-973.0436;Float;False;Global;_Affector;_Affector;3;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;19;-2421.068,-973.3565;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;-2245.944,-972.6654;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2935.559,-420.2718;Float;False;Property;_Distance;Distance;18;0;Create;True;0;0;False;0;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-2038.447,-979.4384;Float;False;DistanceMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2935.004,-317.4798;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-2998.05,-515.4072;Inherit;False;45;DistanceMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-2744.894,-377.8731;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-2496.794,-445.7886;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;227;-2690.188,-642.8907;Float;False;Property;_DistanceRemap;Distance Remap;20;0;Create;True;0;0;False;0;1;1;1;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;31;-2517.094,-496.4949;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;28;-2237.74,-531.2965;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;23;-2053.557,-530.7089;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2255.449,-360.2385;Float;False;Property;_DistancePower;Distance Power;19;0;Create;True;0;0;False;0;1;1;0.2;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;33;-1818.45,-450.2388;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-1637.644,-457.1917;Float;False;ResultMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-3366.347,1857.43;Inherit;False;53;ResultMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;203;-3180.155,2059.244;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;202;-3005.155,1959.243;Float;False;Property;_FlipMorphMask;Flip Morph Mask;0;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;189;-2697.35,1611.004;Inherit;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;187;-2707.247,1962.092;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;-2474.264,1856.568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;177;-2280.953,1743.604;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;132;-1947.373,1486.319;Inherit;True;Property;_MorphMain;Morph Main;3;0;Create;True;0;0;False;0;-1;None;0375bff8996bd734e96bd48295092eeb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GammaToLinearNode;230;-2018.933,1061.066;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-1046.615,398.8686;Inherit;False;53;ResultMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;229;-1797.834,1032.073;Float;False;Property;_UseGammaRendering;Use Gamma Rendering;30;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;219;-2902.337,-124.1142;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;226;-829.6511,528.6901;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;220;-2901.315,152.3236;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;133;-1928.339,1978.218;Inherit;True;Property;_MorphNormal;Morph Normal;4;0;Create;True;0;0;False;0;-1;None;9415ef6bad22e604bae687c3adc0ee3f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;179;-1603.782,1491.728;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;103;-535.1007,624.9363;Float;False;Property;_CenterMaskSubtract;Center Mask Subtract;25;0;Create;True;0;0;False;0;0.75;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-1260.783,1389.728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-948.1693,174.6511;Float;False;Property;_VertexDistortionTiling;Vertex Distortion Tiling;29;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;218;-2615.314,23.32343;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-1251.782,1688.729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;191;-1579.565,1989.366;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-1253.783,1583.728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;225;-635.4039,395.0158;Float;False;Property;_FlipOffsetMask;Flip Offset Mask;2;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;113;-927.8683,-18.3929;Float;True;Property;_VertexOffsetTexture;Vertex Offset Texture;27;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-1256.783,1482.728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-1268.178,1933.093;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-1271.831,2026.093;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-284.7973,531.0767;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-1264.679,2127.093;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;199;-983.8941,1728.685;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;217;-2458.654,21.65442;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;184;-991.3842,1501.629;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-1263.429,2226.967;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;111;-637.6868,55.03267;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-2414.754,-1126.474;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;196;-1020.052,2037.466;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-631.4807,1623.868;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-230.0661,656.0699;Float;False;Property;_CenterMaskMultiply;Center Mask Multiply;24;0;Create;True;0;0;False;0;4;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;114;-277.9813,55.32092;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;105;-139.673,529.8535;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-2311.828,16.77723;Float;False;RotationInRadian;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;197;-763.6547,2035.365;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;1,1,1,1;False;3;FLOAT4;1,1,-1,-1;False;4;FLOAT4;-1,-1,1,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;56.45676,575.2776;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;440.1099,1470.168;Inherit;False;216;RotationInRadian;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;41;-2248.858,-1125.48;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-472.9491,1621.167;Float;False;Morph;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;115;25.90511,52.74559;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;50;330.274,920.8004;Float;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-2040.929,-1116.846;Float;False;CenterVector;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-558.2183,2031.605;Float;False;MorphNormals;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;434.9919,2093.339;Inherit;False;216;RotationInRadian;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;207;701.7459,1473.542;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;214;759.9273,1599.658;Inherit;False;186;Morph;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;119;215.9899,48.42035;Inherit;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;3;FLOAT3;-1,-1,-1;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;108;249.4375,451.1259;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;51;302.2741,764.8003;Float;False;Constant;_Vector0;Vector 0;8;0;Create;True;0;0;False;0;1,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;118;125.9526,-48.14551;Float;False;Property;_VertexDistortionPower;Vertex Distortion Power;28;0;Create;True;0;0;False;0;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;49;566.657,823.687;Float;False;Property;_OffsetYLock;Offset Y Lock;21;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;43;586.7905,730.4666;Float;False;Property;_OffsetPower;Offset Power;22;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;206;696.6832,2099.552;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;511.1227,42.56478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;121;512.0356,157.9077;Float;False;Constant;_Float2;Float 2;24;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;548.5768,645.7773;Inherit;False;44;CenterVector;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;735.9254,2223.337;Inherit;False;152;MorphNormals;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;208;1080.517,1622.996;Inherit;False;False;4;0;FLOAT3;0,0,-1;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;109;505.4623,524.6801;Float;False;Property;_CenterMaskEnabled;Center Mask Enabled;23;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;209;1096.626,2230.124;Inherit;False;False;4;0;FLOAT3;0,0,-1;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;916.3195,638.3792;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;210;1087.143,1312.103;Inherit;False;False;4;0;FLOAT3;-1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;120;744.2634,78.4812;Float;False;Property;_VertexDistortionEnabled;Vertex Distortion Enabled;26;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;1370.645,339.3983;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;213;1091.009,1459.852;Inherit;False;False;4;0;FLOAT3;0,-1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;211;1096.92,1926.641;Inherit;False;False;4;0;FLOAT3;-1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;100;1435.369,-1678.405;Float;False;Property;_ColorTint;Color Tint;6;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotateAboutAxisNode;212;1096.626,2072.916;Inherit;False;False;4;0;FLOAT3;0,-1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;1752.162,919.6628;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;89;1209.255,-1494.071;Inherit;True;Property;_Albedo;Albedo;5;0;Create;True;0;0;False;0;-1;None;20d714081e9fac74e99ad3c851a18b66;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;1913.964,917.308;Float;False;OffsetFinal;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;1464.209,2073.557;Float;False;VertexNormalsFinal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;1738.369,-1584.404;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-771.1036,-879.9979;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1078.105,-829.9976;Float;False;Property;_FinalMaskMultiply;Final Mask Multiply;15;0;Create;True;0;0;False;0;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;-697.9361,-1065.661;Float;False;Property;_FinalColorOne;Final Color One;12;0;Create;True;0;0;False;0;1,0,0,1;1,0.5991886,0.2352941,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;54;-1461.157,-1010.175;Inherit;False;53;ResultMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;83;-425.3648,-819.9307;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;88;-614.2828,-883.5568;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;223;-1057.479,-1005.835;Float;False;Property;_FlipEmissionMask;Flip Emission Mask;1;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;224;-1232.336,-923.7797;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;82;-264.7276,-843.2589;Inherit;True;Property;_Ramp;Ramp;17;0;Create;True;0;0;False;0;-1;None;7150651ef88cabe44a1406ee9f810786;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;37;-371.767,-1167.51;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;81;202.7726,-894.6599;Float;False;Property;_RampEnabled;Ramp Enabled;16;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;173;134.2945,-512.4421;Inherit;True;Property;_Emission;Emission;11;0;Create;True;0;0;False;0;-1;None;7c2971a298af5674ea309ad2022930e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;146.9107,-601.3729;Float;False;Property;_FinalPower;Final Power;14;0;Create;True;0;0;False;0;6;12;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;-703.6391,-1252.178;Float;False;Property;_FinalColorTwo;Final Color Two;13;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;52;233.7712,-787.0007;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;96;847.4246,-533.884;Float;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;233;2296.868,-1042.219;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;90;663.0696,-445.9392;Inherit;True;Property;_MetallicSmoothness;MetallicSmoothness;7;0;Create;True;0;0;False;0;-1;None;c96026a5450b02c4b90d63fd9238e59f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;235;1879.522,-582.8231;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;2280.332,-556.854;Inherit;False;154;OffsetFinal;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-621.119,-752.5731;Float;False;Constant;_Float5;Float 5;16;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;91;1299.092,-1279.551;Inherit;True;Property;_Normal;Normal;10;0;Create;True;0;0;False;0;-1;None;c1b2383bc664c7c46bfbac4fe51e810b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;231;2287.909,-1271.642;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;1188.15,-466.882;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;2224.061,-459.826;Inherit;False;222;VertexNormalsFinal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;234;1876.044,-699.4941;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;614.7059,-791.0023;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;232;2298.132,-1163.286;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;1185.497,-294.6173;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;835.4246,-234.8844;Float;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;243;2604.53,-940.9862;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;244;2604.53,-940.9862;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;241;2604.53,-940.9862;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;SineVFX/LivingParticles/LivingParticleMaskedMorphPbrURP;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;0;Forward;12;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;12;Workflow;1;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;Meta Pass;1;Override Baked GI;0;Vertex Position,InvertActionOnDeselection;1;0;5;True;True;True;True;True;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;242;2604.53,-940.9862;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;245;2604.53,-940.9862;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;4;Universal2D;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;17;0;174;4
WireConnection;17;1;175;1
WireConnection;17;2;175;2
WireConnection;19;0;17;0
WireConnection;19;1;20;0
WireConnection;22;0;19;0
WireConnection;45;0;22;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;24;0;47;0
WireConnection;24;1;26;0
WireConnection;31;0;25;0
WireConnection;28;0;24;0
WireConnection;28;2;31;0
WireConnection;28;4;227;0
WireConnection;23;0;28;0
WireConnection;33;0;23;0
WireConnection;33;1;34;0
WireConnection;53;0;33;0
WireConnection;203;0;200;0
WireConnection;202;1;200;0
WireConnection;202;0;203;0
WireConnection;187;0;202;0
WireConnection;176;0;189;2
WireConnection;176;1;187;0
WireConnection;177;0;189;1
WireConnection;177;1;176;0
WireConnection;132;1;177;0
WireConnection;230;0;132;0
WireConnection;229;1;132;0
WireConnection;229;0;230;0
WireConnection;226;0;55;0
WireConnection;133;1;177;0
WireConnection;179;0;229;0
WireConnection;183;0;179;0
WireConnection;218;0;219;3
WireConnection;218;1;219;4
WireConnection;218;2;220;1
WireConnection;182;0;179;3
WireConnection;191;0;133;0
WireConnection;181;0;179;2
WireConnection;225;1;55;0
WireConnection;225;0;226;0
WireConnection;180;0;179;1
WireConnection;192;0;191;0
WireConnection;194;0;191;1
WireConnection;101;0;225;0
WireConnection;101;1;103;0
WireConnection;195;0;191;2
WireConnection;217;0;218;0
WireConnection;184;0;183;0
WireConnection;184;1;180;0
WireConnection;184;2;181;0
WireConnection;184;3;182;0
WireConnection;193;0;191;3
WireConnection;111;0;113;0
WireConnection;111;3;122;0
WireConnection;39;0;17;0
WireConnection;39;1;20;0
WireConnection;196;0;192;0
WireConnection;196;1;194;0
WireConnection;196;2;195;0
WireConnection;196;3;193;0
WireConnection;185;0;184;0
WireConnection;185;1;199;3
WireConnection;114;0;111;0
WireConnection;105;0;101;0
WireConnection;216;0;217;0
WireConnection;197;0;196;0
WireConnection;106;0;105;0
WireConnection;106;1;107;0
WireConnection;41;0;39;0
WireConnection;186;0;185;0
WireConnection;115;0;114;0
WireConnection;115;1;114;1
WireConnection;115;2;114;2
WireConnection;44;0;41;0
WireConnection;152;0;197;0
WireConnection;207;0;205;0
WireConnection;119;0;115;0
WireConnection;108;0;225;0
WireConnection;108;1;106;0
WireConnection;49;1;50;0
WireConnection;49;0;51;0
WireConnection;206;0;204;0
WireConnection;117;0;118;0
WireConnection;117;1;119;0
WireConnection;208;1;207;2
WireConnection;208;3;214;0
WireConnection;109;1;225;0
WireConnection;109;0;108;0
WireConnection;209;1;206;2
WireConnection;209;3;215;0
WireConnection;42;0;109;0
WireConnection;42;1;46;0
WireConnection;42;2;43;0
WireConnection;42;3;49;0
WireConnection;210;1;207;0
WireConnection;210;3;208;0
WireConnection;120;1;121;0
WireConnection;120;0;117;0
WireConnection;116;0;120;0
WireConnection;116;1;42;0
WireConnection;213;1;207;1
WireConnection;213;3;210;0
WireConnection;211;1;206;0
WireConnection;211;3;209;0
WireConnection;212;1;206;1
WireConnection;212;3;211;0
WireConnection;150;0;116;0
WireConnection;150;1;213;0
WireConnection;154;0;150;0
WireConnection;222;0;212;0
WireConnection;99;0;100;0
WireConnection;99;1;89;0
WireConnection;85;0;223;0
WireConnection;85;1;86;0
WireConnection;83;0;88;0
WireConnection;83;1;84;0
WireConnection;88;0;85;0
WireConnection;223;1;54;0
WireConnection;223;0;224;0
WireConnection;224;0;54;0
WireConnection;82;1;83;0
WireConnection;37;0;36;0
WireConnection;37;1;14;0
WireConnection;37;2;88;0
WireConnection;81;1;37;0
WireConnection;81;0;82;0
WireConnection;233;0;3;0
WireConnection;235;0;97;0
WireConnection;231;0;99;0
WireConnection;95;0;96;0
WireConnection;95;1;90;1
WireConnection;234;0;95;0
WireConnection;3;0;81;0
WireConnection;3;1;52;0
WireConnection;3;2;4;0
WireConnection;3;3;173;1
WireConnection;3;4;52;4
WireConnection;232;0;91;0
WireConnection;97;0;90;4
WireConnection;97;1;98;0
WireConnection;241;0;231;0
WireConnection;241;1;232;0
WireConnection;241;2;233;0
WireConnection;241;3;234;0
WireConnection;241;4;235;0
WireConnection;241;8;155;0
WireConnection;241;10;153;0
ASEEND*/
//CHKSM=9F8AF6F531B7AAFB7FE42EE8B7AEED6CAE226936
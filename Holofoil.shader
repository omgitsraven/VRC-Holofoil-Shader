Shader "Unlit/Holofoil"{
	Properties{
		_MainTex ("Color Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_LightDir ("Light Dir", Vector) = (0.0,0.3,0.2,0.0)
		_RainbowDist ("Rainbow Dist", Range(0.0, 10.0)) = 6.0
		_MaskCurve ("Mask Curve", float) = 0.45
		_SpecBrightLo ("Spec Bright Lo", float) = 0.2
		_SpecBrightHi ("Spec Bright Hi", float) = 0.9
		_SpecFocusLo ("Spec Focus Lo", float) = 10.0
		_SpecFocusHi ("Spec Focus Hi", float) = 192.0
	}
	SubShader{
		Tags { "RenderType"="Opaque" }
		
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			struct v2f{
				float4 vertex : SV_POSITION;
				float4 vertexWorld : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			
			float3 _LightDir;
			float _RainbowDist;
			float _MaskCurve;
			
			float _SpecBrightLo;
			float _SpecBrightHi;
			
			float _SpecFocusLo;
			float _SpecFocusHi;
			
			
			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = normalize( mul( float4( v.normal, 0.0 ), unity_WorldToObject ).xyz );
				return o;
			}
			
			
			// https://web.archive.org/web/20200207113336/http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
			float3 rgb2hsv(float3 c){
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
				float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
				
				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
			float3 hsv2rgb(float3 c){
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
			}
			
			
			fixed4 frag (v2f i) : SV_Target{
				float3 colPx = tex2D(_MainTex, i.uv).rgb;
				float holoPx = 1.0-pow(1.0-tex2D(_MaskTex, i.uv).r,_MaskCurve);
				holoPx *= 1.0-pow(1.0-max(max(colPx.r,colPx.g),colPx.b),10.0);
				
				float3 lightDir = normalize(_LightDir);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertexWorld.xyz);
				float3 reflectDir = reflect(-lightDir,i.worldNormal);
				float specDot = dot(viewDir,reflectDir);
				float specP = lerp(_SpecFocusLo,_SpecFocusHi,holoPx);
				float specA = lerp(_SpecBrightLo,_SpecBrightHi,holoPx);
				float spec = pow(abs(specDot),specP)*specA;
				
				float fresnelAmt = dot(-viewDir,i.worldNormal) + 1;
				fresnelAmt = pow(fresnelAmt,lerp(4.0,1.0,holoPx))*lerp(0.9,1.0,holoPx);
				spec += fresnelAmt;
				
				float3 hsv = rgb2hsv(colPx);
				float holoPush = acos(specDot)/3.14159;
				hsv.x += holoPush*_RainbowDist*holoPx;
				float3 rgb = hsv2rgb(hsv);
				
				return float4(rgb,1.0)+spec;
			}
			ENDCG
		}
	}
}

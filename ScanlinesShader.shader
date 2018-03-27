Shader "Unlit/ScanlinesShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Noise ("Noise Texture", 2D) = "white" {}
		_Tint ("Tint Color", Color) = (1,1,1,1)
		_White ("White", Color) = (1,1,1,1)
		_Black ("Black", Color) = (0,0,0,0)
		_Distort ("Distortion", 2D) = "white" {}
		_Speed ("Speed" , Range(0.0,10.0)) = 5.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 noise: TEXCOORD4;
				float4 localPosition : TEXCOORD1;
				float3 centerPosition : TEXCOORD2;
				float3 worldPosition : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Noise;
			fixed4 _Tint;
			fixed4 _White;
			fixed4 _Black;
			sampler2D _Distort;
			fixed4 _Speed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//v.uv.x += _Time * 0.5;

				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 _Edge = 0.001;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 distort = tex2D(_Distort, i.uv);
				fixed4 noise = tex2D(_Noise, fixed2( (i.uv.x + _Time.x) + distort.r +_Time.y * 0.1, (i.uv.y + _Time.x) + distort.g + _Time.y * 0.1) );
				fixed4 gradient = noise - lerp(_White, _Black, 0.4);

				//i.noise.y -= _Time * _Speed;

				col = tex2D(_MainTex, i.uv) * _Tint + gradient + distort;

				col = col + saturate((noise + _Edge) * 0.2);

				return col;
			}
			ENDCG
		}
	}
}

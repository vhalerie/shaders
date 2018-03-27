Shader "Unlit/FireShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		_Noise ("Noise" , 2D) = "white" {}
		_gradient1 ("Gradient 1", Color) = (1,1,1,1)
		_gradient2 ("Gradient 2", Color) = (0,0,0,0)
		_FireColor ("Fire Color", Color) = (1,1,1,1)
		_ShapeMask ("Mask Transparency", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _BaseColor;
			sampler2D _Noise;
			fixed4 _gradient1;
			fixed4 _gradient2;
			fixed4 _FireColor;
			sampler2D _ShapeMask;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
				fixed scrollX = i.uv.x - _Time.x * 0.5;
				fixed scrollY = i.uv.y - _Time.y * 0.5;

				fixed4 noise = tex2D(_Noise, fixed2(scrollX, scrollY));

				scrollY = (scrollY < 0.1 ) ? 0.5: 0;

				fixed4 gradient = noise - lerp(_gradient1, _gradient2, i.uv.y);

				col = (col + gradient * 15 * _FireColor) / 2.5;

				col.a = (noise.a < 1 * gradient.a) ? 1 : 0;

				col = + 1.0f + col + gradient + gradient;

				fixed4 transparencyMask = tex2D(_ShapeMask, i.uv);
				col.a = transparencyMask.a;
				clip(transparencyMask - 0.1);
				return col;
			}
			ENDCG
		}
	}
}

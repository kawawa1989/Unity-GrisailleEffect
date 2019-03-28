Shader "Custom/Grisaille"
{
    Properties
    {
        [Toggle]_OverlayActive1 ("Overlay Active 1", Float) = 0
        _Overlay1 ("Overlay 1", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive2 ("Overlay Active 2", Float) = 0
        _Overlay2 ("overlay 2", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive3 ("Overlay Active 3", Float) = 0
        _Overlay3 ("overlay 3", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive4 ("Overlay Active 4", Float) = 0
        _Overlay4 ("overlay 4", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive5 ("Overlay Active 5", Float) = 0
        _Overlay5 ("overlay 5", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive6 ("Overlay Active 6", Float) = 0
        _Overlay6 ("overlay 6", Color) = (0.5,0.5,0.5,1)
		
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			fixed4 _Overlay1;
			fixed4 _Overlay2;
			fixed4 _Overlay3;
			fixed4 _Overlay4;
			fixed4 _Overlay5;
			fixed4 _Overlay6;
			int _OverlayActive1;
			int _OverlayActive2;
			int _OverlayActive3;
			int _OverlayActive4;
			int _OverlayActive5;
			int _OverlayActive6;

			inline float calcSynthesisedColor(float overlayColor, float lastColor){	
				float screenMode = 2 * (lastColor + overlayColor - lastColor * overlayColor / 1) - 1;
				float mulMode = lastColor * (overlayColor / 1) * 2;
				float synthsised = lerp(mulMode, screenMode, step(0.5, lastColor));
				return synthsised;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				const int OVERLAY_SIZE = 6;
				fixed4 overlayColors[OVERLAY_SIZE];
				int overlayFlags[OVERLAY_SIZE];
                fixed4 color = tex2D(_MainTex, i.uv);

				overlayColors[0] = _Overlay1;
				overlayColors[1] = _Overlay2;
				overlayColors[2] = _Overlay3;
				overlayColors[3] = _Overlay4;
				overlayColors[4] = _Overlay5;
				overlayColors[5] = _Overlay6;
				overlayFlags[0] = _OverlayActive1;
				overlayFlags[1] = _OverlayActive2;
				overlayFlags[2] = _OverlayActive3;
				overlayFlags[3] = _OverlayActive4;
				overlayFlags[4] = _OverlayActive5;
				overlayFlags[5] = _OverlayActive6;


				// 最後に行った合成処理によって変化した色を格納する
				fixed4 lastColor = fixed4(color.r, color.g, color.b, color.a);
				int index = 0;
				// オーバーレイする回数だけぶん回す
				for (index = 0; index < OVERLAY_SIZE; ++index) {
					fixed4 overlay = overlayColors[index];
					int active = overlayFlags[index];
					if (active == 0) {
						continue;
					}
					float red = calcSynthesisedColor(overlay.r, lastColor.r);
					float green = calcSynthesisedColor(overlay.g, lastColor.g);
					float blue = calcSynthesisedColor(overlay.b, lastColor.b);
					// 今回の計算によって変化した色を格納する。
					lastColor.r = red;
					lastColor.g = green;
					lastColor.b = blue;
				}
				color.r = lastColor.r;
				color.g = lastColor.g;
				color.b = lastColor.b;
                return color;
            }
            ENDCG
        }
    }
}

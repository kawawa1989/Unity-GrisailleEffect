Shader "Custom/Grisaille"
{
    Properties
    {
        [Toggle]_OverlayActive1 ("Blend Active[1]", Float) = 0
        _Overlay1 ("Blend Color[1]", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive2 ("Blend Active[2]", Float) = 0
        _Overlay2 ("Blend Color[2]", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive3 ("Blend Active[3]", Float) = 0
        _Overlay3 ("Blend Color[3]", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive4 ("Blend Active[4]", Float) = 0
        _Overlay4 ("Blend Color[4]", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive5 ("Blend Active[5]", Float) = 0
        _Overlay5 ("Blend Color[5]", Color) = (0.5,0.5,0.5,1)

        [Toggle]_OverlayActive6 ("Blend Active[6]", Float) = 0
        _Overlay6 ("Blend Color[6]", Color) = (0.5,0.5,0.5,1)
		
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle]_LightMapActive ("Blend Active[6]", Float) = 0
        _LightMapTex ("Texture", 2D) = "white" {}
		_BlendLevel ("Level", Range (0, 1)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off 
		ZWrite Off 
		ZTest Always
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
			sampler2D _LightMapTex;
			int _LightMapActive;
			float _BlendLevel;

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

			// baseColorにoverlayColorをオーバーレイの方式で合成した色を計算して返す。
			inline float calcOverlayBlending(float overlayColor, float baseColor){	
				float screenMode = 2 * (baseColor + overlayColor - baseColor * overlayColor / 1) - 1;
				float mulMode = baseColor * (overlayColor / 1) * 2;
				float synthsised = lerp(mulMode, screenMode, step(0.5, baseColor));
				return synthsised;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				const int OVERLAY_SIZE = 6;

				// 合成する色プロパティを配列に格納
				fixed4 overlayColors[OVERLAY_SIZE];
				overlayColors[0] = _Overlay1;
				overlayColors[1] = _Overlay2;
				overlayColors[2] = _Overlay3;
				overlayColors[3] = _Overlay4;
				overlayColors[4] = _Overlay5;
				overlayColors[5] = _Overlay6;

				// 合成するフラグを配列に格納
				int overlayFlags[OVERLAY_SIZE];
				overlayFlags[0] = _OverlayActive1;
				overlayFlags[1] = _OverlayActive2;
				overlayFlags[2] = _OverlayActive3;
				overlayFlags[3] = _OverlayActive4;
				overlayFlags[4] = _OverlayActive5;
				overlayFlags[5] = _OverlayActive6;

				// テクスチャの色情報を取得
                fixed4 color = tex2D(_MainTex, i.uv);
				fixed4 light = tex2D(_LightMapTex, i.uv);

				// http://neareal.com/2428/
				if (_LightMapActive == 1) {
					//Cr = Cd * (1 - As) + Cs * As
					float As = light.a * _BlendLevel;
					float Ad = color.a;					
					color.r = color.r * (1 - As) + light.r * As;
					color.g = color.g * (1 - As) + light.g * As;
					color.b = color.b * (1 - As) + light.b * As;

					/*
					float As = light.a * _BlendLevel;
					float Ad = color.a;
					float Ar = As + (1 - As) * Ad;
					// Cr = [(Cs * As) + (Cd * (1 - As) * Ad)] / Ar
					color.r = ((light.r * As) + (color.r * (1 - As) * Ad)) / Ar;
					color.g = ((light.g * As) + (color.g * (1 - As) * Ad)) / Ar;
					color.b = ((light.b * As) + (color.b * (1 - As) * Ad)) / Ar;
					*/
				}

				// 最後に行った合成処理によって変化した色を格納する
				int index = 0;
				// オーバーレイする回数だけぶん回す
				for (index = 0; index < OVERLAY_SIZE; ++index) {
					fixed4 overlay = overlayColors[index];
					int active = overlayFlags[index];
					if (active == 0) {
						continue;
					}
					// 今回の計算によって変化した色を格納する。
					color.r = calcOverlayBlending(overlay.r, color.r);
					color.g = calcOverlayBlending(overlay.g, color.g);
					color.b = calcOverlayBlending(overlay.b, color.b);
				}
                return color;
            }
            ENDCG
        }
    }
}

Shader "Custom/Light"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Intensity ("Intensity", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }
        Blend SrcAlpha One //Blend semitransparente
        ZWrite Off

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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _Color;
            float _Intensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; //Si el shader no requiere que tenga tile ni offset basta con hacer el output de UVs igual al input de UVs
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float gradient = abs(1 - i.uv.y); //Invierte el sentido del degradado, en este caso en la coordenada v
                return float4(_Color.rgb, gradient * _Intensity);
            }
            ENDCG
        }
    }
}
Shader "VFX/Attack_Base"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(DISTORTION PROPERTIES)]
        [Space(10)]
        _DisTex ("Texture", 2D) = "white" {}
        _DisValue ("Value", Range(2, 10)) = 3
        _DisSpeed ("Speed", Range(-0.4, 0.4)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Geometry"
        }
        Blend SrcAlpha OneMinusSrcAlpha //Permite que el efecto se desvanezca al reiniciar en lugar de desaparecer de repente

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
                float4 color : COLOR; //Para poder modificar el color de la textura del objeto de este shader desde el particle system hay que agregar la semantica de color aqui y en el vertex output
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DisTex;
            float _DisValue;
            float _DisSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half distortion = tex2D(_DisTex, i.uv + (_Time * _DisSpeed)).r;
                i.uv.x += distortion * _DisValue;

                fixed4 col = tex2D(_MainTex, i.uv);
                return float4(col.rgb * i.color.rgb, i.color.a); //Indica que el alpha de los vertices sea el alpha de la textura y al multiplocar col.rgb por i.color.rgb hace posible cambiar el color de la textura desde el particle system, si necesidad de usar una propiedad y hacerlo desde el inspector del material
            }
            ENDCG
        }
    }
}
Shader "VFX/EyeMask"
{
    Properties
    {
        _Mask ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha //Blend normal (transparencia)
        AlphaToMask On //Indica que el objeto que tenga este shader funcionara como una mascara con su alpha y evita que lo que enmascara se renderice en el area del aplha de la mascara
        LOD 100

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

            sampler2D _Mask;
            float4 _Mask_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Mask);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_Mask, i.uv);
                //NOTA: Este codigo se usa cuando el fondo de la mascara va a ser un espacio 3D, si no, basta con retornar col normalmente
                // return float4(0, 0, 0, col.a); //Retorna  color negro si no se usa una textura y como alpha el alpha de la mascara
                return col;
            }
            ENDCG
        }
    }
}
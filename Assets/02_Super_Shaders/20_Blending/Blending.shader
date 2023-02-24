Shader "Custom/Blending"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor ("SrcFactor", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor ("DstFactor", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        ZWrite Off //Hace posible trabajar con transparencias (incluida blending)

        Blend [_SrcFactor] [_DstFactor] //Para poder hacer uso de blend primero hay que configurar el Queue y el RenderType en Transparent. En este caso esta configurado para poder cambiar los valores desde el inspector. Ejemplos de tipos de blending:
        /*
        //p. 78
        • SrcAlpha OneMinusSrcAlpha      //Blending normal (se puede modificar su intensidad), activa el canal alpha
        • One One                        //Blending aditivo (NO se puede modificar su intensidad)
        • OneMinusDstColor One           //Blending aditivo suave (NO se puede modificar su intensidad)
        • DstColor Zero                  //Blending multiplicativo (NO se puede modificar su intensidad)
        • DstColor SrcColor              //Blending multiplicativo x2 (NO se puede modificar su intensidad)
        • SrcColor One                   //Blending overlay (NO se puede modificar su intensidad)
        • OneMinusSrcColor One           //Blending luz suave (NO se puede modificar su intensidad)
        • Zero OneMinusSrcColor          //Blending negativo (NO se puede modificar su intensidad)
        • One OneMinusSrcAlpha           //Blending premultiplicado (se puede modificar su intensidad)
        */
        BlendOp Add //Blending operation. Valor por default, no viene escrito en el codigo
        // BlendOp Sub
        // BlendOp Max
        // BlendOp Min
        // BlendOp RevSub
        //PARA MAS INFORMACION SOBRE Blend CHECAR: https://docs.unity3d.com/Manual/SL-Blend.html

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
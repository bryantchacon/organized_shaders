Shader "Custom/ZTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass //Pass de textura, configurado con el ZTest para renderizar su efecto solo cuando este DELANTE de otros objetos
        {
            ZTest LEqual //Valor por default, no viene en el codigo. ZTest controla como se debe realizar el Depth Testing, este a su vez determina si un pixel debe o no ser actualizado en el Depth Buffer (tambien llamado Z-Buffer). Tiene 7 valores diferentes (p.88-89):
            //NOTA: Aunque se puede aplicar a objetos, no funciona al 100 con estos y al parecer si lo hace si se aplica a la camara, debido a su frustrum.
            /*
            • Less: Renderiza el efecto que indique el shader (o uno de sus pases), por delante de los demas objetos, los que esten a la misma distancia o por detras no.
            • Greater: Renderiza el efecto que indique el shader (o uno de sus pases), por detras de los demas objetos, los que esten a la misma distancia o por delante no.
            • LEqual (Valor por default): Renderiza el efecto que indique el shader (o uno de sus pases), por delante o a la misma distancia de los demas objetos, los que esten por detras no.
            • GEqual: Renderiza el efecto que indique el shader (o uno de sus pases), por detras o a la misma distancia de los demas objetos, los que esten por delante no.
            • Equal: Renderiza el efecto que indique el shader (o uno de sus pases), a la misma distancia de los demas objetos, los que esten por delante y por detras no.
            • NotEqual: Renderiza el efecto que indique el shader (o uno de sus pases), por delante y por detras de los demas objetos, los que esten a la misma distancia no.
            • Always: Siempre rederizara el efecto que indique el shader independientemente de a que distancia este con respecto a los demas.
            */
            //Generalmente se usa en shaders de pases multiples cuando se requiere generar diferencia de colores y profundidades, por ejemplo; un efecto de un personaje saliendo de las sombras hacia donde hay luz, o que al salir de cierto lugar se cambie el color de su ropa, para que esto quede mejor basta con descartar los pixeles del objeto por el que pasa de estar detras a estar por delante.

            // Cull Front

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        Pass //Pass de color, configurado con el ZTest para renderizar su efecto solo cuando este DETRAS de otros objetos QUE TENGAN UN SHADER CON Cull Back
        {
            ZTest Greater

            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            float4 _Color;

            struct vertexInput
            {
                float4 vertex : POSITION;
            };

            struct vertexOutput
            {
                float4 vertex : SV_POSITION;
            };

            vertexOutput vertexShader(vertexInput i)
            {
                vertexOutput o;
                o.vertex = UnityObjectToClipPos(i.vertex);
                return o;
            }

            float4 fragmentShader(vertexOutput o) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
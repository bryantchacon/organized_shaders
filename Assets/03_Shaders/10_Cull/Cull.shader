Shader "Custom/Cull"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Enum(UnityEngine.Rendering.CullMode)]
        _Face ("Face Culling", Float) = 0
    }
    SubShader
    {
        /*
        • Cull controla que caras deben y no deben ser renderizadas, junto con Depth Test se pueden escribir aqui y afectara a todos los pases
        • Back es su valor por defecto aunque no se escriba, lo que hace es no renderizar las caras traseras del objeto al ver a la camara, solo los que ven a ella (aunque en el modo editor solo se nota en los planos, de ahí parecerá que tiene Cull Off, pero si se aplica al ejecutar el juego)
        • Front al revez, no renderiza las caras que esten viendo hacia la camara, pero si los que estan por detras, o sea, hace que se vea el interior del objeto
        • Off renderiza todas las caras
        */
        Cull [_Face] //Optimizado para modificarse desde el inspector con la propiedad _Face

        Pass
        {
        //Tambien aqui se pueden escribir las opciones de Culling y Depth Test pero solo afectara a este pass
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata //vertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f //vertexOutput
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex; //Textura
            float4 _MainTex_ST; //Tilign y offset

            v2f vert (appdata v) //vertexShader
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target //fragmentShader
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
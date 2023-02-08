Shader "Custom/Special_Item"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _PattTex ("Pattern Texture", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _Speed ("Rotation Speed", Range(0, 3)) = 1
        [Header(RAMP PROPERTIES)]
        [Space(10)]
        _RampSpeed ("Speed", Range(1, 10)) = 10
        _RampSaturation ("Saturation", Range(1, 4)) = 3
        [Header(RIM PROPERTIES)]
        [Space(10)]
        _RimColor ("Color", Color) = (1, 1, 1, 1)
        _RimEffect ("Effect", Range(0, 1.5)) = 1
    }
    SubShader
    {
        Pass
        {
            Name "Texture Pass"

            Cull Front //Hace que las caras que ven hacia la camara no se renderizen, pero las internas si, el segundo pass no lo tiene porque en las caras es donde se vera el rim effect

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/CGFiles/TotalRotationCG.cginc"

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
            sampler2D _PattTex;
            sampler2D _RampTex;
            float4 _MainTex_ST;
            float _RampSpeed;
            float _RampSaturation;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                float3 rotVertex = TotalRotation(v.vertex, _Speed); //Uso de la funcion TotalRotation() antes de UnityObjectToClipPos()
                o.vertex = UnityObjectToClipPos(rotVertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv); //Sampleo de la textura principal

                fixed patt = tex2D(_PattTex, i.uv).r; //Sampleo del pattern, se usa una sola coordenada porque es una textura en blanco y negro y solo se usara un canal rgb para samplearla
                fixed4 ramp = tex2D(_RampTex, fixed2(patt + _Time.x * _RampSpeed, 1)) * _RampSaturation; //Samplea la textura ramp, y le da el efecto de movimiento de colores al agregarle el sampleo del pattern como el valor U de los UV mas tiempo por velocidad para darle movimiento y como segundo valor (V), 1, para que el movimiento sea del centro de las caras hacia afuera, y se multiplica todo por _RampSaturation para controlar la saturacion desde el inspector. Ademas, todo esto es con variables fixed (de menor resolucion), para que pueda ejecutarse en dispositivos moviles

                float4 mixed = lerp(ramp, col, 0.85); //Se combinan las texturas con un lerp
                return mixed;
            }
            ENDCG
        }

        Pass
        {
            Name "Rim Pass"

            Tags
            {
                "Queue"="Transparent" //Permite que ver a travez del efecto rim
            }
            Blend One One //Blend aditivo

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/CGFiles/TotalRotationCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 uv : TEXCOORD0; //Por alguna razon el efecto rim solo funciona si aqui uv es una variable de tres dimensiones, en lugar de dos como en el vertex input, y tambien se pone como tal al usarla en la funcion rimEffect, pero solo en estos dos lugares en este pase
                float3 normal : NORMAL;
            };

            float4 _RimColor;
            float _RimEffect;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                float3 rotVertex = TotalRotation(v.vertex, _Speed); //Uso de la funcion TotalRotation() antes de UnityObjectToClipPos()
                o.vertex = UnityObjectToClipPos(rotVertex);

                o.normal = normalize(mul(unity_ObjectToWorld, v.normal)); //Calcula las normales en World-Space
                o.uv = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex.xyz)); //Calcula las UVs en World-Space desde la vista de la camara tambien en World-Space para que el efecto rim se vea bien mientras se mueva la camara

                return o;
            }

            float rimEffect(float3 uv, float3 normal)
            {
                float rim = 1 - abs(dot(uv, normal)) * _RimEffect;
                return rim;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed rimCol = rimEffect(i.uv, i.normal);
                return _RimColor * rimCol * rimCol; //Si en lugar de * se usa - en ambos, se logra un efecto interesante
            }
            ENDCG
        }
    }
}
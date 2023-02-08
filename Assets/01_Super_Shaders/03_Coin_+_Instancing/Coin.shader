Shader "Custom/Coin"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(GOLD PROPERTIES)]
        [Space(10)]
        _GoldTex ("Gold Texture", 2D) = "White" {}

        [Space(10)]

        _Range ("Range", Range(1, 5)) = 1
        _Direction ("Direction", Range(-1, 1)) = -1 //Entre mas cercano a 0 mas lento ira
        _Brightness ("Brightness", Range(0.0, 0.5)) = 0.1
        _Saturation ("Saturation", Range(0.5, 1)) = 0.5

        [Space(10)]

        _Color ("Rim Color", Color) = (1, 1, 1, 1)
        _Rim ("Rim Effect", Range(0, 1)) = 1
    }
    SubShader
    {
        //TEXTURES PASS
        Pass
        {
            Tags //Tags que solo funcionaran en este pass
            {
                "Queue" = "Geometry"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //Hace posible instanciar objetos sin aumentar los draw calls (se agrega en ambos pases en el mismo lugar), paso 1/3
            //ESTA CONFIGURACION DE SOLO ESTOS 3 PARAMETROS ES LA QUE FUNCIONA BIEN (ADEMAS DE ACTIVAR EL Enable GPU Instancing Y QUE EL Rendering Path DE LA CAMARA ESTE EN Forward)
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                //Hace posible instanciar objetos sin aumentar los draw calls (se agrega en ambos pases en el mismo lugar), paso 2/3
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 uvv : TEXCOORD1; //Coordenadas uv para la gold texture
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GoldTex;
            float _Range;
            float _Direction;
            float _Brightness;
            float _Saturation;

            v2f vert (appdata v)
            {
                v2f o;

                //Hace posible instanciar objetos sin aumentar los draw calls (se agrega en ambos pases en el mismo lugar), paso 3/3
                UNITY_SETUP_INSTANCE_ID(v);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.uvv = ComputeScreenPos(o.vertex); //Funcion que asigna la gold texture a la moneda, va despues de UnityObjectToClipPos() para que el efecto no se mueva junto con la moneda al rotar

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 coords = i.uvv.xy / i.uvv.w; //Evita que la proyeccion del gold texture se mueva si se mueve la camara
                coords.x += _Time * _Direction; //Desplaza el gold texture a la izquierda o derecha segun como se manipule _Direction en el inspector

                fixed4 gol = tex2D(_GoldTex, coords * _Range);
                fixed4 col = tex2D(_MainTex, i.uv);

                col *= gol / _Saturation; //Para combinar dos texturas basta con multiplicarlas y para agregarles saturacion dividirla entre ellas

                return col + _Brightness; //Para agregar brillo este se suma a la textura al final
            }
            ENDCG
        }

        //RIM PASS
        Pass
        {
            Tags //Tags que solo funcionaran en este pass
            {
                "Queue" = "Transparent" //Que este pass sea transparent hace que el efecto del pass se renderize sobre las texturas del otro y generalmente va junto con las opciones de blending
            }
            ZWrite Off //Al estar en Off hace posible ver transparencias y tambien va junto con las opciones de blending
            Blend One One //One One hace que el blending sea aditivo

            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            
            //1/3
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;

                //2/3
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL; //Debido a que esta variable es float3 en lugar de float4 como la normal en el vertexInput, se haran unos cambios cuando se use en el vertexShader
                float3 uv : TEXCOORD0;
            };

            float4 _Color;
            float _Rim;

            vertexOutput vertexShader(vertexInput i)
            {
                vertexOutput o;

                //3/3
                UNITY_SETUP_INSTANCE_ID(i);

                o.pos = UnityObjectToClipPos(i.vertex);
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, i.normal.xyz)); //Debido a que o.normal es float3 pero unity_ObjectToWorld e i.normal son float4, se castean poniendo (float3x3) y .xyz donde corresponde y se normaliza todo para que no haya errores
                o.uv = normalize(_WorldSpaceCameraPos - mul((float3x3)unity_ObjectToWorld, i.vertex.xyz)); //Tambien aqui se castean los parametros porque _WorldSpaceCameraPos y o.uv son float3, no float4

                //Documentacion sobre unity_ObjectToWorld y _WorldSpaceCameraPos: https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html

                return o;
            }

            //Funcion para el efecto rim
            float rimEffect(float3 uv, float3 normal)
            {
                float rim = 1 - abs(dot(uv, normal)) * _Rim;
                return rim;
            }

            fixed4 fragmentShader(vertexOutput o) : Color
            {
                fixed rimColor = rimEffect(o.uv, o.normal);
                return _Color * rimColor * rimColor;
            }
            ENDCG
        }
    }
}
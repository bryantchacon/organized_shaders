Shader "Custom/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DisTex ("Distortion Texture", 2D) = "white" {}
        [Header(DISTORTION PROPERTIES)]
        [Space(10)]
        _DisSpeed ("Speed", Range(-0.4, 0.4)) = 0.1
        _DisValue ("Value", Range(2, 10)) = 3
        [Space(10)]
        _DepthValue ("Depth Value", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }

        Pass
        {
            Name "Texture Pass"

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
            sampler2D _DisTex;
            float4 _MainTex_ST;
            float _DisSpeed;
            float _DisValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed distortion = tex2D(_DisTex, i.uv + (_Time * _DisSpeed)).r; //Samplea la textura de distorsion, agrega movimiento a las uvs y solo se pasa su valor en .r para que solo se mueva en una coordenada y porque la variable distortion es de una sola dimension
                i.uv += distortion / _DisValue; //Agrega la textura ya sampleada y la distorsion para poder modificarla desde el inspector
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        //En este pass se genera una nueva textura para renderizar la capa de profundidad, la cual sera sampler2D _CameraDepthNormalsTexture; y se declara SOLO en el area de variables de coneccion en este pass, no vendra de una propiedad global y debe llamarse exactamente asi para que la camara pueda acceder a ella desde el script Render Depth
        Pass
        {
            Name "Depth Pass"

            Blend OneMinusDstColor One //Blend para que ambas texturas de los pases se puedan ver
            
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
                float depth : DEPTH; //Da acceso al depth, es de una sola dimension
            };

            sampler2D _CameraDepthNormalsTexture; //Variable especifica de este pass donde se guardara la textura de profundidad (no proviene de una propiead)
            float _DepthValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //CALCULOS DE LOS VERTICES DE LA TEXTURA DE PROFUNDIDAD
                o.uv = ((o.vertex.xy / o.vertex.w) + 1) / 2; //o.vertex.w son las coordenadas homogeneas, que en si equivalen a una copia del plano con una unidad de profundidad (de aqui el + 1), y se divide todo entre 2 para que el efecto de profundidad (proyeccion del depth texture sobre los UVs) quede centrado y vaya hacia el centro del plano
                o.uv.y = 1 - o.uv.y; //Se voltea el eje v de los UVs para que el efecto se empareje bien con los bordes
                o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w; //Se pasa z porque solo en esa coordenada es donde se vera el efecto de profundidad, la multiplicacion es negativa para que el depth siga las coordenadas de los vertices
                //Como el depth texture es una proyeccion de la camara sobre los uvs se necesita saber hasta donde llega el Far Clip Plane, por esto toda la operacion se multiplica por _ProjectionParams.w, para mas informacion sobre esto ver https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html, pero en resumen .w es 1/FarClipPlane, si en las propiedades de la camara, Far en Clipping Planes es igual a 1000, seria 1/1000 = 0.001, o sea que toda la operacion se multiplica por 0.001 para que el depth texture siempre sea visible, ya que si se multiplicara directamente por 0.001, si se cambia el Far, el efecto dejaria de verse, porque 0.001 seria un valor constante, pero al usar _ProjectionParams.w no importara si Far cambia de valor porque el calculo se haria automaticamente

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //CREACION DE LA TEXTURA DE PROFUNDIDAD
                float screenDepth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, i.uv).zw); //Decodifica la variable _CameraDepthNormalsTexture en una de una sola dimension pasando solo Z y W del tex2D
                float difference = screenDepth - i.depth; //Diferencia entre el screenDepth y el input de profundidad
                float intersection = 0;
                if(difference > 0)
                {
                    intersection = 1 - smoothstep(0, _ProjectionParams.w * _DepthValue, difference); //intersection se genera como un valor suavisado para que el efecto de profundidad se desvanezca con degradado, _ProjectionParams.w se multiplica por _DepthValue para poder modificar la profundidad del efecto desde el inspector
                }

                return intersection;
            }
            ENDCG
        }
    }
}
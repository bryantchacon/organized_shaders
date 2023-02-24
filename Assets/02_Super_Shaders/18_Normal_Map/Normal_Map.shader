//EL MAPA DE NORMALES NECESITA LA FUENTE DE LUZ EN SU CALCULO, PERO EN EL LIBRO NO LO DICE, AQUI SI

Shader "USB/Normal_Map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
        _LightInt ("Light Intencity", Range(0, 1)) = 1 //La aplicacion de un mapa de normales necesita de una fuente de luz, porque debido a esta las normales cumplen su funcion; simular detalles segun el angulo de la luz que reboten en la superficie
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            //Si este include se usa, _LightColor0 no debe ponerse en las variables de coneccion (y viceversa), si no hasta cuando se usa en el fragment shader
            // #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_normal : TEXCOORD1; //Variable para agregar tiling y offset al mapa de normales
                float3 normal_world : TEXCOORD2;
                float4 tangent_world : TEXCOORD3;
                float3 binormal_world : TEXCOORD4; //Esta variable no tiene contraparte en el vertex input porque las binormales en World-Space se calculan usando las normales y tangentes ya calculadas en World-Space
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST; //TRANSFORM_TEX() lo usa internamente para generar el tiling y offset de las normales
            float _LightInt;
            // float4 _LightColor0; //Si _LightColor0 se usa aqui, #include "UnityLightingCommon.cginc" no debe ponerse donde corresponde y viceversa

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT (v2f, o); //Codigo auxiliar para inicializar el vertex output(v2f o) en 0 por si sale una advertencia en el shader luego de agregar los calculos de las normales
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //CALCULOS PARA LA GENERACION DE LAS NORMALES, TANGENTES Y BINORMALES
                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalMap); //Agrega tiling y offset al mapa de normales
                o.normal_world = UnityObjectToWorldNormal(v.normal); //Transforma las normales a World-Space
                o.tangent_world = normalize(mul(v.tangent, unity_WorldToObject)); //Transforma las tangentes a World-Space pero de forma inversa, por eso la funcion que se usa es unity_WorldToObject ?
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w); //Calcula las binormales en World-Space, v.tangent.w se refiere a las coordenadas homogeneas
                return o;
            }

            //EQUIVALE A LA FUNCION UnpackNormal() ? INCLUIDA EN UnityCG.cginc
            float3 DXTCompression(float4 normalMap)
            {
                #if defined (UNITY_NO_DXT5nm)
                    return normalMap.rgb * 2 - 1;
                #else
                    float3 normalCol;
                    normalCol.rg = normalMap.ag * 2 - 1; //Optimizado de a como viene en el libro (p.208)
                    /*
                    b se puede calcular de diferentes formas:
                    normalCol.b = sqrt(1 - dot(normalCol, normalCol));
                    normalCol.b = sqrt(1 - saturate(dot(normalCol.xy, normalCol.xy)));
                    */
                    normalCol.b = sqrt(1 - (pow(normalCol.r, 2) + pow(normalCol.g, 2))); //p. 208-211
                    return normalCol;
                #endif
            }

            //Esta funcion se basa en la de reflexion difusa
            float3 normalMapApply(float lightInt, float3 normalMap, float3 lightDir)
            {
                return lightInt * max(0, dot(normalMap, lightDir));
            }
            //NOTA: Si se usa el color de la luz y este pone el objeto de color negro en los azules es porque en la funcion se le pasa el mapa de normales como parametro, no las normales en si, por eso no se usa en el shader (#include "UnityLightingCommon.cginc", float4 _LightColor0; ni UNITY_LIGHTMODEL_AMBIENT)

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 normal_map = tex2D(_NormalMap, i.uv_normal);
                fixed3 normalMap_compressed = DXTCompression(normal_map);
                float3x3 TBN_matrix = float3x3 //Matriz TBN para transformar el mapa de normales a Tangent-Space
                (
                    i.tangent_world.xyz, //Se especifica que debe usar las coordenadas .xyz porque el vector fue declarado como uno de 4 dimensiones en el vertex output v2f
                    i.binormal_world,
                    i.normal_world
                );
                fixed3 normalMap = normalize(mul(normalMap_compressed, TBN_matrix));
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 normalMap_applied = normalMapApply(_LightInt, normalMap, lightDir);
                col.rgb *= normalMap_applied;
                return col;
            }
            ENDCG
        }
    }
}
Shader "Custom/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness", Range(0,1)) = 0.3
        _Strength("Strength", Range(0,1)) = 0.5
        _Color("Color", COLOR) = (1,1,1,1)
        _Detail("Detail", Range(0,1)) = 0.3
       
    }
    SubShader
    {
        Tags
        {
            "LightMode" = "ForwardBase"
        }
        Lighting On
        LOD 100
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag    
            #pragma target 2.0
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
 
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                half3  worldNormal : NORMAL;
                float4 color : COLOR;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Strength;
            float4 _Color;
            float _Detail;

            //Funcion para generar el efecto Toon
            float Toon(float3 normal, float3 lightDir)
            {
                float NdotL = max(0.0, dot(normalize(normal), normalize(lightDir))); //NdotL es normal + dot product + light direction
                /*
                • dot() retornara 1, 0 o -1 dependiendo de la dirección de las normales respecto a la dirección de la luz sobre ellas
                • max() retorna el máximo entre 0.0 y el resultado de dot(), y como 1 es blanco y 0 es negro, cuando retorna más que 0 da la ilusión de iluminación, y cuando retorna 0 o menos que 0 da la ilusión de sombra detrás del objeto
                • 
                */
                return floor(NdotL/_Detail); //floor redondea la iluminación a números enteros para que se representen como secciones sólidas, esto al pasarle como parámetro el resultado de dividir NdotL entre _Detail, el número de secciones dependerá del valor de _Detail en el inspector
            }
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); //Transforma las coordenadas de las normales a World-Space
                o.color = _LightColor0; //Para poder usar _LightColor0 hay que agregar #include "UnityLightingCommon.cginc" en la sección que corresponde
               
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= Toon(i.worldNormal, _WorldSpaceLightPos0.xyz) * _Strength * _Color + _Brightness * i.color; //_WorldSpaceLightPos0.xyz es la dirección de la iluminación en World-Space. NOTA: Para crear shaders iluminados en CG, se debe usar esta función
                return col;
               
            }
            ENDCG
        }   

        //NOTA: Las sombras ya vienen predefinidas en Shader Graph, por lo tanto, no sera necesario configurarlas en el, ademas de que Shader Graph solo puede compilar UN PASS
        Pass
        {
            Tags
            {
                "LightMode"="ShadowCaster" //Calcula las sombras que se proyecten desde el objeto que tenga este shader hacia los demas
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f 
            { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
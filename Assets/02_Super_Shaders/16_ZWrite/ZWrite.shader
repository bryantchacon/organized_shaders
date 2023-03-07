Shader "Custom/ZWrite"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha //Activa las opciones de blending para trabajar con materiales transparentes y semitransparentes
        ZWrite Off //Valor por default On, no viene en el codigo. Generalmente se desactiva (Off), cuando:
        /*
        • Se usan transparencias, incluido Stencil (carpeta 04_Stencil del proyecto MasterShader), al configurar el ColorMask en 0
        • Se usan las opciones de blending
        • Se quiere evitar errores graficos entre objetos semi transparentes (p. 88), sin embargo, tambien sera necesario (ademas de desactivar el ZWrite y poner el RenderType y Queue en Transparent), ponerlos en diferentes layers sumando o restando uno al valor del Queue, por ejemplo: 3000-1, 3000 y 3000+1 (si son 3 que el de en medio quede con el valor por default y si a los de atras se les suma en lugar de restar entonces se renderizaran primero en frente de los que tengan menor numero, aunque esten detras de ellos, y viceversa si a los de enfrente se les resta)
        */

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}

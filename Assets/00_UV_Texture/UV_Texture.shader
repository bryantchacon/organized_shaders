Shader "Custom/UV_Texture"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }
        // ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST; //Se refiere al offset y tiling de la textura, y se podran modificar desde el editor; tiling es repetir la textura y offset es moverla, ya sea en "x" y/o "y". Basta con que se llame igual que la textura pero con _ST al final y que sea de tipo fidex4
            fixed4 _Color;

            struct vertexInput
            {
                fixed4 vertex : POSITION; //Semantica de la posicion de los vertices
                fixed2 uv : TEXCOORD0; //Semantica de las coordenadas UV, tiene 0 al final porque puede haber mas de una textura asignada a un objeto (si, las UVs se consideran texturas en CG y son la primera), de ahi siguen TEXCOORD1, TEXCOORD2, etc.
            };

            struct vertexOutput
            {
                fixed4 vertex : SV_POSITION;
                fixed2 uv : TEXCOORD0;
            };

            vertexOutput vertexShader(vertexInput i)
            {
                vertexOutput o;
                o.vertex = UnityObjectToClipPos(i.vertex);
                
                // o.uv = i.uv; //Asigna las UV del input a las UV del output

                //Asigna las UV del input a las UV del output y configura su tiling y offset
                // o.uv = (i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
                //_MainTex_ST.xy = Tiling en xy
                //_MainTex_ST.zw = Offset en xy

                o.uv = TRANSFORM_TEX(i.uv, _MainTex); //Optimizacion de "o.uv = (i.uv * _MainTex_ST.xy + _MainTex_ST.zw)", TRANSFORM_TEX() viene incluida UnityCG.cginc

                return o;
            }

            fixed4 fragmentShader(vertexOutput i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
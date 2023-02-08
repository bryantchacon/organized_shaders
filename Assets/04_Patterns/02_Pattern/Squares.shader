Shader "Custom/Squares"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _SquareSize ("Size", Range(0, 5)) = 1
        _DiagonalOffset ("Diagonal Offset", Range(0, 1)) = 0
        _Zoom ("Zoom", Range(1, 5)) = 2
        _DiagonalPivotPosition ("Diagonal Pivot Position", Range(0, 1)) = 0.5
        [Toggle]_Invert ("Invert", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Blend SrcAlpha OneMinusSrcAlpha //Activa el canal alpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            //Llama el archivo RotateCG.cginc para hacer uso de su funcion Rotate
            #include "Assets/CGFiles/RotateCG.cginc"

            //Pragma del toggle _Invert
            #pragma shader_feature _INVERT_ON

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

            float4 _Color;
            float _SquareSize;
            float _DiagonalOffset;
            float _Zoom;
            float _DiagonalPivotPosition;

            // float2 Rotate(float2 uv)
            // {
            //     float pivot = _DiagonalPivotPosition; //Pivote, centro desde el cual girara el patron, al cambiar su valor en el inspector permite moverlo

            //     //_Time, _CosTime y _SinTime son propios de ShaderLab
            //     //SE PUEDE JUGAR CON LOS VALORES DE cosAngle Y sinAngle CAMBIANDO LA COORDENADA DE _CosTime y _SinTime PARA TENER DIFERENTES MOVIMIENTOS EN EL PATRON
            //     // float cosAngle = cos(_Time.y);
            //     // float sinAngle = sin(_Time.y);
            //     float cosAngle = _CosTime.w; //Da el mismo resultado que el codigo anterior comentado porque _Time.y = (t) y _CosTime.w tambien
            //     float sinAngle = _SinTime.w;

            //     float2x2 rot = float2x2 //Matriz de tiempos de _CosTime y _SinTime (_Time)
            //     (
            //         //SE PUEDE JUGAR CON LOS SIGNOS DE cosAngle Y sinAngle PARA TENER DIFERENTES MOVIMIENTOS EN EL PATRON
            //         cosAngle, -sinAngle,
            //         sinAngle, cosAngle
            //     );

            //     float2 uvPiv = uv - pivot; //Argega el pivote a las UVs

            //     float2 uvRot = mul(rot, uvPiv); //Multiplica la matriz de tiempos por las UVs con el pivote agregado, esto para poder hacer la rotacion

            //     return uvRot;
            // }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = Rotate(v.uv, _DiagonalPivotPosition); //Uso de la funcion Rotate(), que ahora se llama desde RotateCG
                return o;
            }

            //Funcion para crear un patron cuadrado y que se usara en el fragment shader (va antes de el)
            float Shape(float x, float y)
            {
                float left =    step(0.1 * _SquareSize, x);
                float bottom =  step(0.1 * _SquareSize, y);
                float up =      step(0.1 * _SquareSize, 1 - y);
                float right =   step(0.1 * _SquareSize, 1 - x);

                return left * bottom * up * right;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float2 translation = float2(cos(_Time.y), sin(_Time.y)); //Dependiendo de que coordenada de _Time se use será mas, o menos lento el movimiento en esa coordenada
                //i.uv += translation;

                i.uv = i.uv * _Zoom - _DiagonalOffset; //Mueve el patron en diagonal porque la coordenada inicia en 0, 0, asi que si _DiagonalOffset vale 0.5, seria 0 - 0.5 = 0.5, y como se resta en ambas coordenadas el desplazamiento es en diagonal
                float cube = Shape(frac(i.uv.x), frac(i.uv.y)); //Uso de la funcion Shape(), frac() hace que el patron aparezca en cada division del tiling, o sea, cuadricula el patron

                //CG if para usar el Toggle _Invert
                #if _INVERT_ON
                    cube = abs(1 - cube); //Invierte la cuadricula
                    return cube * _Color;
                #else
                    return cube * _Color;
                #endif

                return cube;
            }
            ENDCG
        }
    }
}
//Para crear el efecto blur se hace usando una propiedad llamada GrabPass, su documentacion se encuentra en: https://docs.unity3d.com/Manual/SL-GrabPass.html

Shader "Custom/Blur"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Blur ("Blur", Range(0.0, 0.02)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        //Configuracion del GrabPass, paso 1/6
        GrabPass //GrabPass es un pass especial que permite proyectar el contenido de la pantalla sobre el objeto que use este shader por medio de una textura
        {
            "_BackgroundTexture" //Genera la textura para el efecto, corresponde a la proyeccion de la pantalla, o sea, en ella se almacena la proyeccion
        }
        LOD 100

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
                float4 uvgrab : TEXCOORD0; //Se usa para almacenar el calculo hecho por ComputeGrabScreenPos() en el vertex shader, sustituye la variable uv de dos dimensiones porque el resultado de la funcion es de 4, y debido a todo lo anterior solo se usa aqui en el vertex output, paso 3/6
            };

            sampler2D _BackgroundTexture; //Sampler de la textura generada en el GrabPass, debido a esto, no tiene una propiedad de la que provenga, paso 2/6
            float4 _Color;
            float _Blur;

            //Funcion obtenida de https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Random-Range-Node.html, paso 5/6
            void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
            {
                float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                Out = lerp(Min, Max, randomno);
            }

            //Esta funcion es igual a Unity_RandomRange_float, solo que el parametro out con mismo tipo de dato ya no se usa porque la funcion ahora retornara un float
            /*
            float Unity_RandomRange(float2 Seed, float Min, float Max)
            {
                float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                return lerp(Min, Max, randomno);
            }
            */

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvgrab = ComputeGrabScreenPos(o.vertex); //Calcula las coordenadas de la proyeccion para samplear la textura del GrabPass, como argumento se le pasa la posicion de los vertices en Clip-Space, por eso va despues de UnityObjectToClipPos(), paso 4/6
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 projuv = i.uvgrab.xy / i.uvgrab.w; //Equivale a: fixed4 col = tex2Dproj(_BackgroundTexture, i.uvgrab);
                fixed4 col = 0;
                
                float noise = 0; //Se usa como output de Unity_RandomRange_float()
                Unity_RandomRange_float(i.uvgrab, 0, 1, noise);

                const float grabSamples = 32; //Numero de proyecciones, es constante porque los samples no pueden cambiar en tiempo real, y como son 32 sobre el objeto para crear el blur, este shader no es optimo para dispositivos moviles, pero, para crear un efecto de ver a travez de un cristal con cierta opacidad por tener una textura rugosa, basta con que tenga como valor 1
                for(float s = 0; s < grabSamples; s++) //Permite pasar varias proyecciones como textura al objeto que tenga este shader, paso 6/6
                {
                    float2 offset = float2(cos(noise), sin(noise)) * _Blur;
                    col += tex2D(_BackgroundTexture, projuv + offset);
                    noise++;
                }

                return (col /= grabSamples) * _Color;
            }
            ENDCG
        }
    }
}
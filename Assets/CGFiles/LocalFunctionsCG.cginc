#ifndef LocalFunctionsCG
#define LocalFunctionsCG

//FUNCION PARA CREAR EL ALPHA DE UN CIRCULO DEGRADADO EN 2D
//Para poder usar esta funcion hay que agregar las siguientes propiedades en el shader con sus respectivas variables de coneccion
/*
_Radius ("Radius", Range(0.0, 0.5)) = 0.3
_Center ("Center", Range(0, 1)) = 0.5
_Smooth ("Smooth", Range(0.0, 0.5)) = 0.01
*/
float circle(float2 uvs, float center, float radius, float smooth)
{
    float c = length(uvs - center); //length() retorna la distancia entre dos puntos (por eso se guarda en una variable float de una dimension), principalmente se usa para generar circulos (como en este caso), y centrarlo en las UVs, pero tambien se puede usar para crear poligonos con los bordes redondeados
    return smoothstep(c - smooth, c + smooth, radius); //Controla el radio del circulo(por radius) y suaviza su borde. smoothstep() retorna un valor de una sola dimension, por eso se puede usar en el return, porque la funcion es de tipo float
}

//Se usa en el fragment shader asi (o adaptandolo a como se requiera):
/*
float cir = circle(i.uv, _Center, _Radius, _Smooth);

return float4(cir.xxx, 1); //Se usa .xxx como sustitutos de .xyz porque cir es de una sola dimension y la funcion debe retornar un valor de 4 dimensiones, el 1 es por que el vector es una posicion en el espacio
*/

//-------------------------------------------------------------------------------------------

//FUNCION PARA ROTAR EN 2D (SE USA DESPUES DE UnityObjectToClipPos() EN EL VERTEX SHADER)
//Para poder usar esta funcion hay que agregar la siguientes propiedad en el shader con sus respectiva variable de coneccion
/*
_Center ("Center", Range(0, 1)) = 0.5
*/
float2 Rotate2D(float2 uv, float center, float speed)
{
    //Esta linea se comenta porque la funcion se trajo del script Pattern y la variable _DiagonalPivotPosition no existe en este script, en su lugar se sustituye por center de tipo float y se agrega como segundo parametro en la funcion, y en el script Pattern se pone como segundo parametro _DiagonalPivotPosition para que funcione
    // float pivot = _DiagonalPivotPosition; //Pivote, centro desde el cual girara el patron, al cambiar su valor en el inspector permite moverlo
    float pivot = center;
    //_Time, _CosTime y _SinTime son propios de ShaderLab
    //SE PUEDE JUGAR CON LOS VALORES DE cosAngle Y sinAngle CAMBIANDO LA COORDENADA DE _CosTime y _SinTime PARA TENER DIFERENTES MOVIMIENTOS EN EL PATRON
    float cosAngle = cos(_Time.y / speed); //Equivale a _CosTime.x, _Time.y = tiempo
    float sinAngle = sin(_Time.y / speed);

    float2x2 rot = float2x2 //Matriz de tiempos de _CosTime y _SinTime (_Time)
    (
        //SE PUEDE JUGAR CON LOS SIGNOS DE cosAngle Y sinAngle PARA TENER DIFERENTES MOVIMIENTOS EN EL PATRON
        cosAngle, -sinAngle,
        sinAngle, cosAngle
    );

    float2 uvPiv = uv - pivot; //Asigna el pivote de las UVs

    float2 uvRot = mul(rot, uvPiv); //Multiplica la matriz de tiempos por las UVs con el pivote asignado para poder hacer la rotacion

    return uvRot;
}

#endif
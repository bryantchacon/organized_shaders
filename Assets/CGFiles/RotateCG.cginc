//ESTE TIPO DE ARCHIVO ES PARA PODER LLAMAR DESDE CUALQUIER SHADER CUALQUIER FUNCION QUE ESTE CONTENGA

//if para definir un archivo .cginc, dentro de este iran todas las funciones
//NOTA: NO FUNCIONA SI NO LLEVA CG AL FINAL DEL NOMBRE
#ifndef RotateCG //Si RotateCG (este archivo), no esta definido...
#define RotateCG //... definelo

//Funcion para rotar, no funciona si tiene CG al final del nombre
float2 Rotate(float2 uv, float center)
{
    //Esta linea se comenta porque la funcion se trajo del script Pattern y la variable _DiagonalPivotPosition no existe en este script, en su lugar se sustituye por center de tipo float y se agrega como segundo parametro en la funcion, y en el script Pattern se pone como segundo parametro _DiagonalPivotPosition para que funcione
    // float pivot = _DiagonalPivotPosition; //Pivote, centro desde el cual girara el patron, al cambiar su valor en el inspector permite moverlo
    float pivot = center;
    //_Time, _CosTime y _SinTime son propios de ShaderLab
    //SE PUEDE JUGAR CON LOS VALORES DE cosAngle Y sinAngle CAMBIANDO LA COORDENADA DE _CosTime y _SinTime PARA TENER DIFERENTES MOVIMIENTOS EN EL PATRON
    float cosAngle = _CosTime.w; //Equivale a cos(_Time.y), _Time.y = tiempo
    float sinAngle = _SinTime.w;

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

#endif //Fin del if
#ifndef TotalRotationCG
#define TotalRotationCG

float3 TotalRotation(float3 vertex, float speed)
{
    //Variables de rotacion usando cos(graficamente la curva inica en 1) y sin(graficamente la curva inica en 0). _Time es una variable interna y lo que hace es agregar tiempo a la operacion, es similar a Time.deltaTime en C# y al multiplicarlo por _Speed se puede modificar la velocidad desde el inspector
    float c = cos(_Time.y * speed);
    float s = sin(_Time.y * speed);

    //Variables aplicadas para rotar en x
    float3x3 mX = float3x3
    (
        1, 0, 0,
        0, c, -s,
        0, s, c
    );

    //Variables aplicadas para rotar en y
    float3x3 mY = float3x3
    (
        c, 0, s,
        0, 1, 0,
        -s, 0, c
    );

    //Variables aplicadas para rotar en z
    float3x3 mZ = float3x3
    (
        c, -s, 0,
        s, c, 0,
        0, 0, 1
    );

    return mul(mul(mul(mX, mY), mZ), vertex);
}

#endif
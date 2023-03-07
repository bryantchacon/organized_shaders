void Specular_half //Para que el nodo custom function funcione, Precision se debe configurar en Half, el mismo tipo de la funcion aqui
(
    half3 Specular,
    half Smoothness,
    half3 Direction,
    half3 Color,
    half3 WorldNormal,
    half3 WolrdView,
    out half3 Out
)
{
#if SHADERGRAPH_PREVIEW
    Out = 0;
#else
    Smoothness = exp2(10 * Smoothness + 1);
    WorldNormal = normalize(WorldNormal);
    WolrdView = SafeNormalize(WolrdView);
    Out = LightingSpecular(Color, Direction, WorldNormal, WolrdView, half4(Specular, 0), Smoothness);
#endif
}
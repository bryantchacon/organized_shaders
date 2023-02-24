void Base_float(in float liquidEdge, in float4 midEdge, out float4 output)
{
    // fixed4 base = step(i.liquidEdge, 0.5) - midEdge;
    float4 base = step(liquidEdge, 0.5) - midEdge;
    output = base;
}
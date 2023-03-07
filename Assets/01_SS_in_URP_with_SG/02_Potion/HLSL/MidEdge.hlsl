void MidEdge_float(in float liquidEdge, in float midAmount, out float4 output)
{
    // fixed4 midEdge = step(i.liquidEdge, 0.5) - smoothstep(i.liquidEdge, 0.5, (0.5 - _MidAmount));
    float4 midEdge = step(liquidEdge, 0.5) - step(liquidEdge, (0.5 - midAmount));
    output = midEdge;
}
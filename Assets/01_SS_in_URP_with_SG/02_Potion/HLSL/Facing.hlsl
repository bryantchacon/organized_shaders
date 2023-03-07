void Facing_float(in float4 renderBase, in float4 renderTop, in bool facing, out float4 output)
{
    // return facing > 0 ? renderBase : renderTop;
    output = facing > 0 ? renderBase : renderTop;
}
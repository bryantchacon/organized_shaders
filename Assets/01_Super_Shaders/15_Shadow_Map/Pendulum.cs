using UnityEngine;

[ExecuteInEditMode]
public class Pendulum : MonoBehaviour
{
    public float speed = 2.0f;
    public float amplitude = 1.5f;
    public float initialX = 1.3f;

    void Update()
    {
        Transform pos = GetComponent<Transform>();
        float movement = Mathf.Sin(Time.time * speed) * amplitude;
        pos.position = new Vector3(initialX + movement, pos.position.y, pos.position.z);
    }
}
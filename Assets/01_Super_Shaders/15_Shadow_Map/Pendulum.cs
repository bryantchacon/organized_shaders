using UnityEngine;

[ExecuteInEditMode]
public class Pendulum : MonoBehaviour
{
    public bool isMoving;
    public float initialX = 1.3f;
    public float speed = 2.0f;
    public float amplitude = 1.5f;

    void Update()
    {
        Transform pos = GetComponent<Transform>();
        float movement = Mathf.Sin(Time.time * speed) * amplitude;

        if(isMoving)
        {
            pos.position = new Vector3(initialX + movement, pos.position.y, pos.position.z);
        }
    }
}
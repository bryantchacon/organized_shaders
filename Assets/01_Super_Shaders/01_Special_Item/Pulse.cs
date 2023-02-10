using UnityEngine;

[ExecuteInEditMode]
public class Pulse : MonoBehaviour
{
    public float speed = 5.0f;
    public float scale = 0.1f;

    void Update()
    {
        float movement = Mathf.Sin(Time.time * speed);
        transform.localScale = new Vector3(0.6f + movement * scale, 0.6f + movement * scale, 0.6f + movement * scale);
    }
}
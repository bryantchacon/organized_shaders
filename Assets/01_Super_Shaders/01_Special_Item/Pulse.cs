using UnityEngine;

[ExecuteInEditMode]
public class Pulse : MonoBehaviour
{
    public float speed = 5.0f;
    public float scale = 0.1f;

    void Update()
    {
        float movement = Mathf.Sin(Time.time * speed);
        transform.localScale = new Vector3((float)0.6 + movement * scale, (float)0.6 + movement * scale, (float)0.6 + movement * scale);
    }
}
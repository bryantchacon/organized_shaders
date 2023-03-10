using UnityEngine;

[ExecuteInEditMode]
public class RotateItem : MonoBehaviour
{
    public bool isRotate;
    // [Range(30, 100)]
    public float speed = 50;
    private float t;
    private float movement;

    void Update()
    {
        if(isRotate)
        {
            t = Time.deltaTime;
            movement = t * speed;
            transform.Rotate(new Vector3(0, movement, 0));
        }
    }
}
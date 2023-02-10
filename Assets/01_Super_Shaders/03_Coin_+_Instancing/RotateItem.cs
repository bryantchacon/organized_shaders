using UnityEngine;

[ExecuteInEditMode]
public class RotateItem : MonoBehaviour
{
    public bool isRotate;
    // [Range(30, 100)]
    public float speed = 100;
    private float t;

    void Update()
    {
        if(isRotate)
        {
            t = Time.deltaTime;
            transform.Rotate(new Vector3(0, speed * t, 0));
        }
    }
}
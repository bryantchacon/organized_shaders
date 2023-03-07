using UnityEngine;

[ExecuteInEditMode]
public class RenderDepth : MonoBehaviour
{
    void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
        //DepthTextureMode permite generar una nueva textura de profundidad
        //DepthNormals tambien se refiere a la generacion de una textura de profundidad, pero mas normales
        //NOTA: Generar una textura de profundidad tiene costos de performance, asi mismo no todos los dispositivos mobiles soportan depth texture
        //PARA PODER USAR ESTE MODO HAY QUE SETEAR Rendering Path = Deferred, Y SOLO ES COMPATIBLE CON DISPOSITIVOS QUE TENGAN "OpenGL ES 3.0" EN ADELANTE
        //Para mas informacion sobre lo anterior ver "Deferred Shading Rendering Path" en https://docs.unity3d.com/Manual/RenderTech-DeferredShading.html, aunque OpenGl ES 3.0 esta prensente en la mayoria de dispositivos actuales
    }
}
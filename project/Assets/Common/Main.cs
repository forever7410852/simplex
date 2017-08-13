using UnityEngine;
public class Main : MonoBehaviour
{
    [RuntimeInitializeOnLoadMethod]
    static void Initialize()
    {
            GameObject.DontDestroyOnLoad(new GameObject("Main",typeof(LuaFramework.LuaManager)) { 
        });  
        Debug.Log( "RuntimeInitializeOnLoadMethod" );  
    }
}
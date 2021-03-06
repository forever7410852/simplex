﻿using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;

namespace LuaFramework {
    public class LuaBehaviour : MonoBehaviour {
        private string data = null;
        private Dictionary<string, LuaFunction> buttons = new Dictionary<string, LuaFunction>();

        protected void Awake() {
            LuaManager.Instance.CallFunction(string.Concat(name,".", "Awake"), gameObject);
        }

        protected void Start() {
            LuaManager.Instance.CallFunction(string.Concat(name,".", "Start"));
        }

        protected void Update()
        {
            LuaManager.Instance.CallFunction(string.Concat(name, ".", "Update"));
        }

        protected void OnClick() {
            LuaManager.Instance.CallFunction(string.Concat(name,".", "OnClick"));
        }

        protected void OnClickEvent(GameObject go) {
            LuaManager.Instance.CallFunction(name, "OnClick", go);
        }

        /// <summary>
        /// 添加单击事件
        /// </summary>
        public void AddClick(GameObject go, LuaFunction luafunc) {
            if (go == null || luafunc == null) return;
            buttons.Add(go.name, luafunc);
            go.GetComponent<Button>().onClick.AddListener(
                delegate() {
                    luafunc.Call(go);
                }
            );
        }

        /// <summary>
        /// 删除单击事件
        /// </summary>
        /// <param name="go"></param>
        public void RemoveClick(GameObject go) {
            if (go == null) return;
            LuaFunction luafunc = null;
            if (buttons.TryGetValue(go.name, out luafunc)) {
                luafunc.Dispose();
                luafunc = null;
                buttons.Remove(go.name);
            }
        }

        /// <summary>
        /// 清除单击事件
        /// </summary>
        public void ClearClick() {
            foreach (var de in buttons) {
                if (de.Value != null) {
                    de.Value.Dispose();
                }
            }
            buttons.Clear();
        }

        //-----------------------------------------------------------------
        protected void OnDestroy() {
            ClearClick();
#if ASYNC_MODE
            string abName = name.ToLower().Replace("panel", "");
            ResManager.UnloadAssetBundle(abName + AppConst.ExtName);
#endif
            GC.Collect(); Resources.UnloadUnusedAssets();
            LuaManager.Instance.LuaGC();
            Debug.Log("~" + name + " was destroy!");
        }
    }
}
using System;
using System.Collections.Generic;
using UnityEngine;
namespace CatchGoose
{
    [Serializable] public class ItemSize { public string id; public float scale=1; public string evidence; }
    [Serializable] public class ItemSizeCatalog
    {
        public ItemSize[] items;
        Dictionary<string,float> scales;
        public float Get(string id)
        {
            if(scales==null){scales=new Dictionary<string,float>();if(items!=null)foreach(var item in items)scales[item.id]=Mathf.Clamp(item.scale,.55f,1.7f);}
            return scales.TryGetValue(id,out var scale)?scale:1;
        }
    }
    [Serializable] public class ReferenceLabCatalog { public ThemeDefinition theme; public string purpose; }
    [Serializable] public class ReferenceModelBudget {public string id;public int materials,triangles,glassMaterials,colorOnlyMaterials;}
    [Serializable] public class ReferenceMaterialCatalog {public ReferenceModelBudget[] models;}
}

  (func $j43546 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140147
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3986952 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.ContainsKey()
      call $j922
      i32.const 3986916 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.ContainsKey()
      call $j922
      i32.const 3986920 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.get_Item()
      call $j922
      i32.const 4026592 ;; Method$UnityEngine.GameObject.GetComponent<ToolReturnLight>()
      call $j922
      i32.const 3959572 ;; ObjectPoolMa_TypeInfo
      call $j922
      i32.const 5140147
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load offset=696
      i32.const 0
      i32.const 3986952 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.ContainsKey()
      i32.load
      call $j1084
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=700
      i32.const 0
      i32.const 3986916 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.ContainsKey()
      i32.load
      call $j1084
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=700
      i32.const 0
      i32.const 3986920 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.get_Item()
      i32.load
      call $j1068
      local.set $p2
      i32.const 3959572 ;; ObjectPoolMa_TypeInfo
      i32.load
      call $j923
      local.get $p2
      i32.const 0
      i32.const 0
      call $j3311 ;; ObjectPoolMa$$GetObj
      i32.const 4026592 ;; Method$UnityEngine.GameObject.GetComponent<ToolReturnLight>()
      i32.load
      call $j1136
      local.get $p1
      i32.const 0
      call $j961 ;; UnityEngine.Component$$get_gameObject
      local.get $p0
      f32.load offset=688
      i32.const 0
      call $j35316 ;; ToolReturnLight$$SetPos
    end)

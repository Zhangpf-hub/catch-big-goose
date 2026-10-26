  (func $j72946 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5127069
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3986912 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.Add()
      call $j922
      i32.const 3986916 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.ContainsKey()
      call $j922
      i32.const 3955476 ;; UnityEngine.GameObject_TypeInfo
      call $j922
      i32.const 3958084 ;; LevelToolMa_TypeInfo
      call $j922
      i32.const 4031864 ;; Method$UnityEngine.Object.Instantiate<GameObject>()
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 5127069
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=12
    i32.load offset=700
    local.set $p2
    i32.const 3958084 ;; LevelToolMa_TypeInfo
    i32.load
    call $j923
    local.get $p2
    i32.const 3958084 ;; LevelToolMa_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    local.get $p0
    i32.load offset=8
    i32.const 2
    i32.shl
    i32.add
    i32.load offset=16
    i32.const 3986916 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.ContainsKey()
    i32.load
    call $j1084
    i32.eqz
    if $I1
      local.get $p1
      i32.const 0
      call $j2065 ;; Kunpo.AssetRequest$$get_Result
      local.set $p1
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 3955476 ;; UnityEngine.GameObject_TypeInfo
      i32.load
      call $j968
      i32.const 4031864 ;; Method$UnityEngine.Object.Instantiate<GameObject>()
      i32.load
      call $j1874
      local.set $p1
      local.get $p1
      i32.const 0
      i32.const 0
      call $j952 ;; UnityEngine.GameObject$$SetActive
      local.get $p0
      i32.load offset=12
      i32.load offset=700
      local.set $p2
      i32.const 3958084 ;; LevelToolMa_TypeInfo
      i32.load
      call $j923
      local.get $p2
      i32.const 3958084 ;; LevelToolMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      local.get $p0
      i32.load offset=8
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      local.get $p1
      i32.const 3986912 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.Add()
      i32.load
      call $j1069
    end)

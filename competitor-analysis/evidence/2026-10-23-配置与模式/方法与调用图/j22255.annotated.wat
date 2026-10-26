  (func $j22255 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    (local $l5 i32) (local $l6 f32) (local $l7 f32) (local $l8 f32) (local $l9 f32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p4
    local.get $p4
    global.set $primary.global$0
    i32.const 5140145
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3986952 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.ContainsKey()
      call $j922
      i32.const 3986916 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.ContainsKey()
      call $j922
      i32.const 3986920 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.get_Item()
      call $j922
      i32.const 4026588 ;; Method$UnityEngine.GameObject.GetComponent<ToolFindLighting>()
      call $j922
      i32.const 3959572 ;; ObjectPoolMa_TypeInfo
      call $j922
      i32.const 4079264 ;; FingHighlight
      call $j922
      i32.const 5140145
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load offset=696
      i32.const 1
      i32.const 3986952 ;; Method$System.Collections.Generic.Dictionary<ToolType, string>.ContainsKey()
      i32.load
      call $j1084
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=700
      i32.const 1
      i32.const 3986916 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.ContainsKey()
      i32.load
      call $j1084
      i32.eqz
      br_if $B1
      local.get $p0
      i32.load offset=700
      i32.const 1
      i32.const 3986920 ;; Method$System.Collections.Generic.Dictionary<ToolType, GameObject>.get_Item()
      i32.load
      call $j1068
      local.set $l5
      i32.const 3959572 ;; ObjectPoolMa_TypeInfo
      i32.load
      call $j923
      local.get $l5
      i32.const 0
      i32.const 0
      call $j3311 ;; ObjectPoolMa$$GetObj
      i32.const 4026588 ;; Method$UnityEngine.GameObject.GetComponent<ToolFindLighting>()
      i32.load
      call $j1136
      local.set $l5
      local.get $p1
      f32.load offset=8
      local.set $l6
      local.get $p1
      f32.load offset=4
      local.set $l7
      local.get $p1
      f32.load
      local.set $l8
      i32.const 5156933
      i32.load8_u
      i32.eqz
      if $I2
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        call $j922
        i32.const 5156933
        i32.const 1
        i32.store8
      end
      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p1
      local.get $p1
      f32.load offset=80
      local.set $l9
      local.get $l8
      local.get $p1
      f32.load offset=72
      f32.const 0x1p-1 (;=0.5;)
      f32.mul
      f32.add
      local.set $l8
      local.get $l7
      local.get $p1
      f32.load offset=76
      f32.const 0x1p-1 (;=0.5;)
      f32.mul
      f32.add
      local.set $l7
      local.get $l6
      local.get $l9
      f32.const 0x1p-1 (;=0.5;)
      f32.mul
      f32.add
      local.set $l6
      local.get $p2
      i32.const 0
      call $j961 ;; UnityEngine.Component$$get_gameObject
      local.set $p1
      local.get $p0
      f32.load offset=568
      local.set $l9
      local.get $p4
      local.get $l6
      f32.store offset=24
      local.get $p4
      local.get $p4
      i32.load offset=24
      i32.store offset=8
      local.get $p4
      local.get $l7
      f32.store offset=20
      local.get $p4
      local.get $l8
      f32.store offset=16
      local.get $p4
      local.get $p4
      i64.load offset=16
      i64.store
      local.get $l5
      local.get $p4
      local.get $p1
      local.get $l9
      i32.const 0
      call $j35318 ;; ToolFindLighting$$SetPos
    end
    local.get $p0
    i32.load offset=660
    local.set $p1
    local.get $p1
    i32.load offset=12
    local.set $l5
    local.get $l5
    if $I3
      local.get $p1
      local.get $p3
      local.get $l5
      i32.rem_s
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      local.get $p2
      i32.const 0
      call $j979 ;; UnityEngine.Component$$get_transform
      i32.const 0
      call $j8984 ;; HighlightPlus.HighlightEffect$$SetTarget
      local.get $p0
      i32.load offset=660
      local.set $p1
      local.get $p1
      local.set $p2
      local.get $p2
      local.get $p3
      local.get $p1
      i32.load offset=12
      i32.rem_s
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      i32.const 1
      i32.const 0
      call $j3070 ;; HighlightPlus.HighlightEffect$$SetHighlighted
      local.get $p0
      i32.const 4079264 ;; FingHighlight
      i32.load
      i32.const 0
      call $j1451 ;; UnityEngine.MonoBehaviour$$StopCoroutine
      local.get $p0
      i32.const 4079264 ;; FingHighlight
      i32.load
      i32.const 0
      call $j1559 ;; UnityEngine.MonoBehaviour$$StartCoroutine
      drop
    end
    local.get $p4
    i32.const 32
    i32.add
    global.set $primary.global$0)

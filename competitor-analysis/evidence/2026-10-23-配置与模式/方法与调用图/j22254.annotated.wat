  (func $j22254 (type $t9) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32) (result i32)
    (local $l5 i64)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5140057
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4017920 ;; Method$Kunpo.AssetManager.GetAsset<GameObject>()
      call $j922
      i32.const 4026448 ;; Method$UnityEngine.GameObject.GetComponent<LevelBGItem>()
      call $j922
      i32.const 4032052 ;; Method$UnityEngine.Object.Instantiate<GameObject>()
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 5140057
      i32.const 1
      i32.store8
    end
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p3
      i32.const 0
      i32.const 0
      call $j971 ;; UnityEngine.Object$$op_Inequality
      if $I2
        local.get $p1
        local.get $p3
        i32.const 0
        call $j1139 ;; UnityEngine.Object$$get_name
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        br_if $B1
        local.get $p3
        i32.const 0
        call $j961 ;; UnityEngine.Component$$get_gameObject
        local.set $p3
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $p3
        i32.const 0
        call $j1465 ;; UnityEngine.Object$$Destroy
      end
      local.get $p1
      i32.const 4017920 ;; Method$Kunpo.AssetManager.GetAsset<GameObject>()
      i32.load
      call $j3091
      local.set $p3
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p3
      local.get $p2
      i32.const 4032052 ;; Method$UnityEngine.Object.Instantiate<GameObject>()
      i32.load
      call $j14305
      local.set $p2
      local.get $p2
      i32.const 0
      call $j1071 ;; UnityEngine.GameObject$$get_transform
      local.set $p3
      i32.const 5142879
      i32.load8_u
      i32.eqz
      if $I3
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        call $j922
        i32.const 5142879
        i32.const 1
        i32.store8
      end
      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p4
      local.get $p0
      local.get $p4
      i32.load offset=20
      i32.store offset=24
      local.get $p0
      local.get $p4
      i32.load offset=12
      i64.extend_i32_u
      local.get $p4
      i32.load offset=16
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      i64.store offset=16
      local.get $p3
      local.get $p0
      i32.const 16
      i32.add
      i32.const 0
      call $j1159 ;; UnityEngine.Transform$$set_localScale
      local.get $p2
      i32.const 0
      call $j1071 ;; UnityEngine.GameObject$$get_transform
      local.set $p3
      i32.const 5158080
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        call $j922
        i32.const 5158080
        i32.const 1
        i32.store8
      end
      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p4
      local.get $p4
      i32.load
      i64.extend_i32_u
      local.get $p4
      i32.load offset=4
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.or
      local.set $l5
      local.get $p0
      local.get $p4
      i32.load offset=8
      i32.store offset=40
      local.get $p0
      local.get $p0
      i32.load offset=40
      i32.store offset=8
      local.get $p0
      local.get $l5
      i64.store offset=32
      local.get $p0
      local.get $p0
      i64.load offset=32
      i64.store
      local.get $p3
      local.get $p0
      i32.const 0
      call $j1256 ;; UnityEngine.Transform$$set_localPosition
      local.get $p2
      local.get $p1
      i32.const 0
      call $j1663 ;; UnityEngine.Object$$set_name
      local.get $p2
      i32.const 4026448 ;; Method$UnityEngine.GameObject.GetComponent<LevelBGItem>()
      i32.load
      call $j1136
      local.set $p3
      local.get $p3
      local.get $p0
      call $j43572 ;; LevelBGItem$$InitLevel
    end
    local.get $p0
    i32.const 48
    i32.add
    global.set $primary.global$0
    local.get $p3
    return)

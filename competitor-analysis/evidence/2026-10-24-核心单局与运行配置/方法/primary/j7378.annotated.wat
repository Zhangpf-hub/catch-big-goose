  (func $j7378 (type $t10) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result i32)
    (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 f32) (local $l8 f32) (local $l9 f32) (local $l10 f32) (local $l11 i64)
    global.get $primary.global$0
    i32.const 112
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5140099
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
      call $j922
      i32.const 5140099
      i32.const 1
      i32.store8
    end
    i32.const 4012148 ;; Method$JianEngine.SingleMono<LevelObjectPool>.get_Instance()
    i32.load
    call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
    local.get $p1
    i32.load offset=8
    i32.const 0
    call $j43490 ;; LevelObjectPool$$Get
    local.set $l4
    local.get $l4
    i32.const 0
    call $j961 ;; UnityEngine.Component$$get_gameObject
    local.set $l5
    local.get $l5
    i32.const 0
    call $j1071 ;; UnityEngine.GameObject$$get_transform
    local.set $l6
    local.get $p3
    local.get $p1
    i32.load offset=20
    i32.store offset=56
    local.get $p3
    local.get $p1
    i32.load offset=12
    i64.extend_i32_u
    local.get $p1
    i32.load offset=16
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    i64.store offset=48
    local.get $l6
    local.get $p3
    i32.const 48
    i32.add
    i32.const 0
    call $j1289 ;; UnityEngine.Transform$$set_position
    local.get $l5
    i32.const 0
    call $j1071 ;; UnityEngine.GameObject$$get_transform
    local.set $l6
    f32.const 0x0p+0 (;=0;)
    f32.const 0x1p+0 (;=1;)
    i32.const 0
    call $j1305 ;; UnityEngine.Random$$Range
    local.set $l7
    f32.const 0x0p+0 (;=0;)
    f32.const 0x1p+0 (;=1;)
    i32.const 0
    call $j1305 ;; UnityEngine.Random$$Range
    local.set $l8
    local.get $p3
    f32.const 0x0p+0 (;=0;)
    f32.const 0x1p+0 (;=1;)
    i32.const 0
    call $j1305 ;; UnityEngine.Random$$Range
    f32.const 0x1.68p+8 (;=360;)
    f32.mul
    f32.store offset=104
    local.get $p3
    local.get $p3
    i32.load offset=104
    i32.store offset=40
    local.get $p3
    local.get $l8
    f32.const 0x1.68p+8 (;=360;)
    f32.mul
    f32.store offset=100
    local.get $p3
    local.get $l7
    f32.const 0x1.68p+8 (;=360;)
    f32.mul
    f32.store offset=96
    local.get $p3
    local.get $p3
    i64.load offset=96
    i64.store offset=32
    local.get $l6
    local.get $p3
    i32.const 32
    i32.add
    i32.const 0
    call $j1634 ;; UnityEngine.Transform$$set_localEulerAngles
    local.get $l5
    i32.const 0
    call $j1071 ;; UnityEngine.GameObject$$get_transform
    local.get $p0
    i32.const 88
    i32.const 116
    local.get $p2
    i32.const 1
    i32.eq
    select
    i32.add
    i32.load
    i32.const 0
    call $j1610 ;; UnityEngine.Transform$$SetParent
    local.get $l4
    local.get $p1
    i32.load offset=8
    i32.const 0
    call $j21510 ;; ObjectUnit$$Init
    local.get $l4
    local.get $p1
    i32.load8_u offset=24
    i32.const 0
    call $j7288 ;; ObjectUnit$$SetVisible
    local.get $l4
    local.get $p3
    local.get $p1
    i32.load offset=8
    local.get $p3
    call $j43536 ;; LevelManager$$GetObjSize
    f32.store offset=128
    block $B1
      block $B2
        local.get $p0
        i32.load8_u offset=536
        i32.eqz
        br_if $B2
        local.get $p1
        i32.load8_u offset=24
        i32.eqz
        br_if $B2
        local.get $l5
        i32.const 0
        call $j1071 ;; UnityEngine.GameObject$$get_transform
        local.set $p0
        i32.const 5158080
        i32.load8_u
        i32.eqz
        if $I3
          i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
          call $j922
          i32.const 5158080
          i32.const 1
          i32.store8
        end
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        i32.load
        i32.load offset=92
        local.set $p1
        local.get $p1
        i32.load
        i64.extend_i32_u
        local.get $p1
        i32.load offset=4
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        local.set $l11
        local.get $p3
        local.get $p1
        i32.load offset=8
        i32.store offset=88
        local.get $p3
        local.get $p3
        i32.load offset=88
        i32.store offset=24
        local.get $p3
        local.get $l11
        i64.store offset=80
        local.get $p3
        local.get $p3
        i64.load offset=80
        i64.store offset=16
        local.get $p0
        local.get $p3
        i32.const 16
        i32.add
        i32.const 0
        call $j1159 ;; UnityEngine.Transform$$set_localScale
        br $B1
      end
      local.get $l5
      i32.const 0
      call $j1071 ;; UnityEngine.GameObject$$get_transform
      local.set $p1
      i32.const 5142879
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
        call $j922
        i32.const 5142879
        i32.const 1
        i32.store8
      end
      i32.const 3964984 ;; UnityEngine.Vector3_TypeInfo
      i32.load
      i32.load offset=92
      local.set $p0
      local.get $p0
      f32.load offset=20
      local.set $l8
      local.get $l4
      f32.load offset=128
      local.set $l7
      local.get $p0
      f32.load offset=12
      local.get $l7
      f32.mul
      local.set $l9
      local.get $p0
      f32.load offset=16
      local.get $l7
      f32.mul
      local.set $l10
      local.get $p3
      local.get $l8
      local.get $l7
      f32.mul
      f32.store offset=72
      local.get $p3
      local.get $p3
      i32.load offset=72
      i32.store offset=8
      local.get $p3
      local.get $l10
      f32.store offset=68
      local.get $p3
      local.get $l9
      f32.store offset=64
      local.get $p3
      local.get $p3
      i64.load offset=64
      i64.store
      local.get $p1
      local.get $p3
      i32.const 0
      call $j1159 ;; UnityEngine.Transform$$set_localScale
    end
    local.get $p3
    i32.const 112
    i32.add
    global.set $primary.global$0
    local.get $l4
    return)

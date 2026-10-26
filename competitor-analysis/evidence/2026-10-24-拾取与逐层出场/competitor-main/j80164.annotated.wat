  (func $j80164 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i64)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5130115
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3950960 ;; UnityEngine.Vector3[]_TypeInfo
      call $j922
      i32.const 5130115
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load8_u offset=44
    i32.eqz
    if $I1
      local.get $p0
      i32.const 3950960 ;; UnityEngine.Vector3[]_TypeInfo
      i32.load
      local.get $p0
      i32.load offset=12
      i32.load offset=12
      call $j939
      i32.store offset=40
      loop $L2
        local.get $p0
        i32.load offset=12
        local.set $l2
        local.get $l2
        i32.load offset=12
        local.get $l3
        i32.gt_s
        if $I3
          local.get $p0
          i32.load offset=40
          local.set $l4
          local.get $p1
          i32.const 32
          i32.add
          local.get $l2
          local.get $l3
          i32.const 2
          i32.shl
          i32.add
          i32.load offset=16
          i32.const 0
          call $j1418 ;; UnityEngine.Transform$$get_localScale
          local.get $p1
          i32.load offset=40
          local.set $l2
          local.get $p1
          local.get $l2
          i32.store offset=24
          local.get $p1
          local.get $l2
          i32.store offset=8
          local.get $p1
          i64.load offset=32
          local.set $l5
          local.get $p1
          local.get $l5
          i64.store offset=16
          local.get $p1
          local.get $l5
          i64.store
          local.get $l4
          local.get $l3
          i32.const 12
          i32.mul
          i32.add
          local.set $l2
          local.get $l2
          local.get $p1
          i32.load offset=8
          i32.store offset=24
          local.get $p1
          i32.load
          i64.extend_i32_u
          local.get $p1
          i32.load offset=4
          i64.extend_i32_u
          i64.const 32
          i64.shl
          i64.or
          local.set $l5
          local.get $l2
          local.get $l5
          i32.wrap_i64
          i32.store offset=16
          local.get $l2
          local.get $l5
          i64.const 32
          i64.shr_u
          i32.wrap_i64
          i32.store offset=20
          local.get $l3
          i32.const 1
          i32.add
          local.set $l3
          br $L2
        end
      end
      local.get $p0
      i32.const 1
      i32.store8 offset=44
    end
    local.get $p0
    local.get $p0
    local.get $p1
    call $j37976 ;; ShowCreateAnimMod$$ShowAnim
    i32.const 0
    call $j1112 ;; UnityEngine.MonoBehaviour$$StartCoroutine
    drop
    local.get $p1
    i32.const 48
    i32.add
    global.set $primary.global$0)

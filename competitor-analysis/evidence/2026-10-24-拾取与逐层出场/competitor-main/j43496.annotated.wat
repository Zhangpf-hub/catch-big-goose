  (func $j43496 (type $t47) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result f32)
    (local $l4 f32) (local $l5 f32) (local $l6 f32)
    global.get $primary.global$0
    i32.const 80
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5127093
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 5127093
      i32.const 1
      i32.store8
    end
    i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
    i32.load
    call $j923
    local.get $p3
    i32.const -64
    i32.sub
    local.get $p1
    i32.load offset=8
    i32.store
    local.get $p3
    local.get $p1
    i32.load
    i64.extend_i32_u
    local.get $p1
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    i64.store offset=56
    local.get $p3
    i32.const 72
    i32.add
    local.get $p3
    i32.const 56
    i32.add
    i32.const 0
    call $j4086 ;; Kunpo.KUIManager$$WorldToUIPosition
    local.get $p3
    f32.load offset=76
    local.set $l4
    local.get $p3
    local.get $p2
    i32.load offset=8
    i32.store offset=48
    local.get $p3
    local.get $p2
    i32.load
    i64.extend_i32_u
    local.get $p2
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    i64.store offset=40
    local.get $p3
    i32.const 72
    i32.add
    local.get $p3
    i32.const 40
    i32.add
    i32.const 0
    call $j4086 ;; Kunpo.KUIManager$$WorldToUIPosition
    local.get $l4
    local.get $p3
    f32.load offset=76
    f32.sub
    local.set $l4
    local.get $p0
    i32.load offset=56
    f32.load offset=48
    local.set $l5
    local.get $p3
    local.get $p1
    i32.load offset=8
    i32.store offset=32
    local.get $p3
    local.get $p1
    i32.load
    i64.extend_i32_u
    local.get $p1
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    i64.store offset=24
    local.get $p3
    i32.const 72
    i32.add
    local.get $p3
    i32.const 24
    i32.add
    i32.const 0
    call $j4086 ;; Kunpo.KUIManager$$WorldToUIPosition
    local.get $p3
    f32.load offset=72
    local.set $l6
    local.get $p3
    local.get $p2
    i32.load offset=8
    i32.store offset=16
    local.get $p3
    local.get $p2
    i32.load
    i64.extend_i32_u
    local.get $p2
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    i64.store offset=8
    local.get $p3
    i32.const 72
    i32.add
    local.get $p3
    i32.const 8
    i32.add
    i32.const 0
    call $j4086 ;; Kunpo.KUIManager$$WorldToUIPosition
    local.get $l4
    f32.abs
    local.get $l5
    f32.mul
    local.get $l6
    local.get $p3
    f32.load offset=72
    f32.sub
    f32.abs
    local.get $p0
    i32.load offset=56
    f32.load offset=52
    f32.mul
    f32.add
    local.set $l4
    local.get $p3
    i32.const 80
    i32.add
    global.set $primary.global$0
    local.get $l4
    return)

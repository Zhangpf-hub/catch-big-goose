  (func $j22240 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    local.get $p0
    i32.load offset=76
    i32.const 0
    call $j979 ;; UnityEngine.Component$$get_transform
    local.set $l3
    local.get $p2
    local.get $p1
    i32.load offset=8
    i32.store offset=8
    local.get $p2
    local.get $p1
    i32.load
    i64.extend_i32_u
    local.get $p1
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    i64.store
    local.get $l3
    local.get $p2
    i32.const 0
    call $j1289 ;; UnityEngine.Transform$$set_position
    local.get $p0
    i32.load offset=76
    i32.const 0
    call $j2083 ;; UnityEngine.ParticleSystem$$Play
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)

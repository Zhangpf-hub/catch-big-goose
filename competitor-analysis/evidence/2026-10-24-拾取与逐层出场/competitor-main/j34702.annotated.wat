  (func $j34702 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i64)
    local.get $p1
    i32.load
    i64.extend_i32_u
    local.get $p1
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    local.set $l3
    local.get $p0
    local.get $l3
    i32.wrap_i64
    i32.store offset=76
    local.get $p0
    local.get $l3
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=80
    local.get $p0
    local.get $p1
    i32.load offset=8
    i32.store offset=84)

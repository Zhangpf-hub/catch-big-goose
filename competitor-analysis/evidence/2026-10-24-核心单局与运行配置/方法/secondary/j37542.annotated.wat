  (func $j37542 (type $t2) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 f32) (local $l4 f32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 0
    i32.const 50458
    call_indirect $primary.table (type $t1)
    local.set $l2
    local.get $p1
    local.get $p0
    i32.load offset=8
    i32.store offset=8
    local.get $p1
    local.get $p0
    i32.load
    i64.extend_i32_u
    local.get $p0
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    i64.store
    local.get $p1
    i32.const 16
    i32.add
    local.get $l2
    local.get $p1
    i32.const 0
    i32.const 50437
    call_indirect $primary.table (type $t6)
    local.get $p1
    f32.load offset=20
    local.set $l3
    local.get $p1
    i32.const 16
    i32.add
    i32.const 0
    i32.const 55112
    call_indirect $primary.table (type $t3)
    local.get $p1
    f32.load offset=20
    local.set $l4
    local.get $p1
    i32.const 32
    i32.add
    global.set $primary.global$0
    local.get $l3
    local.get $l4
    f32.gt
    return)

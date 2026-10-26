  (func $j13265 (type $t10) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result i32)
    local.get $p1
    i32.const 16
    i32.add
    local.get $p2
    f32.load offset=16
    i32.const 0
    call $j2828 ;; System.Single$$CompareTo
    return)

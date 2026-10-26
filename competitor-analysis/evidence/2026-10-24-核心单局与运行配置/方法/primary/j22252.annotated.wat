  (func $j22252 (type $t99) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 f32) (param $p5 i32) (result i32)
    i32.const 5140115
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3969216 ;; LevelManager.<DestroyAnim>d__227_TypeInfo
      call $j922
      i32.const 5140115
      i32.const 1
      i32.store8
    end
    i32.const 3969216 ;; LevelManager.<DestroyAnim>d__227_TypeInfo
    i32.load
    call $j924
    local.set $p5
    local.get $p5
    i32.const 0
    i32.store offset=8
    local.get $p5
    local.get $p0
    i32.store offset=16
    local.get $p5
    local.get $p1
    i32.store offset=20
    local.get $p5
    local.get $p4
    f32.store offset=32
    local.get $p5
    local.get $p3
    i32.store offset=28
    local.get $p5
    local.get $p2
    i32.store offset=24
    local.get $p5
    return)

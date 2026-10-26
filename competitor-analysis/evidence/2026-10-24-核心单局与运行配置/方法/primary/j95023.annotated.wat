  (func $j95023 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5140150
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3969248 ;; LevelManager.<MessObjPosAnim>d__297_TypeInfo
      call $j922
      i32.const 5140150
      i32.const 1
      i32.store8
    end
    i32.const 3969248 ;; LevelManager.<MessObjPosAnim>d__297_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 0
    i32.store offset=8
    local.get $p1
    local.get $p0
    i32.store offset=16
    local.get $p1
    return)

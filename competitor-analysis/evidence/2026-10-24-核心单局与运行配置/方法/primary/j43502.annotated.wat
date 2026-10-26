  (func $j43502 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5140177
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3969268 ;; LevelManager.StateAPI_TypeInfo
      call $j922
      i32.const 5140177
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=868
    local.set $p1
    local.get $p1
    i32.eqz
    if $I1
      i32.const 3969268 ;; LevelManager.StateAPI_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      local.get $p0
      i32.store offset=8
      local.get $p0
      local.get $p1
      i32.store offset=868
    end
    local.get $p1
    return)

  (func $j2087 (type $t3) (param $p0 i32) (result i32)
    i32.const 5140071
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5140071
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=12
    local.set $p0
    local.get $p0
    if $I1
      local.get $p0
      i32.const 1
      i32.eq
      return
    end
    i32.const 0
    return)

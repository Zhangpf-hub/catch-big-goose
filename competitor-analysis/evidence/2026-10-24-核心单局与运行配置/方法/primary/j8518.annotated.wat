  (func $j8518 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139663
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4084944 ;; LongTable
      call $j922
      i32.const 5139663
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
    i32.const 10
    i32.eq
    if $I1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 4084944 ;; LongTable
      i32.load
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      local.set $p0
    else
      i32.const 0
      local.set $p0
    end
    local.get $p0
    return)

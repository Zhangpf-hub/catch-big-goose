  (func $j14562 (type $t3) (param $p0 i32) (result i32)
    i32.const 5127144
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 5127144
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 5140203
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 5140203
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 10001
    i32.const 10031
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    i32.const 1
    i32.eq
    select
    return)

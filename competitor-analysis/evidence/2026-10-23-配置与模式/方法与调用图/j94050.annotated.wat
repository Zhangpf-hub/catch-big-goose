  (func $j94050 (type $t4) (param $p0 i32)
    i32.const 5127154
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 5127154
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store offset=4
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store offset=16)

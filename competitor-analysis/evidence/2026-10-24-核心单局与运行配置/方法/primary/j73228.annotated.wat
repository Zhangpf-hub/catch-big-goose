  (func $j73228 (type $t15) (param $p0 i32) (param $p1 f32) (param $p2 i32)
    i32.const 5127065
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5127065
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    f32.store offset=56)

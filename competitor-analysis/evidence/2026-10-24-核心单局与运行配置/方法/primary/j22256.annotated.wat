  (func $j22256 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    i32.const 5140068
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5140068
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 68
    i32.const 64
    local.get $p1
    select
    i32.add
    local.get $p2
    i32.store
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 76
    i32.const 72
    local.get $p1
    select
    i32.add
    local.get $p3
    i32.store
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop)

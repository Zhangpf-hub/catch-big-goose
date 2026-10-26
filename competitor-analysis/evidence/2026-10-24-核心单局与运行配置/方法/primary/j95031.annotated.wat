  (func $j95031 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i64)
    i32.const 5140174
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 5140174
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 5140225
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 5140225
      i32.const 1
      i32.store8
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=152
    i32.store offset=856
    i64.const 0
    local.set $l2
    local.get $p0
    local.get $l2
    i32.wrap_i64
    i32.store offset=860
    local.get $p0
    local.get $l2
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=864
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store offset=84)

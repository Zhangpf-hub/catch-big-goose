  (func $j43517 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140087
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5140087
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=380
    i32.const 1
    i32.store8 offset=8
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=16
    local.set $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 5142651
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5142651
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=124
    i32.const 0
    call $j35771) ;; ThinkingManager$$ScreenBattleStart

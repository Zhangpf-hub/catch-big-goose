  (func $j95043 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    i32.const 5140044
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3939112 ;; System.Action<GameState>_TypeInfo
      call $j922
      i32.const 3951352 ;; System.Action_TypeInfo
      call $j922
      i32.const 4029160 ;; Method$LevelManager.GetNetworkInfo()
      call $j922
      i32.const 4029176 ;; Method$LevelManager.OnChangeState()
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 5140044
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
    i32.load
    call $j924
    local.get $p0
    local.get $p0
    call $j43085 ;; MainLevelModeCtrl$$.ctor
    i32.const 5140219
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
      call $j922
      i32.const 5140219
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.store offset=384
    i32.const 5140219
    i32.load8_u
    i32.eqz
    if $I2
      i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
      call $j922
      i32.const 5140219
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.store offset=388
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    local.set $p1
    i32.const 3939112 ;; System.Action<GameState>_TypeInfo
    i32.load
    call $j924
    local.set $l2
    local.get $l2
    local.get $p0
    i32.const 4029176 ;; Method$LevelManager.OnChangeState()
    i32.load
    i32.const 0
    call $j969
    local.get $p1
    local.get $l2
    i32.const 0
    call $j1045 ;; System.Delegate$$Combine
    local.set $p1
    local.get $p1
    i32.const 3939112 ;; System.Action<GameState>_TypeInfo
    i32.load
    call $j966
    local.set $l2
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l2
    i32.store offset=4
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p1
    i32.const 3939112 ;; System.Action<GameState>_TypeInfo
    i32.load
    call $j966
    drop
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.load offset=136
    i32.store offset=8
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store offset=24
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=80
    local.set $p1
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j924
    local.set $l2
    local.get $l2
    local.get $p0
    i32.const 4029160 ;; Method$LevelManager.GetNetworkInfo()
    i32.load
    i32.const 0
    call $j994 ;; System.Action$$.ctor
    local.get $p1
    local.get $l2
    i32.const 0
    call $j1045 ;; System.Delegate$$Combine
    local.set $p0
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    local.set $p1
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    i32.store offset=80
    i32.const 3951356 ;; ActionManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j968
    drop
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $p0
    i32.const 3959504 ;; UnityEngine.Object_TypeInfo
    i32.load
    call $j923
    block $B3
      local.get $p0
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      if $I4
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        i32.const 1
        local.set $p0
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load8_u offset=164
        br_if $B3
      end
      i32.const 0
      local.set $p0
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store8 offset=81)

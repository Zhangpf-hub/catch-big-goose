  (func $j43085 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    local.get $p0
    local.get $p1
    i32.store offset=8
    local.get $p0
    local.get $p1
    local.get $p0
    call $j43502 ;; LevelManager$$get_ForStates
    i32.store offset=12
    local.get $p0
    local.get $p1
    i32.load offset=380
    i32.store offset=16
    i32.const 5140202
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
      call $j922
      i32.const 5140202
      i32.const 1
      i32.store8
    end
    i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store
    i32.const 3958468 ;; MainLevelModeCtrl_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    local.get $p0
    call $j43087) ;; MainLevelModeCtrl$$OnCtrlInit

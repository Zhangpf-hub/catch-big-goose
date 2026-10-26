  (func $j71899 (type $t4) (param $p0 i32)
    i32.const 5140010
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
      call $j922
      i32.const 5140010
      i32.const 1
      i32.store8
    end
    i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
    i32.load
    call $j924
    local.set $p0
    i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store
    i32.const 3969408 ;; MainLevelModeCtrl.<>c_TypeInfo
    i32.load
    i32.load offset=92
    drop)

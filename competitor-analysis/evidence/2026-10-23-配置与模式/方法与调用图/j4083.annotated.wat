  (func $j4083 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5140110
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5140110
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j4065 ;; NetDataManager$$GetMaxUnlockStar
    local.get $p0
    i32.ge_s
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 5142651
      i32.load8_u
      i32.eqz
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        call $j922
        i32.const 5142651
        i32.const 1
        i32.store8
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.get $p0
      i32.const 0
      call $j7259 ;; PlayerNetSelfSaveData$$TodayHasWin
      i32.const 1
      i32.xor
      local.set $p0
    else
      i32.const 0
      local.set $p0
    end
    local.get $p0
    return)

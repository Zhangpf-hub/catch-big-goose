  (func $j14377 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139750
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139750
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j21658 ;; NetDataManager$$get_TodayHasUpgradeMainLevel
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j4065 ;; NetDataManager$$GetMaxUnlockStar
      local.set $p0
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
      call $j14206 ;; PlayerNetSelfSaveData$$GetTodayMainLevelTryCount
      i32.const 1
      i32.lt_s
      local.set $p0
    else
      i32.const 0
      local.set $p0
    end
    local.get $p0
    return)

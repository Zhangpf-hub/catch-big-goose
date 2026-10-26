  (func $j4065 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139733
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139733
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j2521 ;; NetDataManager$$get_DailyBaseLevelIndex
    local.set $p0
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j14565 ;; MainLevelManager$$GetMaxUnlockStar
    return)

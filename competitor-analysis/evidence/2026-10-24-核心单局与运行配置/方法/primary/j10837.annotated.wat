  (func $j10837 (type $t3) (param $p0 i32) (result i32)
    i32.const 5127146
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 5127146
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 5140204
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 5140204
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=8
    local.set $p0
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j4436 ;; ConfigManager$$GetMainLevelUpgradedData
    local.set $p0
    local.get $p0
    if $I2
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=16
      local.get $p0
      i32.load offset=8
      i32.const 0
      call $j14565 ;; MainLevelManager$$GetMaxUnlockStar
      i32.lt_s
      local.set $p0
    else
      i32.const 0
      local.set $p0
    end
    local.get $p0
    return)

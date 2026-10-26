  (func $j3660 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i64)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5127151
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4017564 ;; Method$ArrayHelper.GetValueOrDefault<MainLevelUpgradedDataData>()
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5127151
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 5127181
    i32.load8_u
    i32.eqz
    if $I1
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 5127181
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=4
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j2521 ;; NetDataManager$$get_DailyBaseLevelIndex
    local.set $l5
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $l5
    i32.const 0
    call $j4153 ;; ConfigManager$$GetMainLevelUpgradedDataList
    local.get $p0
    i32.const 1
    i32.sub
    i32.const 0
    i32.const 4017564 ;; Method$ArrayHelper.GetValueOrDefault<MainLevelUpgradedDataData>()
    i32.load
    call $j3364
    local.set $l4
    local.get $p3
    i32.const 8
    i32.add
    local.get $l4
    i32.load offset=16
    i32.const 0
    call $j3322 ;; LevelIndexAndType$$MainLevel
    local.get $p3
    i64.load offset=8
    local.set $l7
    i32.const 5127182
    i32.load8_u
    i32.eqz
    if $I2
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 5127182
      i32.const 1
      i32.store8
    end
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.set $l6
    local.get $l6
    local.get $l7
    i32.wrap_i64
    i32.store offset=8
    local.get $l6
    local.get $l7
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=12
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $l4
    i32.load offset=8
    local.get $p0
    call $j14565 ;; MainLevelManager$$GetMaxUnlockStar
    local.set $l4
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l4
    i32.store offset=16
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.const 1
    i32.const 2
    local.get $p0
    i32.const 1
    i32.eq
    select
    i32.const 0
    local.get $p1
    i32.const 0
    i32.const 0
    call $j2956 ;; LevelManager$$StartGame
    i32.const 3958464 ;; MainLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $l5
    local.get $p0
    call $j14562 ;; MainLevelManager$$get_FunctionId
    local.get $p2
    i32.const 0
    call $j35695 ;; ThinkingManager$$TrackMainLevelStart
    local.get $p3
    i32.const 16
    i32.add
    global.set $primary.global$0)

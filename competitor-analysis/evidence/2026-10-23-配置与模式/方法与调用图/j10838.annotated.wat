  (func $j10838 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    (local $l5 i32) (local $l6 i64)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $l5
    local.get $l5
    global.set $primary.global$0
    i32.const 5127153
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296 ;; ABPackManager_TypeInfo
      call $j922
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3961192 ;; RewardData_TypeInfo
      call $j922
      i32.const 4055244 ;; Method$MainLevelManager.<>c__DisplayClass31_0.<TryStartGame>b__0()
      call $j922
      i32.const 4055248 ;; Method$MainLevelManager.<>c__DisplayClass31_0.<TryStartGame>b__1()
      call $j922
      i32.const 4055252 ;; Method$MainLevelManager.<>c__DisplayClass31_0.<TryStartGame>b__2()
      call $j922
      i32.const 3969404 ;; MainLevelManager.<>c__DisplayClass31_0_TypeInfo
      call $j922
      i32.const 4079640 ;; Function_
      call $j922
      i32.const 4120668 ;; 关卡未解锁
      call $j922
      i32.const 4077728 ;; EndLevel
      call $j922
      i32.const 4120636 ;; 关卡加载中
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5127153
      i32.const 1
      i32.store8
    end
    local.get $l5
    i32.const 0
    i32.store offset=28
    i32.const 3969404 ;; MainLevelManager.<>c__DisplayClass31_0_TypeInfo
    i32.load
    call $j924
    local.set $p4
    local.get $p4
    local.get $p1
    i32.store offset=16
    local.get $p4
    local.get $p3
    i32.store8 offset=12
    local.get $p4
    local.get $p0
    i32.store offset=8
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j4065 ;; NetDataManager$$GetMaxUnlockStar
    local.set $p1
    local.get $p4
    i32.load offset=8
    local.set $p0
    block $B1
      local.get $p1
      local.get $p0
      i32.lt_s
      if $I2
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4120668 ;; 关卡未解锁
        i32.load
        i32.const 0
        call $j1145 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $l5
      i32.const 16
      i32.add
      local.get $p0
      i32.const 0
      call $j7298 ;; NetDataManager$$GetMainLevelIndex
      i32.const 0
      call $j3322 ;; LevelIndexAndType$$MainLevel
      local.get $l5
      i64.load offset=16
      local.set $l6
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      i32.load
      call $j923
      local.get $l5
      local.get $l6
      i64.store
      local.get $l5
      local.get $l6
      i64.store offset=8
      local.get $l5
      i32.const 0
      call $j5156 ;; LevelLoaderManager$$GetLevelLoader
      local.set $p0
      local.get $p0
      i32.const 0
      i32.const 0
      call $j4700 ;; LevelLoader$$Load
      block $B3
        local.get $p4
        i32.load offset=8
        local.set $p1
        local.get $p1
        i32.const 2
        i32.lt_s
        br_if $B3
        local.get $p0
        i32.load8_u offset=24
        br_if $B3
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 600
        i32.const 4120636 ;; 关卡加载中
        i32.load
        i32.const 0
        call $j1145 ;; Kunpo.KUIManager$$OpenATip
        br $B1
      end
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 5127183
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3958464 ;; MainLevelManager_TypeInfo
        call $j922
        i32.const 5127183
        i32.const 1
        i32.store8
      end
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.get $p1
      i32.store
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j1480 ;; NetInitManager$$UseVideoMode
      if $I5
        local.get $p4
        i32.load offset=8
        local.set $p0
        i32.const 3958464 ;; MainLevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 1
        i32.const 0
        local.get $p0
        call $j3660 ;; MainLevelManager$$StartGame
        br $B1
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 5142651
      i32.load8_u
      i32.eqz
      if $I6
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
      local.get $p4
      i32.load offset=8
      i32.const 0
      call $j7259 ;; PlayerNetSelfSaveData$$TodayHasWin
      if $I7
        i32.const 4077728 ;; EndLevel
        i32.load
        i32.const 0
        call $j3026 ;; UIObjectInfoPop$$OpenInfoPop
        br $B1
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j5670 ;; NetDataManager$$CanStartFree
      if $I8
        i32.const 3951296 ;; ABPackManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j3370 ;; ABPackManager$$IsUseEnergyRes
        if $I9
          i32.const 3961192 ;; RewardData_TypeInfo
          i32.load
          call $j924
          local.set $p0
          local.get $p0
          i32.const 20103
          i32.const 1
          i32.const 0
          i32.const 1
          i32.const 1
          i32.const 0
          call $j2275 ;; RewardData$$.ctor
          local.get $p0
          i32.const 4063796 ;; 
          i32.load
          i32.const 0
          i32.const 0
          call $j3826 ;; RewardManager$$ConsumeRewardArchiveSave
        end
        local.get $p4
        i32.load8_u offset=12
        local.set $p1
        local.get $p4
        i32.load offset=8
        local.set $p0
        i32.const 3958464 ;; MainLevelManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        local.get $p1
        i32.const 1
        local.get $p0
        call $j3660 ;; MainLevelManager$$StartGame
        br $B1
      end
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      block $B10
        local.get $p2
        i32.const 0
        i32.const 0
        call $j971 ;; UnityEngine.Object$$op_Inequality
        i32.eqz
        br_if $B10
        i32.const 0
        call $j3687 ;; DirectPayItem$$get_isCanDirectPay
        i32.eqz
        br_if $B10
        local.get $p2
        i32.const 0
        i32.const 24184
        global.set $__wasm_split_waitTableId
        i32.const 24184
        call_indirect $primary.table (type $t0)
        br $B1
      end
      i32.const 3951296 ;; ABPackManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j3370 ;; ABPackManager$$IsUseEnergyRes
      if $I11
        i32.const 3957844 ;; Kunpo.KUIManager_TypeInfo
        i32.load
        call $j923
        i32.const 234
        i32.const 0
        i32.const 0
        i32.const 0
        i32.const 0
        call $j1082 ;; Kunpo.KUIManager$$OpenUI
        br $B1
      end
      local.get $p4
      i32.load offset=16
      local.set $p0
      local.get $p0
      i32.load offset=60
      local.set $p1
      local.get $p0
      i32.load8_u offset=24
      local.set $p2
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.load
      call $j924
      local.set $p0
      local.get $p2
      if $I12
        local.get $p0
        local.get $p4
        i32.const 4055244 ;; Method$MainLevelManager.<>c__DisplayClass31_0.<TryStartGame>b__0()
        i32.load
        i32.const 0
        call $j969
        i32.const 3939040 ;; System.Action<bool>_TypeInfo
        i32.load
        call $j924
        local.set $p2
        local.get $p2
        local.get $p4
        i32.const 4055248 ;; Method$MainLevelManager.<>c__DisplayClass31_0.<TryStartGame>b__1()
        i32.load
        i32.const 0
        call $j969
        local.get $p1
        local.get $p0
        local.get $p2
        i32.const 0
        call $j2390 ;; UIFakeADPop$$OpenFakeAD
        br $B1
      end
      local.get $p0
      local.get $p4
      i32.const 4055252 ;; Method$MainLevelManager.<>c__DisplayClass31_0.<TryStartGame>b__2()
      i32.load
      i32.const 0
      call $j969
      local.get $p4
      i32.load offset=8
      local.set $p2
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      local.get $l5
      i32.const 10001
      i32.const 10031
      local.get $p2
      i32.const 1
      i32.eq
      select
      i32.store offset=28
      local.get $l5
      i32.const 28
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $p2
      local.get $p1
      local.get $p0
      i32.const 4079640 ;; Function_
      i32.load
      local.get $p2
      i32.const 0
      call $j962 ;; System.String$$Concat
      i32.const 0
      call $j1752 ;; ShareHelper$$ShareRandom
    end
    local.get $l5
    i32.const 32
    i32.add
    global.set $primary.global$0)

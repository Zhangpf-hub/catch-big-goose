  (func $j2956 (type $t11) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32) (param $p5 i32)
    (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i64)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l6
    local.get $l6
    global.set $primary.global$0
    i32.const 5140083
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296 ;; ABPackManager_TypeInfo
      call $j922
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3955500 ;; GameSceneMa_TypeInfo
      call $j922
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 3950212 ;; int[]_TypeInfo
      call $j922
      i32.const 3958052 ;; LevelManager_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3958472 ;; MainLevelRecordData_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 3959844 ;; PVPManager_TypeInfo
      call $j922
      i32.const 3961192 ;; RewardData_TypeInfo
      call $j922
      i32.const 3962284 ;; SoundManager_TypeInfo
      call $j922
      i32.const 3969092 ;; Kunpo.KUIManager.UINameEnum_TypeInfo
      call $j922
      i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
      call $j922
      i32.const 4075888 ;; CountDownTime
      call $j922
      i32.const 4077844 ;; EndlessTime
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5140083
      i32.const 1
      i32.store8
    end
    local.get $l6
    i32.const 0
    i32.store offset=12
    i64.const 0
    local.set $l9
    local.get $p0
    local.get $l9
    i32.wrap_i64
    i32.store offset=204
    local.get $p0
    local.get $l9
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=208
    i32.const 0
    call $j5758 ;; GameManager$$IsStartGameDirection
    local.set $p5
    block $B1
      block $B2
        local.get $p1
        i32.const 1
        i32.ne
        br_if $B2
        local.get $p2
        br_if $B2
        local.get $p5
        i32.eqz
        br_if $B2
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959304 ;; NetInitManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.load8_u offset=166
        i32.eqz
        br_if $B2
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.const 1
        i32.store8 offset=80
        i32.const 3951296 ;; ABPackManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j3370 ;; ABPackManager$$IsUseEnergyRes
        if $I3
          i32.const 3961192 ;; RewardData_TypeInfo
          i32.load
          call $j924
          local.set $p5
          local.get $p5
          i32.const 20103
          i32.const 1
          i32.const 0
          i32.const 1
          i32.const 1
          i32.const 0
          call $j2275 ;; RewardData$$.ctor
          local.get $p5
          i32.const 4063796 ;; 
          i32.load
          i32.const 0
          i32.const 0
          call $j3826 ;; RewardManager$$ConsumeRewardArchiveSave
        end
        i32.const 3951296 ;; ABPackManager_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j6690 ;; ABPackManager$$get_NewPlayerGuideABType
        i32.const 1
        i32.ne
        br_if $B1
        local.get $l6
        i32.const 801
        i32.store offset=12
        i32.const 3969092 ;; Kunpo.KUIManager.UINameEnum_TypeInfo
        i32.load
        local.set $p5
        local.get $l6
        i32.const -1
        i32.store offset=4
        local.get $l6
        local.get $p5
        i32.store
        local.get $l6
        local.get $l6
        i32.load offset=12
        i32.store offset=8
        local.get $l6
        i32.const 0
        call $j1009 ;; System.Enum$$ToString
        i32.const 1
        i32.const 4017944 ;; Method$Kunpo.AssetManager.LoadAsset<GameObject>()
        i32.load
        call $j1569
        drop
        br $B1
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 0
      i32.store8 offset=80
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 5142651
    i32.load8_u
    i32.eqz
    if $I4
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5142651
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B5
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=96
      br_if $B5
      i32.const 0
      call $j8923 ;; LaunchManager$$GetFeedGameChannel
      br_if $B5
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 1
      i32.const 0
      i32.const 0
      i32.const 0
      i32.const 0
      call $j7301 ;; NetDataManager$$AddGlobalLevelData
    end
    block $B6
      local.get $p1
      i32.const 2
      i32.ne
      br_if $B6
      local.get $p2
      br_if $B6
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 5142651
      i32.load8_u
      i32.eqz
      if $I7
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
      local.set $p5
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 5140203
      i32.load8_u
      i32.eqz
      if $I8
        i32.const 3958464 ;; MainLevelManager_TypeInfo
        call $j922
        i32.const 5140203
        i32.const 1
        i32.store8
      end
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      local.get $p5
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 0
      call $j21191 ;; PlayerNetSelfSaveData$$AddTryCount
      i32.const 0
      call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
    end
    local.get $p0
    i32.const 4075888 ;; CountDownTime
    i32.load
    i32.const 0
    call $j1451 ;; UnityEngine.MonoBehaviour$$StopCoroutine
    local.get $p0
    i32.const 4077844 ;; EndlessTime
    i32.load
    i32.const 0
    call $j1451 ;; UnityEngine.MonoBehaviour$$StopCoroutine
    local.get $p0
    i32.const 0
    i32.store8 offset=56
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 0
    i32.store8 offset=5
    i32.const 3958472 ;; MainLevelRecordData_TypeInfo
    i32.load
    call $j924
    local.set $p5
    i64.const 4294967297
    local.set $l9
    local.get $p5
    local.get $l9
    i32.wrap_i64
    i32.store offset=56
    local.get $p5
    local.get $l9
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=60
    local.get $p5
    i32.const 1
    i32.store offset=40
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p5
    i32.store offset=40
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    i32.const 14
    i32.const 0
    call $j3510 ;; ConfigManager$$GetCommonInt
    i32.const 1
    i32.shl
    local.set $p5
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    i32.const 3950212 ;; int[]_TypeInfo
    i32.load
    local.get $p5
    i32.const 3
    local.get $p5
    i32.const 3
    i32.gt_s
    select
    call $j939
    i32.store offset=24
    i32.const 0
    local.set $p5
    loop $L9
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=40
      i32.load offset=24
      i32.load offset=12
      local.set $l8
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      local.set $l7
      local.get $p5
      local.get $l8
      i32.lt_s
      if $I10
        local.get $l7
        i32.load offset=40
        i32.load offset=24
        local.get $p5
        i32.const 2
        i32.shl
        i32.add
        i32.const 0
        i32.store offset=16
        local.get $p5
        i32.const 1
        i32.add
        local.set $p5
        br $L9
      end
    end
    local.get $l7
    i32.const 0
    i32.store8 offset=36
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p1
    i32.store offset=28
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p2
    i32.store offset=12
    local.get $p3
    if $I11
      i32.const 3955500 ;; GameSceneMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 1
      i32.const 0
      call $j2691 ;; GameSceneMa$$CloseScene
    end
    local.get $p0
    i32.load offset=80
    i32.const 0
    call $j43478 ;; LevelToolMa$$InitTool
    i32.const 1
    i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
    i32.load
    local.get $p0
    i32.load offset=384
    local.get $p2
    local.get $p4
    call $j1181
    local.get $p0
    local.get $p5
    call $j2169 ;; LevelManager$$CleanAll
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    local.get $p2
    local.get $p5
    call $j43528 ;; LevelManager$$InitLevelData
    i64.const 4812096201845374976
    local.set $l9
    local.get $p0
    local.get $l9
    i32.wrap_i64
    i32.store offset=728
    local.get $p0
    local.get $l9
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=732
    local.get $p0
    f32.const 0x0p+0 (;=0;)
    i32.const 1
    local.get $p5
    call $j8916 ;; LevelManager$$SetPrograss
    local.get $p0
    f32.const 0x0p+0 (;=0;)
    i32.const 2
    local.get $p5
    call $j8916 ;; LevelManager$$SetPrograss
    block $B12
      block $B13
        i32.const 3958052 ;; LevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=12
        i32.const 3
        i32.ne
        br_if $B13
        i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $p5
        i32.const 3959504 ;; UnityEngine.Object_TypeInfo
        i32.load
        call $j923
        local.get $p5
        i32.const 0
        call $j1022 ;; UnityEngine.Object$$op_Implicit
        i32.eqz
        br_if $B13
        i32.const 3964288 ;; UIOnlineGamePage_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        i32.const 0
        i32.const 0
        i32.const 0
        call $j6156 ;; UIOnlineGamePage$$SetMyProgress
        br $B12
      end
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 7
      i32.ne
      br_if $B12
      i32.const 3959844 ;; PVPManager_TypeInfo
      i32.load
      call $j923
      f32.const 0x0p+0 (;=0;)
      i32.const 0
      call $j21437 ;; PVPManager$$SetSelfCurProgress
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    block $B14
      local.get $p5
      call $j2087 ;; LevelManager$$HasTwoPlayer
      if $I15
        i32.const 3951356 ;; ActionManager_TypeInfo
        i32.load
        call $j923
        i32.const 3951356 ;; ActionManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=56
        local.set $p1
        local.get $p1
        if $I16
          local.get $p1
          local.get $p0
          f32.load offset=272
          local.get $p0
          f32.load offset=336
          call $j50878
        end
        local.get $p1
        local.get $p0
        i32.load offset=144
        local.get $p0
        i32.load offset=108
        local.get $p1
        call $j14617 ;; LevelManager$$SetContentList
        local.get $p0
        i32.const 112
        i32.add
        local.set $p5
        local.get $p0
        i32.const 160
        i32.add
        local.set $p1
        br $B14
      end
      local.get $p0
      i32.const 92
      i32.add
      local.set $p5
      local.get $p0
      i32.const 144
      i32.add
      local.set $p1
    end
    local.get $p5
    local.get $p1
    i32.load
    local.get $p5
    i32.load
    local.get $p5
    call $j14617 ;; LevelManager$$SetContentList
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    local.get $p5
    local.get $p5
    call $j43549 ;; LevelManager$$CreateLevel
    i32.const 3962284 ;; SoundManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j37562 ;; SoundManager$$ResetLevel
    local.get $p0
    local.get $p5
    call $j43525 ;; LevelManager$$LevelRefreshStoreList
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u offset=81
    if $I17
      local.get $p0
      i32.load offset=612
      local.get $p0
      i32.load offset=144
      local.get $p0
      i32.load offset=160
      local.get $p0
      i32.load offset=148
      local.get $p0
      i32.load offset=164
      i32.const 0
      call $j43495 ;; LevelObjAnimManager$$InitAnim
    end
    local.get $p0
    local.get $p5
    call $j43511 ;; LevelManager$$SetShakeForceMul
    local.get $l6
    i32.const 16
    i32.add
    global.set $primary.global$0)

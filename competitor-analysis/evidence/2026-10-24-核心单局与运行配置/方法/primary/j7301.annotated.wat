  (func $j7301 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    i32.const 5139775
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
      call $j922
      i32.const 3958064 ;; LevelSettleUpload_TypeInfo
      call $j922
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 4031440 ;; Method$NetworkHelper.GetServeEvent<LevelSettleUpload>()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4055872 ;; Method$NetDataManager.<>c__DisplayClass84_0.<AddGlobalLevelData>b__0()
      call $j922
      i32.const 4055876 ;; Method$NetDataManager.<>c__DisplayClass84_0.<AddGlobalLevelData>b__1()
      call $j922
      i32.const 3969852 ;; NetDataManager.<>c__DisplayClass84_0_TypeInfo
      call $j922
      i32.const 4120676 ;; 关卡胜利信息
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5139775
      i32.const 1
      i32.store8
    end
    i32.const 3969852 ;; NetDataManager.<>c__DisplayClass84_0_TypeInfo
    i32.load
    call $j924
    local.set $p4
    local.get $p4
    local.get $p3
    i32.store offset=12
    local.get $p4
    local.get $p1
    i32.store8 offset=9
    local.get $p4
    local.get $p2
    i32.store8 offset=8
    local.get $p4
    local.get $p0
    i32.store8 offset=16
    block $B1
      local.get $p0
      i32.eqz
      if $I2
        local.get $p4
        i32.load8_u offset=9
        i32.eqz
        br_if $B1
      end
      i32.const 3958064 ;; LevelSettleUpload_TypeInfo
      i32.load
      call $j924
      local.set $p0
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      i32.const 5143542
      i32.load8_u
      i32.eqz
      if $I3
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        call $j922
        i32.const 5143542
        i32.const 1
        i32.store8
      end
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=112
      i32.store offset=8
      i32.const 5142099
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        call $j922
        i32.const 5142099
        i32.const 1
        i32.store8
      end
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=120
      i32.store offset=12
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      i32.load offset=24
      i32.store offset=16
      local.get $p0
      local.get $p4
      i32.load8_u offset=9
      i32.store offset=20
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 5140203
      i32.load8_u
      i32.eqz
      if $I5
        i32.const 3958464 ;; MainLevelManager_TypeInfo
        call $j922
        i32.const 5140203
        i32.const 1
        i32.store8
      end
      i32.const 3958464 ;; MainLevelManager_TypeInfo
      i32.load
      call $j923
      block $B6
        i32.const 3958464 ;; MainLevelManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=4
        i32.const 1
        i32.ne
        if $I7
          i32.const 0
          call $j40304 ;; NetUrls.Rank$$get_ExtraUploadLevelSettle
          local.set $p1
          br $B6
        end
        i32.const 0
        call $j40300 ;; NetUrls.Rank$$get_UploadLevelSettle
        local.set $p1
      end
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      i32.load
      call $j924
      local.set $p2
      local.get $p2
      local.get $p4
      i32.const 4055872 ;; Method$NetDataManager.<>c__DisplayClass84_0.<AddGlobalLevelData>b__0()
      i32.load
      i32.const 0
      call $j969
      i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
      i32.load
      call $j924
      local.set $p3
      local.get $p3
      local.get $p4
      i32.const 4055876 ;; Method$NetDataManager.<>c__DisplayClass84_0.<AddGlobalLevelData>b__1()
      i32.load
      i32.const 0
      call $j969
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      call $j923
      local.get $p0
      local.get $p1
      local.get $p2
      local.get $p3
      i32.const 2
      i32.const 4120676 ;; 关卡胜利信息
      i32.load
      i32.const 4063796 ;; 
      i32.load
      i32.const 0
      i32.const 4031440 ;; Method$NetworkHelper.GetServeEvent<LevelSettleUpload>()
      i32.load
      call $j1391
    end)

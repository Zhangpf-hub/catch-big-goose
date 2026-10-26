  (func $j95010 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 f32)
    global.get $primary.global$0
    i32.const 208
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140047
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296 ;; ABPackManager_TypeInfo
      call $j922
      i32.const 3951352 ;; System.Action_TypeInfo
      call $j922
      i32.const 3952576 ;; CameraControl_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3954608 ;; EnergyABType_TypeInfo
      call $j922
      i32.const 3955156 ;; FreeLevelCountABType_TypeInfo
      call $j922
      i32.const 3955880 ;; GuideABType_TypeInfo
      call $j922
      i32.const 3958032 ;; LevelHardABType_TypeInfo
      call $j922
      i32.const 4029152 ;; Method$LevelManager.<Start>b__83_0()
      call $j922
      i32.const 3958340 ;; LongTimeABPackType_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 3961964 ;; ShareADRateABType_TypeInfo
      call $j922
      i32.const 3962028 ;; ShowPrograssABType_TypeInfo
      call $j922
      i32.const 3963108 ;; TeachABType_TypeInfo
      call $j922
      i32.const 3963120 ;; TeachShakeABType_TypeInfo
      call $j922
      i32.const 3964796 ;; UseSubmitABType_TypeInfo
      call $j922
      i32.const 3965720 ;; WxSdkTool_TypeInfo
      call $j922
      i32.const 4120656 ;; 关卡教程分包:
      call $j922
      i32.const 4126512 ;; 进度条分包:
      call $j922
      i32.const 4120784 ;; 分享占比分包:
      call $j922
      i32.const 4122444 ;; 引导分包:
      call $j922
      i32.const 4120612 ;; 关卡偏移分包:
      call $j922
      i32.const 4108992 ;; ios
      call $j922
      i32.const 4126832 ;; 难度2分包:
      call $j922
      i32.const 4120352 ;; 体力分包:
      call $j922
      i32.const 4123520 ;; 时间分包:
      call $j922
      i32.const 4123116 ;; 教程分包:
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4120356 ;; 体力系统分包:
      call $j922
      i32.const 4084976 ;; LoopCheckTip
      call $j922
      i32.const 4077896 ;; Enter
      call $j922
      i32.const 4126000 ;; 订阅分包:
      call $j922
      i32.const 5140047
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 0
    i32.store offset=204
    local.get $p1
    i32.const 0
    i32.store offset=200
    local.get $p1
    i32.const 0
    i32.store offset=196
    local.get $p1
    i32.const 0
    i32.store offset=192
    local.get $p1
    i32.const 0
    i32.store offset=188
    local.get $p1
    i32.const 0
    i32.store offset=184
    local.get $p1
    i32.const 0
    i32.store offset=180
    local.get $p1
    i32.const 0
    i32.store offset=176
    local.get $p1
    i32.const 0
    i32.store offset=172
    local.get $p1
    i32.const 0
    i32.store offset=168
    local.get $p1
    i32.const 0
    i32.store offset=164
    local.get $p0
    i32.load offset=124
    i32.load offset=16
    i32.const 0
    call $j3515 ;; UnityEngine.Camera$$get_orthographicSize
    local.set $l4
    loop $L1
      local.get $p0
      i32.load offset=124
      local.set $l3
      local.get $l3
      i32.load offset=12
      local.get $l2
      i32.gt_s
      if $I2
        local.get $l3
        local.get $l2
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.get $l4
        i32.const 3952576 ;; CameraControl_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=4
        f32.mul
        i32.const 0
        call $j2868 ;; UnityEngine.Camera$$set_orthographicSize
        local.get $l2
        i32.const 1
        i32.add
        local.set $l2
        br $L1
      end
    end
    local.get $p0
    local.get $l2
    call $j43537 ;; LevelManager$$GetNetworkInfo
    i32.const 3951296 ;; ABPackManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j24958 ;; ABPackManager$$get_TeachHasShakeABType
    i32.const 1
    i32.eq
    if $I3
      local.get $p0
      i32.const 4084976 ;; LoopCheckTip
      i32.load
      i32.const 0
      call $j1559 ;; UnityEngine.MonoBehaviour$$StartCoroutine
      drop
    end
    local.get $p0
    local.get $l2
    call $j43526 ;; LevelManager$$InitStoreList
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    local.get $l2
    call $j3058 ;; NetInitManager$$IsHideAllLog
    i32.eqz
    if $I4
      i32.const 3951296 ;; ABPackManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j15948 ;; ABPackManager$$get_TimeABType
      i32.store offset=204
      i32.const 3958340 ;; LongTimeABPackType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 152
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=204
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4123520 ;; 时间分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      local.set $l2
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $l2
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j24959 ;; ABPackManager$$get_LevelABType
      i32.store offset=200
      i32.const 3958032 ;; LevelHardABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 136
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=200
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4126832 ;; 难度2分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j50928 ;; ABPackManager$$get_PrograssUIABType
      i32.store offset=196
      i32.const 3962028 ;; ShowPrograssABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 120
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=196
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4126512 ;; 进度条分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j24960 ;; ABPackManager$$get_EnergyStartABType
      i32.store offset=192
      i32.const 3954608 ;; EnergyABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 104
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=192
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4120352 ;; 体力分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j11648 ;; ABPackManager$$get_TeachLevelABType
      i32.store offset=188
      i32.const 3963108 ;; TeachABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 88
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=188
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4123116 ;; 教程分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j24961 ;; ABPackManager$$get_EnergyShareRateABType
      i32.store offset=184
      i32.const 3961964 ;; ShareADRateABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 72
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=184
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4120784 ;; 分享占比分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j11650 ;; ABPackManager$$get_MoreFreeLevelABType
      i32.store offset=180
      i32.const 3955156 ;; FreeLevelCountABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 56
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=180
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4120356 ;; 体力系统分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j15949 ;; ABPackManager$$get_DaliyOffsetABIndex
      i32.store offset=176
      local.get $p1
      i32.const 176
      i32.add
      i32.const 0
      call $j1012 ;; System.Int32$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4120612 ;; 关卡偏移分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j24958 ;; ABPackManager$$get_TeachHasShakeABType
      i32.store offset=172
      i32.const 3963120 ;; TeachShakeABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 40
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=172
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4120656 ;; 关卡教程分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j11649 ;; ABPackManager$$get_ShowSubmitABType
      i32.store offset=168
      i32.const 3964796 ;; UseSubmitABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 24
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=168
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4126000 ;; 订阅分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      local.get $p1
      i32.const 0
      call $j6690 ;; ABPackManager$$get_NewPlayerGuideABType
      i32.store offset=164
      i32.const 3955880 ;; GuideABType_TypeInfo
      i32.load
      local.set $l3
      local.get $p1
      i32.const 8
      i32.add
      local.set $l2
      local.get $l2
      i32.const -1
      i32.store offset=4
      local.get $l2
      local.get $l3
      i32.store
      local.get $l2
      local.get $p1
      i32.load offset=164
      i32.store offset=8
      local.get $l2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l2
      local.get $l2
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $l2
      i32.const 4122444 ;; 引导分包:
      i32.load
      local.get $l3
      local.get $l2
      local.get $l2
      local.get $l2
      local.get $l2
      i32.const 0
      call $j1120 ;; GameManager$$StringAppend
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
    end
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    call $j923
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=16
    i32.const 4108992 ;; ios
    i32.load
    i32.const 0
    call $j949 ;; System.String$$op_Equality
    if $I5
      local.get $p0
      local.get $p0
      f32.load offset=800
      f32.store offset=796
    end
    i32.const 5
    i32.const 15
    i32.const 0
    call $j1479 ;; UnityEngine.Random$$Range
    local.set $l2
    i32.const 0
    call $j7540 ;; DelayRequestManager$$get_Instance
    i32.const 0
    i32.const 1
    local.get $l2
    f32.convert_i32_s
    i32.const 0
    i32.const 0
    call $j7541 ;; DelayRequestManager$$DelayRequest
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.get $l2
    call $j14365 ;; NetInitManager$$UseShakeTestVideoMode
    if $I6
      i32.const 3951352 ;; System.Action_TypeInfo
      i32.load
      call $j924
      local.set $l2
      local.get $l2
      local.get $p0
      i32.const 4029152 ;; Method$LevelManager.<Start>b__83_0()
      i32.load
      i32.const 0
      call $j994 ;; System.Action$$.ctor
      i32.const 3965720 ;; WxSdkTool_TypeInfo
      i32.load
      call $j923
      i32.const 4077896 ;; Enter
      i32.load
      local.get $l2
      i32.const 0
      call $j31268 ;; WxSdkTool$$AddKeyDownEvent
    end
    local.get $p1
    i32.const 208
    i32.add
    global.set $primary.global$0)

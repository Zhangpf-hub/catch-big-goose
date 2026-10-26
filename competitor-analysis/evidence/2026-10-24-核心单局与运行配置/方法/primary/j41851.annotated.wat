  (func $j41851 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32)
    i32.const 5139774
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 4004932 ;; Method$System.Collections.Generic.List<string>.ToArray()
      call $j922
      i32.const 3959144 ;; MultipleProvinceDataGetBody_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 4031444 ;; Method$NetworkHelper.GetServeEvent<MultipleProvinceDataGetBody>()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4055740 ;; Method$NetDataManager.<>c.<GetMultipleProvinceData>b__83_0()
      call $j922
      i32.const 3969780 ;; NetDataManager.<>c_TypeInfo
      call $j922
      i32.const 4080316 ;; GetMultipleProvinceData
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5139774
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.const 1
    i32.store8 offset=80
    i32.const 3959144 ;; MultipleProvinceDataGetBody_TypeInfo
    i32.load
    call $j924
    local.set $p0
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    call $j923
    i32.const 5143542
    i32.load8_u
    i32.eqz
    if $I1
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
    if $I2
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
    local.get $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=84
    i32.const 4004932 ;; Method$System.Collections.Generic.List<string>.ToArray()
    i32.load
    call $j1523
    i32.store offset=16
    i32.const 0
    call $j40303 ;; NetUrls.Rank$$get_GetMultiProvincesData
    local.set $l2
    i32.const 3969780 ;; NetDataManager.<>c_TypeInfo
    i32.load
    call $j923
    i32.const 3969780 ;; NetDataManager.<>c_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    local.set $l1
    local.get $l1
    i32.eqz
    if $I3
      i32.const 3969780 ;; NetDataManager.<>c_TypeInfo
      i32.load
      call $j923
      i32.const 3969780 ;; NetDataManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l3
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      i32.load
      call $j924
      local.set $l1
      local.get $l1
      local.get $l3
      i32.const 4055740 ;; Method$NetDataManager.<>c.<GetMultipleProvinceData>b__83_0()
      i32.load
      i32.const 0
      call $j969
      i32.const 3969780 ;; NetDataManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      local.get $l1
      i32.store offset=4
      i32.const 3969780 ;; NetDataManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      drop
    end
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $l2
    local.get $l1
    i32.const 0
    i32.const 2
    i32.const 4080316 ;; GetMultipleProvinceData
    i32.load
    i32.const 4063796 ;; 
    i32.load
    i32.const 0
    i32.const 4031444 ;; Method$NetworkHelper.GetServeEvent<MultipleProvinceDataGetBody>()
    i32.load
    call $j1391)

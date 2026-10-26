  (func $j72149 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140341
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4125392 ;; 获取AB参数成功
      call $j922
      i32.const 5140341
      i32.const 1
      i32.store8
    end
    i32.const 4125392 ;; 获取AB参数成功
    i32.load
    i32.const 2
    local.get $p1
    call $j1407 ;; GameManager$$LogInColor
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j1600 ;; NetInitManager$$CanShowSEventDetail
    if $I1
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j1163 ;; LitJson.JsonMapper$$ToJson
      local.set $p2
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $p2
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
    end
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 3
    local.get $p1
    call $j20234 ;; ServerFileCreate$$BuildABTestDataFile
    local.set $p2
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=44
    local.set $p1
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    local.get $p1
    local.get $p1
    call $j50924 ;; ABTestManager$$SetABData
    local.get $p0
    i32.load offset=8
    local.set $p0
    local.get $p0
    if $I2
      local.get $p0
      local.get $p2
      i32.const 0
      call $j1184
    end)

  (func $j8812 (type $t8) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
    i32.const 5139800
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3957776 ;; LitJson.JsonData_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 4031436 ;; Method$NetworkHelper.GetServeEvent<JsonData>()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      call $j922
      i32.const 4055756 ;; Method$NetDataManager.<>c__DisplayClass113_0.<UploadLibraryChiForestOrderInfo>b__0()
      call $j922
      i32.const 4055760 ;; Method$NetDataManager.<>c__DisplayClass113_0.<UploadLibraryChiForestOrderInfo>b__1()
      call $j922
      i32.const 3969788 ;; NetDataManager.<>c__DisplayClass113_0_TypeInfo
      call $j922
      i32.const 3964232 ;; UILibraryHelper_TypeInfo
      call $j922
      i32.const 4121420 ;; 图书馆活动已结束
      call $j922
      i32.const 4116696 ;; uid
      call $j922
      i32.const 4124236 ;; 正式服编辑模式不加积分
      call $j922
      i32.const 4114284 ;; score
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4114316 ;; sdkid
      call $j922
      i32.const 4116572 ;; type
      call $j922
      i32.const 4069820 ;; 1001
      call $j922
      i32.const 5139800
      i32.const 1
      i32.store8
    end
    i32.const 3969788 ;; NetDataManager.<>c__DisplayClass113_0_TypeInfo
    i32.load
    call $j924
    local.set $p4
    local.get $p4
    local.get $p1
    i32.store offset=8
    local.get $p4
    local.get $p3
    i32.store offset=12
    local.get $p4
    local.get $p0
    i32.store offset=16
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 0
      call $j2164 ;; NetInitManager$$ServerType
      i32.const 2
      i32.ne
      br_if $B1
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $p0
      i32.const 3959504 ;; UnityEngine.Object_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      call $j1022 ;; UnityEngine.Object$$op_Implicit
      i32.eqz
      br_if $B1
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.const 0
      call $j2761 ;; NetInitManager$$UseEditor
      i32.eqz
      br_if $B1
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      i32.const 4124236 ;; 正式服编辑模式不加积分
      i32.load
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
      return
    end
    local.get $p4
    i32.load offset=16
    local.set $p0
    local.get $p0
    i32.const 101
    i32.ge_s
    if $I2
      i32.const 0
      local.get $p0
      local.get $p4
      i32.load offset=8
      local.get $p4
      i32.load offset=12
      i32.const 4069820 ;; 1001
      i32.load
      i32.const 0
      call $j13416 ;; ThinkingManager$$AddLibraryScore
      return
    end
    i32.const 3964232 ;; UILibraryHelper_TypeInfo
    i32.load
    call $j923
    block $B3
      i32.const 0
      call $j8340 ;; UILibraryHelper$$GetLibraryStatus
      local.set $p0
      local.get $p0
      i32.const 4
      i32.gt_u
      br_if $B3
      i32.const 1
      local.get $p0
      i32.shl
      i32.const 19
      i32.and
      i32.eqz
      br_if $B3
      i32.const 5
      i32.const 4121420 ;; 图书馆活动已结束
      i32.load
      i32.const 0
      call $j1429 ;; GameManager$$LogInColor
      return
    end
    i32.const 3957776 ;; LitJson.JsonData_TypeInfo
    i32.load
    call $j924
    local.set $p0
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    call $j923
    i32.const 5143542
    i32.load8_u
    i32.eqz
    if $I4
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 5143542
      i32.const 1
      i32.store8
    end
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    call $j923
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=112
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $p1
    local.get $p0
    i32.const 4116696 ;; uid
    i32.load
    local.get $p1
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 5142099
    i32.load8_u
    i32.eqz
    if $I5
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 5142099
      i32.const 1
      i32.store8
    end
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    call $j923
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=120
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $p1
    local.get $p0
    i32.const 4114316 ;; sdkid
    i32.load
    local.get $p1
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    local.get $p4
    i32.load offset=16
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $p1
    local.get $p0
    i32.const 4114284 ;; score
    i32.load
    local.get $p1
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    local.get $p2
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $p1
    local.get $p0
    i32.const 4116572 ;; type
    i32.load
    local.get $p1
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 0
    i32.const 18794
    global.set $__wasm_split_waitTableId
    i32.const 18794
    call_indirect $primary.table (type $t3)
    local.set $p1
    i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    local.get $p4
    i32.const 4055756 ;; Method$NetDataManager.<>c__DisplayClass113_0.<UploadLibraryChiForestOrderInfo>b__0()
    i32.load
    i32.const 0
    call $j969
    i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
    i32.load
    call $j924
    local.set $p3
    local.get $p3
    local.get $p4
    i32.const 4055760 ;; Method$NetDataManager.<>c__DisplayClass113_0.<UploadLibraryChiForestOrderInfo>b__1()
    i32.load
    i32.const 0
    call $j969
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.set $p4
    i32.const 4063796 ;; 
    i32.load
    local.set $p0
    local.get $p4
    local.get $p1
    local.get $p2
    local.get $p3
    i32.const 2
    local.get $p0
    local.get $p0
    i32.const 0
    i32.const 4031436 ;; Method$NetworkHelper.GetServeEvent<JsonData>()
    i32.load
    call $j1391)

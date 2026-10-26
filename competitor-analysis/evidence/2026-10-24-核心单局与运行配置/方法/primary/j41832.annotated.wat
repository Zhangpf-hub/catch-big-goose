  (func $j41832 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32)
    i32.const 5139777
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
      call $j922
      i32.const 3957776 ;; LitJson.JsonData_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 4031436 ;; Method$NetworkHelper.GetServeEvent<JsonData>()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4055884 ;; Method$NetDataManager.<>c__DisplayClass87_0.<RefreshTeamListData>b__0()
      call $j922
      i32.const 4055888 ;; Method$NetDataManager.<>c__DisplayClass87_0.<RefreshTeamListData>b__1()
      call $j922
      i32.const 3969856 ;; NetDataManager.<>c__DisplayClass87_0_TypeInfo
      call $j922
      i32.const 4116696 ;; uid
      call $j922
      i32.const 4106420 ;; end_num
      call $j922
      i32.const 4115300 ;; start_num
      call $j922
      i32.const 4122744 ;; 战队列表数据
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4114316 ;; sdkid
      call $j922
      i32.const 5139777
      i32.const 1
      i32.store8
    end
    i32.const 3969856 ;; NetDataManager.<>c__DisplayClass87_0_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    local.get $p0
    i32.store offset=8
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
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=112
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4116696 ;; uid
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
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
    i32.const 3959324 ;; NetworkConfig_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=120
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4114316 ;; sdkid
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 1
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4115300 ;; start_num
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 100
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4106420 ;; end_num
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 0
    i32.const 18715
    global.set $__wasm_split_waitTableId
    i32.const 18715
    call_indirect $primary.table (type $t3)
    local.set $l2
    i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    local.get $p1
    i32.const 4055884 ;; Method$NetDataManager.<>c__DisplayClass87_0.<RefreshTeamListData>b__0()
    i32.load
    i32.const 0
    call $j969
    i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
    i32.load
    call $j924
    local.set $l4
    local.get $l4
    local.get $p1
    i32.const 4055888 ;; Method$NetDataManager.<>c__DisplayClass87_0.<RefreshTeamListData>b__1()
    i32.load
    i32.const 0
    call $j969
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $l2
    local.get $l3
    local.get $l4
    i32.const 2
    i32.const 4122744 ;; 战队列表数据
    i32.load
    i32.const 4063796 ;; 
    i32.load
    i32.const 0
    i32.const 4031436 ;; Method$NetworkHelper.GetServeEvent<JsonData>()
    i32.load
    call $j1391)

  (func $j41845 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32)
    i32.const 5139804
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
      i32.const 4012168 ;; Method$JianEngine.SingleMono<RedPacketHelper>.get_Instance()
      call $j922
      i32.const 4055780 ;; Method$NetDataManager.<>c__DisplayClass117_0.<GetRedPacketReward>b__0()
      call $j922
      i32.const 4055784 ;; Method$NetDataManager.<>c__DisplayClass117_0.<GetRedPacketReward>b__1()
      call $j922
      i32.const 3969800 ;; NetDataManager.<>c__DisplayClass117_0_TypeInfo
      call $j922
      i32.const 4116696 ;; uid
      call $j922
      i32.const 4104044 ;; channel
      call $j922
      i32.const 4102292 ;; act_id
      call $j922
      i32.const 4125140 ;; 红包活动-获取红包奖励
      call $j922
      i32.const 4108408 ;; id
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4114316 ;; sdkid
      call $j922
      i32.const 5139804
      i32.const 1
      i32.store8
    end
    i32.const 3969800 ;; NetDataManager.<>c__DisplayClass117_0_TypeInfo
    i32.load
    call $j924
    local.set $p3
    local.get $p3
    local.get $p1
    i32.store offset=8
    local.get $p3
    local.get $p2
    i32.store offset=12
    i32.const 3957776 ;; LitJson.JsonData_TypeInfo
    i32.load
    call $j924
    local.set $p1
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
    local.set $p2
    local.get $p1
    i32.const 4116696 ;; uid
    i32.load
    local.get $p2
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
    local.set $p2
    local.get $p1
    i32.const 4114316 ;; sdkid
    i32.load
    local.get $p2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 3
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $p2
    local.get $p1
    i32.const 4104044 ;; channel
    i32.load
    local.get $p2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    local.get $p0
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $p0
    local.get $p1
    i32.const 4108408 ;; id
    i32.load
    local.get $p0
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 4012168 ;; Method$JianEngine.SingleMono<RedPacketHelper>.get_Instance()
    i32.load
    call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
    i32.load offset=24
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $p0
    local.get $p1
    i32.const 4102292 ;; act_id
    i32.load
    local.get $p0
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 0
    i32.const 18801
    global.set $__wasm_split_waitTableId
    i32.const 18801
    call_indirect $primary.table (type $t3)
    local.set $p0
    i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    local.get $p3
    i32.const 4055780 ;; Method$NetDataManager.<>c__DisplayClass117_0.<GetRedPacketReward>b__0()
    i32.load
    i32.const 0
    call $j969
    i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
    i32.load
    call $j924
    local.set $l4
    local.get $l4
    local.get $p3
    i32.const 4055784 ;; Method$NetDataManager.<>c__DisplayClass117_0.<GetRedPacketReward>b__1()
    i32.load
    i32.const 0
    call $j969
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    local.get $p1
    local.get $p0
    local.get $p2
    local.get $l4
    i32.const 2
    i32.const 4125140 ;; 红包活动-获取红包奖励
    i32.load
    i32.const 4063796 ;; 
    i32.load
    i32.const 0
    i32.const 4031436 ;; Method$NetworkHelper.GetServeEvent<JsonData>()
    i32.load
    call $j1391)

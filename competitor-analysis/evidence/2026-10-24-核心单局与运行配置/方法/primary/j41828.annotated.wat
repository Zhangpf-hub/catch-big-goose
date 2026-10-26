  (func $j41828 (type $t4) (param $p0 i32)
    (local $l1 i32)
    i32.const 5139809
    i32.load8_u
    i32.eqz
    if $I0
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
      i32.const 4125156 ;; 红包活动-设置自己排行榜公开
      call $j922
      i32.const 4116696 ;; uid
      call $j922
      i32.const 4102292 ;; act_id
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4109172 ;; is_open
      call $j922
      i32.const 5139809
      i32.const 1
      i32.store8
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
    local.set $l1
    local.get $p0
    i32.const 4116696 ;; uid
    i32.load
    local.get $l1
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 1
    i32.const 0
    call $j3481 ;; LitJson.JsonData$$op_Implicit
    local.set $l1
    local.get $p0
    i32.const 4109172 ;; is_open
    i32.load
    local.get $l1
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 4012168 ;; Method$JianEngine.SingleMono<RedPacketHelper>.get_Instance()
    i32.load
    call $j1366 ;; JianEngine.SingleMono<object>$$get_Instance
    i32.load offset=24
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $l1
    local.get $p0
    i32.const 4102292 ;; act_id
    i32.load
    local.get $l1
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 0
    i32.const 18808
    global.set $__wasm_split_waitTableId
    i32.const 18808
    call_indirect $primary.table (type $t3)
    local.set $l1
    i32.const 3959332 ;; NetworkHelper_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $l1
    i32.const 0
    i32.const 0
    i32.const 2
    i32.const 4125156 ;; 红包活动-设置自己排行榜公开
    i32.load
    i32.const 4063796 ;; 
    i32.load
    i32.const 0
    i32.const 4031436 ;; Method$NetworkHelper.GetServeEvent<JsonData>()
    i32.load
    call $j1391)

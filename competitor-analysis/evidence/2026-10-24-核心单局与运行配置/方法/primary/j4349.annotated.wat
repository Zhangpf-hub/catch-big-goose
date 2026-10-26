  (func $j4349 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32)
    i32.const 5139739
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
      call $j922
      i32.const 3951352 ;; System.Action_TypeInfo
      call $j922
      i32.const 3957776 ;; LitJson.JsonData_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 4031472 ;; Method$NetworkHelper.UploadEvent<JsonData>()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 4055856 ;; Method$NetDataManager.<>c__DisplayClass37_0.<UploadPlayerServerData>b__0()
      call $j922
      i32.const 4055860 ;; Method$NetDataManager.<>c__DisplayClass37_0.<UploadPlayerServerData>b__1()
      call $j922
      i32.const 3969840 ;; NetDataManager.<>c__DisplayClass37_0_TypeInfo
      call $j922
      i32.const 4123688 ;; 更新用户信息
      call $j922
      i32.const 4116696 ;; uid
      call $j922
      i32.const 4115232 ;; star
      call $j922
      i32.const 4113320 ;; province
      call $j922
      i32.const 4107884 ;; head
      call $j922
      i32.const 4114900 ;; skin
      call $j922
      i32.const 4105980 ;; dy_play_time
      call $j922
      i32.const 4104196 ;; city
      call $j922
      i32.const 4119868 ;; 上传位置: {0}
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4114316 ;; sdkid
      call $j922
      i32.const 4111668 ;; nickname
      call $j922
      i32.const 5139739
      i32.const 1
      i32.store8
    end
    i32.const 3969840 ;; NetDataManager.<>c__DisplayClass37_0_TypeInfo
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
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    i32.load offset=16
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4111668 ;; nickname
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    i32.load offset=40
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4107884 ;; head
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    i32.const 32
    i32.add
    i32.const 0
    call $j1012 ;; System.Int32$$ToString
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4114900 ;; skin
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    i32.load offset=36
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4115232 ;; star
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    i32.load offset=24
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4113320 ;; province
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 4063796 ;; 
    i32.load
    i32.const 0
    call $j1089 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4104196 ;; city
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    i32.const 0
    i32.const 0
    call $j1140 ;; LitJson.JsonData$$op_Implicit
    local.set $l2
    local.get $p0
    i32.const 4105980 ;; dy_play_time
    i32.load
    local.get $l2
    i32.const 0
    call $j1016 ;; LitJson.JsonData$$set_Item
    block $B3
      i32.const 0
      call $j1326 ;; NetworkConfig$$get_GameChannel
      i32.const 32
      i32.ne
      if $I4
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j1326 ;; NetworkConfig$$get_GameChannel
        i32.const 3
        i32.ne
        br_if $B3
      end
      i32.const 0
      call $j8923 ;; LaunchManager$$GetFeedGameChannel
      if $I5
        i32.const 3959324 ;; NetworkConfig_TypeInfo
        i32.load
        call $j923
        i32.const 0
        call $j1521 ;; NetworkConfig$$get_TimeStamp
        local.set $l2
      else
        i32.const 0
        local.set $l2
      end
      local.get $l2
      i32.const 0
      call $j1140 ;; LitJson.JsonData$$op_Implicit
      local.set $l2
      local.get $p0
      i32.const 4105980 ;; dy_play_time
      i32.load
      local.get $l2
      i32.const 0
      call $j1016 ;; LitJson.JsonData$$set_Item
    end
    local.get $p0
    i32.const 4113320 ;; province
    i32.load
    i32.const 0
    call $j1155 ;; LitJson.JsonData$$get_Item
    local.set $l2
    i32.const 4119868 ;; 上传位置: {0}
    i32.load
    local.get $l2
    i32.const 0
    call $j1006 ;; System.String$$Format
    i32.const 0
    i32.const 0
    call $j1648 ;; Kunpo.Debugger$$LogWarning
    i32.const 0
    call $j32886 ;; NetUrls.User$$get_UpdateInfo
    local.set $l2
    i32.const 3951352 ;; System.Action_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    local.get $p1
    i32.const 4055856 ;; Method$NetDataManager.<>c__DisplayClass37_0.<UploadPlayerServerData>b__0()
    i32.load
    i32.const 0
    call $j994 ;; System.Action$$.ctor
    i32.const 3939000 ;; System.Action<ValueTuple<string, string>>_TypeInfo
    i32.load
    call $j924
    local.set $l4
    local.get $l4
    local.get $p1
    i32.const 4055860 ;; Method$NetDataManager.<>c__DisplayClass37_0.<UploadPlayerServerData>b__1()
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
    i32.const 4123688 ;; 更新用户信息
    i32.load
    i32.const 0
    i32.const 4031472 ;; Method$NetworkHelper.UploadEvent<JsonData>()
    i32.load
    call $j2016)

  (func $j14378 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l4
    local.get $l4
    global.set $primary.global$0
    i32.const 5139783
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 3957776 ;; LitJson.JsonData_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      call $j922
      i32.const 3969868 ;; NetDataManager.<>c__DisplayClass93_0_TypeInfo
      call $j922
      i32.const 4055920 ;; Method$NetDataManager.<>c__DisplayClass93_1.<UpSpGooseToTable>b__0()
      call $j922
      i32.const 3969872 ;; NetDataManager.<>c__DisplayClass93_1_TypeInfo
      call $j922
      i32.const 4116696 ;; uid
      call $j922
      i32.const 4113320 ;; province
      call $j922
      i32.const 4070392 ;; 35
      call $j922
      i32.const 4119984 ;; 不存在该大鹅{0}
      call $j922
      i32.const 4114284 ;; score
      call $j922
      i32.const 4114316 ;; sdkid
      call $j922
      i32.const 4115360 ;; status
      call $j922
      i32.const 5139783
      i32.const 1
      i32.store8
    end
    i32.const 3969868 ;; NetDataManager.<>c__DisplayClass93_0_TypeInfo
    i32.load
    call $j924
    local.set $p2
    local.get $p2
    local.get $p0
    i32.store offset=8
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      i32.const 0
      call $j1293 ;; ConfigManager$$GetGoose
      i32.eqz
      if $I2
        local.get $l4
        local.get $p2
        i32.load offset=8
        i32.store offset=12
        i32.const 3957596 ;; int_TypeInfo
        i32.load
        local.get $l4
        i32.const 12
        i32.add
        call $j935
        local.set $p0
        i32.const 4119984 ;; 不存在该大鹅{0}
        i32.load
        local.get $p0
        i32.const 0
        call $j1006 ;; System.String$$Format
        local.set $p0
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 0
        call $j1075 ;; UnityEngine.Debug$$LogWarning
        br $B1
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.get $p2
      i32.load offset=8
      i32.store offset=84
      local.get $p2
      call $j1769 ;; NetDataManager$$UploadPlayerSelfArchives
      local.get $p2
      i32.load offset=8
      local.get $p2
      call $j7297 ;; NetDataManager$$UpdateDefaultGoose
      i32.const 5142653
      i32.load8_u
      i32.eqz
      if $I3
        i32.const 3959288 ;; NetDataManager_TypeInfo
        call $j922
        i32.const 5142653
        i32.const 1
        i32.store8
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      i32.load8_u offset=45
      i32.eqz
      br_if $B1
      i32.const 3969872 ;; NetDataManager.<>c__DisplayClass93_1_TypeInfo
      i32.load
      call $j924
      local.set $p0
      local.get $p0
      local.get $p2
      i32.store offset=12
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 5142653
      i32.load8_u
      i32.eqz
      if $I4
        i32.const 3959288 ;; NetDataManager_TypeInfo
        call $j922
        i32.const 5142653
        i32.const 1
        i32.store8
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=28
      i32.load offset=24
      local.set $p2
      local.get $p0
      i32.const 3957776 ;; LitJson.JsonData_TypeInfo
      i32.load
      call $j924
      i32.store offset=8
      local.get $p0
      i32.load offset=8
      local.set $l3
      i32.const 3959324 ;; NetworkConfig_TypeInfo
      i32.load
      call $j923
      i32.const 5143542
      i32.load8_u
      i32.eqz
      if $I5
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
      local.set $l5
      local.get $l3
      i32.const 4116696 ;; uid
      i32.load
      local.get $l5
      i32.const 0
      call $j1016 ;; LitJson.JsonData$$set_Item
      local.get $p0
      i32.load offset=8
      local.set $l3
      i32.const 5142099
      i32.load8_u
      i32.eqz
      if $I6
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
      local.set $l5
      local.get $l3
      i32.const 4114316 ;; sdkid
      i32.load
      local.get $l5
      i32.const 0
      call $j1016 ;; LitJson.JsonData$$set_Item
      local.get $p0
      i32.load offset=8
      local.set $l3
      local.get $p1
      i32.const 0
      call $j1140 ;; LitJson.JsonData$$op_Implicit
      local.set $p1
      local.get $l3
      i32.const 4114284 ;; score
      i32.load
      local.get $p1
      i32.const 0
      call $j1016 ;; LitJson.JsonData$$set_Item
      local.get $p0
      i32.load offset=8
      local.set $p1
      local.get $p2
      i32.const 0
      call $j1089 ;; LitJson.JsonData$$op_Implicit
      local.set $p2
      local.get $p1
      i32.const 4113320 ;; province
      i32.load
      local.get $p2
      i32.const 0
      call $j1016 ;; LitJson.JsonData$$set_Item
      local.get $p0
      i32.load offset=8
      local.set $p1
      i32.const 1
      i32.const 0
      call $j1140 ;; LitJson.JsonData$$op_Implicit
      local.set $p2
      local.get $p1
      i32.const 4115360 ;; status
      i32.load
      local.get $p2
      i32.const 0
      call $j1016 ;; LitJson.JsonData$$set_Item
      i32.const 3939040 ;; System.Action<bool>_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      local.get $p0
      i32.const 4055920 ;; Method$NetDataManager.<>c__DisplayClass93_1.<UpSpGooseToTable>b__0()
      i32.load
      i32.const 0
      call $j969
      local.get $p1
      local.get $p1
      call $j4349 ;; NetDataManager$$UploadPlayerServerData
    end
    local.get $l4
    i32.const 16
    i32.add
    global.set $primary.global$0)

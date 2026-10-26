  (func $j21660 (type $t4) (param $p0 i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5139729
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951296 ;; ABPackManager_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3953520 ;; DaliyRewardManager_TypeInfo
      call $j922
      i32.const 3984728 ;; Method$System.Collections.Generic.Dictionary<string, int>.Add()
      call $j922
      i32.const 3984732 ;; Method$System.Collections.Generic.Dictionary<string, int>.Clear()
      call $j922
      i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
      call $j922
      i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
      call $j922
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 3965720 ;; WxSdkTool_TypeInfo
      call $j922
      i32.const 5139729
      i32.const 1
      i32.store8
    end
    local.get $p0
    i64.const 0
    i64.store offset=16
    local.get $p0
    i32.const 0
    i32.store offset=12
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i64.load offset=16
    i64.store offset=24
    i32.const 3951296 ;; ABPackManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    i32.const 24
    i32.add
    i32.const 0
    call $j15949 ;; ABPackManager$$get_DaliyOffsetABIndex
    f64.convert_i32_s
    i32.const 0
    call $j4143 ;; System.DateTime$$AddDays
    i64.store offset=24
    local.get $p0
    i32.const 24
    i32.add
    i32.const 0
    call $j1527 ;; System.DateTime$$get_Year
    local.set $l1
    local.get $p0
    i32.const 24
    i32.add
    i32.const 0
    call $j1860 ;; System.DateTime$$get_Month
    local.set $l2
    local.get $p0
    i32.const 24
    i32.add
    i32.const 0
    call $j1861 ;; System.DateTime$$get_Day
    local.set $l3
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $l1
    local.get $l2
    local.get $l3
    i32.const 0
    call $j11341 ;; ConfigManager$$GetDaliyInfo
    local.set $l1
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=48
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    local.get $p0
    local.get $p0
    i32.const 24
    i32.add
    f64.const 0x1p+0 (;=1;)
    i32.const 0
    call $j4143 ;; System.DateTime$$AddDays
    i64.store offset=16
    local.get $p0
    i32.const 16
    i32.add
    i32.const 0
    call $j1527 ;; System.DateTime$$get_Year
    local.get $p0
    i32.const 16
    i32.add
    i32.const 0
    call $j1860 ;; System.DateTime$$get_Month
    local.get $p0
    i32.const 16
    i32.add
    i32.const 0
    call $j1861 ;; System.DateTime$$get_Day
    i32.const 0
    call $j11341 ;; ConfigManager$$GetDaliyInfo
    local.set $l1
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $l1
    i32.store offset=56
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=60
    i32.const 3984732 ;; Method$System.Collections.Generic.Dictionary<string, int>.Clear()
    i32.load
    call $j1200
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    i32.load8_u offset=167
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=60
      local.set $l1
      local.get $p0
      i32.const 1
      i32.store offset=12
      local.get $l1
      local.set $l4
      i32.const 3955516 ;; GameTypeEnum_TypeInfo
      i32.load
      local.set $l1
      local.get $p0
      i32.const -1
      i32.store offset=4
      local.get $p0
      local.get $l1
      i32.store
      local.get $p0
      local.get $p0
      i32.load offset=12
      i32.store offset=8
      local.get $l4
      local.get $p0
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=48
      i32.load offset=36
      i32.const 3984728 ;; Method$System.Collections.Generic.Dictionary<string, int>.Add()
      i32.load
      call $j1228
    end
    i32.const 0
    local.set $l1
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=48
      i32.load offset=28
      i32.load offset=12
      i32.eqz
      br_if $B2
      loop $L3
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        local.get $l1
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=48
        i32.load offset=28
        i32.load offset=12
        i32.ge_s
        br_if $B2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=60
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=48
        i32.load offset=28
        local.get $l1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
        i32.load
        call $j1040
        local.set $l4
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=60
        local.set $l2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=48
        i32.load offset=28
        local.get $l1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        local.set $l3
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=48
        i32.load offset=28
        local.get $l1
        i32.const 1
        i32.add
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 0
        call $j1292 ;; System.Int32$$Parse
        local.set $l5
        block $B4
          local.get $l4
          i32.eqz
          if $I5
            local.get $l2
            local.get $l3
            local.get $l5
            i32.const 3984728 ;; Method$System.Collections.Generic.Dictionary<string, int>.Add()
            i32.load
            call $j1228
            br $B4
          end
          local.get $l2
          local.get $l3
          local.get $l5
          i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
          i32.load
          call $j1858
        end
        local.get $l1
        i32.const 2
        i32.add
        local.set $l1
        br $L3
      end
      unreachable
    end
    i32.const 3953520 ;; DaliyRewardManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j47655 ;; DaliyRewardManager$$InitDaliyReward
    i32.const 3965720 ;; WxSdkTool_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 32
    i32.add
    global.set $primary.global$0)

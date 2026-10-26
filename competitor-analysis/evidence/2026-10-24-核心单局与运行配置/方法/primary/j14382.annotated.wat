  (func $j14382 (type $t11) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32) (param $p5 i32)
    (local $l6 i32) (local $l7 i32)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p5
    local.get $p5
    global.set $primary.global$0
    local.get $p5
    local.get $p3
    i32.store offset=40
    local.get $p5
    local.get $p2
    i32.store offset=44
    i32.const 5139793
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3953096 ;; ConfigManager_TypeInfo
      call $j922
      i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
      call $j922
      i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
      call $j922
      i32.const 3958620 ;; System.Math_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3961060 ;; ResGetWay_TypeInfo
      call $j922
      i32.const 3961124 ;; ResourcePosition_TypeInfo
      call $j922
      i32.const 3961140 ;; ResourceType_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 4080696 ;; Gold
      call $j922
      i32.const 4077848 ;; Energy
      call $j922
      i32.const 4073416 ;; Box
      call $j922
      i32.const 5139793
      i32.const 1
      i32.store8
    end
    local.get $p5
    i32.const 0
    i32.store offset=36
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j8813 ;; NetDataManager$$InitNewRes
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=28
    local.set $p2
    local.get $p2
    local.get $p0
    local.get $p2
    local.get $p0
    i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
    i32.load
    call $j1033
    local.get $p1
    i32.add
    i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
    i32.load
    call $j1858
    local.get $p0
    i32.const 4077848 ;; Energy
    i32.load
    i32.const 0
    call $j949 ;; System.String$$op_Equality
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=28
      local.set $l6
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=28
      local.get $p0
      i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
      i32.load
      call $j1033
      local.set $p3
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j6273 ;; ServerFileCreate$$GetFreeLevelCount
      local.set $p2
      i32.const 3958620 ;; System.Math_TypeInfo
      i32.load
      call $j923
      i32.const 5154302
      i32.load8_u
      i32.eqz
      if $I2
        i32.const 4029896 ;; Method$System.Math.ThrowMinMaxException<int>()
        call $j922
        i32.const 3958620 ;; System.Math_TypeInfo
        call $j922
        i32.const 5154302
        i32.const 1
        i32.store8
      end
      local.get $p2
      i32.const -1
      i32.le_s
      if $I3
        i32.const 3958620 ;; System.Math_TypeInfo
        i32.load
        call $j923
        i32.const 0
        local.get $p2
        i32.const 4029896 ;; Method$System.Math.ThrowMinMaxException<int>()
        i32.load
        i32.const 142103
        global.set $__wasm_split_waitTableId
        i32.const 142103
        call_indirect $primary.table (type $t2)
      end
      local.get $l6
      local.get $p0
      i32.const 0
      local.get $p2
      local.get $p3
      local.get $p2
      local.get $p3
      i32.lt_s
      select
      local.get $p3
      i32.const 0
      i32.lt_s
      select
      i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
      i32.load
      call $j1858
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=28
    local.get $p0
    i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
    i32.load
    call $j1033
    local.set $p3
    block $B4
      local.get $p1
      i32.const 1
      i32.lt_s
      br_if $B4
      block $B5
        local.get $p0
        i32.const 4080696 ;; Gold
        i32.load
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        i32.eqz
        if $I6
          local.get $p0
          i32.const 4073416 ;; Box
          i32.load
          i32.const 0
          call $j949 ;; System.String$$op_Equality
          i32.eqz
          br_if $B4
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          call $j923
          i32.const 3959288 ;; NetDataManager_TypeInfo
          i32.load
          i32.load offset=92
          i32.load offset=32
          i32.load offset=36
          i32.const 16
          i32.add
          local.set $p2
          br $B5
        end
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        i32.load offset=36
        i32.const 20
        i32.add
        local.set $p2
      end
      local.get $p2
      local.get $p1
      local.get $p2
      i32.load
      i32.add
      i32.store
    end
    local.get $p4
    if $I7
      i32.const 3958620 ;; System.Math_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 31
      i32.shr_s
      local.set $p2
      local.get $p1
      local.get $p2
      i32.add
      local.get $p2
      i32.xor
      local.set $p4
      i32.const 3961124 ;; ResourcePosition_TypeInfo
      i32.load
      local.set $l6
      local.get $p5
      i32.const 24
      i32.add
      local.set $p2
      local.get $p2
      i32.const -1
      i32.store offset=4
      local.get $p2
      local.get $l6
      i32.store
      local.get $p2
      local.get $p5
      i32.load offset=44
      i32.store offset=8
      local.get $p2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $l6
      i32.const 3961060 ;; ResGetWay_TypeInfo
      i32.load
      local.set $l7
      local.get $p5
      i32.const 8
      i32.add
      local.set $p2
      local.get $p2
      i32.const -1
      i32.store offset=4
      local.get $p2
      local.get $l7
      i32.store
      local.get $p2
      local.get $p5
      i32.load offset=40
      i32.store offset=8
      local.get $p2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      local.set $p2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      i32.gt_s
      local.get $p0
      local.get $p4
      local.get $l6
      local.get $p2
      local.get $p0
      call $j7299 ;; NetDataManager$$GetGameSumTime
      local.get $p3
      i32.const 0
      call $j19392 ;; ThinkingManager$$Resource
    end
    local.get $p5
    i32.const 20103
    i32.store offset=36
    i32.const 3961140 ;; ResourceType_TypeInfo
    i32.load
    local.set $p3
    local.get $p5
    i32.const 24
    i32.add
    local.set $p2
    local.get $p2
    i32.const -1
    i32.store offset=4
    local.get $p2
    local.get $p3
    i32.store
    local.get $p2
    local.get $p5
    i32.load offset=36
    i32.store offset=8
    block $B8
      local.get $p0
      local.get $p2
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      i32.eqz
      br_if $B8
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=88
      local.set $p2
      local.get $p2
      i32.eqz
      br_if $B8
      local.get $p2
      i32.const 20103
      i32.const 0
      call $j1561
    end
    i32.const 3953096 ;; ConfigManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    i32.const 0
    call $j4792 ;; ConfigManager$$GetItemData
    local.set $p0
    local.get $p0
    if $I9
      local.get $p0
      i32.load offset=8
      local.set $p0
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      local.get $p1
      i32.const 0
      call $j15938 ;; ActionManager$$TriggerAddToolEvent
    end
    local.get $p5
    i32.const 48
    i32.add
    global.set $primary.global$0)

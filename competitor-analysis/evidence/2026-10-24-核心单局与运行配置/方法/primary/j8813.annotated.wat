  (func $j8813 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5139794
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3984728 ;; Method$System.Collections.Generic.Dictionary<string, int>.Add()
      call $j922
      i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
      call $j922
      i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3961140 ;; ResourceType_TypeInfo
      call $j922
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 5139794
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=28
      local.get $p0
      i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
      i32.load
      call $j1040
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=28
      local.get $p0
      i32.const 0
      i32.const 3984728 ;; Method$System.Collections.Generic.Dictionary<string, int>.Add()
      i32.load
      call $j1228
      local.get $p1
      i32.const 20103
      i32.store offset=12
      i32.const 3961140 ;; ResourceType_TypeInfo
      i32.load
      local.set $l2
      local.get $p1
      i32.const -1
      i32.store offset=4
      local.get $p1
      local.get $l2
      i32.store
      local.get $p1
      local.get $p1
      i32.load offset=12
      i32.store offset=8
      local.get $p0
      local.get $p1
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=32
        i32.load offset=28
        local.set $l2
        i32.const 3961880 ;; ServerFileCreate_TypeInfo
        i32.load
        call $j923
        local.get $l2
        local.get $p0
        i32.const 0
        call $j6273 ;; ServerFileCreate$$GetFreeLevelCount
        i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
        i32.load
        call $j1858
        br $B1
      end
      local.get $p1
      i32.const 20104
      i32.store offset=12
      i32.const 3961140 ;; ResourceType_TypeInfo
      i32.load
      local.set $l2
      local.get $p1
      i32.const -1
      i32.store offset=4
      local.get $p1
      local.get $l2
      i32.store
      local.get $p1
      local.get $p1
      i32.load offset=12
      i32.store offset=8
      local.get $p0
      local.get $p1
      i32.const 0
      call $j1009 ;; System.Enum$$ToString
      i32.const 0
      call $j949 ;; System.String$$op_Equality
      i32.eqz
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=28
      local.set $l2
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      i32.load
      call $j923
      local.get $l2
      local.get $p0
      i32.const 0
      call $j8554 ;; ServerFileCreate$$GetOnlineBaseFreeCount
      i32.const 3984760 ;; Method$System.Collections.Generic.Dictionary<string, int>.set_Item()
      i32.load
      call $j1858
    end
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)

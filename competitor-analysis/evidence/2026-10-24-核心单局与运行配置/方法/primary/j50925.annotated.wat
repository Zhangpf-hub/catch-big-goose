  (func $j50925 (type $t10) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result i32)
    (local $l4 i32) (local $l5 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5140279
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
      call $j922
      i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
      call $j922
      i32.const 3983488 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Count()
      call $j922
      i32.const 3983492 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Item()
      call $j922
      i32.const 3985772 ;; Method$System.Collections.Generic.Dictionary<string, string>.get_Item()
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4123352 ;; 无该AB String数据:
      call $j922
      i32.const 4127388 ;; ：
      call $j922
      i32.const 4071664 ;; AB测试数值
      call $j922
      i32.const 4067492 ;; ,
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 4126044 ;; 该AB String为空:
      call $j922
      i32.const 5140279
      i32.const 1
      i32.store8
    end
    local.get $p3
    i32.const 0
    i32.store offset=12
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j4064 ;; NetInitManager$$GetExData
    drop
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.eqz
      br_if $B1
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3983488 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Count()
      i32.load
      drop
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l4
      local.get $l4
      i32.load offset=16
      local.get $l4
      i32.load offset=24
      i32.sub
      i32.const 1
      i32.lt_s
      br_if $B1
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.get $p0
      i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
      i32.load
      call $j1040
      i32.eqz
      if $I2
        i32.const 4123352 ;; 无该AB String数据:
        i32.load
        local.get $p0
        i32.const 0
        call $j962 ;; System.String$$Concat
        local.set $p1
        i32.const 4063796 ;; 
        i32.load
        local.set $p0
        local.get $p1
        local.get $p0
        local.get $p0
        local.get $p0
        local.get $p0
        local.get $p0
        local.get $p3
        call $j1120 ;; GameManager$$StringAppend
        local.set $p0
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 0
        call $j1075 ;; UnityEngine.Debug$$LogWarning
        br $B1
      end
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.get $p0
      i32.const 3983492 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Item()
      i32.load
      call $j1033
      i32.load offset=32
      local.set $l4
      block $B3
        local.get $l4
        if $I4
          i32.const 0
          local.set $l5
          local.get $l4
          i32.load offset=8
          br_if $B3
        end
        i32.const 1
        local.set $l5
      end
      local.get $l5
      if $I5
        i32.const 4126044 ;; 该AB String为空:
        i32.load
        local.get $p0
        i32.const 0
        call $j962 ;; System.String$$Concat
        local.set $p1
        i32.const 4063796 ;; 
        i32.load
        local.set $p0
        local.get $p1
        local.get $p0
        local.get $p0
        local.get $p0
        local.get $p0
        local.get $p0
        local.get $p3
        call $j1120 ;; GameManager$$StringAppend
        local.set $p0
        i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
        i32.load
        call $j923
        local.get $p0
        i32.const 0
        call $j1075 ;; UnityEngine.Debug$$LogWarning
        br $B1
      end
      local.get $l4
      i32.const 4067492 ;; ,
      i32.load
      i32.const 0
      i32.const 0
      call $j3149 ;; System.String$$Split
      local.set $p0
      local.get $p0
      i32.load offset=12
      local.get $p1
      i32.le_s
      br_if $B1
      local.get $p0
      local.get $p1
      i32.const 2
      i32.shl
      i32.add
      i32.load offset=16
      local.get $p3
      i32.const 12
      i32.add
      i32.const 0
      call $j1399 ;; System.Int32$$TryParse
      local.set $p0
      local.get $p3
      i32.load offset=12
      local.get $p2
      local.get $p0
      select
      local.set $p2
    end
    local.get $p3
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p2
    return)

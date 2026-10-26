  (func $j110200 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140278
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3984736 ;; Method$System.Collections.Generic.Dictionary<string, int>.ContainsKey()
      call $j922
      i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
      call $j922
      i32.const 3983488 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Count()
      call $j922
      i32.const 3983492 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Item()
      call $j922
      i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
      call $j922
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4123364 ;; 无该int数据:
      call $j922
      i32.const 4071668 ;; AB测试数值{0}：{1}
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5140278
      i32.const 1
      i32.store8
    end
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
      local.set $l3
      local.get $l3
      i32.load offset=16
      local.get $l3
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
      if $I2
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
        i32.load offset=24
        local.set $p1
        br $B1
      end
      i32.const 4123364 ;; 无该int数据:
      i32.load
      local.get $p0
      i32.const 0
      call $j962 ;; System.String$$Concat
      local.set $l3
      i32.const 4063796 ;; 
      i32.load
      local.set $p0
      local.get $l3
      local.get $p0
      local.get $p0
      local.get $p0
      local.get $p0
      local.get $p0
      local.get $p0
      call $j1120 ;; GameManager$$StringAppend
      local.set $p0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.const 0
      call $j1075 ;; UnityEngine.Debug$$LogWarning
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0
    local.get $p1
    return)

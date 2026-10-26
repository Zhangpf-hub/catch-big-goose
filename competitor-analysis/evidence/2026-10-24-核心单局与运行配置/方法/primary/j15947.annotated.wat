  (func $j15947 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140277
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
      call $j922
      i32.const 3985772 ;; Method$System.Collections.Generic.Dictionary<string, string>.get_Item()
      call $j922
      i32.const 4071660 ;; AB测试实际分组 
      call $j922
      i32.const 4070568 ;; :
      call $j922
      i32.const 5140277
      i32.const 1
      i32.store8
    end
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=4
    local.get $p0
    i32.const 3985748 ;; Method$System.Collections.Generic.Dictionary<string, string>.ContainsKey()
    i32.load
    call $j1040
    if $I1
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=4
      local.get $p0
      i32.const 3985772 ;; Method$System.Collections.Generic.Dictionary<string, string>.get_Item()
      i32.load
      call $j1033
      local.set $p1
      i32.const 2
      i32.const 4071660 ;; AB测试实际分组 
      i32.load
      local.get $p0
      i32.const 4070568 ;; :
      i32.load
      local.get $p1
      i32.const 0
      call $j1151 ;; System.String$$Concat
      local.get $p0
      call $j1429 ;; GameManager$$LogInColor
      local.get $p0
      local.get $p1
      i32.const 0
      call $j35741 ;; ThinkingManager$$SetRealABTestFeature
    end)

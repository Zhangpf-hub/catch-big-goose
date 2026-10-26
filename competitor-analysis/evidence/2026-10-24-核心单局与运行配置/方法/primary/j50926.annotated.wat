  (func $j50926 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32)
    i32.const 5140275
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 4017088 ;; Method$System.Array.IndexOf<string>()
      call $j922
      i32.const 3983480 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.ContainsKey()
      call $j922
      i32.const 3983492 ;; Method$System.Collections.Generic.Dictionary<string, ABTestDataData>.get_Item()
      call $j922
      i32.const 4111716 ;; noABKey
      call $j922
      i32.const 5140275
      i32.const 1
      i32.store8
    end
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j11647 ;; ABTestManager$$GetFeatureType
    local.set $p2
    block $B1
      local.get $p2
      i32.const 4111716 ;; noABKey
      i32.load
      i32.const 0
      call $j949 ;; System.String$$op_Equality
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
      br_if $B1
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
      i32.load offset=16
      local.set $l3
      local.get $l3
      i32.eqz
      br_if $B1
      local.get $l3
      local.get $p2
      i32.const 4017088 ;; Method$System.Array.IndexOf<string>()
      i32.load
      call $j2987
      local.set $p2
      local.get $p2
      i32.const 0
      i32.lt_s
      br_if $B1
      i32.const 3951300 ;; ABTestManager_TypeInfo
      i32.load
      call $j923
      local.get $p0
      local.get $p2
      local.get $p1
      local.get $p0
      call $j50925 ;; ABTestManager$$GetABListIntVar
      local.set $p1
    end
    local.get $p1
    return)

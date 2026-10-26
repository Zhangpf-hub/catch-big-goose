  (func $j2670 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 0
    local.set $p1
    i32.const 5139645
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3985608 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.ContainsKey()
      call $j922
      i32.const 3985612 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.get_Item()
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 5139645
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      local.get $p0
      i32.const 0
      call $j5052 ;; SpLevelManager$$IsCurSpLevelSign
      i32.eqz
      br_if $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=48
      i32.eqz
      br_if $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=48
      local.get $p0
      i32.const 3985608 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.ContainsKey()
      i32.load
      call $j1040
      i32.eqz
      br_if $B1
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      call $j923
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load offset=48
      local.get $p0
      i32.const 3985612 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelWindowData>.get_Item()
      i32.load
      call $j1033
      local.set $p1
    end
    local.get $p1
    return)

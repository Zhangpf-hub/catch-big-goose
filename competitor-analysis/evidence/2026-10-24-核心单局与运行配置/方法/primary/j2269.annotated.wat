  (func $j2269 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32)
    i32.const 5139647
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3985596 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>.Add()
      call $j922
      i32.const 3985600 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>.ContainsKey()
      call $j922
      i32.const 3985592 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>..ctor()
      call $j922
      i32.const 3985604 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>.get_Item()
      call $j922
      i32.const 3942568 ;; System.Collections.Generic.Dictionary<string, SpLevelSaveData>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 3962320 ;; SpLevelSaveData_TypeInfo
      call $j922
      i32.const 5139647
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j5052 ;; SpLevelManager$$IsCurSpLevelSign
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 5142651
      i32.load8_u
      i32.eqz
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        call $j922
        i32.const 5142651
        i32.const 1
        i32.store8
      end
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      local.set $l2
      local.get $l2
      local.set $p1
      local.get $l2
      i32.load offset=180
      local.set $l2
      local.get $l2
      i32.eqz
      if $I3
        i32.const 3942568 ;; System.Collections.Generic.Dictionary<string, SpLevelSaveData>_TypeInfo
        i32.load
        call $j924
        local.set $l2
        local.get $l2
        i32.const 3985592 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>..ctor()
        i32.load
        call $j967
        local.get $p1
        local.get $l2
        i32.store offset=180
        local.get $p1
        i32.load offset=180
        local.set $l2
      end
      local.get $l2
      local.get $p0
      i32.const 3985600 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>.ContainsKey()
      i32.load
      call $j1040
      local.set $l3
      local.get $p1
      i32.load offset=180
      local.set $l2
      local.get $l3
      i32.eqz
      if $I4
        local.get $l2
        local.get $p0
        i32.const 3962320 ;; SpLevelSaveData_TypeInfo
        i32.load
        call $j924
        i32.const 3985596 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>.Add()
        i32.load
        call $j953
        local.get $p1
        i32.load offset=180
        local.set $l2
      end
      local.get $l2
      local.get $p0
      i32.const 3985604 ;; Method$System.Collections.Generic.Dictionary<string, SpLevelSaveData>.get_Item()
      i32.load
      call $j1033
      local.set $p0
    else
      i32.const 0
      local.set $p0
    end
    local.get $p0
    return)

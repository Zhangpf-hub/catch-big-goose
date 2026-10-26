  (func $j72226 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5134509
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3988140 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>.TryAdd()
      call $j922
      i32.const 3988124 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.get_Item()
      call $j922
      i32.const 3988128 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.set_Item()
      call $j922
      i32.const 3988116 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>.set_Item()
      call $j922
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 5134509
      i32.const 1
      i32.store8
    end
    i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
    i32.load
    call $j923
    local.get $p1
    i32.const 0
    call $j1163 ;; LitJson.JsonMapper$$ToJson
    local.set $p1
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j1600 ;; NetInitManager$$CanShowSEventDetail
    if $I1
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j1051 ;; UnityEngine.Debug$$Log
    end
    i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
    i32.load
    call $j923
    local.get $p2
    i32.load offset=16
    i32.load offset=96
    i32.load
    i32.load
    local.get $p2
    i32.load offset=16
    i32.load offset=96
    i32.load
    i32.const 0
    local.get $p1
    call $j1044
    local.set $p1
    local.get $p0
    i32.load offset=8
    i32.load offset=108
    local.get $p0
    i32.load offset=12
    local.get $p1
    i32.const 3988140 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>.TryAdd()
    i32.load
    call $j11247
    drop
    local.get $p0
    i32.load offset=8
    i32.load offset=116
    local.get $p0
    i32.load offset=12
    i32.const 3988124 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.get_Item()
    i32.load
    call $j1068
    local.get $p2
    i32.load offset=16
    i32.load offset=96
    i32.const 3
    call $j926
    call $j1035
    local.set $l3
    local.get $l3
    if $I2
      local.get $p2
      i32.load offset=16
      i32.load offset=96
      i32.load offset=16
      i32.load
      local.get $p2
      i32.load offset=16
      i32.load offset=96
      i32.load offset=16
      local.get $l3
      i32.const 1
      local.get $p1
      call $j5174
    end
    local.get $p0
    i32.load offset=8
    i32.load offset=116
    local.get $p0
    i32.load offset=12
    i32.const 0
    i32.const 3988128 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.set_Item()
    i32.load
    call $j1608
    local.get $p0
    i32.load offset=8
    i32.load offset=112
    local.get $p0
    i32.load offset=12
    i32.const 0
    i32.const 3988116 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>.set_Item()
    i32.load
    call $j23503)

  (func $j72225 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5134510
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
      call $j922
      i32.const 3988124 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.get_Item()
      call $j922
      i32.const 3988128 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.set_Item()
      call $j922
      i32.const 3988116 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>.set_Item()
      call $j922
      i32.const 3971056 ;; ServerFileCreate.ServerConfigType_TypeInfo
      call $j922
      i32.const 4125452 ;; 获取cdn配置表 {0} 失败
      call $j922
      i32.const 5134510
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 0
    i32.store offset=12
    local.get $p1
    local.get $p0
    i32.load offset=12
    i32.store offset=8
    i32.const 3971056 ;; ServerFileCreate.ServerConfigType_TypeInfo
    i32.load
    local.get $p1
    i32.const 8
    i32.add
    call $j935
    local.set $l3
    i32.const 4125452 ;; 获取cdn配置表 {0} 失败
    i32.load
    local.get $l3
    i32.const 0
    call $j1006 ;; System.String$$Format
    local.set $l3
    i32.const 3953888 ;; UnityEngine.Debug_TypeInfo
    i32.load
    call $j923
    local.get $l3
    i32.const 0
    call $j1050 ;; UnityEngine.Debug$$LogError
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
    if $I1
      local.get $p1
      i32.const 12
      i32.add
      i32.const 4
      call $j948
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
      i32.const 0
      local.get $p1
      i32.load offset=12
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
    call $j23503
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)

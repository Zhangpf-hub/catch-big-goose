  (func $j38172 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32) (local $l5 i32) (local $l6 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l5
    local.get $l5
    global.set $primary.global$0
    local.get $p3
    i32.load offset=28
    i32.eqz
    if $I0
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      call $j922
      i32.const 3939460 ;; System.Action<string>_TypeInfo
      call $j922
      i32.const 4020036 ;; Method$System.Collections.Generic.CollectionExtensions.GetValueOrDefault<ServerFileCreate.ServerConfigType, Delegate>()
      call $j922
      i32.const 3988136 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>.ContainsKey()
      call $j922
      i32.const 3988112 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>.TryGetValue()
      call $j922
      i32.const 3988144 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>.get_Item()
      call $j922
      i32.const 3988128 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.set_Item()
      call $j922
      i32.const 3988116 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>.set_Item()
      call $j922
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      call $j922
      i32.const 3971056 ;; ServerFileCreate.ServerConfigType_TypeInfo
      call $j922
      i32.const 4103956 ;; cdn配置表 {0}
      call $j922
      local.get $p3
      call $j978
    end
    local.get $l5
    i32.const 0
    i32.store8 offset=15
    local.get $p3
    i32.load offset=28
    i32.const 0
    call $j926
    call $j924
    local.set $l4
    local.get $p3
    i32.load offset=28
    i32.load offset=4
    local.set $l6
    local.get $p3
    i32.load offset=28
    i32.load offset=4
    i32.load
    local.get $l6
    local.get $l4
    i32.const 0
    i32.const 0
    local.get $l6
    i32.load offset=8
    global.set $__wasm_split_waitTableId
    global.get $__wasm_split_waitTableId
    call_indirect $primary.table (type $t8)
    local.get $l4
    local.get $p0
    i32.store offset=8
    local.get $l4
    local.get $p1
    i32.store offset=12
    block $B1
      local.get $p0
      i32.load offset=108
      local.get $p1
      i32.const 3988136 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>.ContainsKey()
      i32.load
      call $j1084
      if $I2
        local.get $p2
        i32.eqz
        br_if $B1
        local.get $p0
        i32.load offset=108
        local.get $l4
        i32.load offset=12
        i32.const 3988144 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, object>.get_Item()
        i32.load
        call $j1068
        local.set $p0
        local.get $p3
        i32.load offset=28
        i32.load offset=16
        i32.load
        local.get $p3
        i32.load offset=28
        i32.load offset=16
        local.get $p2
        i32.const 1
        local.get $p0
        local.get $p3
        i32.load offset=28
        i32.const 3
        call $j926
        call $j966
        call $j5174
        br $B1
      end
      local.get $p0
      i32.load offset=116
      local.get $l4
      i32.load offset=12
      i32.const 4020036 ;; Method$System.Collections.Generic.CollectionExtensions.GetValueOrDefault<ServerFileCreate.ServerConfigType, Delegate>()
      i32.load
      call $j11398
      local.set $p1
      local.get $p0
      i32.load offset=116
      local.get $l4
      i32.load offset=12
      local.get $p1
      local.get $p2
      i32.const 0
      call $j1045 ;; System.Delegate$$Combine
      i32.const 3988128 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, Delegate>.set_Item()
      i32.load
      call $j1608
      local.get $p0
      i32.load offset=112
      local.get $l4
      i32.load offset=12
      local.get $l5
      i32.const 15
      i32.add
      i32.const 3988112 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>.TryGetValue()
      i32.load
      call $j1164
      if $I3
        local.get $l5
        i32.load8_u offset=15
        br_if $B1
      end
      local.get $p0
      local.get $l4
      i32.load offset=12
      i32.const 0
      call $j38177 ;; ServerFileCreate$$GetServerConfigUrl
      local.set $p1
      local.get $p0
      i32.load offset=112
      local.get $l4
      i32.load offset=12
      i32.const 1
      i32.const 3988116 ;; Method$System.Collections.Generic.Dictionary<ServerFileCreate.ServerConfigType, bool>.set_Item()
      i32.load
      call $j23503
      i32.const 3939192 ;; System.Action<JsonData>_TypeInfo
      i32.load
      call $j924
      local.set $p0
      local.get $p0
      local.get $l4
      local.get $p3
      i32.load offset=28
      i32.load offset=20
      i32.const 0
      call $j969
      i32.const 3939460 ;; System.Action<string>_TypeInfo
      i32.load
      call $j924
      local.set $p2
      local.get $p2
      local.get $l4
      local.get $p3
      i32.load offset=28
      i32.load offset=24
      i32.const 0
      call $j969
      local.get $l5
      local.get $l4
      i32.load offset=12
      i32.store offset=8
      i32.const 3971056 ;; ServerFileCreate.ServerConfigType_TypeInfo
      i32.load
      local.get $l5
      i32.const 8
      i32.add
      call $j935
      local.set $p3
      i32.const 4103956 ;; cdn配置表 {0}
      i32.load
      local.get $p3
      i32.const 0
      call $j1006 ;; System.String$$Format
      local.set $p3
      i32.const 3959332 ;; NetworkHelper_TypeInfo
      i32.load
      call $j923
      local.get $p1
      local.get $p0
      local.get $p2
      i32.const 3
      local.get $p3
      i32.const 0
      i32.const 0
      call $j3469 ;; NetworkHelper$$GetServerFile
    end
    local.get $l5
    i32.const 16
    i32.add
    global.set $primary.global$0)

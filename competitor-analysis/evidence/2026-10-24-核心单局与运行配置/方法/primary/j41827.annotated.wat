  (func $j41827 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i64) (local $l5 i32) (local $l6 i32)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    local.get $p3
    local.get $p0
    i32.store offset=44
    i32.const 5139760
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983428 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>.Add()
      call $j922
      i32.const 3983436 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>.ContainsKey()
      call $j922
      i32.const 3983448 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>.set_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 4015460 ;; Method$System.ValueTuple<int, int>..ctor()
      call $j922
      i32.const 5139760
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p3
    local.get $p3
    call $j21666 ;; NetDataManager$$CheckRelation
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=40
    local.get $p3
    i32.const 44
    i32.add
    i32.const 0
    call $j1012 ;; System.Int32$$ToString
    i32.const 3983436 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>.ContainsKey()
    i32.load
    call $j1040
    local.set $l6
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=40
    local.set $p0
    local.get $p3
    i32.const 44
    i32.add
    i32.const 0
    call $j1012 ;; System.Int32$$ToString
    local.set $l5
    block $B1
      local.get $l6
      if $I2
        local.get $p3
        i64.const 0
        i64.store offset=32
        local.get $p3
        i32.const 32
        i32.add
        local.get $p1
        local.get $p2
        i32.const 4015460 ;; Method$System.ValueTuple<int, int>..ctor()
        i32.load
        call $j3063
        local.get $p3
        i64.load offset=32
        local.set $l4
        local.get $p3
        local.get $l4
        i64.store offset=24
        local.get $p3
        local.get $l4
        i64.store
        local.get $p0
        local.get $l5
        local.get $p3
        i32.const 3983448 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>.set_Item()
        i32.load
        call $j1070
        br $B1
      end
      local.get $p3
      i64.const 0
      i64.store offset=32
      local.get $p3
      i32.const 32
      i32.add
      local.get $p1
      local.get $p2
      i32.const 4015460 ;; Method$System.ValueTuple<int, int>..ctor()
      i32.load
      call $j3063
      local.get $p3
      i64.load offset=32
      local.set $l4
      local.get $p3
      local.get $l4
      i64.store offset=16
      local.get $p3
      local.get $l4
      i64.store offset=8
      local.get $p0
      local.get $l5
      local.get $p3
      i32.const 8
      i32.add
      i32.const 3983428 ;; Method$System.Collections.Generic.Dictionary<string, ValueTuple<int, int>>.Add()
      i32.load
      call $j953
    end
    local.get $p3
    i32.const 48
    i32.add
    global.set $primary.global$0)

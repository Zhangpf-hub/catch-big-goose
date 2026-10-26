  (func $j43528 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    (local $l4 i64) (local $l5 i32)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p3
    local.get $p3
    global.set $primary.global$0
    i32.const 5140089
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3994400 ;; Method$System.Collections.Generic.HashSet<string>.Add()
      call $j922
      i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
      call $j922
      i32.const 3950280 ;; LevelObjStruct[]_TypeInfo
      call $j922
      i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
      call $j922
      i32.const 5140089
      i32.const 1
      i32.store8
    end
    local.get $p3
    i64.const 0
    i64.store offset=40
    i32.const 6
    i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
    i32.load
    local.get $p0
    i32.load offset=384
    local.get $p1
    local.get $p2
    call $j1181
    i32.const 21
    i32.const 3956632 ;; IGameModeLevelCtrl_TypeInfo
    i32.load
    local.get $p0
    i32.load offset=384
    call $j951
    local.set $p1
    local.get $p0
    local.get $p1
    i32.store offset=200
    local.get $p0
    local.get $p1
    i32.store offset=196
    local.get $p0
    i32.load offset=380
    local.set $p1
    local.get $p1
    i32.load offset=24
    i32.const 0
    i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
    i32.load
    call $j947
    local.set $p2
    local.get $p1
    i32.const 3950280 ;; LevelObjStruct[]_TypeInfo
    i32.load
    local.get $p2
    i32.load offset=28
    i32.load offset=12
    call $j939
    i32.store offset=12
    local.get $p0
    i32.load offset=380
    local.set $p1
    local.get $p1
    i32.const 3950280 ;; LevelObjStruct[]_TypeInfo
    i32.load
    local.get $p1
    i32.load offset=12
    i32.load offset=12
    call $j939
    i32.store offset=20
    i32.const 0
    local.set $p1
    loop $L1
      local.get $p0
      i32.load offset=380
      i32.load offset=12
      i32.load offset=12
      local.get $p1
      i32.gt_s
      if $I2
        local.get $p3
        i32.const 40
        i32.add
        i32.const 8
        call $j948
        local.get $p0
        i32.load offset=380
        i32.load offset=24
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=24
        local.set $p2
        local.get $p3
        local.get $p2
        local.get $p0
        i32.load offset=380
        i32.load offset=24
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=28
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 1
        i32.sub
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.store offset=40
        local.get $p3
        local.get $p0
        i32.load offset=380
        i32.load offset=24
        i32.const 0
        i32.const 4001968 ;; Method$System.Collections.Generic.List<LevelDataData>.get_Item()
        i32.load
        call $j947
        i32.load offset=32
        local.get $p1
        i32.const 2
        i32.shl
        i32.add
        i32.load offset=16
        i32.store offset=44
        local.get $p0
        i32.load offset=380
        i32.load offset=12
        local.set $p2
        local.get $p3
        i64.load offset=40
        local.set $l4
        local.get $p3
        local.get $l4
        i64.store offset=32
        local.get $p3
        local.get $l4
        i64.store offset=8
        local.get $p2
        local.get $p1
        i32.const 3
        i32.shl
        i32.add
        local.get $p3
        i32.load offset=8
        i64.extend_i32_u
        local.get $p3
        i32.load offset=12
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        i64.store offset=16
        local.get $p0
        i32.load offset=380
        local.set $p2
        local.get $p2
        i32.load offset=20
        local.set $l5
        local.get $p2
        i32.load offset=12
        local.get $p1
        i32.const 3
        i32.shl
        i32.add
        i64.load offset=16
        local.set $l4
        local.get $p3
        local.get $l4
        i32.wrap_i64
        i32.store offset=24
        local.get $p3
        local.get $l4
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        i32.store offset=28
        local.get $p3
        i64.load offset=24
        local.set $l4
        local.get $p3
        local.get $l4
        i64.store offset=16
        local.get $p3
        local.get $l4
        i64.store
        local.get $l5
        local.get $p1
        i32.const 3
        i32.shl
        i32.add
        local.get $p3
        i32.load
        i64.extend_i32_u
        local.get $p3
        i32.load offset=4
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        i64.store offset=16
        local.get $p0
        i32.load offset=380
        local.set $p2
        local.get $p2
        i32.load offset=16
        local.get $p2
        i32.load offset=12
        local.get $p1
        i32.const 3
        i32.shl
        i32.add
        i32.load offset=16
        i32.const 3994400 ;; Method$System.Collections.Generic.HashSet<string>.Add()
        i32.load
        call $j1061
        drop
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $p3
    i32.const 48
    i32.add
    global.set $primary.global$0)

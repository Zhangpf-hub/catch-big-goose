  (func $j7379 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i64) (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140040
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3982128 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.TryGetValue()
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 5140040
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 0
    i32.store offset=28
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    call $j923
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    local.set $l3
    local.get $p0
    i32.load
    i64.extend_i32_u
    local.get $p0
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    local.set $l2
    local.get $p1
    local.get $l2
    i64.store offset=16
    local.get $p1
    local.get $l2
    i64.store offset=8
    local.get $l3
    local.get $p1
    i32.const 8
    i32.add
    local.get $p1
    i32.const 28
    i32.add
    i32.const 3982128 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.TryGetValue()
    i32.load
    call $j1052
    if $I1
      local.get $p1
      i32.load offset=28
      i32.load8_u offset=24
      i32.const 0
      i32.ne
      local.set $l4
    end
    local.get $p1
    i32.const 32
    i32.add
    global.set $primary.global$0
    local.get $l4
    return)

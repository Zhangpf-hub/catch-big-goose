  (func $j5156 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i64) (local $l3 i64) (local $l4 i32)
    global.get $primary.global$0
    i32.const -64
    i32.add
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140037
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3982128 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.TryGetValue()
      call $j922
      i32.const 3982132 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.set_Item()
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 3958044 ;; LevelLoader_TypeInfo
      call $j922
      i32.const 5140037
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 0
    i32.store offset=60
    local.get $p0
    local.get $p1
    call $j4381 ;; LevelIndexAndType$$get_IsExist
    if $I1
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      i32.load
      call $j923
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      local.set $l4
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
      i64.store offset=48
      local.get $p1
      local.get $l2
      i64.store offset=24
      local.get $l4
      local.get $p1
      i32.const 24
      i32.add
      local.get $p1
      i32.const 60
      i32.add
      i32.const 3982128 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.TryGetValue()
      i32.load
      call $j1052
      i32.eqz
      if $I2
        i32.const 3958044 ;; LevelLoader_TypeInfo
        i32.load
        call $j924
        local.set $p0
        local.get $p1
        local.get $l2
        i64.store offset=16
        local.get $p1
        local.get $l2
        i64.store offset=40
        local.get $p1
        i32.load offset=16
        i64.extend_i32_u
        local.get $p1
        i32.load offset=20
        i64.extend_i32_u
        i64.const 32
        i64.shl
        i64.or
        local.set $l3
        local.get $p0
        local.get $l3
        i32.wrap_i64
        i32.store offset=8
        local.get $p0
        local.get $l3
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        i32.store offset=12
        local.get $p1
        local.get $p0
        i32.store offset=60
        i32.const 3958048 ;; LevelLoaderManager_TypeInfo
        i32.load
        call $j923
        i32.const 3958048 ;; LevelLoaderManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $p0
        local.get $p1
        local.get $l2
        i64.store offset=32
        local.get $p1
        local.get $l2
        i64.store offset=8
        local.get $p0
        local.get $p1
        i32.const 8
        i32.add
        local.get $p1
        i32.load offset=60
        i32.const 3982132 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>.set_Item()
        i32.load
        call $j1070
      end
      local.get $p1
      i32.load offset=60
      local.set $l4
    end
    local.get $p1
    i32.const -64
    i32.sub
    global.set $primary.global$0
    local.get $l4
    return)

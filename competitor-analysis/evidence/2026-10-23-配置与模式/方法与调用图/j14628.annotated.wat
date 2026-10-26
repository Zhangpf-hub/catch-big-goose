  (func $j14628 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i64)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140038
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 5140038
      i32.const 1
      i32.store8
    end
    local.get $p2
    i64.const 0
    i64.store offset=24
    local.get $p2
    local.get $p1
    i32.store offset=28
    local.get $p2
    local.get $p0
    i32.store offset=24
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    call $j923
    local.get $p2
    i64.load offset=24
    local.set $l3
    local.get $p2
    local.get $l3
    i64.store offset=16
    local.get $p2
    local.get $l3
    i64.store offset=8
    local.get $p2
    i32.const 8
    i32.add
    local.get $p2
    call $j5156 ;; LevelLoaderManager$$GetLevelLoader
    local.set $p0
    local.get $p2
    i32.const 32
    i32.add
    global.set $primary.global$0
    local.get $p0
    return)

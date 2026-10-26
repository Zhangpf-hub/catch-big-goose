  (func $j43492 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i64) (local $l4 i32)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5127117
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3994404 ;; Method$System.Collections.Generic.HashSet<string>.Clear()
      call $j922
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 3958036 ;; LevelIndexAndType_TypeInfo
      call $j922
      i32.const 4118780 ;; {0} is not exist
      call $j922
      i32.const 5127117
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.const 0
    call $j4381 ;; LevelIndexAndType$$get_IsExist
    local.set $l4
    local.get $p1
    i32.load
    i64.extend_i32_u
    local.get $p1
    i32.load offset=4
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.or
    local.set $l3
    block $B1
      local.get $l4
      i32.eqz
      if $I2
        local.get $p2
        local.get $l3
        i64.store offset=24
        i32.const 3958036 ;; LevelIndexAndType_TypeInfo
        i32.load
        local.get $p2
        i32.const 24
        i32.add
        call $j935
        local.set $p0
        i32.const 4118780 ;; {0} is not exist
        i32.load
        local.get $p0
        i32.const 0
        call $j1006 ;; System.String$$Format
        i32.const 0
        i32.const 0
        call $j1229 ;; Kunpo.Debugger$$LogError
        br $B1
      end
      local.get $p0
      i32.load offset=16
      local.set $p1
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      i32.load
      call $j923
      local.get $p2
      local.get $l3
      i64.store offset=8
      local.get $p2
      local.get $l3
      i64.store offset=16
      local.get $p2
      i32.const 8
      i32.add
      local.get $p1
      i32.const 0
      call $j22267 ;; LevelDataHelper$$AddLevelObjNameListToSet
      local.get $p0
      local.get $p0
      i32.load offset=16
      local.get $p2
      call $j43494 ;; LevelObjectPool$$ClearByExclusion
      local.get $p0
      i32.load offset=16
      i32.const 3994404 ;; Method$System.Collections.Generic.HashSet<string>.Clear()
      i32.load
      call $j1524
    end
    local.get $p2
    i32.const 32
    i32.add
    global.set $primary.global$0)

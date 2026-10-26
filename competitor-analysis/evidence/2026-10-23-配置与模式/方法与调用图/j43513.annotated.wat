  (func $j43513 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5140129
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003040 ;; Method$System.Collections.Generic.List<ObjectUnit>.Contains()
      call $j922
      i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 3997932 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Count()
      call $j922
      i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
      call $j922
      i32.const 5140129
      i32.const 1
      i32.store8
    end
    i32.const 0
    local.set $p2
    loop $L1
      block $B2
        i32.const 3997932 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Count()
        i32.load
        drop
        local.get $p2
        local.get $p0
        i32.load offset=624
        i32.load offset=12
        i32.ge_s
        br_if $B2
        local.get $p0
        i32.load offset=624
        local.get $p2
        i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
        i32.load
        call $j947
        local.set $l3
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        block $B3
          local.get $l3
          i32.load offset=12
          i32.const 1
          i32.lt_s
          br_if $B3
          local.get $p0
          i32.load offset=624
          local.get $p2
          i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
          i32.load
          call $j947
          local.get $p1
          i32.const 4003040 ;; Method$System.Collections.Generic.List<ObjectUnit>.Contains()
          i32.load
          call $j1262
          i32.eqz
          br_if $B3
          local.get $p0
          i32.load offset=624
          local.get $p2
          i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
          i32.load
          call $j947
          local.get $p1
          i32.const 4003052 ;; Method$System.Collections.Generic.List<ObjectUnit>.Remove()
          i32.load
          call $j1387
          drop
          local.get $p0
          local.get $p2
          local.get $p2
          call $j22239 ;; LevelManager$$PlayStoreAnim
          br $B2
        end
        local.get $p2
        i32.const 1
        i32.add
        local.set $p2
        br $L1
      end
    end
    local.get $p0
    local.get $p2
    call $j22245 ;; LevelManager$$GetStoreCount
    i32.eqz
    if $I4
      local.get $p0
      i32.const 0
      i32.const 1
      local.get $p2
      call $j10877 ;; LevelManager$$SetStoreContentPos
    end)

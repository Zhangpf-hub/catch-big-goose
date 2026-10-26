  (func $j43525 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140127
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
      call $j922
      i32.const 3997932 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Count()
      call $j922
      i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
      call $j922
      i32.const 5140127
      i32.const 1
      i32.store8
    end
    i32.const 0
    local.set $p1
    loop $L1
      i32.const 3997932 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Count()
      i32.load
      drop
      local.get $p1
      local.get $p0
      i32.load offset=624
      i32.load offset=12
      i32.lt_s
      if $I2
        local.get $p0
        i32.load offset=624
        local.get $p1
        i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
        i32.load
        call $j947
        i32.const 4003036 ;; Method$System.Collections.Generic.List<ObjectUnit>.Clear()
        i32.load
        call $j1025 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Clear
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L1
      end
    end
    local.get $p0
    i32.const 0
    i32.const 0
    local.get $p1
    call $j10877) ;; LevelManager$$SetStoreContentPos

  (func $j10884 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    i32.const 5140120
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3994408 ;; Method$System.Collections.Generic.HashSet<string>.Contains()
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 5140120
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      i32.eqz
      if $I2
        i32.const 0
        local.set $p1
        i32.const 0
        local.set $p2
        br $B1
      end
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      local.get $p0
      i32.load offset=148
      i32.load offset=12
      return
    end
    loop $L3
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      local.get $p1
      local.get $p0
      i32.load offset=148
      i32.load offset=12
      i32.lt_s
      if $I4
        local.get $p2
        local.get $p2
        i32.const 1
        i32.add
        local.get $p0
        i32.load offset=380
        i32.load offset=16
        local.get $p0
        i32.load offset=148
        local.get $p1
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.load offset=12
        i32.const 3994408 ;; Method$System.Collections.Generic.HashSet<string>.Contains()
        i32.load
        call $j1657
        select
        local.set $p2
        local.get $p1
        i32.const 1
        i32.add
        local.set $p1
        br $L3
      end
    end
    local.get $p2
    return)

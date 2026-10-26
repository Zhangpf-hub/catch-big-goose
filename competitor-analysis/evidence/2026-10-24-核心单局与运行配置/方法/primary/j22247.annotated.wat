  (func $j22247 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5140168
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 5140168
      i32.const 1
      i32.store8
    end
    i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
    i32.load
    drop
    block $B1
      local.get $p0
      i32.load offset=148
      i32.load offset=12
      i32.const 1
      i32.lt_s
      br_if $B1
      i32.const 0
      local.set $p1
      loop $L2
        i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
        i32.load
        drop
        local.get $p1
        local.get $p0
        i32.load offset=152
        i32.load offset=12
        i32.ge_s
        br_if $B1
        local.get $p0
        i32.load offset=152
        local.get $p1
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j1139 ;; UnityEngine.Object$$get_name
        local.get $p0
        i32.load offset=148
        i32.const 0
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j1139 ;; UnityEngine.Object$$get_name
        i32.const 0
        call $j949 ;; System.String$$op_Equality
        if $I3
          local.get $p0
          i32.load offset=152
          local.get $p1
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.const 0
          call $j979 ;; UnityEngine.Component$$get_transform
          return
        else
          local.get $p1
          i32.const 1
          i32.add
          local.set $p1
          br $L2
        end
        unreachable
      end
      unreachable
    end
    i32.const 0
    return)

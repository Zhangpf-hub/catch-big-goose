  (func $j43541 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i32) (local $l4 i32) (local $l5 i32)
    i32.const 5140148
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
      call $j922
      i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
      call $j922
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      call $j922
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      call $j922
      i32.const 5140148
      i32.const 1
      i32.store8
    end
    i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
    i32.load
    call $j924
    local.set $l3
    local.get $l3
    i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
    i32.load
    call $j965
    i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
    i32.load
    drop
    local.get $p0
    i32.load offset=152
    i32.load offset=12
    local.set $p2
    loop $L1
      local.get $p2
      i32.const 1
      i32.sub
      local.set $p2
      local.get $p2
      i32.const -1
      i32.gt_s
      if $I2
        local.get $p0
        i32.load offset=152
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.load8_u offset=16
        i32.eqz
        br_if $L1
        local.get $p1
        i32.eqz
        if $I3
          local.get $p0
          i32.load offset=152
          local.get $p2
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          local.set $l4
          i32.const 0
          local.set $l5
          block $B4
            local.get $l4
            i32.load8_u offset=16
            i32.eqz
            br_if $B4
            local.get $l4
            i32.load8_u offset=17
            br_if $B4
            local.get $l4
            i32.load8_u offset=92
            i32.const 0
            i32.ne
            local.set $l5
          end
          local.get $l5
          i32.eqz
          br_if $L1
          local.get $p0
          i32.load offset=152
          local.get $p2
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          i32.load8_u offset=19
          br_if $L1
        end
        local.get $l3
        local.get $p0
        i32.load offset=152
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.load offset=12
        i32.const 4004900 ;; Method$System.Collections.Generic.List<string>.Contains()
        i32.load
        call $j1262
        br_if $L1
        local.get $l3
        local.get $p0
        i32.load offset=152
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.load offset=12
        i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
        i32.load
        call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
        br $L1
      end
    end
    local.get $l3
    return)

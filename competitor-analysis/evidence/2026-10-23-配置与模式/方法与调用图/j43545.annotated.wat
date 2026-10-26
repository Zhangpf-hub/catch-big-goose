  (func $j43545 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l3
    local.get $l3
    global.set $primary.global$0
    i32.const 5140158
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      call $j922
      i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
      call $j922
      i32.const 5140158
      i32.const 1
      i32.store8
    end
    i32.const 0
    local.set $p2
    loop $L1
      i32.const 4003060 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Count()
      i32.load
      drop
      local.get $p2
      local.get $p0
      i32.load offset=152
      i32.load offset=12
      i32.lt_s
      if $I2
        local.get $p0
        i32.load offset=152
        local.get $p2
        i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
        i32.load
        call $j947
        i32.const 0
        call $j21513 ;; ObjectUnit$$CanShake
        if $I3
          local.get $p0
          i32.load offset=152
          local.get $p2
          i32.const 4003064 ;; Method$System.Collections.Generic.List<ObjectUnit>.get_Item()
          i32.load
          call $j947
          local.set $l4
          local.get $l3
          local.get $p1
          i32.load offset=8
          i32.store offset=8
          local.get $l3
          local.get $p1
          i32.load
          i64.extend_i32_u
          local.get $p1
          i32.load offset=4
          i64.extend_i32_u
          i64.const 32
          i64.shl
          i64.or
          i64.store
          local.get $l4
          local.get $l3
          i32.const 0
          call $j14312 ;; ObjectUnit$$AddForce
        end
        local.get $p2
        i32.const 1
        i32.add
        local.set $p2
        br $L1
      end
    end
    local.get $l3
    i32.const 16
    i32.add
    global.set $primary.global$0)

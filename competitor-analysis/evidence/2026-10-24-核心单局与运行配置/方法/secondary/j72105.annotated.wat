  (func $j72105 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i64)
    global.get $primary.global$0
    i32.const 32
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5139829
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4015480 ;; Method$System.ValueTuple<string, string>..ctor()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4073472 ;; BuildJsonFail
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4123964 ;; 构建类失败
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139829
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      if $I2
        local.get $p0
        i32.load offset=8
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B1
        local.get $p0
        i32.load offset=32
        local.get $p0
        i32.load offset=20
        local.get $p0
        i32.load offset=12
        call_indirect $primary.table (type $t3)
        br $B1
      end
      local.get $p0
      i32.load offset=12
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $p2
      i64.const 0
      i64.store offset=24
      local.get $p2
      i32.const 24
      i32.add
      i32.const 4073472 ;; BuildJsonFail
      i32.load
      i32.const 4123964 ;; 构建类失败
      i32.load
      i32.const 4015480 ;; Method$System.ValueTuple<string, string>..ctor()
      i32.load
      i32.const 9406
      call_indirect $primary.table (type $t6)
      local.get $p2
      i64.load offset=24
      local.set $l3
      local.get $p2
      local.get $l3
      i64.store offset=16
      local.get $p2
      local.get $l3
      i64.store offset=8
      local.get $p0
      i32.load offset=32
      local.get $p2
      i32.const 8
      i32.add
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      call_indirect $primary.table (type $t4)
    end
    local.get $p2
    i32.const 32
    i32.add
    global.set $primary.global$0)

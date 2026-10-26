  (func $j72106 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i64)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5139830
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4070008 ;; 18009
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139830
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.load offset=16
      br_if $B1
      local.get $p1
      i32.load
      i32.const 4070008 ;; 18009
      i32.load
      i32.const 0
      i32.const 1023
      call_indirect $primary.table (type $t5)
      i32.eqz
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.const 735
      call_indirect $primary.table (type $t0)
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=64
      i32.const 0
      i32.store offset=32
    end
    local.get $p0
    i32.load offset=12
    local.set $p0
    local.get $p0
    if $I2
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
      local.get $p2
      local.get $l3
      i64.store
      local.get $p2
      local.get $l3
      i64.store offset=8
      local.get $p0
      i32.load offset=32
      local.get $p2
      local.get $p0
      i32.load offset=20
      local.get $p0
      i32.load offset=12
      call_indirect $primary.table (type $t4)
    end
    local.get $p2
    i32.const 16
    i32.add
    global.set $primary.global$0)

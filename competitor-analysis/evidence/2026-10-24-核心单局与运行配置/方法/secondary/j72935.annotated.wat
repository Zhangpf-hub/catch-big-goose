  (func $j72935 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l4
    local.get $l4
    global.set $primary.global$0
    i32.const 5140493
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957596 ;; int_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3950496 ;; object[]_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4121412 ;; 图书馆加分失败{0} {1} {2}({3})
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140493
      i32.const 1
      i32.store8
    end
    i32.const 3959304 ;; NetInitManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    block $B1
      i32.const 0
      i32.const 7446
      call_indirect $primary.table (type $t1)
      i32.eqz
      if $I2
        local.get $p1
        i32.load
        local.set $p1
        br $B1
      end
      i32.const 3950496 ;; object[]_TypeInfo
      i32.load
      i32.const 4
      i32.const 3013
      call_indirect $primary.table (type $t2)
      local.set $p2
      local.get $p0
      i32.load offset=8
      local.set $l3
      local.get $p2
      local.get $l3
      i32.const 1070
      call_indirect $primary.table (type $t3)
      local.get $p2
      local.get $l3
      i32.store offset=16
      local.get $p0
      i32.load offset=12
      local.set $l3
      local.get $p2
      local.get $l3
      i32.const 1070
      call_indirect $primary.table (type $t3)
      local.get $p2
      local.get $l3
      i32.store offset=20
      local.get $l4
      local.get $p0
      i32.load offset=16
      i32.store offset=12
      i32.const 3957596 ;; int_TypeInfo
      i32.load
      local.get $l4
      i32.const 12
      i32.add
      i32.const 1282
      call_indirect $primary.table (type $t2)
      local.set $l3
      local.get $p2
      local.get $l3
      i32.const 1070
      call_indirect $primary.table (type $t3)
      local.get $p2
      local.get $l3
      i32.store offset=24
      local.get $p1
      i32.load
      local.set $p1
      local.get $p2
      local.get $p1
      i32.const 1070
      call_indirect $primary.table (type $t3)
      local.get $p2
      local.get $p1
      i32.store offset=28
      i32.const 1
      i32.const 4121412 ;; 图书馆加分失败{0} {1} {2}({3})
      i32.load
      local.get $p2
      i32.const 0
      i32.const 81956
      call_indirect $primary.table (type $t5)
      i32.const 0
      i32.const 5839
      call_indirect $primary.table (type $t4)
    end
    i32.const 0
    local.get $p0
    i32.load offset=16
    local.get $p0
    i32.load offset=8
    local.get $p0
    i32.load offset=12
    local.get $p1
    i32.const 0
    i32.const 16576
    call_indirect $primary.table (type $t11)
    local.get $l4
    i32.const 16
    i32.add
    global.set $primary.global$0)

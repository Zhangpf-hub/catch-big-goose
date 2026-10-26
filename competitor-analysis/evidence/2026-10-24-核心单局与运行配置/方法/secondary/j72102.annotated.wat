  (func $j72102 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    i32.const 5140487
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140487
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p1
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=64
        local.get $p2
        i32.store offset=16
        local.get $p0
        i32.load offset=8
        local.set $p0
        local.get $p0
        i32.eqz
        br_if $B1
        local.get $p0
        i32.const 1
        i32.const 0
        i32.const 5294
        call_indirect $primary.table (type $t4)
        return
      end
      local.get $p0
      i32.load offset=8
      local.set $p0
      local.get $p0
      i32.eqz
      br_if $B1
      local.get $p0
      i32.const 0
      i32.const 0
      i32.const 5294
      call_indirect $primary.table (type $t4)
    end)

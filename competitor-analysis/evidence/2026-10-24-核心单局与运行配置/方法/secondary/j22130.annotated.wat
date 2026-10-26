  (func $j22130 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5139997
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958052 ;; LevelManager_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139997
      i32.const 1
      i32.store8
    end
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p0
    i32.load offset=8
    local.set $p1
    i32.const 3958052 ;; LevelManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=28
    i32.const 1
    i32.eq
    if $I1
      local.get $p1
      i32.const 1
      i32.const 1
      i32.const 100
      i32.const 0
      local.get $p0
      i32.const 17867
      call_indirect $primary.table (type $t11)
      i32.const 3
      i32.const 0
      i32.const 17121
      call_indirect $primary.table (type $t3)
      local.get $p0
      i32.load offset=8
      i32.const 2
      i32.const 0
      i32.const 0
      i32.const 0
      local.get $p0
      i32.const 17819
      call_indirect $primary.table (type $t11)
      return
    end
    local.get $p1
    i32.const 1
    i32.const 2
    i32.const 100
    i32.const 0
    local.get $p0
    i32.const 17867
    call_indirect $primary.table (type $t11)
    i32.const 0
    i32.const 17124
    call_indirect $primary.table (type $t0))

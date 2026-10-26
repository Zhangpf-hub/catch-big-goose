  (func $j72682 (type $t4) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5139977
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139977
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=8
    local.set $p0
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    local.get $p1
    local.get $p0
    local.get $p0
    call $j46543) ;; EndlessLevelMa$$LoadCompelet

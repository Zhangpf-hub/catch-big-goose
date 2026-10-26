  (func $j101297 (type $t1) (param $p0 i32) (result i32)
    i32.const 5139958
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3954604 ;; EndlessLevelMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139958
      i32.const 1
      i32.store8
    end
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    i32.const 3954604 ;; EndlessLevelMa_TypeInfo
    i32.load
    i32.load offset=92
    i32.load
    return)

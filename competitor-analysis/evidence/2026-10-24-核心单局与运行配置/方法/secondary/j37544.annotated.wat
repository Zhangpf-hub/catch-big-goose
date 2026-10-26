  (func $j37544 (type $t1) (param $p0 i32) (result i32)
    i32.const 5139667
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5139667
      i32.const 1
      i32.store8
    end
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    i32.const 735
    call_indirect $primary.table (type $t0)
    block $B1
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=73
      if $I2
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.const 735
        call_indirect $primary.table (type $t0)
        i32.const 1
        local.set $p0
        i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
        i32.load
        i32.load offset=92
        f32.load offset=76
        f32.const 0x1.99999ap-3 (;=0.2;)
        f32.gt
        br_if $B1
      end
      i32.const 0
      local.set $p0
    end
    local.get $p0
    return)

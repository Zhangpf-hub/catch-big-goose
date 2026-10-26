  (func $j80610 (type $t3) (param $p0 i32) (param $p1 i32)
    i32.const 5140302
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4068428 ;; /
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140302
      i32.const 1
      i32.store8
    end)

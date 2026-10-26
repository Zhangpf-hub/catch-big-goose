  (func $j94041 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5140003
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
      call $j922
      i32.const 5140003
      i32.const 1
      i32.store8
    end
    i32.const 3962324 ;; SpModeLongTableMa_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j8518 ;; SpModeLongTableMa$$IsCurModeLevel
    i32.const 1
    i32.xor
    return)

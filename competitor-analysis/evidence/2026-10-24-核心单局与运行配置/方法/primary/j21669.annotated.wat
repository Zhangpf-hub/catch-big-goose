  (func $j21669 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139796
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3964096 ;; UIDebugPop_TypeInfo
      call $j922
      i32.const 5139796
      i32.const 1
      i32.store8
    end
    i32.const 3964096 ;; UIDebugPop_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u
    i32.eqz
    return)

  (func $j21659 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139747
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3961880 ;; ServerFileCreate_TypeInfo
      call $j922
      i32.const 5139747
      i32.const 1
      i32.store8
    end
    i32.const 3961880 ;; ServerFileCreate_TypeInfo
    i32.load
    call $j923
    i32.const 0
    call $j6273 ;; ServerFileCreate$$GetFreeLevelCount
    return)

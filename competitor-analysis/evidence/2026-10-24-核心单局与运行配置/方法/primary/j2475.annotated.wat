  (func $j2475 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    i32.const 5140273
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951300 ;; ABTestManager_TypeInfo
      call $j922
      i32.const 5140273
      i32.const 1
      i32.store8
    end
    i32.const 3951300 ;; ABTestManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j11647 ;; ABTestManager$$GetFeatureType
    local.get $p1
    i32.const 0
    call $j949 ;; System.String$$op_Equality
    return)

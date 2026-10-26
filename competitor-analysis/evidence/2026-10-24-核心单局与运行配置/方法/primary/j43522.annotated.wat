  (func $j43522 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140066
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957648 ;; IntegralWallHelper_TypeInfo
      call $j922
      i32.const 5140066
      i32.const 1
      i32.store8
    end
    i32.const 3957648 ;; IntegralWallHelper_TypeInfo
    i32.load
    call $j923
    i32.const 3957648 ;; IntegralWallHelper_TypeInfo
    i32.load
    i32.load offset=92
    i32.load8_u offset=20
    i32.eqz
    if $I1
      i32.const 5142659
      i32.load8_u
      i32.eqz
      if $I2
        i32.const 3955472 ;; GameManager_TypeInfo
        call $j922
        i32.const 5142659
        i32.const 1
        i32.store8
      end
      i32.const 3955472 ;; GameManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=16
      if $I3
        i32.const 3
        i32.const 10
        i32.const 0
        call $j1479 ;; UnityEngine.Random$$Range
        local.set $p0
        i32.const 0
        call $j7540 ;; DelayRequestManager$$get_Instance
        i32.const 3
        i32.const 1
        local.get $p0
        f32.convert_i32_s
        i32.const 0
        i32.const 0
        call $j7541 ;; DelayRequestManager$$DelayRequest
        return
      end
      i32.const 3957648 ;; IntegralWallHelper_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j22441 ;; IntegralWallHelper$$GetToken
    end)

  (func $j14620 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32) (local $l4 i32)
    i32.const 5140153
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939116 ;; System.Action<GeneralCallbackResult>_TypeInfo
      call $j922
      i32.const 3994792 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.get_complete()
      call $j922
      i32.const 3994796 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.get_fail()
      call $j922
      i32.const 3994804 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.set_complete()
      call $j922
      i32.const 3994808 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.set_fail()
      call $j922
      i32.const 4029156 ;; Method$LevelManager.CompeletAcc()
      call $j922
      i32.const 3962464 ;; WeChatWASM.StartAccelerometerOption_TypeInfo
      call $j922
      i32.const 4054868 ;; Method$LevelManager.<>c.<InitShake>b__305_0()
      call $j922
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      call $j922
      i32.const 4116668 ;; ui
      call $j922
      i32.const 5140153
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load8_u offset=376
    i32.const 1
    i32.xor
    local.get $p1
    i32.or
    if $I1
      i32.const 3962464 ;; WeChatWASM.StartAccelerometerOption_TypeInfo
      i32.load
      call $j924
      local.set $p1
      local.get $p1
      i32.const 0
      call $j19894 ;; WeChatWASM.StartAccelerometerOption$$.ctor
      local.get $p1
      i32.const 4116668 ;; ui
      i32.load
      i32.store offset=20
      i32.const 3994792 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.get_complete()
      i32.load
      drop
      local.get $p1
      i32.load offset=16
      local.set $p2
      i32.const 3939116 ;; System.Action<GeneralCallbackResult>_TypeInfo
      i32.load
      call $j924
      local.set $l3
      local.get $l3
      local.get $p0
      i32.const 4029156 ;; Method$LevelManager.CompeletAcc()
      i32.load
      i32.const 0
      call $j969
      local.get $p2
      local.get $l3
      i32.const 0
      call $j1045 ;; System.Delegate$$Combine
      i32.const 3939116 ;; System.Action<GeneralCallbackResult>_TypeInfo
      i32.load
      call $j966
      local.set $p2
      i32.const 3994804 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.set_complete()
      i32.load
      drop
      local.get $p1
      local.get $p2
      i32.store offset=16
      i32.const 3994796 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.get_fail()
      i32.load
      drop
      local.get $p1
      i32.load offset=12
      local.set $l3
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      call $j923
      i32.const 3969160 ;; LevelManager.<>c_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=36
      local.set $p2
      local.get $p2
      i32.eqz
      if $I2
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        call $j923
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        i32.load
        local.set $l4
        i32.const 3939116 ;; System.Action<GeneralCallbackResult>_TypeInfo
        i32.load
        call $j924
        local.set $p2
        local.get $p2
        local.get $l4
        i32.const 4054868 ;; Method$LevelManager.<>c.<InitShake>b__305_0()
        i32.load
        i32.const 0
        call $j969
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        local.get $p2
        i32.store offset=36
        i32.const 3969160 ;; LevelManager.<>c_TypeInfo
        i32.load
        i32.load offset=92
        drop
      end
      local.get $l3
      local.get $p2
      i32.const 0
      call $j1045 ;; System.Delegate$$Combine
      i32.const 3939116 ;; System.Action<GeneralCallbackResult>_TypeInfo
      i32.load
      call $j966
      local.set $p2
      i32.const 3994808 ;; Method$WeChatWASM.ICallback<GeneralCallbackResult, GeneralCallbackResult, GeneralCallbackResult>.set_fail()
      i32.load
      drop
      local.get $p1
      local.get $p2
      i32.store offset=12
      local.get $p1
      i32.const 0
      call $j18141 ;; WeChatWASM.WX$$StartAccelerometer
      local.get $p0
      i32.const 1
      i32.store8 offset=376
    end)

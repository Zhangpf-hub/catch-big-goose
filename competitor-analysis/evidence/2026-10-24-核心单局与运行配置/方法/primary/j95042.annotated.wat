  (func $j95042 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140154
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3939272 ;; System.Action<OnAccelerometerChangeListenerResult>_TypeInfo
      call $j922
      i32.const 4029180 ;; Method$LevelManager.ShakePhone()
      call $j922
      i32.const 5140154
      i32.const 1
      i32.store8
    end
    i32.const 3939272 ;; System.Action<OnAccelerometerChangeListenerResult>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    local.get $p0
    i32.const 4029180 ;; Method$LevelManager.ShakePhone()
    i32.load
    i32.const 0
    call $j969
    local.get $p1
    i32.const 0
    call $j18144) ;; WeChatWASM.WX$$OnAccelerometerChange

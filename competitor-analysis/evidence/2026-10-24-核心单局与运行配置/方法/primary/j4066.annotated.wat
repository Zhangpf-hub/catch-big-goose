  (func $j4066 (type $t3) (param $p0 i32) (result i32)
    i32.const 0
    local.set $p0
    i32.const 5139761
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951356 ;; ActionManager_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3962304 ;; SpLevelManager_TypeInfo
      call $j922
      i32.const 4126712 ;; 重置关卡
      call $j922
      i32.const 5139761
      i32.const 1
      i32.store8
    end
    i32.const 3962304 ;; SpLevelManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 0
      call $j19973 ;; SpLevelManager$$IsInVideoLevel
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 0
      call $j21663 ;; NetDataManager$$IsNextDay
      i32.eqz
      br_if $B1
      i32.const 4126712 ;; 重置关卡
      i32.load
      i32.const 0
      i32.const 0
      call $j1221 ;; Kunpo.Debugger$$Log
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=84
      local.set $p0
      local.get $p0
      if $I2
        local.get $p0
        i32.load offset=32
        local.get $p0
        i32.load offset=20
        local.get $p0
        i32.load offset=12
        global.set $__wasm_split_waitTableId
        global.get $__wasm_split_waitTableId
        call_indirect $primary.table (type $t0)
      end
      i32.const 3951356 ;; ActionManager_TypeInfo
      i32.load
      call $j923
      i32.const 10
      i32.const 0
      i32.const 0
      call $j1940 ;; ActionManager$$TriggerEvent
      i32.const 1
      local.set $p0
    end
    local.get $p0
    return)

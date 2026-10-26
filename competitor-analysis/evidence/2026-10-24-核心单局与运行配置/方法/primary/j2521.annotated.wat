  (func $j2521 (type $t3) (param $p0 i32) (result i32)
    (local $l1 i32)
    i32.const 5139721
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139721
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=52
    local.set $l1
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.set $p0
    local.get $l1
    i32.const -1
    i32.le_s
    if $I1
      local.get $p0
      i32.load offset=48
      local.set $p0
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      i32.load
      call $j923
      local.get $p0
      i32.load offset=20
      return
    end
    local.get $p0
    i32.load offset=52
    return)

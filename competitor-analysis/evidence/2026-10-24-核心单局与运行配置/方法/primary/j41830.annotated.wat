  (func $j41830 (type $t4) (param $p0 i32)
    i32.const 5139738
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3960204 ;; PlayerNetPublicSaveData_TypeInfo
      call $j922
      i32.const 5139738
      i32.const 1
      i32.store8
    end
    i32.const 3960204 ;; PlayerNetPublicSaveData_TypeInfo
    i32.load
    call $j924
    local.set $p0
    local.get $p0
    i32.const 0
    call $j8747 ;; PlayerNetPublicSaveData$$.ctor
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=28
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    drop
    i32.const 1
    local.get $p0
    call $j21668) ;; NetDataManager$$CheckDefaultPlayerPublicData

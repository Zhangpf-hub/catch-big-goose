  (func $j72113 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5139824
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958488 ;; MainTableRankHelper_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 3959304 ;; NetInitManager_TypeInfo
      call $j922
      i32.const 4063796 ;; 
      call $j922
      i32.const 5139824
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load8_u offset=8
    if $I1
      local.get $p0
      i32.load8_u offset=9
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        call $j41834 ;; NetDataManager$$RefreshGlobalData
      end
      i32.const 3958488 ;; MainTableRankHelper_TypeInfo
      i32.load
      call $j923
      i32.const 0
      i32.const 4063796 ;; 
      i32.load
      i32.const 0
      call $j22081 ;; MainTableRankHelper$$RefreshGlobalSimpleData
    end
    block $B3
      local.get $p0
      i32.load8_u offset=9
      i32.eqz
      br_if $B3
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959304 ;; NetInitManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load
      i32.load8_u offset=161
      i32.eqz
      br_if $B3
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
    end
    local.get $p0
    i32.load offset=12
    local.set $p0
    local.get $p0
    if $I4
      local.get $p0
      i32.const 1
      i32.const 0
      call $j1184
    end)

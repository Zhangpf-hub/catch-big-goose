  (func $j21663 (type $t3) (param $p0 i32) (result i32)
    i32.const 5139762
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139762
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    block $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=92
      i32.eqz
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=92
      i32.load offset=16
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1527 ;; System.DateTime$$get_Year
      i32.ne
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=92
      i32.load offset=20
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1860 ;; System.DateTime$$get_Month
      i32.ne
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=32
      i32.load offset=92
      i32.load offset=24
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.const 16
      i32.add
      i32.const 0
      call $j1861 ;; System.DateTime$$get_Day
      i32.ne
      return
    end
    i32.const 1
    return)

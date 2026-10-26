  (func $j41834 (type $t4) (param $p0 i32)
    i32.const 5139766
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983300 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>.Clear()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139766
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=64
    i32.load offset=8
    i32.const 3983300 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>.Clear()
    i32.load
    call $j1200)

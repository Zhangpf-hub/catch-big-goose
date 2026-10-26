  (func $j41861 (type $t4) (param $p0 i32)
    (local $l1 i32)
    i32.const 5139768
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983292 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>..ctor()
      call $j922
      i32.const 3941644 ;; System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139768
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
    i32.eqz
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=64
      local.set $p0
      i32.const 3941644 ;; System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>_TypeInfo
      i32.load
      call $j924
      local.set $l1
      local.get $l1
      i32.const 3983292 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>..ctor()
      i32.load
      call $j967
      local.get $p0
      local.get $l1
      i32.store offset=8
    end)

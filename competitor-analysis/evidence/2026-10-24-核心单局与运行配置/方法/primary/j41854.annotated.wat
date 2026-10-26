  (func $j41854 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    (local $l3 i32)
    i32.const 5139772
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3983296 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>.Add()
      call $j922
      i32.const 3982660 ;; Method$System.Collections.Generic.Dictionary<string, Action<bool>>.Add()
      call $j922
      i32.const 3983304 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>.ContainsKey()
      call $j922
      i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
      call $j922
      i32.const 4003448 ;; Method$System.Collections.Generic.List<PlayerNetPublicSaveData>..ctor()
      call $j922
      i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
      call $j922
      i32.const 3947364 ;; System.Collections.Generic.List<PlayerNetPublicSaveData>_TypeInfo
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139772
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
      i32.load offset=64
      i32.load offset=8
      local.get $p0
      i32.const 3983304 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>.ContainsKey()
      i32.load
      call $j1040
      br_if $B1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=64
      i32.load offset=8
      local.set $p2
      i32.const 3947364 ;; System.Collections.Generic.List<PlayerNetPublicSaveData>_TypeInfo
      i32.load
      call $j924
      local.set $l3
      local.get $l3
      i32.const 4003448 ;; Method$System.Collections.Generic.List<PlayerNetPublicSaveData>..ctor()
      i32.load
      call $j965
      local.get $p2
      local.get $p0
      local.get $l3
      i32.const 3983296 ;; Method$System.Collections.Generic.Dictionary<string, List<PlayerNetPublicSaveData>>.Add()
      i32.load
      call $j953
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load8_u offset=80
      local.set $p2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      local.get $p2
      i32.eqz
      if $I2
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=84
        local.get $p0
        i32.const 4004888 ;; Method$System.Collections.Generic.List<string>.Add()
        i32.load
        call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=88
        local.get $p0
        local.get $p1
        i32.const 3982660 ;; Method$System.Collections.Generic.Dictionary<string, Action<bool>>.Add()
        i32.load
        call $j953
        i32.const 4004940 ;; Method$System.Collections.Generic.List<string>.get_Count()
        i32.load
        drop
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        i32.load offset=92
        i32.load offset=84
        i32.load offset=12
        i32.const 3
        i32.lt_s
        br_if $B1
        i32.const 3959288 ;; NetDataManager_TypeInfo
        i32.load
        call $j923
        local.get $p0
        call $j41851 ;; NetDataManager$$GetMultipleProvinceData
        return
      end
      local.get $p0
      local.get $p1
      local.get $p0
      call $j41849 ;; NetDataManager$$GetProvinceData
    end)

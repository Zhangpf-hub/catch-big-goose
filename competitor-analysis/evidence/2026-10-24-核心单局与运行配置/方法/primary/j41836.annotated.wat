  (func $j41836 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5139787
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3985876 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.ContainsKey()
      call $j922
      i32.const 3985880 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.Remove()
      call $j922
      i32.const 3994408 ;; Method$System.Collections.Generic.HashSet<string>.Contains()
      call $j922
      i32.const 3994412 ;; Method$System.Collections.Generic.HashSet<string>.Remove()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139787
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=44
    local.get $p0
    i32.const 3994408 ;; Method$System.Collections.Generic.HashSet<string>.Contains()
    i32.load
    call $j1657
    if $I1
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=44
      local.get $p0
      i32.const 3994412 ;; Method$System.Collections.Generic.HashSet<string>.Remove()
      i32.load
      call $j2126
      drop
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=40
    local.get $p0
    i32.const 3985876 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.ContainsKey()
    i32.load
    call $j1040
    if $I2
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      call $j923
      i32.const 3959288 ;; NetDataManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=40
      local.get $p0
      i32.const 3985880 ;; Method$System.Collections.Generic.Dictionary<string, Texture2D>.Remove()
      i32.load
      call $j1337
      drop
    end)

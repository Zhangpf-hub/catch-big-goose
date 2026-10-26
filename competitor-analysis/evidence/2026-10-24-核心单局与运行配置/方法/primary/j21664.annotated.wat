  (func $j21664 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 5139789
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
      call $j922
      i32.const 3959288 ;; NetDataManager_TypeInfo
      call $j922
      i32.const 5139789
      i32.const 1
      i32.store8
    end
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    call $j923
    local.get $p0
    local.get $p0
    call $j8813 ;; NetDataManager$$InitNewRes
    i32.const 3959288 ;; NetDataManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=32
    i32.load offset=28
    local.get $p0
    i32.const 3984756 ;; Method$System.Collections.Generic.Dictionary<string, int>.get_Item()
    i32.load
    call $j1033
    return)

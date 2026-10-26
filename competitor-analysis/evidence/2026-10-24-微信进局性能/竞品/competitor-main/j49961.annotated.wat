  (func $j49961 (type $t10) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (result i32)
    i32.const 5121034
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951804 ;; Kunpo.AssetManager_TypeInfo
      call $j922
      i32.const 3987084 ;; Method$System.Collections.Generic.Dictionary<Type, Func<string, bool, AssetRequest>>.get_Item()
      call $j922
      i32.const 5121034
      i32.const 1
      i32.store8
    end
    i32.const 3951804 ;; Kunpo.AssetManager_TypeInfo
    i32.load
    i32.load offset=92
    i32.load offset=24
    local.get $p1
    i32.const 3987084 ;; Method$System.Collections.Generic.Dictionary<Type, Func<string, bool, AssetRequest>>.get_Item()
    i32.load
    call $j1033
    local.get $p0
    local.get $p2
    call $j15021
    return)

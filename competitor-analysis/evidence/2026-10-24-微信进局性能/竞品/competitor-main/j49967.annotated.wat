  (func $j49967 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    i32.const 0
    local.set $p1
    i32.const 5121026
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3951804 ;; Kunpo.AssetManager_TypeInfo
      call $j922
      i32.const 4005936 ;; Method$System.Collections.Generic.List<Type>.get_Count()
      call $j922
      i32.const 4005940 ;; Method$System.Collections.Generic.List<Type>.get_Item()
      call $j922
      i32.const 5121026
      i32.const 1
      i32.store8
    end
    block $B1
      local.get $p0
      i32.const 0
      i32.lt_s
      br_if $B1
      i32.const 4005936 ;; Method$System.Collections.Generic.List<Type>.get_Count()
      i32.load
      drop
      local.get $p0
      i32.const 3951804 ;; Kunpo.AssetManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=20
      i32.load offset=12
      i32.ge_s
      br_if $B1
      i32.const 3951804 ;; Kunpo.AssetManager_TypeInfo
      i32.load
      i32.load offset=92
      i32.load offset=20
      local.get $p0
      i32.const 4005940 ;; Method$System.Collections.Generic.List<Type>.get_Item()
      i32.load
      call $j947
      local.set $p1
    end
    local.get $p1
    return)

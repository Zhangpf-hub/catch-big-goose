  (func $j22236 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140128
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
      call $j922
      i32.const 3997932 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Count()
      call $j922
      i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
      call $j922
      i32.const 5140128
      i32.const 1
      i32.store8
    end
    local.get $p0
    local.get $p0
    call $j22245 ;; LevelManager$$GetStoreCount
    i32.eqz
    if $I1
      local.get $p0
      i32.const 1
      i32.const 1
      local.get $p0
      call $j10877 ;; LevelManager$$SetStoreContentPos
    end
    local.get $p0
    i32.load offset=624
    local.get $p0
    i32.load offset=628
    i32.const 3997936 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Item()
    i32.load
    call $j947
    local.get $p1
    i32.const 4003032 ;; Method$System.Collections.Generic.List<ObjectUnit>.Add()
    i32.load
    call $j955 ;; System.Collections.Generic.List<__Il2CppFullySharedGenericType>$$Add
    local.get $p0
    local.get $p0
    i32.load offset=628
    local.get $p0
    call $j22239 ;; LevelManager$$PlayStoreAnim
    local.get $p0
    i32.load offset=628
    i32.const 1
    i32.add
    local.set $p2
    local.get $p0
    local.get $p2
    i32.store offset=628
    i32.const 3997932 ;; Method$System.Collections.Generic.List<List<ObjectUnit>>.get_Count()
    i32.load
    drop
    local.get $p0
    local.get $p2
    local.get $p0
    i32.load offset=624
    i32.load offset=12
    i32.rem_s
    i32.store offset=628
    local.get $p0
    local.get $p1
    i32.const 0
    call $j979 ;; UnityEngine.Component$$get_transform
    local.get $p0
    call $j43546) ;; LevelManager$$CreateThrowLight

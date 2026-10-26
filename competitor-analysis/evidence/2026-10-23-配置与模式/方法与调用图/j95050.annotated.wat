  (func $j95050 (type $t4) (param $p0 i32)
    i32.const 5140042
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3982120 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>..ctor()
      call $j922
      i32.const 3941396 ;; System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>_TypeInfo
      call $j922
      i32.const 3958048 ;; LevelLoaderManager_TypeInfo
      call $j922
      i32.const 5140042
      i32.const 1
      i32.store8
    end
    i32.const 3941396 ;; System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>_TypeInfo
    i32.load
    call $j924
    local.set $p0
    local.get $p0
    i32.const 3982120 ;; Method$System.Collections.Generic.Dictionary<LevelIndexAndType, LevelLoader>..ctor()
    i32.load
    call $j967
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store
    i32.const 3958048 ;; LevelLoaderManager_TypeInfo
    i32.load
    i32.load offset=92
    drop)

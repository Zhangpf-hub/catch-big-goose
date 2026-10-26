  (func $j95069 (type $t4) (param $p0 i32)
    i32.const 5140024
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3979496 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>..ctor()
      call $j922
      i32.const 3940812 ;; System.Collections.Generic.Dictionary<int, List<LevelDataData>>_TypeInfo
      call $j922
      i32.const 3958024 ;; LevelDataHelper_TypeInfo
      call $j922
      i32.const 5140024
      i32.const 1
      i32.store8
    end
    i32.const 3940812 ;; System.Collections.Generic.Dictionary<int, List<LevelDataData>>_TypeInfo
    i32.load
    call $j924
    local.set $p0
    local.get $p0
    i32.const 3979496 ;; Method$System.Collections.Generic.Dictionary<int, List<LevelDataData>>..ctor()
    i32.load
    call $j967
    i32.const 3958024 ;; LevelDataHelper_TypeInfo
    i32.load
    i32.load offset=92
    local.get $p0
    i32.store offset=8
    i32.const 3958024 ;; LevelDataHelper_TypeInfo
    i32.load
    i32.load offset=92
    drop)

  (func $j94996 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5127118
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3994392 ;; Method$System.Collections.Generic.HashSet<string>..ctor()
      call $j922
      i32.const 3945048 ;; System.Collections.Generic.HashSet<string>_TypeInfo
      call $j922
      i32.const 3995976 ;; Method$JObjectPoolGroup<ObjectUnit>..ctor()
      call $j922
      i32.const 3946064 ;; JObjectPoolGroup<ObjectUnit>_TypeInfo
      call $j922
      i32.const 4012144 ;; Method$JianEngine.SingleMono<LevelObjectPool>..ctor()
      call $j922
      i32.const 5127118
      i32.const 1
      i32.store8
    end
    i32.const 3946064 ;; JObjectPoolGroup<ObjectUnit>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3995976 ;; Method$JObjectPoolGroup<ObjectUnit>..ctor()
    i32.load
    call $j10912
    local.get $p0
    local.get $p1
    i32.store offset=12
    i32.const 3945048 ;; System.Collections.Generic.HashSet<string>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3994392 ;; Method$System.Collections.Generic.HashSet<string>..ctor()
    i32.load
    call $j1214
    local.get $p0
    local.get $p1
    i32.store offset=16
    local.get $p0
    i32.const 4012144 ;; Method$JianEngine.SingleMono<LevelObjectPool>..ctor()
    i32.load
    call $j3442)

  (func $j95008 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5140185
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955476 ;; UnityEngine.GameObject_TypeInfo
      call $j922
      i32.const 5140185
      i32.const 1
      i32.store8
    end
    local.get $p0
    local.set $p2
    local.get $p1
    i32.const 0
    call $j2065 ;; Kunpo.AssetRequest$$get_Result
    local.set $p0
    local.get $p2
    local.get $p0
    i32.const 3955476 ;; UnityEngine.GameObject_TypeInfo
    i32.load
    call $j968
    i32.store offset=704
    local.get $p0
    i32.const 3955476 ;; UnityEngine.GameObject_TypeInfo
    i32.load
    call $j968
    drop)

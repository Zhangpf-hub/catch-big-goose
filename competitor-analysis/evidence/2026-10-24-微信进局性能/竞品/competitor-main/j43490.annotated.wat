  (func $j43490 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    i32.const 5127110
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3995980 ;; Method$JObjectPoolGroup<ObjectUnit>.GetItem()
      call $j922
      i32.const 5127110
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=12
    local.get $p1
    i32.const 0
    i32.const 3995980 ;; Method$JObjectPoolGroup<ObjectUnit>.GetItem()
    i32.load
    call $j22384
    local.set $p0
    local.get $p0
    i32.const 0
    call $j961 ;; UnityEngine.Component$$get_gameObject
    local.get $p1
    i32.const 0
    call $j1663 ;; UnityEngine.Object$$set_name
    local.get $p0
    i32.const 0
    call $j961 ;; UnityEngine.Component$$get_gameObject
    i32.const 1
    i32.const 0
    call $j952 ;; UnityEngine.GameObject$$SetActive
    local.get $p0
    return)

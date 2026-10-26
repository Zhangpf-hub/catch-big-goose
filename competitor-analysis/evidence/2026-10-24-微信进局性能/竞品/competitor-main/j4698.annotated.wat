  (func $j4698 (type $t2) (param $p0 i32) (param $p1 i32) (param $p2 i32)
    i32.const 5127111
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3995988 ;; Method$JObjectPoolGroup<ObjectUnit>.RecycleItem()
      call $j922
      i32.const 5127111
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=12
    local.get $p1
    i32.const 0
    call $j961 ;; UnityEngine.Component$$get_gameObject
    i32.const 0
    call $j1139 ;; UnityEngine.Object$$get_name
    local.get $p1
    i32.const 3995988 ;; Method$JObjectPoolGroup<ObjectUnit>.RecycleItem()
    i32.load
    call $j7395)

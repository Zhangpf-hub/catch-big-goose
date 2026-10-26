  (func $j4082 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5140109
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4084980 ;; LoopCreateObj
      call $j922
      i32.const 5140109
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.const 4084980 ;; LoopCreateObj
    i32.load
    i32.const 0
    call $j1451) ;; UnityEngine.MonoBehaviour$$StopCoroutine

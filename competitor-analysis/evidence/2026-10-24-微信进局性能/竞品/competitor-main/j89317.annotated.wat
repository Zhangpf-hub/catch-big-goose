  (func $j89317 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5126975
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
      call $j922
      i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
      call $j922
      i32.const 5126975
      i32.const 1
      i32.store8
    end
    i32.const 3947688 ;; System.Collections.Generic.List<string>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 4004876 ;; Method$System.Collections.Generic.List<string>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $p1
    i32.store offset=12
    local.get $p0
    i32.const 0
    call $j1166) ;; UnityEngine.MonoBehaviour$$.ctor | UnityEngine.RectTransform$$.ctor

  (func $j94998 (type $t0) (param $p0 i32) (param $p1 i32)
    i32.const 5127101
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3980264 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>..ctor()
      call $j922
      i32.const 3940996 ;; System.Collections.Generic.Dictionary<int, Coroutine>_TypeInfo
      call $j922
      i32.const 4003028 ;; Method$System.Collections.Generic.List<ObjectUnit>..ctor()
      call $j922
      i32.const 4005744 ;; Method$System.Collections.Generic.List<Transform>..ctor()
      call $j922
      i32.const 3947832 ;; System.Collections.Generic.List<Transform>_TypeInfo
      call $j922
      i32.const 3947284 ;; System.Collections.Generic.List<ObjectUnit>_TypeInfo
      call $j922
      i32.const 5127101
      i32.const 1
      i32.store8
    end
    i32.const 3947832 ;; System.Collections.Generic.List<Transform>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 4005744 ;; Method$System.Collections.Generic.List<Transform>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $p1
    i32.store offset=36
    i32.const 3947832 ;; System.Collections.Generic.List<Transform>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 4005744 ;; Method$System.Collections.Generic.List<Transform>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $p1
    i32.store offset=40
    i32.const 3947284 ;; System.Collections.Generic.List<ObjectUnit>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 4003028 ;; Method$System.Collections.Generic.List<ObjectUnit>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $p1
    i32.store offset=44
    i32.const 3947284 ;; System.Collections.Generic.List<ObjectUnit>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 4003028 ;; Method$System.Collections.Generic.List<ObjectUnit>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $p1
    i32.store offset=48
    i32.const 3947284 ;; System.Collections.Generic.List<ObjectUnit>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 4003028 ;; Method$System.Collections.Generic.List<ObjectUnit>..ctor()
    i32.load
    call $j965
    local.get $p0
    local.get $p1
    i32.store offset=52
    i32.const 3940996 ;; System.Collections.Generic.Dictionary<int, Coroutine>_TypeInfo
    i32.load
    call $j924
    local.set $p1
    local.get $p1
    i32.const 3980264 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>..ctor()
    i32.load
    call $j967
    local.get $p0
    local.get $p1
    i32.store offset=60
    local.get $p0
    i32.const 0
    call $j1166) ;; UnityEngine.MonoBehaviour$$.ctor | UnityEngine.RectTransform$$.ctor

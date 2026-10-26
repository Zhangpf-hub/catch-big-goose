  (func $j43501 (type $t6) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32)
    i32.const 5127100
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3980268 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.Add()
      call $j922
      i32.const 3980272 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.ContainsKey()
      call $j922
      i32.const 3980276 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.Remove()
      call $j922
      i32.const 3980280 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.get_Item()
      call $j922
      i32.const 5127100
      i32.const 1
      i32.store8
    end
    local.get $p0
    i32.load offset=60
    local.get $p1
    i32.const 3980272 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.ContainsKey()
    i32.load
    call $j1084
    if $I1
      local.get $p0
      i32.load offset=60
      local.get $p1
      i32.const 3980280 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.get_Item()
      i32.load
      call $j1068
      if $I2
        local.get $p0
        local.get $p0
        i32.load offset=60
        local.get $p1
        i32.const 3980280 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.get_Item()
        i32.load
        call $j1068
        i32.const 0
        call $j1739 ;; UnityEngine.MonoBehaviour$$StopCoroutine
      end
      local.get $p0
      i32.load offset=60
      local.get $p1
      i32.const 3980276 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.Remove()
      i32.load
      call $j1859
      drop
    end
    local.get $p0
    i32.load offset=60
    local.get $p1
    local.get $p2
    i32.const 3980268 ;; Method$System.Collections.Generic.Dictionary<int, Coroutine>.Add()
    i32.load
    call $j1069)

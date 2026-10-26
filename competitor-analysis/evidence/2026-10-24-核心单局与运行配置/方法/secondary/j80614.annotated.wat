  (func $j80614 (type $t3) (param $p0 i32) (param $p1 i32)
    global.get $primary.global$0
    i32.const 48
    i32.sub
    local.set $p0
    local.get $p0
    global.set $primary.global$0
    i32.const 5140311
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3989156 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.Dispose()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3989160 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.MoveNext()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3989164 ;; Method$System.Collections.Generic.List.Enumerator<HotFixScriptable>.get_Current()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 3957796 ;; LitJson.JsonMapper_TypeInfo
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4000932 ;; Method$System.Collections.Generic.List<HotFixScriptable>.GetEnumerator()
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4068412 ;; .txt
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 4068428 ;; /
      i32.const 810
      call_indirect $primary.table (type $t0)
      i32.const 5140311
      i32.const 1
      i32.store8
    end
    local.get $p0
    i64.const 0
    i64.store offset=40
    local.get $p0
    i64.const 0
    i64.store offset=32
    local.get $p0
    i32.const 48
    i32.add
    global.set $primary.global$0)

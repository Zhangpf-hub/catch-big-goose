  (func $j38173 (type $t5) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result i32)
    (local $l3 i64) (local $l4 i32)
    global.get $primary.global$0
    i32.const 96
    i32.sub
    local.set $p2
    local.get $p2
    global.set $primary.global$0
    i32.const 5140312
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4018352 ;; Method$System.Runtime.CompilerServices.AsyncTaskMethodBuilder.Start<ServerFileCreate.<LoadHotFixScriptable>d__54>()
      call $j922
      i32.const 3951880 ;; System.Runtime.CompilerServices.AsyncTaskMethodBuilder_TypeInfo
      call $j922
      i32.const 5140312
      i32.const 1
      i32.store8
    end
    local.get $p2
    i32.const 40
    i32.add
    i32.const 0
    i32.const 52
    call $j942
    drop
    i32.const 3951880 ;; System.Runtime.CompilerServices.AsyncTaskMethodBuilder_TypeInfo
    i32.load
    call $j923
    local.get $p2
    i32.const 8
    i32.add
    i32.const 0
    call $j2252 ;; System.Runtime.CompilerServices.AsyncTaskMethodBuilder$$Create | System.Runtime.CompilerServices.AsyncTaskMethodBuilder<__Il2CppFullySharedGenericType>$$Create
    local.get $p2
    i32.load offset=16
    local.set $l4
    local.get $p2
    local.get $l4
    i32.store offset=32
    local.get $p2
    local.get $l4
    i32.store offset=52
    local.get $p2
    i64.load offset=8
    local.set $l3
    local.get $p2
    local.get $l3
    i64.store offset=24
    local.get $p2
    local.get $l3
    i32.wrap_i64
    i32.store offset=44
    local.get $p2
    local.get $l3
    i64.const 32
    i64.shr_u
    i32.wrap_i64
    i32.store offset=48
    local.get $p2
    local.get $p0
    i32.store offset=56
    local.get $p2
    local.get $p1
    i32.store offset=68
    local.get $p2
    i32.const -1
    i32.store offset=40
    local.get $p2
    i32.const 40
    i32.add
    i32.const 4
    i32.or
    local.set $p0
    local.get $p0
    local.get $p2
    i32.const 40
    i32.add
    i32.const 4018352 ;; Method$System.Runtime.CompilerServices.AsyncTaskMethodBuilder.Start<ServerFileCreate.<LoadHotFixScriptable>d__54>()
    i32.load
    call $j2424
    local.get $p0
    i32.const 0
    call $j2301 ;; System.Runtime.CompilerServices.AsyncTaskMethodBuilder$$get_Task
    local.set $p0
    local.get $p2
    i32.const 96
    i32.add
    global.set $primary.global$0
    local.get $p0
    return)

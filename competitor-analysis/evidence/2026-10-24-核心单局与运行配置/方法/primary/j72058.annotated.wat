  (func $j72058 (type $t0) (param $p0 i32) (param $p1 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $p1
    local.get $p1
    global.set $primary.global$0
    i32.const 5140488
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3957596 ;; int_TypeInfo
      call $j922
      i32.const 4123168 ;; 新鹅已上桌{0}
      call $j922
      i32.const 5140488
      i32.const 1
      i32.store8
    end
    local.get $p1
    local.get $p0
    i32.load offset=8
    i32.store offset=12
    i32.const 3957596 ;; int_TypeInfo
    i32.load
    local.get $p1
    i32.const 12
    i32.add
    call $j935
    local.set $p0
    i32.const 5
    i32.const 4123168 ;; 新鹅已上桌{0}
    i32.load
    local.get $p0
    i32.const 0
    call $j1006 ;; System.String$$Format
    i32.const 0
    call $j1429 ;; GameManager$$LogInColor
    local.get $p1
    i32.const 16
    i32.add
    global.set $primary.global$0)

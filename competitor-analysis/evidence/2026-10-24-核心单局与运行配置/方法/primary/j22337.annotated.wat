  (func $j22337 (type $t36) (param $p0 i32) (param $p1 f32) (param $p2 i32) (param $p3 i32)
    (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32) (local $l10 i32)
    global.get $primary.global$0
    i32.const 16
    i32.sub
    local.set $l5
    local.get $l5
    global.set $primary.global$0
    local.get $l5
    local.get $p2
    i32.store offset=12
    i32.const 5150175
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4004508 ;; Method$System.Collections.Generic.List<float>.Add()
      call $j922
      i32.const 5150175
      i32.const 1
      i32.store8
    end
    local.get $p3
    i32.load offset=16
    i32.load offset=96
    i32.const 2
    call $j926
    local.set $l4
    local.get $l4
    i32.load offset=20
    i32.const -1
    i32.le_s
    if $I1
      local.get $l4
      i32.load offset=128
      i32.const 8
      i32.sub
      local.set $l7
    else
      i32.const 4
      local.set $l7
    end
    local.get $l7
    i32.const 15
    i32.add
    i32.const -16
    i32.and
    local.set $l6
    local.get $l5
    local.get $l6
    i32.sub
    local.set $l4
    local.get $l4
    global.set $primary.global$0
    local.get $l4
    local.get $l6
    i32.sub
    local.set $l6
    local.get $l6
    global.set $primary.global$0
    local.get $p0
    i32.load offset=16
    local.set $l8
    local.get $l4
    local.get $p2
    local.get $l5
    i32.const 12
    i32.add
    local.get $p3
    i32.load offset=16
    i32.load offset=96
    i32.const 2
    call $j926
    i32.load offset=20
    i32.const 31
    i32.shr_u
    select
    local.get $l7
    call $j931
    drop
    local.get $p3
    i32.load offset=16
    i32.load offset=96
    i32.load offset=12
    i32.load
    local.set $l9
    local.get $p3
    i32.load offset=16
    i32.load offset=96
    i32.load offset=12
    local.set $l10
    local.get $p3
    i32.load offset=16
    i32.load offset=96
    i32.const 2
    call $j926
    i32.load offset=20
    i32.const 31
    i32.shr_u
    if $I2
      local.get $l4
      local.set $p2
    else
      local.get $l4
      i32.load
      local.set $p2
    end
    local.get $l9
    local.get $l10
    local.get $l8
    local.get $p2
    call $j1131
    i32.eqz
    if $I3
      local.get $p0
      i32.load offset=8
      local.set $l8
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.const 2
      call $j926
      i32.load offset=20
      i32.const 31
      i32.shr_u
      local.set $p2
      local.get $l4
      local.get $l5
      i32.load offset=12
      local.get $l5
      i32.const 12
      i32.add
      local.get $p2
      select
      local.get $l7
      call $j931
      drop
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.const 5
      call $j926
      call $j924
      local.set $p2
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=24
      i32.load
      local.set $l9
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=24
      local.set $l10
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.const 2
      call $j926
      i32.load offset=20
      i32.const 31
      i32.shr_u
      i32.eqz
      if $I4
        local.get $l4
        i32.load
        local.set $l4
      end
      local.get $l9
      local.get $l10
      local.get $p2
      local.get $p1
      local.get $l4
      call $j43938
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=28
      i32.load
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=28
      local.get $l8
      local.get $p2
      call $j977
      local.get $p0
      i32.load offset=12
      local.get $p1
      i32.const 4004508 ;; Method$System.Collections.Generic.List<float>.Add()
      i32.load
      call $j3189
      local.get $p0
      i32.load offset=16
      local.set $p2
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.const 2
      call $j926
      i32.load offset=20
      i32.const 31
      i32.shr_u
      local.set $l4
      local.get $l6
      local.get $l5
      i32.load offset=12
      local.get $l5
      i32.const 12
      i32.add
      local.get $l4
      select
      local.get $l7
      call $j931
      drop
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=32
      i32.load
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=32
      local.get $p0
      i32.load offset=8
      call $j954
      local.set $p0
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=36
      i32.load
      local.set $l4
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.load offset=36
      local.set $l8
      local.get $p3
      i32.load offset=16
      i32.load offset=96
      i32.const 2
      call $j926
      i32.load offset=20
      i32.const 31
      i32.shr_u
      i32.eqz
      if $I5
        local.get $l6
        i32.load
        local.set $l6
      end
      local.get $l4
      local.get $l8
      local.get $p2
      local.get $l6
      local.get $p0
      i32.const 1
      i32.sub
      call $j1175
    end
    local.get $l5
    i32.const 16
    i32.add
    global.set $primary.global$0)

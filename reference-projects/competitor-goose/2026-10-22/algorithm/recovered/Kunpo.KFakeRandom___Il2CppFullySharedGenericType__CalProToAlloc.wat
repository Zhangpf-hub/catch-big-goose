;; Kunpo.KFakeRandom<__Il2CppFullySharedGenericType>$$CalProToAlloc
;; Function-table index: 101435; signature checked. Compiled WASM, not C# source.
  (func $j95581 (type $t0) (param $p0 i32) (param $p1 i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 f32) (local $l7 f32)
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    i32.load
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    local.get $p0
    i32.load offset=8
    local.get $p0
    i32.load offset=32
    call $j1263
    local.set $l3
    local.get $l3
    local.set $l2
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $l4
    local.get $l2
    local.get $l4
    i32.load offset=72
    i32.add
    local.set $l2
    local.get $l2
    local.get $l2
    i32.const 8
    i32.sub
    local.get $l4
    i32.load offset=68
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    i32.load
    local.set $l4
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $l2
    local.get $l3
    local.get $l2
    i32.load offset=72
    i32.add
    local.set $l3
    local.get $l3
    local.get $l3
    i32.const 8
    i32.sub
    local.get $l2
    i32.load offset=68
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    local.get $l4
    i32.const 1
    i32.add
    i32.store
    local.get $l2
    i32.load offset=64
    drop
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    i32.load
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    local.get $p0
    i32.load offset=8
    local.get $p0
    i32.load offset=32
    call $j1263
    local.set $l3
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    i32.load
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    local.get $p0
    i32.load offset=8
    local.get $p0
    i32.load offset=32
    call $j1263
    local.set $l2
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $l4
    local.get $l2
    local.get $l4
    i32.load offset=72
    i32.add
    local.set $l2
    local.get $l2
    local.get $l2
    i32.const 8
    i32.sub
    local.get $l4
    i32.load offset=68
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    i32.load
    local.set $l4
    local.get $p0
    i32.load offset=20
    local.set $l5
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $l2
    local.get $l3
    local.get $l2
    i32.load offset=52
    i32.add
    local.set $l3
    local.get $l3
    local.get $l3
    i32.const 8
    i32.sub
    local.get $l2
    i32.load offset=48
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    local.get $l4
    f32.convert_i32_s
    local.get $l5
    f32.convert_i32_s
    f32.div
    f32.store
    local.get $l2
    i32.load offset=44
    drop
    local.get $p0
    i32.const 0
    i32.store offset=24
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    i32.load
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    local.get $p0
    i32.load offset=8
    local.get $p0
    i32.load offset=32
    call $j1263
    local.set $l2
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $l3
    local.get $l2
    local.get $l3
    i32.load offset=52
    i32.add
    local.set $l2
    local.get $l2
    local.get $l2
    i32.const 8
    i32.sub
    local.get $l3
    i32.load offset=48
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    f32.load
    local.set $l7
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    i32.load
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    local.get $p0
    i32.load offset=8
    local.get $p0
    i32.load offset=32
    call $j1263
    local.set $l2
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $l3
    local.get $l2
    local.get $l3
    i32.load offset=12
    i32.add
    local.set $l2
    local.get $l7
    local.get $l2
    local.get $l2
    i32.const 8
    i32.sub
    local.get $l3
    i32.load offset=8
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    f32.load
    f32.sub
    local.set $l6
    block $B0
      block $B1
        local.get $l6
        f32.const 0x0p+0 (;=0;)
        f32.gt
        if $I2
          local.get $p1
          i32.load offset=16
          i32.load offset=96
          i32.load offset=40
          i32.load
          local.get $p1
          i32.load offset=16
          i32.load offset=96
          i32.load offset=40
          local.get $p0
          i32.load offset=8
          local.get $p0
          i32.load offset=32
          call $j1263
          local.set $l2
          local.get $p1
          i32.load offset=16
          i32.load offset=96
          i32.const 5
          call $j926
          i32.load offset=64
          local.set $l3
          local.get $l2
          local.get $l3
          i32.load offset=32
          i32.add
          local.set $l2
          local.get $l2
          local.get $l2
          i32.const 8
          i32.sub
          local.get $l3
          i32.load offset=28
          i32.load offset=20
          i32.const -1
          i32.gt_s
          select
          f32.load
          local.get $l6
          f32.sub
          f32.const 0x0p+0 (;=0;)
          f32.ge
          br_if $B1
          local.get $p1
          i32.load offset=16
          i32.load offset=96
          i32.load offset=40
          i32.load
          local.get $p1
          i32.load offset=16
          i32.load offset=96
          i32.load offset=40
          local.get $p0
          i32.load offset=8
          local.get $p0
          i32.load offset=32
          call $j1263
          local.set $l2
          local.get $p1
          i32.load offset=16
          i32.load offset=96
          i32.const 5
          call $j926
          i32.load offset=64
          local.set $l3
          local.get $l2
          local.get $l3
          i32.load offset=32
          i32.add
          local.set $l2
          local.get $l2
          local.get $l2
          i32.const 8
          i32.sub
          local.get $l3
          i32.load offset=28
          i32.load offset=20
          i32.const -1
          i32.gt_s
          select
          f32.load
          local.set $l6
          br $B1
        end
        local.get $l6
        f32.const 0x0p+0 (;=0;)
        f32.lt
        i32.eqz
        br_if $B0
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.load offset=40
        i32.load
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.load offset=40
        local.get $p0
        i32.load offset=8
        local.get $p0
        i32.load offset=32
        call $j1263
        local.set $l2
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.const 5
        call $j926
        i32.load offset=64
        local.set $l3
        local.get $l2
        local.get $l3
        i32.load offset=32
        i32.add
        local.set $l2
        local.get $l2
        local.get $l2
        i32.const 8
        i32.sub
        local.get $l3
        i32.load offset=28
        i32.load offset=20
        i32.const -1
        i32.gt_s
        select
        f32.load
        local.get $l6
        f32.sub
        f32.const 0x1p+0 (;=1;)
        f32.le
        br_if $B1
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.load offset=40
        i32.load
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.load offset=40
        local.get $p0
        i32.load offset=8
        local.get $p0
        i32.load offset=32
        call $j1263
        local.set $l2
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.const 5
        call $j926
        i32.load offset=64
        local.set $l3
        local.get $l2
        local.get $l3
        i32.load offset=32
        i32.add
        local.set $l2
        local.get $l2
        local.get $l2
        i32.const 8
        i32.sub
        local.get $l3
        i32.load offset=28
        i32.load offset=20
        i32.const -1
        i32.gt_s
        select
        f32.load
        f32.const 0x1p+0 (;=1;)
        f32.sub
        local.set $l6
      end
      local.get $p0
      local.get $l6
      f32.store offset=24
    end
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    i32.load
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=40
    local.get $p0
    i32.load offset=8
    local.get $p0
    i32.load offset=32
    call $j1263
    local.set $l2
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $l4
    local.get $l2
    local.get $l4
    i32.load offset=32
    i32.add
    local.set $l3
    local.get $l3
    local.get $l3
    i32.const 8
    i32.sub
    local.get $l4
    i32.load offset=28
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    f32.load
    local.set $l6
    local.get $p0
    f32.load offset=24
    local.set $l7
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.const 5
    call $j926
    i32.load offset=64
    local.set $p0
    local.get $l2
    local.get $p0
    i32.load offset=32
    i32.add
    local.set $p1
    local.get $p1
    local.get $p1
    i32.const 8
    i32.sub
    local.get $p0
    i32.load offset=28
    i32.load offset=20
    i32.const -1
    i32.gt_s
    select
    local.get $l6
    local.get $l7
    f32.sub
    f32.store
    local.get $p0
    i32.load offset=24
    drop)

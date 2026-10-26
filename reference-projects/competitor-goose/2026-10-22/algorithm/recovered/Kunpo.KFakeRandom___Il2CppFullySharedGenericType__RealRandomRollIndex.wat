;; Kunpo.KFakeRandom<__Il2CppFullySharedGenericType>$$RealRandomRollIndex
;; Function-table index: 101440; signature checked. Compiled WASM, not C# source.
  (func $j95578 (type $t1) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 f32)
    i32.const 5150179
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 4004528
      call $j922
      i32.const 4004532
      call $j922
      i32.const 5150179
      i32.const 1
      i32.store8
    end
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=32
    i32.load
    local.get $p1
    i32.load offset=16
    i32.load offset=96
    i32.load offset=32
    local.get $p0
    i32.load offset=8
    call $j954
    i32.const 1
    i32.sub
    local.set $l2
    local.get $p0
    i32.const 0
    i32.store offset=28
    local.get $p0
    local.get $l2
    i32.store offset=32
    i32.const 0
    local.set $l2
    loop $L1
      block $B2
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.load offset=32
        i32.load
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.load offset=32
        local.get $p0
        i32.load offset=8
        call $j954
        local.set $l3
        local.get $p0
        f32.load offset=28
        local.set $l5
        local.get $l2
        local.get $l3
        i32.ge_s
        br_if $B2
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
        local.get $l2
        call $j1263
        local.set $l3
        local.get $p1
        i32.load offset=16
        i32.load offset=96
        i32.const 5
        call $j926
        i32.load offset=64
        local.set $l4
        local.get $l3
        local.get $l4
        i32.load offset=32
        i32.add
        local.set $l3
        local.get $l5
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
        f32.add
        local.set $l5
        local.get $p0
        local.get $l5
        f32.store offset=28
        local.get $p0
        i32.load offset=12
        local.get $l2
        local.get $l5
        i32.const 4004532
        i32.load
        call $j43257
        local.get $l2
        i32.const 1
        i32.add
        local.set $l2
        br $L1
      end
    end
    f32.const 0x0p+0 (;=0;)
    local.get $l5
    i32.const 0
    call $j1305
    local.set $l5
    local.get $p0
    local.get $p0
    i32.load offset=20
    i32.const 1
    i32.add
    i32.store offset=20
    i32.const 0
    local.set $l2
    loop $L3
      local.get $p1
      i32.load offset=16
      i32.load offset=96
      i32.load offset=32
      i32.load
      local.get $p1
      i32.load offset=16
      i32.load offset=96
      i32.load offset=32
      local.get $p0
      i32.load offset=8
      call $j954
      local.get $l2
      i32.gt_s
      if $I4
        local.get $p0
        i32.load offset=12
        local.get $l2
        i32.const 4004528
        i32.load
        call $j4080
        local.get $l5
        f32.gt
        if $I5
          local.get $p0
          local.get $l2
          i32.store offset=32
          local.get $l2
          return
        else
          local.get $l2
          i32.const 1
          i32.add
          local.set $l2
          br $L3
        end
        unreachable
      end
    end
    local.get $p0
    i32.load offset=32
    return)

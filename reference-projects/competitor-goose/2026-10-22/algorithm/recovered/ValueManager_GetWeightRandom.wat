;; ValueManager$$GetWeightRandom
;; Function-table index: 26412; signature checked. Compiled WASM, not C# source.
  (func $j18335 (type $t97) (param $p0 f32) (param $p1 f32) (param $p2 f32) (param $p3 f32) (param $p4 i32) (result f32)
    (local $l5 f32) (local $l6 f32)
    i32.const 5150501
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3958628
      call $j922
      i32.const 5150501
      i32.const 1
      i32.store8
    end
    local.get $p2
    f32.abs
    local.set $l5
    local.get $p3
    f32.abs
    local.set $l6
    local.get $l5
    local.get $l6
    local.get $l5
    local.get $l6
    f32.gt
    select
    f32.const 0x1.0c6f7ap-20 (;=1e-06;)
    f32.mul
    local.set $l5
    i32.const 3958628
    i32.load
    i32.load offset=92
    f32.load
    f32.const 0x1p+3 (;=8;)
    f32.mul
    local.set $l6
    local.get $p3
    local.get $p2
    f32.sub
    f32.abs
    local.get $l5
    local.get $l6
    local.get $l5
    local.get $l6
    f32.gt
    select
    f32.lt
    if $I1
      local.get $p0
      local.get $p1
      i32.const 0
      call $j1305
      return
    end
    local.get $p0
    local.set $l5
    local.get $p1
    local.get $p0
    f32.sub
    local.set $p1
    f32.const 0x0p+0 (;=0;)
    local.get $p2
    local.get $p3
    f32.add
    f32.const 0x1p+0 (;=1;)
    f32.mul
    f32.const 0x1p-1 (;=0.5;)
    f32.mul
    i32.const 0
    call $j1305
    local.set $p0
    local.get $p0
    local.get $p0
    f32.add
    local.get $p3
    local.get $p2
    f32.sub
    f32.div
    local.set $l6
    local.get $p2
    local.get $p2
    f32.add
    local.get $p3
    local.get $p2
    f32.sub
    f32.div
    local.set $p0
    local.get $l5
    local.get $p1
    local.get $l6
    local.get $p0
    f32.const 0x1p-2 (;=0.25;)
    f32.mul
    local.get $p0
    f32.mul
    f32.add
    f32.sqrt
    local.get $p0
    f32.const 0x1p-1 (;=0.5;)
    f32.mul
    f32.sub
    f32.mul
    f32.add
    return)

;; LevelManager$$GetDynamicVisibleHeight
;; Function-table index: 17841; signature checked. Compiled WASM, not C# source.
  (func $j22249 (type $t78) (param $p0 i32) (param $p1 i32) (param $p2 f32) (param $p3 i32) (result f32)
    (local $l4 f32) (local $l5 f32) (local $l6 f32) (local $l7 f32)
    local.get $p0
    f32.load offset=348
    local.set $l4
    local.get $p0
    i32.const 264
    i32.const 328
    local.get $p1
    i32.const 1
    i32.eq
    select
    i32.add
    f32.load
    local.set $l5
    local.get $l4
    local.get $l5
    f32.sub
    local.set $l6
    local.get $l5
    local.set $l7
    local.get $p0
    f32.load offset=340
    local.set $l5
    local.get $l6
    local.get $l4
    f32.div
    local.set $l4
    local.get $l7
    local.get $l5
    local.get $p0
    f32.load offset=344
    local.get $l5
    f32.sub
    f32.const 0x0p+0 (;=0;)
    local.get $l4
    f32.const 0x1p+0 (;=1;)
    f32.min
    local.get $l4
    f32.const 0x0p+0 (;=0;)
    f32.lt
    select
    f32.const 0x0p+0 (;=0;)
    f32.max
    f32.mul
    f32.add
    local.get $p2
    f32.const 0x1p+0 (;=1;)
    f32.min
    f32.mul
    f32.sub
    return)

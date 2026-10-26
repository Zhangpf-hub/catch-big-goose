;; LevelManager$$GetObjSize
;; Function-table index: 17835; signature checked. Compiled WASM, not C# source.
  (func $j43536 (type $t24) (param $p0 i32) (param $p1 i32) (param $p2 i32) (result f32)
    (local $l3 f32)
    i32.const 5140098
    i32.load8_u
    i32.eqz
    if $I0
      i32.const 3955276
      call $j922
      i32.const 3958052
      call $j922
      i32.const 3961680
      call $j922
      i32.const 3962304
      call $j922
      i32.const 4079720
      call $j922
      i32.const 5140098
      i32.const 1
      i32.store8
    end
    i32.const 3958052
    i32.load
    call $j923
    i32.const 3958052
    i32.load
    i32.load offset=92
    i32.load offset=12
    i32.const 9
    i32.eq
    if $I1
      i32.const 3961680
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      call $j38359
      return
    end
    i32.const 3958052
    i32.load
    call $j923
    f32.const 0x1p+0 (;=1;)
    local.set $l3
    block $B2
      i32.const 3958052
      i32.load
      i32.load offset=92
      i32.load offset=12
      i32.const 6
      i32.ne
      br_if $B2
      i32.const 3962304
      i32.load
      call $j923
      i32.const 3962304
      i32.load
      i32.load offset=92
      i32.load offset=4
      i32.const 4079720
      i32.load
      i32.const 0
      call $j949
      i32.eqz
      br_if $B2
      i32.const 3955276
      i32.load
      call $j923
      local.get $p1
      i32.const 0
      i32.const 24846
      global.set $__wasm_split_waitTableId
      i32.const 24846
      call_indirect $primary.table (type $t16)
      local.set $l3
    end
    local.get $l3
    return)
